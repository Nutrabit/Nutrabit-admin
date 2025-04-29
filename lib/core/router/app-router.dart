import 'package:go_router/go_router.dart';
import 'package:nutrabit_admin/presentaciones/screens/home.dart';
import 'package:nutrabit_admin/presentaciones/screens/login.dart';
import 'package:nutrabit_admin/presentaciones/screens/pacientes/detallePaciente.dart';
import 'package:nutrabit_admin/presentaciones/screens/pacientes/pacientes.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => Home()
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => Login()
    ),
    GoRoute(
      path: '/pacientes',
      builder: (context, state) => Pacientes()
    ),
    GoRoute(
      path: '/pacientes/:id',
      builder: (context, state) => DetallePaciente()
    ), 
  ]
);