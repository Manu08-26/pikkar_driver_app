import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase only on mobile platforms (Android/iOS).
  // On web/desktop you can still use API auth.
  if (!kIsWeb) {
    try {
      await Firebase.initializeApp();
      debugPrint('✅ Firebase initialized successfully');
    } catch (e) {
      debugPrint('⚠️ Firebase initialization failed: $e');
    }
  }
  
  runApp(const RapidoApp());
}
