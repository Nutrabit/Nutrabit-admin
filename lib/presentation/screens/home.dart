import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
                    onPressed: () {
                      context.go('/cambiar-clave');
                    },
                    child: const Text(
                      'Cambiar contraseña',
                      style: TextStyle(
                        color: Color.fromRGBO(130, 130, 130, 1),
                        fontSize: 12,
                      ),
                    ),
                  ),
      ),
    );
  }
}