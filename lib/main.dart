import 'dart:convert';
import 'package:another_flushbar/flushbar.dart';
import 'package:final_project/core/cubits/language_cubit/languages_cubit.dart';
import 'package:final_project/core/cubits/theme_cubit/theme_cubit.dart';
import 'package:final_project/core/utils/app_router.dart';
import 'package:final_project/core/utils/my_bloc_observer.dart';
import 'package:final_project/core/utils/service_locator.dart';
import 'package:final_project/core/utils/shared_pref.dart';
import 'package:final_project/core/utils/themes.dart';
import 'package:final_project/features/login/presentation/views/login_screen.dart';
import 'package:final_project/features/show_groups/presentation/manager/cubit/get_groups_cubit.dart';
import 'package:final_project/generated/l10n.dart';
import 'package:final_project/push_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'features/myBooks/data/repository/get_book_files_repo/get_book_files_repo_impl.dart';
import 'features/myBooks/presentation/manager/get_files_cubit/get_book_files_cubit.dart';
import 'features/show_files/data/repository/get_files_repo/get_files_repo_impl.dart';
import 'features/show_files/presentation/manager/get_files_cubit/get_files_cubit.dart';
import 'features/show_groups/data/repository/get_groups_repo_impl.dart';
import 'firebase_options.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// function to listen to background changes
Future _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    print("Some notification Received in background...");
  }
}

void showNotification({required String title, required String body}) {
  if (title != null && body != null) {
    Flushbar(
      title: title,
      message: body,
      titleColor: Colors.black,
      messageColor: Colors.grey,
      duration: Duration(seconds: 3),
      barBlur: 10,
      flushbarStyle: FlushbarStyle.FLOATING,
      borderRadius: BorderRadius.circular(15),
      margin: EdgeInsets.all(50),
     backgroundColor: Colors.white.withOpacity(0.8),
      routeBlur: 10,

      flushbarPosition: FlushbarPosition.TOP,
    )..show(navigatorKey.currentContext!);
  } else {
    print("Error: Notification title or body is null.");
  }
}

// Initialize local notifications for mobile platforms
Future<void> initializeLocalNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

// Show a notification when the app is in the foreground (non-web platforms)
Future<void> showLocalNotification(String title, String body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'your_channel_id',
    'your_channel_name',
    channelDescription: 'your_channel_description',
    importance: Importance.high,
    priority: Priority.high,
    ticker: 'ticker',
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
    payload: 'item x',
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // initialize firebase messaging
  await PushNotifications.init();

  // initialize local notifications
  if (!kIsWeb) {
    await initializeLocalNotifications();
  }

  // Listen to background notifications
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

  // on background notification tapped
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.notification != null) {
      print("Background Notification Tapped");
      navigatorKey.currentState!.pushNamed("/message", arguments: message);
    }
  });
// Handling foreground notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      // Check if notification title and body are not null
      String? title = message.notification?.title;
      String? body = message.notification?.body;

      if (title != null && body != null) {
        // Show local notification (non-web)
        if (!kIsWeb) {
          showLocalNotification(title, body);
        } else {
          // Show dialog for web
          showNotification(title: title, body: body);
        }
      } else {
        print("Notification title or body is null.");
      }
    }
  });

  // for handling in terminated state
  final RemoteMessage? message =
      await FirebaseMessaging.instance.getInitialMessage();

  if (message != null) {
    print("Launched from terminated state");
    Future.delayed(Duration(seconds: 1), () {
      navigatorKey.currentState!.pushNamed("/message", arguments: message);
    });
  }

  setupServiceLocator();
  Bloc.observer = MyBlocObserver();
  await initSharedPrefernce();

  // استرجاع القيم المحفوظة في SharedPreferences
  bool isDarkMode = prefs.getBool('isDarkMode') ?? false;
  String savedLanguage = prefs.getString('language') ?? 'en';

  runApp(MyApp(locale: Locale(savedLanguage), isDarkMode: isDarkMode));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.isDarkMode, required this.locale});

  final bool isDarkMode;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              LanguageCubit()..changeLanguage(locale.languageCode),
        ),
        BlocProvider(
          create: (context) => GetFilesCubit(getIt.get<GetFilesRepoImpl>()),
        ),
        BlocProvider(
          create: (context) =>
              GetBookFilesCubit(getIt.get<GetBookFilesRepoImpl>()),
        ),
        BlocProvider(
          create: (context) => ThemeCubit()..toggleTheme(isDarkMode),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BlocBuilder<LanguageCubit, Locale>(
            builder: (context, locale) {
              return MaterialApp(
                navigatorKey: navigatorKey,
                debugShowCheckedModeBanner: false,
                home: MaterialApp.router(
                  routerConfig: AppRouter.router,
                  locale: locale,
                  localizationsDelegates: const [
                    S.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: S.delegate.supportedLocales,
                  debugShowCheckedModeBanner: false,
                  themeMode: themeMode,
                  theme: lightMode,
                  darkTheme: darkTheme,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
