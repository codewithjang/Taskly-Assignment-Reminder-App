import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/storage_service.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'providers/assignment_provider.dart';
import 'providers/settings_provider.dart';
import 'pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('th_TH', null);

  // ⭐ Initialize Firebase
  await Firebase.initializeApp();

  // ⭐ Initialize Hive storages
  await StorageService.init();  
  await AuthService.init();    

  // ⭐ Initialize Notification
  await NotificationService.initialize();

  runApp(const AssignmentApp());
}

class AssignmentApp extends StatelessWidget {
  const AssignmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()..load()),
        ChangeNotifierProvider(
            create: (_) => AssignmentProvider(StorageService())..load()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Assignment Reminder",
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0D47A1),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
