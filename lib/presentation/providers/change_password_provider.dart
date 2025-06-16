import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final changePasswordProvider =
    AsyncNotifierProvider<ChangePasswordNotifier, void>(
  ChangePasswordNotifier.new,
);

class ChangePasswordNotifier extends AsyncNotifier<void> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  FutureOr<void> build() {
    return null;
  }

  // Envía email de restablecimiento si el email pertenece a un admin.
  Future<void> sendPasswordResetEmail(String email) async {
    state = const AsyncLoading();
    try {
      if (await _isAdminByEmail(email)) {
        await _auth.sendPasswordResetEmail(email: email.trim());
        state = const AsyncData(null);
      } else {
        throw FirebaseAuthException(
          code: 'not-admin',
          message: 'El email no está registrado como administrador.',
        );
      }
    } on FirebaseAuthException catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // Cambia la contraseña del usuario.
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String repeatPassword,
  }) async {
    state = const AsyncLoading();
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'no-user',
        );
      } 
      if (newPassword.length < 6) {
        throw FirebaseAuthException(
          code: 'weak-password',
        );
      } 
       if (currentPassword == newPassword) {
        throw FirebaseAuthException(
          code: 'same-password',
        );
      } 
      if (newPassword != repeatPassword) {
        throw FirebaseAuthException(
          code: 'password-mismatch',
        );
      }

      // Re-autenticación
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword.trim(),
      );

      
      await user.reauthenticateWithCredential(cred);

      // Actualizar contraseña
      await user.updatePassword(newPassword.trim());
      state = const AsyncData(null);

    } on FirebaseAuthException catch (e, st) {
      String msg;
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          msg = 'La contraseña actual es incorrecta.';
          break;
        case 'user-not-found':
          msg = 'No se encontró ningún usuario con ese email.';
          break;
        case 'weak-password':
          msg = 'La nueva contraseña debe tener mínimo 6 caracteres.';
          break;
        case 'same-password':
          msg = 'La nueva contraseña no puede ser igual a la actual.';
          break;
        case 'password-mismatch':
          msg = 'Las contraseñas no coinciden.';
          break;
        case 'no-user':
          msg = 'No hay ningún usuario autenticado.';
          break;
        default:
          msg = e.message ?? 'Error de autenticación: ${e.code}';
      }
      state = AsyncError(
        FirebaseAuthException(code: e.code, message: msg),
        st,
      );
    } on FirebaseException catch (e, st) {
      final msg = e.message ?? 'Error de autenticación';
      state = AsyncError(
        FirebaseAuthException(code: 'firebase-error', message: msg),
        st,
      );
    } catch (e, st) {
      state = AsyncError(
        Exception('Error inesperado: $e'),
        st,
      );
    }
  }

  // Verifica si el email pertenece a un admin en Firestore.
  Future<bool> _isAdminByEmail(String email) async {
    try {
      final snapshot = await _db
          .collection('admin')
          .where('email', isEqualTo: email.trim())
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error al verificar admin por email: $e');
      return false;
    }
  }
}
