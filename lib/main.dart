import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/routes.dart';
import 'core/theme.dart';
import 'provider/providers.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/dashboard/dashboard_router.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/ticket/ticket_list_screen.dart';
import 'screens/ticket/ticket_detail_screen.dart';
import 'screens/ticket/create_ticket_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/notification/notification_screen.dart';
import 'screens/admin/manage_user_screen.dart';
import 'screens/settings/setting_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Nonaktifkan fetch font dari internet (pakai font cache lokal)
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TicketProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => UserManagementProvider()),
      ],
      child: const AppView(),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Ticketing Helpdesk',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash:         (_) => const SplashScreen(),
        AppRoutes.login:          (_) => const LoginScreen(),
        AppRoutes.register:       (_) => const RegisterScreen(),
        AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
        AppRoutes.dashboard:      (_) => const DashboardRouter(),
        AppRoutes.ticketList:     (_) => const TicketListScreen(),
        AppRoutes.ticketDetail:   (_) => const TicketDetailScreen(),
        AppRoutes.createTicket:   (_) => const CreateTicketScreen(),
        AppRoutes.notification:   (_) => const NotificationScreen(),
        AppRoutes.profile:        (_) => const ProfileScreen(),
        AppRoutes.settings:       (_) => const SettingScreen(),
        AppRoutes.manageUsers:    (_) => const ManageUsersScreen(),
      },
    );
  }
}