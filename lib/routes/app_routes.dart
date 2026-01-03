import 'package:flutter/material.dart';
import '../driver/splash_screen.dart';
import '../driver/login_screen.dart';
import '../driver/select_vehicle_screen.dart';
import '../driver/onboard_vehicle_screen.dart';
import '../driver/upload_rc_screen.dart';
import '../driver/profile_info_screen.dart';
import '../driver/home_screen.dart';
import '../driver/earnings_statement_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
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
      selectVehicle: (context) => const SelectVehicleScreen(),
      onboardVehicle: (context) => const OnboardVehicleScreen(),
      uploadRC: (context) => const UploadRCScreen(),
      profileInfo: (context) => const ProfileInfoScreen(),
      home: (context) => const HomeScreen(),
      earningsStatement: (context) => const EarningsStatementScreen(),
    };
  }
}

