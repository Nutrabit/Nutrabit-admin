import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Notificaciones extends StatelessWidget {
  const Notificaciones({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/notificaciones/crear'),
        backgroundColor: Color(0xFFD7F9DE),
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: const Icon(Icons.add),
      ),
    );
  }
}
