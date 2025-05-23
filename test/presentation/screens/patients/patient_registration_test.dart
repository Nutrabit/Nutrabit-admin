import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrabit_admin/presentation/screens/patients/patient_registration.dart';
import 'package:nutrabit_admin/core/services/user_service.dart'; // Asegúrate de tener este import

final createUserProvider = Provider<CreateUserFn>((ref) => createUser);

typedef CreateUserFn = Future<void> Function({
  required WidgetRef ref,
  required String name,
  required String lastName,
  required String email,
  required DateTime? birthday,
  required int height,
  required int weight,
  required String gender,
  required BuildContext context,
  required VoidCallback onDone,
});

void main() {
  testWidgets('Muestra campos y valida email', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: PatientRegistrationForm())),
      ),
    );

    expect(find.text('Nuevo paciente'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Nombre *'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Apellido *'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Email *'), findsOneWidget);
    expect(find.text('Crear cuenta'), findsOneWidget);
  });

  testWidgets('Muestra SnackBar si campos requeridos están vacíos', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: PatientRegistrationForm()),
        ),
      ),
    );

    await tester.tap(find.text('Crear cuenta'));
    await tester.pump(); // Procesa SnackBar

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('llená los campos'), findsOneWidget);
  });

  testWidgets('Muestra SnackBar si el email es inválido', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: PatientRegistrationForm())),
      ),
    );

    await tester.enterText(find.widgetWithText(TextFormField, 'Nombre *'), 'Juan');
    await tester.enterText(find.widgetWithText(TextFormField, 'Apellido *'), 'Pérez');
    await tester.enterText(find.widgetWithText(TextFormField, 'Email *'), 'no-email');

    await tester.pumpAndSettle();

    await tester.tap(find.text('Crear cuenta'));
    await tester.pump();

    expect(find.textContaining('email válido'), findsOneWidget);
  });
}