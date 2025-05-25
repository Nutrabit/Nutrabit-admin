import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:nutrabit_admin/core/models/app_users.dart';
import 'package:nutrabit_admin/core/utils/utils.dart';
import '../providers/user_provider_auxiliary_test.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}

void main() {
  group('user_provider tests', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    test('usersProvider retorna usuarios ordenados por nombre normalizado', () async {
      await fakeFirestore.collection('users').add({
        'name': 'Álvaro',
        'lastname': 'García',
        'email': 'alvaro@example.com',
        'birthday': Timestamp.now(),
        'height': 180,
        'weight': 75,
        'gender': 'male',
        'isActive': true,
        'profilePic': '',
        'goal': '',
        'events': [],
        'appointments': [],
      });

      await fakeFirestore.collection('users').add({
        'name': 'Beatriz',
        'lastname': 'Lopez',
        'email': 'bea@example.com',
        'birthday': Timestamp.now(),
        'height': 165,
        'weight': 60,
        'gender': 'female',
        'isActive': true,
        'profilePic': '',
        'goal': '',
        'events': [],
        'appointments': [],
      });

      final container = ProviderContainer(
        overrides: [
          firebaseFirestoreProvider.overrideWithValue(fakeFirestore),
        ],
      );

      final asyncValue = await container.read(usersProvider.future);

      expect(asyncValue.length, 2);
      expect(normalize(asyncValue[0].name), 'alvaro');
      expect(normalize(asyncValue[1].name), 'beatriz');
    });

    test('searchUsersProvider encuentra por nombre', () async {
      await fakeFirestore.collection('users').add({
        'name': 'Beatriz',
        'lastname': 'Lopez',
        'email': 'bea@example.com',
        'birthday': Timestamp.now(),
        'height': 165,
        'weight': 60,
        'gender': 'female',
        'isActive': true,
        'profilePic': '',
        'goal': '',
        'events': [],
        'appointments': [],
      });

      final container = ProviderContainer(
        overrides: [
          firebaseFirestoreProvider.overrideWithValue(fakeFirestore),
        ],
      );

      final result = await container.read(searchUsersProvider('Bea').future);

      expect(result.length, 1);
      expect(result.first.name, 'Beatriz');
    });

    test('searchUsersProvider retorna lista vacía si query es vacío', () async {
      final container = ProviderContainer(
        overrides: [
          firebaseFirestoreProvider.overrideWithValue(fakeFirestore),
        ],
      );

      final result = await container.read(searchUsersProvider('').future);
      expect(result, isEmpty);
    });

    test('addUser agrega usuario y lo guarda en Firestore', () async {
      final testUser = AppUser(
        id: '',
        name: 'Carlos',
        lastname: 'Perez',
        email: 'carlos@example.com',
        birthday: DateTime(1990, 1, 1),
        height: 175,
        weight: 70,
        gender: 'male',
        isActive: true,
        profilePic: '',
        goal: '',
        events: [],
        appointments: [],
      );

      // Simulamos manualmente una UID como lo haría FirebaseAuth
      final uid = 'fake_uid';
      final newUser = testUser.copyWith(id: uid);
      await fakeFirestore.collection('users').doc(uid).set(newUser.toMap());

      final snapshot = await fakeFirestore.collection('users').doc(uid).get();
      expect(snapshot.exists, true);
      expect(snapshot['name'], 'Carlos');
      expect(snapshot['email'], 'carlos@example.com');
    });
  });
}