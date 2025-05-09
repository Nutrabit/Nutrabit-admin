import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutrabit_admin/core/utils/utils.dart';
import 'package:nutrabit_admin/core/models/app_users.dart';
import 'package:nutrabit_admin/presentation/providers/user_provider.dart';

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
}) async {
  AppUser newUser = AppUser(
    id: '',
    name: name,
    lastname: lastName,
    email: email,
    birthday: birthday,
    dni: '',
    age: 0,
    height: height,
    weight: weight,
    gender: gender,
    isActive: true,
    profilePic: '',
    goal: '',
    files: [],
    events: [],
    appointments: [],
  );
  
  try {
    await addUser(newUser);
    ref.refresh(usersProvider);

    if (context.mounted) {
      await showCustomDialog(
        context: context,
        message: 'Usuario creado exitosamente.',
        buttonText: 'Continuar',
        buttonColor: Colors.green,
        onPressed: () {
          Navigator.of(context).pop();
          context.go("/pacientes");
        },
      );
    }
  } catch (e) {
    if (context.mounted) {
      await showCustomDialog(
        context: context,
        message: 'Ocurrió un error: $e',
        buttonText: 'Continuar',
        buttonColor: Colors.red,
        onPressed: () {
          Navigator.of(context).pop();
        },
      );
    }
  }
}
