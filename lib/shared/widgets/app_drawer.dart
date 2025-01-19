import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/user/presentation/controllers/user_controller.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userControllerProvider);
    final user = userState.value; // Puede ser null o un UserEntity

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Encabezado con info del usuario
            UserAccountsDrawerHeader(
              accountName: Text(user?.name ?? 'Sin nombre'),
              accountEmail: Text(user?.email ?? 'Sin email'),
            ),
            // Opción 1: Ir a Agenda (o Home)
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Agenda'),
              onTap: () {
                // Navegamos a la ruta raíz (Home)
                context.go('/');
              },
            ),
            // Opción 2: Ir a Asistencia
            ListTile(
              leading: const Icon(Icons.checklist),
              title: const Text('Asistencia'),
              onTap: () {
                // Supongamos que la ruta es /attendance
                context.go('/attendance');
              },
            ),
            const Divider(),
            // Cerrar Sesión
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Cerrar Sesión'),
              onTap: () async {
                await ref.read(userControllerProvider.notifier).signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
