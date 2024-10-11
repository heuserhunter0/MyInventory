import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();  // Firebase initialization
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue, // You can customize your theme colors
      ),
      initialRoute: '/login', // Start the app at the login screen
      routes: {
        '/login': (context) => LoginScreen(), // Route to login screen
        '/register': (context) => RegisterScreen(), // Route to registration screen
        '/home': (context) => HomeScreen(), // Route to home screen after login
      },
    );
  }
}