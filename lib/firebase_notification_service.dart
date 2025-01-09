import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Initialisation des notifications locales
    var androidInitialize = AndroidInitializationSettings('app_icon'); // Utilise l'icône de l'application
    var initializationSettings = InitializationSettings(android: androidInitialize);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Demande la permission de recevoir des notifications (sur iOS)
    await _firebaseMessaging.requestPermission();

    // Obtenez le token FCM
    String? token = await _firebaseMessaging.getToken();
    print("FCM Token: $token");

    // Gestion des messages en premier plan
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message);
    });

    // Gestion des messages en arrière-plan
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!');
    });

    // Gestion des messages lorsque l'application est complètement fermée
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("Handling a background message: ${message.messageId}");
  }

  // Afficher les notifications locales
  Future<void> _showNotification(RemoteMessage message) async {
    try {
      // Configuration des détails de la notification Android avec un son personnalisé
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'default_channel_id', // ID du canal
        'Default Channel', // Nom du canal
        importance: Importance.high, // Importance élevée pour une notification en haut de l'écran
        priority: Priority.high, // Priorité élevée pour s'assurer que la notification soit visible immédiatement
        sound: RawResourceAndroidNotificationSound('notification_sound'), // Son personnalisé (mettre notification_sound.wav dans le dossier res/raw)
      );
      const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

      // Affichage de la notification avec les détails
      await flutterLocalNotificationsPlugin.show(
        0, // ID de la notification
        message.notification?.title, // Titre de la notification
        message.notification?.body, // Corps de la notification
        platformDetails, // Détails de la notification (son, priorité, etc.)
        payload: 'item x', // Payload pour l'interaction avec la notification (si nécessaire)
      );
    } catch (e) {
      print('Error displaying notification: $e');
    }
  }
}