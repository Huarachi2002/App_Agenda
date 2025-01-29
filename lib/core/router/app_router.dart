import 'package:app_task/features/attendance/presentation/pages/attendance_page.dart';
import 'package:app_task/features/agenda/presentation/pages/teacher_agenda_content.dart';
import 'package:app_task/features/recording/presentation/pages/grabar_clase_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Importa tus páginas
import '../../features/user/presentation/pages/login_page.dart';
import '../../features/user/presentation/pages/home_page.dart';

// Importa tu userControllerProvider
import '../../features/user/presentation/controllers/user_controller.dart';

/// Este provider creará y expondrá la instancia de GoRouter
final goRouterProvider = Provider<GoRouter>((ref) {
  // Observamos el estado del userController para saber si hay user logueado
  final userState = ref.watch(userControllerProvider);

  // isLoggedIn: si userState tiene un valor distinto de null
  final isLoggedIn = userState.value != null;

  return GoRouter(
    // Define las rutas principales
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/teacher',
        name: 'teacher_home',
        builder: (context, state) => const TeacherAgendaContent(),
      ),
      GoRoute(
        path: '/attendance',
        name: 'attendance',
        builder: (context, state) => const AttendancePage(),
      ),
      GoRoute(
        path: '/recording',
        name: 'recording',
        builder: (context, state) => const GrabarClasePage(),
      )
    ],
    // Redirecciones basadas en estado
    redirect: (context, state) {
      final goingToLogin = state.path == '/login';

      // Si no está logueado y NO estamos en /login, redirigimos a login
      if (!isLoggedIn && !goingToLogin) {
        return '/login';
      }

      // Si está logueado y está intentando ir a /login, redirigimos a Home
      if (isLoggedIn && goingToLogin) {
        return '/';
      }

      // En otros casos, no redirigimos
      return null;
    },
    // Opción: puedes mostrar una pantalla de carga mientras se determina el estado 
    // (usando refreshListenable o un AsyncGuard).
    // refreshListenable: GoRouterRefreshStream(ref.watch(userControllerProvider).asStream()),
  );
});
