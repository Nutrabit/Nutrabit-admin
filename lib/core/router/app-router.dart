import 'package:go_router/go_router.dart';
import 'package:nutrabit_admin/presentaciones/screens/calendario/calendario.dart';
import 'package:nutrabit_admin/presentaciones/screens/calendario/detalleDiaCalendario.dart';
import 'package:nutrabit_admin/presentaciones/screens/home.dart';
import 'package:nutrabit_admin/presentaciones/screens/listaInteres/altaListaInteres.dart';
import 'package:nutrabit_admin/presentaciones/screens/listaInteres/listaInteres.dart';
import 'package:nutrabit_admin/presentaciones/screens/login.dart';
import 'package:nutrabit_admin/presentaciones/screens/notificaciones/altaNotificacion.dart';
import 'package:nutrabit_admin/presentaciones/screens/notificaciones/detalleNotificacion.dart';
import 'package:nutrabit_admin/presentaciones/screens/notificaciones/notificaciones.dart';
import 'package:nutrabit_admin/presentaciones/screens/pacientes/altaPaciente.dart';
import 'package:nutrabit_admin/presentaciones/screens/pacientes/altaArchivosPaciente.dart';
import 'package:nutrabit_admin/presentaciones/screens/pacientes/detallePaciente.dart';
import 'package:nutrabit_admin/presentaciones/screens/pacientes/pacientes.dart';
import 'package:nutrabit_admin/presentaciones/screens/pacientes/turnos.dart';
import 'package:nutrabit_admin/presentaciones/screens/publicidades/altaPubli.dart';
import 'package:nutrabit_admin/presentaciones/screens/publicidades/detallePubli.dart';
import 'package:nutrabit_admin/presentaciones/screens/publicidades/publicidades.dart';

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
      builder: (context, state) => Pacientes(),
      routes: [
        GoRoute(
          path: '/alta',
          builder: (context, state) => AltaPaciente()
        ),
        GoRoute(
          path: '/:id',
          builder: (context, state) => DetallePaciente(id: state.pathParameters['id'] as String),
          routes: [
            GoRoute(
              path: '/archivos',
              builder: (context, state) => AltaArchivosPaciente(id: state.pathParameters['id'] as String)
            ) 
          ],
          
        ),
        GoRoute(
          path: '/calendario',
          builder: (context, state) => Calendario(),
          routes: [
            GoRoute(
              path: '/:fecha',
              builder: (context, state) => DetalleDiaCalendario(fecha: state.pathParameters['fecha'] as String)
            ) 
          ]
        ),
        GoRoute(
          path: '/turnos',
          builder: (context, state) => Turnos()
        ),
      ]
    ),
    
    GoRoute(
      path: '/publicidades',
      builder: (context, state) => Publicidades(),
      routes: [
        GoRoute(
          path: '/:id',
          builder: (context, state) => DetallePublicidad(id: state.pathParameters['id'] as String)
        ),
        GoRoute(
          path: '/alta',
          builder: (context, state) => AltaPublicidad()
        ) 
      ]
    ),
    GoRoute(
      path: '/notificaciones',
      builder: (context, state) => Notificaciones(),
      routes: [
        GoRoute(
          path: '/:id',
          builder: (context, state) => DetalleNotificacion(id: state.pathParameters['id'] as String)
        ),
        GoRoute(
          path: '/alta',
          builder: (context, state) => AltaNotificacion()
        ) 
      ]
    ),
    GoRoute(
      path: '/listaInteres',
      builder: (context, state) => ListaInteres(),
      routes: [
        GoRoute(
          path: '/alta',
          builder: (context, state) => AltaListaInteres()
        ) 
      ]
    )
  ]
);