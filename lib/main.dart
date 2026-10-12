import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_theme.dart';
import 'core/services/notification_service.dart';

import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/home/screens/main_navigation_shell.dart';

import 'features/attendance_approval/providers/attendance_provider.dart';
import 'features/attendance_approval/providers/approval_provider.dart';
import 'features/leave_requests/providers/leave_request_provider.dart';
import 'features/department_tasks/providers/task_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo hệ thống thông báo nội bộ
  await NotificationService.instance.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initAuth()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => ApprovalProvider()),
        ChangeNotifierProvider(create: (_) => LeaveRequestProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: const HrmApp(),
    ),
  );
}

class HrmApp extends StatelessWidget {
  const HrmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ASOFT HRM - Company Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (auth.isLoggedIn) {
            return const MainNavigationShell();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
