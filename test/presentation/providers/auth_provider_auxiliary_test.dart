import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthNotifier extends AsyncNotifier<void> {
  FirebaseAuth auth;
  FirebaseFirestore db;

  AuthNotifier({
    FirebaseAuth? authInstance,
    FirebaseFirestore? firestoreInstance,
  })  : auth = authInstance ?? FirebaseAuth.instance,
        db = firestoreInstance ?? FirebaseFirestore.instance;

  @override
  FutureOr<void> build() => null;

  Future<bool?> login(String emailAddress, String password) async {
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      final uid = credential.user!.uid;
      return await isAdmin(uid);
    } on FirebaseAuthException catch (e) {
      return null;
    }
  }

  Future<bool> isAdmin(String uid) async {
    try {
      final doc = await db.collection("admin").doc(uid).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      await auth.signOut();
      return true;
    } catch (e) {
      return false;
    }
  }
}
