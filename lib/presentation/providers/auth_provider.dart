import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider = AsyncNotifierProvider<AuthNotifier, void>(
  () => AuthNotifier(),
);

class AuthNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  FirebaseFirestore db = FirebaseFirestore.instance;

  Future<bool?> login(String emailAddress, String password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailAddress.trim(),
        password: password.trim(),
      );

      String uid = credential.user!.uid;
      return await isAdmin(uid);
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: code=${e.code}, message=${e.message}');
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
      return null;
    }
  }

  Future<bool> isAdmin(String uid) async {
    try {
      final doc = await db.collection("admin").doc(uid).get();
      return doc.exists;
    } catch (e) {
      print("Error al verificar admin: $e");
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      return true;
    } catch (e) {
      print("Error al hacer logout: $e");
      return false;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    state = const AsyncLoading();
    try {
      if (await isAdminByEmail(email)) {
        // Caso admin válido
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
        state = const AsyncData(null);
      } else {
        // 🔥 Lanzamos un FirebaseAuthException
        throw FirebaseAuthException(
          code: 'not-admin',
          message: 'El email no está registrado como administrador.',
        );
      }
    } on FirebaseAuthException catch (e, st) {
      // 🔍 Aquí cae el 'not-admin' o cualquier otro FirebaseAuthException
      state = AsyncError(e, st);
    }
  }

  Future<bool> isAdminByEmail(String email) async {
    try {
      // 1️⃣ Consulta: busca en 'admin' donde el campo 'email' sea igual
      final snapshot =
          await db
              .collection('admin')
              .where('email', isEqualTo: email.trim())
              .limit(1) // sólo necesitamos saber si hay al menos uno
              .get();

      // 2️⃣ Devuelve true si encontramos al menos un doc
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      // En caso de error (p.ej. problemas de red), loguea y devuelve false
      print("Error al verificar admin por email: $e");
      return false;
    }
  }

  /// Cambia la contraseña del usuario autenticado después de reautenticarse
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String repeatPassword,
  }) async {
    state = const AsyncLoading();
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'no-user',
          message: 'No hay ningún usuario autenticado.',
        );
      } else if (newPassword.length < 6) {
        throw FirebaseAuthException(
          code: 'weak-password',
          message: 'La nueva contraseña debe tener minimo 6 caracteres.',
        );
      } else if (currentPassword == newPassword) {
        throw FirebaseAuthException(
          code: 'same-password',
          message: 'La nueva contraseña no puede ser igual a la actual.',
        );
      } else if (newPassword != repeatPassword) {
        throw FirebaseAuthException(
          code: 'password-mismatch',
          message: 'Las contraseñas no coinciden.',
        );
      } else {
        // Re-autenticación
        final cred = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword.trim(),
        );
        await user.reauthenticateWithCredential(cred);

        // Actualizar contraseña
        await user.updatePassword(newPassword.trim());
        state = const AsyncData(null);
        logout();
      }
    } on FirebaseAuthException catch (e, st) {
      // Aquí interceptamos los códigos y volvemos a emitir
      String message;
      switch (e.code) {
        case 'invalid-credential':
          message = 'La contraseña actual es incorrecta.';
          break;
        default:
          message = e.message ?? 'Error desconocido: ${e.code}';
      }
      state = AsyncError(
        FirebaseAuthException(code: e.code, message: message),
        st,
      );
    }
  }
}
