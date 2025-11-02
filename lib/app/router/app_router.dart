import 'package:flutter/material.dart';
import '../main_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  // Route names
  static const String home = '/';
  static const String sessionDetail = '/session';
  static const String subjectDetail = '/subject';
  static const String addSubject = '/add-subject';
  static const String addSession = '/add-session';
  static const String addExam = '/add-exam';
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const MainScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
  
  /// Navigate to session detail by ID (for deep linking from notifications)
  static Future<void> navigateToSession(String sessionId) async {
    final context = navigatorKey.currentContext;
    if (context != null) {
      // Will be implemented when session detail screen is ready
      // Navigator.of(context).pushNamed(sessionDetail, arguments: sessionId);
    }
  }
}

