import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrabit_admin/presentation/providers/auth_provider.dart';

class Login extends ConsumerStatefulWidget  {
  
  @override
   ConsumerState<Login> createState() => _LoginState();
}
class _LoginState extends ConsumerState<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String email = '';
  String password = '';

  void login() async {
    
    String email = emailController.text;
    String password = passwordController.text;
    final credentials = (emailController.text, passwordController.text);
    ref.read(loginAuthProvider(credentials));
    try {
    
    // Podés navegar a la home, por ejemplo
  } catch (e) {
    print('Error de login: $e');
    // Mostrar error con un Snackbar o similar
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Email',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Contraseña',
                
              ),
            ),
            ElevatedButton(onPressed: login, child: Text("Iniciar Sesión")),
          ],
        ),
      ),
    );
  }
}