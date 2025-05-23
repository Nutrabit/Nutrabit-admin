import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class FakeLogin extends StatelessWidget {
  const FakeLogin({super.key});
  @override
  Widget build(BuildContext context) => const Text('LoginPage');
}

class FakePatientDetail extends StatelessWidget {
  final String id;
  const FakePatientDetail({super.key, required this.id});
  @override
  Widget build(BuildContext context) => Text('PatientDetail: $id');
}

class FakeAttachFilesScreen extends StatelessWidget {
  final String patientId;
  const FakeAttachFilesScreen({super.key, required this.patientId});
  @override
  Widget build(BuildContext context) => Text('AttachFiles: $patientId');
}

GoRouter createTestRouter() {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const FakeLogin(),
      ),
      GoRoute(
        path: '/pacientes/:id',
        builder: (context, state) => FakePatientDetail(
          id: state.pathParameters['id']!,
        ),
        routes: [
          GoRoute(
            path: 'archivos',
            builder: (context, state) => FakeAttachFilesScreen(
              patientId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
    ],
  );
}

void main() {
  group('GoRouter navigation', () {
    late GoRouter router;

    setUp(() {
      router = createTestRouter();
    });

    testWidgets('Navega al login correctamente', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('LoginPage'), findsOneWidget);
    });

    testWidgets('Navega al detalle de paciente con ID', (tester) async {
      router.go('/pacientes/abc123');
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('PatientDetail: abc123'), findsOneWidget);
    });

    testWidgets('Navega a la pantalla de archivos del paciente', (tester) async {
      router.go('/pacientes/abc123/archivos');
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('AttachFiles: abc123'), findsOneWidget);
    });
  });
}