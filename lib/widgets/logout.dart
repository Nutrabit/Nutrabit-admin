import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:nutrabit_admin/core/utils/decorations.dart';
import 'package:nutrabit_admin/presentation/providers/auth_provider.dart';

class Logout extends ConsumerStatefulWidget {
  const Logout({super.key});

  @override
  ConsumerState<Logout> createState() => _LogoutState();
}

class _LogoutState extends ConsumerState<Logout> {
  void _confirmLogout(BuildContext context) {
    final style = defaultAlertDialogStyle;

    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            shape: style.shape,
            backgroundColor: style.backgroundColor,
            elevation: style.elevation,
            titleTextStyle: style.titleTextStyle,
            contentTextStyle: style.contentTextStyle,
            contentPadding: style.contentPadding,
            actionsPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            title: const Text('¿Cerrar sesión?', textAlign: TextAlign.center),
            content: const Text(
              '¿Estás segura/o de que querés cerrar sesión?',
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                style: style.buttonStyle,
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text('Cancelar', style: style.buttonTextStyle),
              ),
              TextButton(
                style: style.buttonStyle,
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text('Confirmar', style: style.buttonTextStyle),
              ),
            ],
          ),
    ).then((confirm) async {
      if (confirm == true) {
        final result = await ref.read(authProvider.notifier).logout();
        if (result) {
          if (mounted) context.go('/login');
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error al cerrar sesión')),
            );
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: FaIcon(FontAwesomeIcons.rightFromBracket),
      label: Text('Cerrar sesión'),
      onPressed: () => _confirmLogout(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
    );
  }
}
