import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:nutrabit_admin/presentation/providers/auth_provider.dart';

class Logout extends ConsumerStatefulWidget {
  const Logout({super.key});

  @override
  ConsumerState<Logout> createState() => _LogoutState();
}

class _LogoutState extends ConsumerState<Logout> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const FaIcon(FontAwesomeIcons.rightFromBracket),
      tooltip: 'Cerrar sesión',
      onPressed: () {
        final logout = ref.read(authProvider.notifier).logout().then((r) {
          if (r == true) {
            context.go('/login');
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error al cerrar sesión')));
          }
          ;
        });
      },
    );
  }
}
