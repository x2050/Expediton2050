import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'theme/expedition_theme.dart';

class ExpeditionApp extends StatelessWidget {
  const ExpeditionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expedition Aurélio',
      debugShowCheckedModeBanner: false,
      theme: ExpeditionTheme.light(),
      home: const HomeScreen(),
    );
  }
}
