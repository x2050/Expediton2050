import 'package:flutter/material.dart';
import 'app.dart';

Future<void> main() async {
  // Initialize Flutter plugin bindings before app startup.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExpeditionApp());
}
