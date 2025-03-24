import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const SocietyManagementApp());
}

class SocietyManagementApp extends StatelessWidget {
  const SocietyManagementApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Society Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
} 