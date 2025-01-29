import 'package:app_task/features/agenda/data/datasource/comunication_remote_datasource.dart';
import 'package:app_task/features/agenda/data/repository_impl/comunication_repository_impl.dart';
import 'package:app_task/features/recording/data/repositories_impl/teacher_record_repository_impl.dart';
import 'package:app_task/features/recording/presentation/controllers/teacher_record_notifier.dart';
import 'package:app_task/features/teacher/presentation/controllers/notifier/create_communication_notifier.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_task/core/router/app_router.dart';
import 'package:app_task/features/user/data/datasources/user_remote_datasource.dart';
import 'package:app_task/features/user/data/repositories_impl/user_repository_impl.dart';
import 'package:app_task/features/user/presentation/controllers/user_controller.dart';
import 'package:app_task/services/fcm_service.dart';
import 'package:http/http.dart' as http;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Inicializa FCM
  final fcmService = FCMService();
  await fcmService.initialize();
  
  runApp(
    ProviderScope(
      overrides: [
        communicationRepositoryProvider.overrideWithValue(
          CommunicationRepositoryImpl(
            CommunicationRemoteDataSourceImpl(http.Client()),
          ),
        ),

        teacherRecordRepositoryProvider.overrideWithValue(
          TeacherRecordRepositoryImpl(http.Client()),
        ),

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
