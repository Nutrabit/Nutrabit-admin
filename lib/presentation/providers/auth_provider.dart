import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/src/notifier.dart';

// NotifierProvider authProvider = NotifierProvider<AuthNotifier>(authProvider.new);
final authProvider = AsyncNotifierProvider<AuthNotifier, void>(
  () => AuthNotifier(),
);

class AuthNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // TODO: implement build
    throw UnimplementedError();
  }

  Future<UserCredential?> login(String emailAddress, String password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      print(credential);
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }
}
// Future<void> registerUser(emailAddress, password) async {
//   try {
//     final credential = await FirebaseAuth.instance
//         .createUserWithEmailAndPassword(
//           email: emailAddress,
//           password: password,
//         );
//   } on FirebaseAuthException catch (e) {
//     if (e.code == 'weak-password') {
//       print('The password provided is too weak.');
//     } else if (e.code == 'email-already-in-use') {
//       print('The account already exists for that email.');
//     }
//   } catch (e) {
//     print(e);
//   }
// }

// Future<void> loginUser(emailAddress, password, ref) async {
//   try {
//     final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
//       email: emailAddress,
//       password: password,
//     );
//   } on FirebaseAuthException catch (e) {
//     if (e.code == 'user-not-found') {
//       print('No user found for that email.');
//     } else if (e.code == 'wrong-password') {
//       print('Wrong password provided for that user.');
//     }
//   }
// }


// final loginAuthProvider = FutureProvider.family<void, (String email, String password)>((ref, credentials) async {
//   final email = credentials.$1;
//   final password = credentials.$2;

//   try {
//     final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
//       email: email,
//       password: password,
//     );
//     // Podés retornar el credential si querés
//   } on FirebaseAuthException catch (e) {
//     if (e.code == 'user-not-found') {
//       print('No user found for that email.');
//     } else if (e.code == 'wrong-password') {
//       print('Wrong password provided for that user.');
//     }
//   }
// });