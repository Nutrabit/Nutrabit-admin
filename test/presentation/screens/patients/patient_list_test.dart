import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nutrabit_admin/core/models/app_users.dart';
import 'package:nutrabit_admin/presentation/providers/user_provider.dart';
import 'package:nutrabit_admin/presentation/screens/patients/patient_list.dart';

void main() {
  Widget createTestApp(Widget child, ProviderContainer container) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => child,
        ),
        GoRoute(
          path: '/pacientes/alta',
          builder: (context, state) => const Scaffold(body: Text('Alta')),
        ),
        GoRoute(
          path: '/pacientes/:id',
          builder: (context, state) => Scaffold(
            body: Text('Detalle paciente: ${state.pathParameters['id']}'),
          ),
        ),
      ],
    );

    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: router),
    );
  }

  final mockUsers = [
    AppUser(
      id: '1',
      name: 'Juan',
      lastname: 'Pérez',
      email: '',
      gender: '',
      birthday: null,
      height: 0,
      weight: 0,
      profilePic: '',
      isActive: true,
      goal: 'Bajar de peso',
      events: [],
      appointments: [],
    ),
    AppUser(
      id: '2',
      name: 'Ana',
      lastname: 'López',
      email: '',
      gender: '',
      birthday: null,
      height: 0,
      weight: 0,
      profilePic: '',
      isActive: true,
      goal: 'Bajar de peso',
      events: [],
      appointments: [],
    ),
  ];

  testWidgets('Renderiza PatientList correctamente con pacientes', (tester) async {
    final container = ProviderContainer(overrides: [
      usersProvider.overrideWith((ref) async => mockUsers),
      searchUsersProvider('juan').overrideWith((ref) async => [mockUsers[0]]),
      searchUsersProvider('').overrideWith((ref) async => mockUsers),
    ]);

    await tester.pumpWidget(createTestApp(const PatientList(), container));
    await tester.pumpAndSettle();

    expect(find.text('Pacientes'), findsOneWidget);
    expect(find.textContaining('Juan'), findsOneWidget);
    expect(find.textContaining('Ana'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('Campo de búsqueda filtra resultados', (tester) async {
    final container = ProviderContainer(overrides: [
      usersProvider.overrideWith((ref) async => []),
      searchUsersProvider('juan').overrideWith((ref) async => [mockUsers[0]]),
      searchUsersProvider('').overrideWith((ref) async => []),
    ]);

    await tester.pumpWidget(createTestApp(const PatientList(), container));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'juan');
    await tester.pumpAndSettle();

    expect(find.textContaining('Juan'), findsOneWidget);
  });

  testWidgets('El botón de agregar paciente navega a la pantalla de alta', (tester) async {
    final container = ProviderContainer(overrides: [
      usersProvider.overrideWith((ref) async => []),
      searchUsersProvider('').overrideWith((ref) async => []),
    ]);

    await tester.pumpWidget(createTestApp(const PatientList(), container));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('Alta'), findsOneWidget);
  });

  testWidgets('Muestra mensaje si no se encuentran pacientes', (tester) async {
    final container = ProviderContainer(overrides: [
      usersProvider.overrideWith((ref) async => []),
      searchUsersProvider('').overrideWith((ref) async => []),
    ]);

    await tester.pumpWidget(createTestApp(const PatientList(), container));
    await tester.pumpAndSettle();

    expect(find.text('No se encontraron pacientes'), findsOneWidget);
  });

  testWidgets('El ícono de limpiar aparece y limpia el campo', (tester) async {
    final container = ProviderContainer(overrides: [
      usersProvider.overrideWith((ref) async => []),
      searchUsersProvider('j').overrideWith((ref) async => []),
      searchUsersProvider('').overrideWith((ref) async => []),
    ]);

    await tester.pumpWidget(createTestApp(const PatientList(), container));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'j');
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.clear), findsOneWidget);

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.controller?.text, isEmpty);
  });

}
