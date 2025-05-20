import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/app_users.dart';
import '../../core/utils/utils.dart';

final usersProvider = FutureProvider<List<AppUser>>((ref) async {
  final firestore = FirebaseFirestore.instance;
  QuerySnapshot snapshot = await firestore.collection('users').get();
  List<AppUser> users = snapshot.docs.map((doc) => AppUser.fromFirestore(doc)).toList();

  users.sort((a, b) => normalize(a.name).compareTo(normalize(b.name)));

  return users;
});

Future<void> addUser(AppUser user) async {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
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

final userProvider = StateNotifierProvider<UserNotifier, AsyncValue<void>>(
  (ref) => UserNotifier(),
);

class UserNotifier extends StateNotifier<AsyncValue<void>> {
  UserNotifier() : super(const AsyncData(null));

  Future<void> updateUserState(String id, bool newState) async {
    state = const AsyncLoading();
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .update({'isActive': newState});
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updatePatient({
    required String id,
    required String name,
    required String lastname,
    required String email,
    required int height,
    required int weight,
    required String gender,
    Timestamp? birthday,
    required String activity,
  }) async {
    state = const AsyncLoading();
    try {
      await FirebaseFirestore.instance.collection('users').doc(id).update({
        'name': name,
        'lastname': lastname,
        'email': email,
        'height': height,
        'weight': weight,
        'gender': gender,
        'birthday': birthday,
        'activity': activity,
        'modifiedAt': FieldValue.serverTimestamp(),
        'deletedAt': null,
      });
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final userStreamProvider = StreamProvider.family<DocumentSnapshot, String>((ref, id) {
  return FirebaseFirestore.instance.collection('users').doc(id).snapshots();
});

final searchUsersProvider = FutureProvider.family<List<AppUser>, String>(
  (ref, query) async {
    if (query.isEmpty) return []; 

    final firestore = FirebaseFirestore.instance;
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
  },
);
