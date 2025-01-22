import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FCMService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Suscribe a uno o más temas
  Future<void> subscribeToTopics(List<String> topics) async {
    for (final topic in topics) {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('Suscrito al tema: $topic');
    }
  }

  /// Desuscribe de uno o más temas
  Future<void> unsubscribeFromTopics(List<String> topics) async {
    for (final topic in topics) {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('Desuscrito del tema: $topic');
    }
  }

  /// Inicializa FCM y notificaciones locales
  Future<void> initialize() async {
    // Solicita permisos para notificaciones
    await _firebaseMessaging.requestPermission();

    // Configura notificaciones locales
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings =
        InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(initializationSettings);

    // Configura los manejadores para notificaciones
    FirebaseMessaging.onMessage.listen(_handleForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationClick);

    // Obtener el token del dispositivo
    final token = await _firebaseMessaging.getToken();
    print('Token del dispositivo: $token');
  }

  /// Maneja notificaciones en primer plano
  void _handleForegroundNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      _showNotification(notification);
    }
  }

  /// Maneja clics en notificaciones
  void _handleNotificationClick(RemoteMessage message) {
    // Maneja la acción al hacer clic en una notificación
    print('Notificación clicada: ${message.data}');
  }

  /// Muestra notificaciones locales
  Future<void> _showNotification(RemoteNotification notification) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel', // ID del canal
      'Notificaciones Importantes',
      importance: Importance.high,
      priority: Priority.high,
    );
    const platformDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      notification.hashCode, // ID único
      notification.title,
      notification.body,
      platformDetails,
    );
  }
}
