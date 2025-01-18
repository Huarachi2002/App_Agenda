import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/user_controller.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: userState.when(
        data: (user) {
          if (user == null) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navegamos a login page o llamamos signIn anónimo para demo
                  ref.read(userControllerProvider.notifier).signIn(
                        'test@test.com',
                        'password123',
                      );
                },
                child: const Text('Iniciar sesión (demo)'),
              ),
            );
          } else {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Hola, ${user.name} (${user.role})'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(userControllerProvider.notifier).signOut();
                    },
                    child: const Text('Cerrar sesión'),
                  ),
                ],
              ),
            );
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
