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