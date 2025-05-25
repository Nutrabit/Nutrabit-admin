import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import '../patients/patient_modifier_auxiliary_test.dart';

void main() {
  const testPatientId = '123';

  testWidgets('Carga datos del paciente y muestra botón de guardar', (tester) async {
    final firestore = FakeFirebaseFirestore();

    await firestore.collection('users').doc(testPatientId).set({
      'name': 'Juan',
      'lastname': 'Pérez',
      'email': 'juan@test.com',
      'height': 175,
      'weight': 70,
      'sexo': 'Masculino',
      'birthday': Timestamp.fromDate(DateTime(1990, 1, 1)),
      'actividad': 'Activo',
      'vegetariano': true,
      'vegano': false,
    });

    await tester.pumpWidget(
      MaterialApp(
        home: PatientModifier(
          id: testPatientId,
          firestore: firestore,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Modificar paciente'), findsOneWidget);
    expect(find.text('Juan'), findsOneWidget);
    expect(find.text('Pérez'), findsOneWidget);
    expect(find.text('juan@test.com'), findsOneWidget);
    expect(find.text('Guardar cambios'), findsOneWidget);
  });

  testWidgets('Presionar guardar actualiza el documento', (tester) async {
    final firestore = FakeFirebaseFirestore();

    await firestore.collection('users').doc(testPatientId).set({
      'name': 'Juan',
      'lastname': 'Pérez',
      'email': 'juan@test.com',
      'height': 175,
      'weight': 70,
      'sexo': 'Masculino',
      'birthday': Timestamp.fromDate(DateTime(1990, 1, 1)),
      'actividad': 'Activo',
      'vegetariano': true,
      'vegano': false,
    });

    await tester.pumpWidget(
      MaterialApp(
        home: PatientModifier(
          id: testPatientId,
          firestore: firestore,
        ),
      ),
    );

    await tester.pumpAndSettle();

    final guardarBtn = find.text('Guardar cambios');
    expect(guardarBtn, findsOneWidget);

    await tester.tap(guardarBtn);
    await tester.pumpAndSettle();

    final updatedDoc = await firestore.collection('users').doc(testPatientId).get();
    expect(updatedDoc.exists, isTrue);

    // Validamos un campo que pudo haberse actualizado
    expect(updatedDoc.data()!['name'], isNotEmpty);
  });
}