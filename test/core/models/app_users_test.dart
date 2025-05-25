import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutrabit_admin/core/models/app_users.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  group('AppUser', () {
    final now = DateTime.now();

    final sampleUser = AppUser(
      id: '123',
      name: 'John',
      lastname: 'Doe',
      email: 'john@example.com',
      birthday: DateTime(2000, 1, 1),
      height: 180,
      weight: 75,
      gender: 'male',
      isActive: true,
      profilePic: 'url_pic',
      goal: 'Lose weight',
      events: [
        {'type': 'login', 'timestamp': '2024-01-01'}
      ],
      appointments: [Timestamp.fromDate(now)],
      createdAtParam: now,
      modifiedAtParam: now,
      deletedAtParam: null,
    );

    test('toMap() serializes properly', () {
      final map = sampleUser.toMap();
      expect(map['id'], '123');
      expect(map['name'], 'John');
      expect(map['lastname'], 'Doe');
      expect(map['email'], 'john@example.com');
      expect(map['birthday'], Timestamp.fromDate(DateTime(2000, 1, 1)));
      expect(map['height'], 180);
      expect(map['weight'], 75);
      expect(map['gender'], 'male');
      expect(map['isActive'], true);
      expect(map['profilePic'], 'url_pic');
      expect(map['goal'], 'Lose weight');
      expect(map['events'], isA<List>());
      expect(map['appointments'], isA<List<Timestamp>>());
      expect(map['createdAt'], Timestamp.fromDate(now));
      expect(map['modifiedAt'], Timestamp.fromDate(now));
      expect(map['deletedAt'], null);
    });

    test('copyWith() overrides values correctly', () {
      final updatedUser = sampleUser.copyWith(name: 'Jane', weight: 65);
      expect(updatedUser.name, 'Jane');
      expect(updatedUser.weight, 65);
      expect(updatedUser.id, '123'); // unchanged
    });

    test('fromFirestore() parses correctly with FakeFirestore', () async {
      final firestore = FakeFirebaseFirestore();

      await firestore.collection('users').doc('123').set({
        'id': '123',
        'name': 'John',
        'lastname': 'Doe',
        'email': 'john@example.com',
        'birthday': Timestamp.fromDate(DateTime(2000, 1, 1)),
        'height': 180,
        'weight': 75,
        'gender': 'male',
        'isActive': true,
        'profilePic': 'url_pic',
        'goal': 'Lose weight',
        'events': [
          {'type': 'login', 'timestamp': '2024-01-01'}
        ],
        'appointments': [Timestamp.fromDate(now)],
        'createdAt': Timestamp.fromDate(now),
        'modifiedAt': Timestamp.fromDate(now),
        'deletedAt': null,
      });

      final snapshot = await firestore.collection('users').doc('123').get();
      final user = AppUser.fromFirestore(snapshot);

      expect(user.id, '123');
      expect(user.name, 'John');
      expect(user.birthday, DateTime(2000, 1, 1));
      expect(user.appointments.first.toDate(), now);
    });
  });
}