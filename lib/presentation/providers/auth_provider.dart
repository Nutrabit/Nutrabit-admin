import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authProvider = AsyncNotifierProvider<AuthNotifier, bool>(
  () => AuthNotifier(),
);

class AuthNotifier extends AsyncNotifier<bool> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  
  @override
  FutureOr<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    final wasLoggedIn = prefs.getBool('isAdminLoggedIn') ?? false;
    if (!wasLoggedIn) {
      return false;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      await prefs.remove('isAdminLoggedIn');
      return false;
    }

    final doc = await db.collection('admin').doc(user.uid).get();
    if (!doc.exists) {
      await prefs.remove('isAdminLoggedIn');

      await FirebaseAuth.instance.signOut();
      return false;
    }

    return true;
  }

  Stream<bool> get stream async* {
    yield state.value ?? false;
  }

  // ignore: body_might_complete_normally_nullable
  Future<bool?> login(String emailAddress, String password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailAddress.trim(),
        password: password.trim(),
      );

      String uid = credential.user!.uid;
      bool isAdminLoggedIn = await isAdmin(uid);

      if (isAdminLoggedIn) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isAdminLoggedIn', true);

        state = const AsyncData(true);
        return isAdminLoggedIn;
      }
    } on FirebaseAuthException catch (e,st) {
      String msg;
      switch (e.code) {
        case 'user-not-found':
          msg = 'Usuario no encontrado';
          break;
        case 'invalid-email':
          msg = 'Email inválido';
          break;
        case 'invalid-credential':
        case 'missing-password':
          msg = 'Contraseña y/o email inválidos';
          break;
        default:
          msg = e.message ?? 'Error: ${e.code}';
      }
      print('FirebaseAuthException: code=${e.code}, message=${e.message}');
      state = AsyncError(FirebaseAuthException(code: e.code, message: msg), st);
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isAdminLoggedIn') ?? false;
  }

  Future<bool> isAdmin(String uid) async {
    try {
      final doc = await db.collection("admin").doc(uid).get();
      if (!doc.exists) {
        await FirebaseAuth.instance.signOut();
        return false;
      } else {
        return doc.exists;
      }
    } catch (e) {
      print("Error al verificar admin: $e");
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      await FirebaseAuth.instance.signOut();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isAdminLoggedIn');

      state = const AsyncData(false);
      return true;
    } catch (e) {
      print("Error al hacer logout: $e");
      return false;
    }
  }


}
