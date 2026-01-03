import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (uncomment when Firebase is configured)
  // await Firebase.initializeApp();
  
  runApp(const RapidoApp());
}
