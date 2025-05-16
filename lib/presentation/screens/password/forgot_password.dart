// TODO Implement this library.import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class ForgotPassword extends ConsumerStatefulWidget {
  const ForgotPassword({super.key});

  @override
  ConsumerState<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends ConsumerState<ForgotPassword> {
  // 📝 Controlador para leer el email que ingresa el usuario
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 🔍 Escuchamos cambios en authProvider para mostrar mensajes
  }

  // ▶️ Se ejecuta al pulsar el botón “Enviar email de recuperación”
  void sendEmail() {
    final email = _emailController.text.trim();
    // 🔍 Validación simple de formato
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ingresá un email válido.')));
      return;
    }
    // 🚀 Disparamos el método del provider
    ref.read(authProvider.notifier).sendPasswordResetEmail(email);
  }

  @override
  Widget build(BuildContext context) {
    // 👀 Observamos el estado para saber si está cargando
    final authState = ref.watch(authProvider);

    ref.listen<AsyncValue<void>>(authProvider, (prev, next) {
      next.when(
        loading: () {
          // Opcional: mostrar un loader global si querés
        },
        data: (_) {
          // 🎉 Éxito: primero mostramos el diálogo
          showDialog(
            context: context,
            builder:
                (_) => AlertDialog(
                  title: const Text('¡Email enviado!'),
                  content: const Text(
                    'Revisa tu bandeja de entrada para restablecer tu contraseña.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('OK'),
                    ),
                  ],
                ),
          );
        },
        error: (err, _) {
          // ⚠️ Error: extraemos el mensaje de FirebaseAuthException o genérico
          final msg =
              (err is FirebaseAuthException)
                  ? err.message ?? err.code
                  : err.toString();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $msg')),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ✉️ Campo de texto para el email
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Tu email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // 🔘 Botón de envío
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                // ⏳ Deshabilitado si estamos en estado Loading
                onPressed: authState is AsyncLoading ? null : sendEmail,
                child:
                    authState is AsyncLoading
                        // ➿ Indicador de progreso si está cargando
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        // ✅ Texto normal si no está cargando
                        : const Text('Enviar email de recuperación'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
