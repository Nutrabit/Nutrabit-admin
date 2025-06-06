import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutrabit_admin/core/utils/utils.dart';
import 'package:nutrabit_admin/core/models/app_users.dart';
import 'package:nutrabit_admin/presentation/providers/user_provider.dart';

Future<void> createUser({
  required WidgetRef ref,
  required String name,
  required String dni,
  required String lastName,
  required String email,
  required DateTime? birthday,
  required int height,
  required int weight,
  required String gender,
  required BuildContext context,
  required VoidCallback onDone,
}) async {
  AppUser newUser = AppUser(
    id: '',
    dni: dni,
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
  await addUser(newUser);
  ref.refresh(paginatedUsersProvider);
  onDone();
  
  if (context.mounted) {
    await showCustomDialog(
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

  final rawMessage = e.toString().toLowerCase();
  String friendlyMessage = 'Ocurrió un error inesperado.';

  if (rawMessage.contains('email-already-in-use') || rawMessage.contains('email address is already in use')) {
    friendlyMessage = 'Email ya registrado';
  }

  if (context.mounted) {
    await showCustomDialog(
      context: context,
      message: 'Ocurrió un error: $friendlyMessage',
      buttonText: 'Continuar',
      buttonColor: const Color(0xFFDC607A),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }
}
}