import 'package:app_task/core/router/app_router.dart';
import 'package:app_task/features/user/data/datasources/user_remote_datasource.dart';
import 'package:app_task/features/user/data/repositories_impl/user_repository_impl.dart';
import 'package:app_task/features/user/presentation/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    ProviderScope(
      overrides: [
        // Sobrescribimos userRepositoryProvider con nuestra implementación.
        userRepositoryProvider.overrideWithValue(
          UserRepositoryImpl(UserRemoteDataSourceImpl()),
        ),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends ConsumerWidget  {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'Agenda Escolar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routeInformationParser: goRouter.routeInformationParser,
      routerDelegate: goRouter.routerDelegate,
      routeInformationProvider: goRouter.routeInformationProvider,
    );
  }
}
