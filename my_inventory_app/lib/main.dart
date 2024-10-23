import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_item_screen.dart';
import 'screens/edit_item_screen.dart';
import 'screens/item_details_screen.dart';
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
        '/add_item': (context) => AddItemScreen(), // Route to add item screen
        '/edit_item': (context) {  
          final String itemId = ModalRoute.of(context)!.settings.arguments as String;
          return EditItemScreen(itemId: itemId,);
        }, // Route to edit item screen
        '/item_details': (context) {  
          final String itemId = ModalRoute.of(context)!.settings.arguments as String;
          return ItemDetailsScreen(itemId: itemId,);
        }, // Route to item details screen
        '/qr_scanner': (context) => QRViewExample(), // Route to QR scanner screen
      },
    );
  }
}