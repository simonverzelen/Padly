import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:padly/core/route/route_constants.dart';
import 'package:padly/core/route/router.dart' as router;
import 'package:padly/features/users/domain/entities/padly_user.dart';
import 'package:padly/features/users/domain/services/user_service.dart';
import 'package:padly/core/theme/app_theme.dart';
import 'package:padly/core/utils/seed_mock_users.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:padly/features/games/data/repositories/sports_repository.dart';
import 'package:app_links/app_links.dart';
import 'package:padly/features/games/domain/services/games_service.dart';

import 'core/config/env.dart';

import 'firebase_options.dart';

final navigatorKey = GlobalKey<NavigatorState>();

// Held at top-level so the subscription is never garbage-collected.
// ignore: unused_element
StreamSubscription<Uri>? _deepLinkSubscription;

void _handleDeepLink(Uri uri) {
  if (uri.scheme == 'padly' &&
      uri.host == 'game' &&
      uri.pathSegments.isNotEmpty) {
    final gameId = uri.pathSegments.first;
    GamesServices().fetchGame(gameId).then((game) {
      if (game == null) return;
      navigatorKey.currentState?.pushNamed(
        gameDetailScreenRoute,
        arguments: {'game': game},
      );
    });
  }
}

// function to listen to background changes
@pragma('vm:entry-point')
Future firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    print("Some notification Received in background...");
  }
}

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Keep the native splash visible while the app initialises.
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Load env file
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  // Pre-warm the sports cache so all screens get instant data.
  unawaited(SportsRepository.instance.getSports());

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

  FirebaseAuth.instance.setLanguageCode('nl');

  if (kDebugMode) {
    //await seedMockUsers();
  }

  /*final _firebaseMessaging = FirebaseMessaging.instance;

  final PushNotifications _pushNotifications =
      PushNotifications(firebaseMessaging: _firebaseMessaging);

  // initialize firebase messaging
  await _pushNotifications.init();

  // initialize local notifications
  // dont use local notifications for web platform
  if (!kIsWeb) {
    await PushNotifications.localNotiInit(navigatorKey);
  }

  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundMessage);

  // on background notification tapped
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.notification != null) {
      print("Background Notification Tapped");
      //navigatorKey.currentState!.pushNamed("/message", arguments: message);
    }
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    String payloadData = jsonEncode(message.data);

    if (notification != null && android != null) {
      _pushNotifications.showSimpleNotification(
        notification: notification,
        android: android,
        payload: payloadData,
      );
    }
  });

  // for handling in terminated state
  final RemoteMessage? message = await _firebaseMessaging.getInitialMessage();

  if (message != null) {
    print("Launched from terminated state");
    // Future.delayed(Duration(seconds: 1), () {
    //   navigatorKey.currentState!.pushNamed("/message", arguments: message);
    // });
  }*/

  final UserService userService = UserService();
  PadlyUser? userInfo;
  try {
    userInfo = await userService.getUser();
  } catch (_) {
    // Non-fatal: continue to runApp with no user info; auth gate will redirect.
    userInfo = null;
  }

  //await _pushNotifications.sendMessageNotification("title", "body");

  // All initialisation complete — dismiss the native splash.
  FlutterNativeSplash.remove();

  runApp(
    ProviderScope(
      child: MyApp(userInfo: userInfo),
    ),
  );

  // Deep link handling — iOS & Android
  final appLinks = AppLinks();
  _deepLinkSubscription = appLinks.uriLinkStream.listen(_handleDeepLink);
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final initialUri = await appLinks.getInitialLink();
    if (initialUri != null) _handleDeepLink(initialUri);
  });
}

class MyApp extends StatelessWidget {
  final PadlyUser? userInfo;
  const MyApp({
    super.key,
    required this.userInfo,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final route = currentUser != null
        ? userInfo?.firstName != null && userInfo?.lastName != null
            ? (userInfo?.selectedSports?.isNotEmpty == true)
                ? entryPointScreenRoute
                : selectSportsScreenRoute
            : onbordingScreenRoute
        : notificationPermissionScreenRoute;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Padly: Play More. Search Less',
      theme: AppTheme.darkTheme(context),
      themeMode: ThemeMode.dark,
      onGenerateRoute: router.generateRoute,
      initialRoute: route,
      navigatorKey: navigatorKey,
    );
  }
}
