import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutrabit_admin/core/utils/utils.dart';
import 'package:nutrabit_admin/core/models/app_users.dart';
import 'package:nutrabit_admin/presentation/providers/user_provider.dart';

typedef AddUserFn = Future<void> Function(AppUser user);
typedef ShowDialogFn = Future<void> Function({
  required BuildContext context,
  required String message,
  required String buttonText,
  required Color buttonColor,
  required VoidCallback onPressed,
});

Future<void> createUser({
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
  AddUserFn addUserFn = addUser, 
  ShowDialogFn showDialogFn = showCustomDialog, 
}) async {
  final newUser = AppUser(
    id: '',
    name: name,
    lastname: lastName,
    email: email,
    birthday: birthday,
    height: height,
    weight: weight,
    gender: gender,
    isActive: true,
    profilePic: '',
    goal: '',
    events: [],
    appointments: [],
  );

  try {
    await addUserFn(newUser);
    onDone();
    if (context.mounted) {
      await showDialogFn(
        context: context,
        message: 'Usuario creado exitosamente.',
        buttonText: 'Continuar',
        buttonColor: const Color(0xFFBAF4C7),
        onPressed: () {
          Navigator.of(context).pop();
          context.go("/pacientes");
        },
      );
    }
  } catch (e) {
    onDone();
    if (context.mounted) {
      await showDialogFn(
        context: context,
        message: 'Ocurrió un error: $e',
        buttonText: 'Continuar',
        buttonColor: const Color(0xFFDC607A),
        onPressed: () {
          Navigator.of(context).pop();
        },
      );
    }
  }
}

// Firma esperada de createUser (coincide con la función real)
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

// Este provider envuelve la función original para poder ser sobreescrita en tests
final createUserProvider = Provider<CreateUserFn>((ref) => createUser);