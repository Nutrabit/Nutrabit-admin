import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import '../patients/patient_detail_auxiliary_test.dart';

void main() {
  testWidgets('Renderiza datos de paciente con FakeFirestore sin fallar por imagen', (tester) async {
    final firestore = FakeFirebaseFirestore();

    await firestore.collection('users').doc('123').set({
      'name': 'Laura',
      'lastname': 'Gómez',
      'email': 'laura@test.com',
      'weight': 60,
      'height': 165,
      'dieta': 'Keto',
      'isActive': true,
      'birthday': Timestamp.fromDate(DateTime(2000, 1, 1)),
      'profilePic': '', // ← para que use AssetImage en producción
    });

    await tester.pumpWidget(
      MaterialApp(
        home: PatientDetail(id: '123', firestore: firestore),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Laura Gómez'), findsOneWidget);
    expect(find.text('laura@test.com'), findsOneWidget);
    expect(find.textContaining('Keto'), findsOneWidget);
    expect(find.textContaining('60 kg'), findsOneWidget);
    expect(find.textContaining('165 cm'), findsOneWidget);
  });
}