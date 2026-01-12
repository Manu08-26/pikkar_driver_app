import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase is optional (configs are intentionally not committed).
  // If google-services.json / GoogleService-Info.plist are missing, we continue without Firebase.
  try {
    await Firebase.initializeApp();
  } catch (e, st) {
    // Keep running, but log clearly (Firebase Phone OTP requires proper Firebase config).
    print('❌ Firebase.initializeApp failed: $e');
    print(st);
  }

  runApp(const RapidoApp());
}
