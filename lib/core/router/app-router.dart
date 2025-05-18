import 'package:go_router/go_router.dart';
import 'package:nutrabit_admin/presentation/screens/calendar/calendario.dart';
import 'package:nutrabit_admin/presentation/screens/calendar/detalleDiaCalendario.dart';
import 'package:nutrabit_admin/presentation/screens/home.dart';
import 'package:nutrabit_admin/presentation/screens/interest_list/altaListaInteres.dart';
import 'package:nutrabit_admin/presentation/screens/interest_list/listaInteres.dart';
import 'package:nutrabit_admin/presentation/screens/login.dart';
import 'package:nutrabit_admin/presentation/screens/notifications/altaNotificacion.dart';
import 'package:nutrabit_admin/presentation/screens/notifications/detalleNotificacion.dart';
import 'package:nutrabit_admin/presentation/screens/notifications/notificaciones.dart';
import 'package:nutrabit_admin/presentation/screens/password/change_password.dart';
import 'package:nutrabit_admin/presentation/screens/password/forgot_password.dart';
import 'package:nutrabit_admin/presentation/screens/patients/patient_detail.dart';
import 'package:nutrabit_admin/presentation/screens/patients/patient_list.dart';
import 'package:nutrabit_admin/presentation/screens/patients/patient_registration.dart';
import 'package:nutrabit_admin/presentation/screens/patients/turnos.dart';
import 'package:nutrabit_admin/presentation/screens/publicity/altaPubli.dart';
import 'package:nutrabit_admin/presentation/screens/publicity/detallePubli.dart';
import 'package:nutrabit_admin/presentation/screens/publicity/publicidades.dart';
import 'package:nutrabit_admin/presentation/screens/files/attach_files_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/', builder: (context, state) => Home()),
    GoRoute(path: '/login', builder: (context, state) => Login()),
    GoRoute(
      path: '/pacientes',
      builder: (context, state) => PatientList(),
      routes: [
        GoRoute(path: '/alta', builder: (context, state) => PatientRegistration()),
        GoRoute(
          path: ':id',
          builder:
              (context, state) =>
                  PatientDetail(id: state.pathParameters['id'] as String),
          routes: [
            GoRoute(
              path: 'archivos',
              builder: (context, state) => AttachFilesScreen(
                patientId: state.pathParameters['id'] as String,
              ),
            ),
            GoRoute(
              path: 'calendario',
              builder: (context, state) => Calendario(),
              routes: [
                GoRoute(
                  path: ':fecha',
                  builder:
                      (context, state) => DetalleDiaCalendario(
                        fecha: state.pathParameters['fecha'] as String,
                      ),
                ),
              ],
            ),
            GoRoute(path: 'turnos', builder: (context, state) => Turnos()),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/publicidades',
      builder: (context, state) => Publicidades(),
      routes: [
        GoRoute(
          path: ':id',
          builder:
              (context, state) =>
                  DetallePublicidad(id: state.pathParameters['id'] as String),
        ),
        GoRoute(path: 'alta', builder: (context, state) => AltaPublicidad()),
      ],
    ),
    GoRoute(
      path: '/notificaciones',
      builder: (context, state) => Notificaciones(),
      routes: [
        GoRoute(
          path: ':id',
          builder:
              (context, state) =>
                  DetalleNotificacion(id: state.pathParameters['id'] as String),
        ),
        GoRoute(path: 'alta', builder: (context, state) => AltaNotificacion()),
      ],
    ),
    GoRoute(
      path: 'listaInteres',
      builder: (context, state) => ListaInteres(),
      routes: [
        GoRoute(path: 'alta', builder: (context, state) => AltaListaInteres()),
      ],
    ),
    GoRoute(path: '/recuperar-clave', builder: (context, state) => ForgotPassword()),
    GoRoute(path: '/cambiar-clave', builder: (context, state) =>  ChangePassword()),
  ],
);

