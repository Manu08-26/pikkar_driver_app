import 'package:flutter/material.dart';
import '../driver/home/splash_screen.dart';
import '../driver/auth/login_screen.dart';
import '../driver/auth/login_screen_api.dart';
import '../driver/registration/select_vehicle_screen.dart';
import '../driver/registration/onboard_vehicle_screen.dart';
import '../driver/registration/upload_rc_screen.dart';
import '../driver/registration/profile_info_screen.dart';
import '../driver/home/home_screen.dart';
import '../driver/earnings/earnings_statement_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String loginAPI = '/login-api'; // New API-based login
  static const String otpVerification = '/otp-verification';
  static const String selectVehicle = '/select-vehicle';
  static const String onboardVehicle = '/onboard-vehicle';
  static const String uploadRC = '/upload-rc';
  static const String profileInfo = '/profile-info';
  static const String home = '/home';
  static const String earningsStatement = '/earnings-statement';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      loginAPI: (context) => const LoginScreenAPI(), // New API login
      selectVehicle: (context) => const SelectVehicleScreen(),
      onboardVehicle: (context) => const OnboardVehicleScreen(),
      uploadRC: (context) => const UploadRCScreen(),
      profileInfo: (context) => const ProfileInfoScreen(),
      home: (context) => const HomeScreen(),
      earningsStatement: (context) => const EarningsStatementScreen(),
    };
  }
}

