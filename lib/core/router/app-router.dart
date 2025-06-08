import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:nutrabit_admin/core/models/course_model.dart';
import 'package:nutrabit_admin/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrabit_admin/presentation/screens/calendar/calendar.dart';
import 'package:nutrabit_admin/presentation/screens/calendar/patient_calendarDay.dart';
import 'package:nutrabit_admin/presentation/screens/courses/course_creation.dart';
import 'package:nutrabit_admin/presentation/screens/courses/course_list_screen.dart';
import 'package:nutrabit_admin/presentation/screens/home.dart';
import 'package:nutrabit_admin/presentation/screens/interest_list/altaListaInteres.dart';
import 'package:nutrabit_admin/presentation/screens/interest_list/listaInteres.dart';
import 'package:nutrabit_admin/presentation/screens/login.dart';
import 'package:nutrabit_admin/presentation/screens/notifications/notification_creation.dart';
import 'package:nutrabit_admin/presentation/screens/notifications/notifications_list_screen.dart';
import 'package:nutrabit_admin/presentation/screens/password/change_password.dart';
import 'package:nutrabit_admin/presentation/screens/password/forgot_password.dart';
import 'package:nutrabit_admin/presentation/screens/patients/patient_detail.dart';
import 'package:nutrabit_admin/presentation/screens/patients/patient_list.dart';
import 'package:nutrabit_admin/presentation/screens/patients/patient_registration.dart';
import 'package:nutrabit_admin/presentation/screens/patients/appointments.dart';
import 'package:nutrabit_admin/presentation/screens/files/attach_files_screen.dart';
import 'package:nutrabit_admin/core/models/notification_model.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

/// A [Listenable] that notifies listeners when the provided [Stream] emits a value.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final appRouter = Provider<GoRouter>((ref) {
  final isLoggedInAsync = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(
      ref.watch(authProvider.notifier).stream,
    ),
    redirect: (context, state) {
      final isLoggedIn = isLoggedInAsync.value;

      // Mientras se resuelve la sesión
      if (isLoggedIn == null) return null;

      final isLoggingIn = state.uri.toString() == '/login';

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => HomePage()),
      GoRoute(path: '/login', builder: (context, state) => Login()),
      GoRoute(
        path: '/pacientes',
        builder: (context, state) => PatientList(),
        routes: [
          GoRoute(
            path: '/alta',
            builder: (context, state) => PatientRegistration(),
          ),
          GoRoute(
            path: ':id',
            builder:
                (context, state) =>
                    PatientDetail(id: state.pathParameters['id'] as String),
            routes: [
              GoRoute(
                name: 'archivos',
                path: 'archivos',
                builder:
                    (context, state) => AttachFilesScreen(
                      patientId: state.pathParameters['id'] as String,
                    ),
              ),
              GoRoute(
                name: 'calendar',
                path: 'calendario',
                builder:
                    (_, state) =>
                        Calendar(patientId: state.pathParameters['id']!),
                routes: [
                  GoRoute(
                    name: 'calendarDetail',
                    path: 'detalle',
                    builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>;
                      final date = extra['date'] as DateTime;
                      final patientId = extra['patientId'] as String;
                      return CalendarDayPatient(
                        date: date,
                        patientId: patientId,
                      );
                    },
                  ),
                ],
              ),
              GoRoute(
                name: 'appointments',
                path: 'turnos',
                builder: (context, state) {
                  final patientId = state.pathParameters['id'];
                  if (patientId == null) {
                    return const Scaffold(body: Center(child: Text('Paciente no encontrado')));
                  }
                  return Appointments(id: patientId);
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/cursos',
        builder: (context, state) => const CourseListScreen(),
        routes: [
          GoRoute(
            path: 'crear',
            builder: (context, state) => const CourseCreationScreen(),
          ),
          GoRoute(
            path: 'editar',
            builder: (context, state) {
              final course = state.extra as Course;
              return CourseCreationScreen(course: course);
            },
          ),
        ],
      ),
      GoRoute(
        name: 'notifications',
        path: '/notificaciones',
        builder: (context, state) => NotificationsListScreen(),
        routes: [
          GoRoute(
            path: 'crear',
            builder:
                (context, state) => const NotificationCreation(),
          ),
          GoRoute(
            path: 'editar',
            builder: (context, state) {
              final notification = state.extra as NotificationModel;
              return NotificationCreation(notification: notification);
            },
          ),
        ],
      ),
      GoRoute(
        path: 'listaInteres',
        builder: (context, state) => ListaInteres(),
        routes: [
          GoRoute(
            path: 'alta',
            builder: (context, state) => AltaListaInteres(),
          ),
        ],
      ),
      GoRoute(
        path: '/recuperar-clave',
        builder: (context, state) => ForgotPassword(),
      ),
      GoRoute(
        path: '/cambiar-clave',
        builder: (context, state) => ChangePassword(),
      ),
      GoRoute(
        path: '/splash',
        builder:
            (_, __) => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
      ),
    ],
  );
});
