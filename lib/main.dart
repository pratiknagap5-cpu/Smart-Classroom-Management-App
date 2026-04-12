import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'models/student.dart';
import 'models/attendance.dart';
import 'models/fee.dart';
import 'services/auth_service.dart';
import 'services/student_service.dart';
import 'services/attendance_service.dart';
import 'services/fee_service.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  // Note: Ensure google-services.json is added in android/app
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(StudentAdapter());
  Hive.registerAdapter(AttendanceAdapter());
  Hive.registerAdapter(FeeAdapter());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => StudentService()),
        ChangeNotifierProvider(create: (_) => AttendanceService()),
        ChangeNotifierProvider(create: (_) => FeeService()),
      ],
      child: MaterialApp(
        title: 'Smart Classroom Management',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          fontFamily: 'Inter',
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.accent,
            surface: AppColors.surface,
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          // Smoother default page transitions
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: _FadeTransitionBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            },
          ),
          useMaterial3: true,
        ),
        initialRoute: '/',
        // ── onGenerateRoute with fade transitions ────────────────────
        // Replaces the static `routes` map to enable custom transitions
        // on every route change (especially splash → auth).
        onGenerateRoute: (settings) {
          final routes = <String, WidgetBuilder>{
            '/': (_) => const SplashScreen(),
            '/auth': (_) => const AuthWrapper(),
            '/dashboard': (_) => const DashboardScreen(),
            '/login': (_) => const LoginScreen(),
          };

          final builder = routes[settings.name];
          if (builder == null) {
            return null;
          }

          // Splash → auth gets a longer, smoother fade
          if (settings.name == '/auth') {
            return PageRouteBuilder<void>(
              settings: settings,
              transitionDuration: const Duration(milliseconds: 500),
              reverseTransitionDuration: const Duration(milliseconds: 300),
              pageBuilder: (context, animation, secondaryAnimation) {
                return builder(context);
              },
              transitionsBuilder: (context, animation, _, child) {
                return FadeTransition(
                  opacity: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  ),
                  child: child,
                );
              },
            );
          }

          // All other routes use the theme's page transition
          return MaterialPageRoute<void>(
            settings: settings,
            builder: builder,
          );
        },
      ),
    );
  }
}

/// Custom fade transition for Android page navigation.
/// Eliminates the default "slide up" which causes jank when
/// combined with splash screen disposal and heavy init work.
class _FadeTransitionBuilder extends PageTransitionsBuilder {
  const _FadeTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
      child: child,
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  Future<void> initUserBoxes(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    if (!Hive.isBoxOpen(HiveBoxes.students(uid))) {
      await Hive.openBox<Student>(HiveBoxes.students(uid));
    }
    if (!Hive.isBoxOpen(HiveBoxes.attendance(uid))) {
      await Hive.openBox<Attendance>(HiveBoxes.attendance(uid));
    }
    if (!Hive.isBoxOpen(HiveBoxes.fees(uid))) {
      await Hive.openBox<Fee>(HiveBoxes.fees(uid));
    }

    if (!context.mounted) return;
    await Future.wait([
      context.read<StudentService>().init(uid),
      context.read<AttendanceService>().init(uid),
      context.read<FeeService>().init(uid),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          return FutureBuilder(
            future: initUserBoxes(context),
            builder: (context, futureSnapshot) {
              if (futureSnapshot.connectionState == ConnectionState.done) {
                return const DashboardScreen();
              }
              return const Scaffold(
                backgroundColor: AppColors.background,
                body: Center(child: CircularProgressIndicator()),
              );
            },
          );
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
