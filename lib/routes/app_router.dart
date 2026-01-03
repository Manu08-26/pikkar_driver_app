import 'package:go_router/go_router.dart';
import '../core/constants/route_constants.dart';
import '../driver/splash_screen.dart';
import '../driver/login_screen.dart';
import '../driver/otp_verification_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteConstants.splash,
    routes: [
      GoRoute(
        path: RouteConstants.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteConstants.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteConstants.verifyOtp,
        builder: (context, state) {
          final phoneNumber = state.extra as String? ?? '';
          return OTPVerificationScreen(phoneNumber: phoneNumber);
        },
      ),
    ],
  );
}

