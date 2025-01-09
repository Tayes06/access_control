import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'video_list_screen.dart';
import 'firebase_options.dart';

/// Fonction globale pour gérer les notifications en arrière-plan
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  _showLocalNotification(message.notification?.title, message.notification?.body);
}

/// Instance des notifications locales
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Configuration des notifications locales
void _configureLocalNotifications() {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

/// Fonction pour afficher une notification locale
Future<void> _showLocalNotification(String? title, String? body) async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
    'high_importance_channel', // ID du canal
    'Notifications Importantes', // Nom du canal
    channelDescription: 'Ce canal est utilisé pour les notifications importantes.',
    importance: Importance.high,
    priority: Priority.high,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('notification'), // Fichier sonore personnalisé
  );

  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);

  await flutterLocalNotificationsPlugin.show(
    0, // ID de la notification
    title ?? 'Alerte sécurité',
    body ?? 'Une nouvelle présence détectée chez vous',
    notificationDetails,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Configurer le handler pour les notifications en arrière-plan
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Configurer les notifications locales
  _configureLocalNotifications();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Configurer Firebase Messaging au démarrage de l'application
    _configureFirebaseMessaging();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Video App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const VideoListScreen(),
    );
  }

  /// Configure Firebase Messaging
  void _configureFirebaseMessaging() {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Demander les permissions pour les notifications (pour iOS)
    messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Obtenir le token FCM pour ce téléphone (facultatif)
    messaging.getToken().then((token) {
      print("Token FCM : $token");
    });

    // Configurer les notifications reçues au premier plan
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Notification reçue au premier plan : ${message.notification?.title}");
      _showLocalNotification(
        message.notification?.title,
        message.notification?.body,
      );
    });

    // Configurer les notifications ouvertes par l'utilisateur
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notification ouverte par l'utilisateur : ${message.notification?.title}");
    });

    // Souscrire au topic "videos" pour recevoir des notifications de nouvelles vidéos
    messaging.subscribeToTopic("videos");
  }
}
