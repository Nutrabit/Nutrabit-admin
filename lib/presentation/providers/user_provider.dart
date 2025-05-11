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
  final firestore = FirebaseFirestore.instance;
  try {
    await firestore.collection('users').add(user.toMap());
  } catch (e) {
    throw Exception('Error al agregar el usuario: $e');
  }
}

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


