import 'package:nutrabit_admin/core/models/app_users.dart';
import 'package:nutrabit_admin/core/utils/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Provider auxiliar que permite inyectar instancias mockeadas de Firebase
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final usersProvider = FutureProvider<List<AppUser>>((ref) async {
  final firestore = ref.read(firebaseFirestoreProvider);
  final snapshot = await firestore.collection('users').get();
  final users = snapshot.docs.map((doc) => AppUser.fromFirestore(doc)).toList();
  users.sort((a, b) => normalize(a.name).compareTo(normalize(b.name)));
  return users;
});

Future<void> addUser(AppUser user, WidgetRef ref) async {
  final auth = ref.read(firebaseAuthProvider);
  final firestore = ref.read(firebaseFirestoreProvider);

  try {
    final password = generateRandomPassword();
    UserCredential userCredential = await auth.createUserWithEmailAndPassword(
      email: user.email,
      password: password,
    );
    final uid = userCredential.user!.uid;
    final newUser = user.copyWith(id: uid);
    await firestore.collection('users').doc(uid).set(newUser.toMap());
  } on FirebaseAuthException catch (e) {
    throw Exception('Error de autenticación: ${e.message}');
  } catch (e) {
    throw Exception('Error al agregar el usuario: $e');
  }
}

final searchUsersProvider = FutureProvider.family<List<AppUser>, String>((ref, query) async {
  if (query.isEmpty) return [];

  final firestore = ref.read(firebaseFirestoreProvider);
  final usersCollection = firestore.collection('users');

  final usersByName = await usersCollection.orderBy('name').startAt([query]).endAt([query + '\uf8ff']).get();
  final usersByLastName = await usersCollection.orderBy('lastname').startAt([query]).endAt([query + '\uf8ff']).get();
  final usersByEmail = await usersCollection.orderBy('email').startAt([query]).endAt([query + '\uf8ff']).get();

  final Map<String, QueryDocumentSnapshot> usersMap = {};
  for (var doc in usersByName.docs) {
    usersMap[doc.id] = doc;
  }
  for (var doc in usersByLastName.docs) {
    usersMap[doc.id] = doc;
  }
  for (var doc in usersByEmail.docs) {
    usersMap[doc.id] = doc;
  }

  final users = usersMap.values.map((doc) => AppUser.fromFirestore(doc)).toList();
  users.sort((a, b) => normalize(a.name).compareTo(normalize(b.name)));
  return users;
});