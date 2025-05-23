import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutrabit_admin/core/models/app_users.dart';
import '../services/user_service_auxiliary_test.dart';
import 'package:nutrabit_admin/presentation/providers/user_provider.dart';

class MockWidgetRef extends Mock implements WidgetRef {}

void main() {
  late MockWidgetRef mockRef;

  setUp(() {
    mockRef = MockWidgetRef();
    registerFallbackValue(usersProvider);
    when(() => mockRef.refresh(usersProvider))
        .thenReturn(const AsyncValue.data(<AppUser>[]));
  });

  testWidgets('createUser maneja errores mostrando diálogo de error', (tester) async {
    bool onDoneCalled = false;
    bool dialogShown = false;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: const Text('Test')),
        ),
      ),
    );

    final context = tester.element(find.text('Test'));

    await createUser(
      ref: mockRef,
      name: 'Error',
      lastName: 'Case',
      email: 'fail@example.com',
      birthday: DateTime(2000, 1, 1),
      height: 180,
      weight: 75,
      gender: 'male',
      context: context,
      onDone: () => onDoneCalled = true,
      addUserFn: (_) async => throw Exception('falló!'),
      showDialogFn: ({
        required BuildContext context,
        required String message,
        required String buttonText,
        required Color buttonColor,
        required VoidCallback onPressed,
      }) async {
        dialogShown = true;
        expect(message, contains('Ocurrió un error'));
        onPressed();
      },
    );

    expect(onDoneCalled, isTrue);
    expect(dialogShown, isTrue);
  });
}