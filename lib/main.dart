import 'package:app_task/features/auth/data/datasources/user_remote_datasource.dart';
import 'package:app_task/features/user/data/repositories_impl/user_repository_impl.dart';
import 'package:app_task/features/user/presentation/controllers/user_controller.dart';
import 'package:app_task/features/user/presentation/pages/home_page.dart';
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

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agenda Escolar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}
