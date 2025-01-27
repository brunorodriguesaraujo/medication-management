import 'package:flutter/material.dart';
import 'package:medicationmanagement/notification/notification_service.dart';
import 'home/home_page.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> checkExactAlarmPermission() async {
  await Permission.scheduleExactAlarm.request();
  await Permission.notification.request();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await checkExactAlarmPermission();
  NotificationService().initNotification();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciador de Medicamentos',
      locale: const Locale('pt', 'BR'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(title: 'Gerenciador de Medicamentos'),
    );
  }
}
