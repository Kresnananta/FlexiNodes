import 'package:flutter/material.dart';
import 'screens/choose_role_page.dart';
import 'screens/driver_home_page.dart';
import 'screens/landing_page.dart';
import 'screens/receiver_home_page.dart';
void main() {
  runApp(const FlexiNodesApp());
}

class FlexiNodesApp extends StatelessWidget {
  const FlexiNodesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flexi Nodes',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingPage(),
        '/sign-in': (context) => const PlaceholderScreen(title: 'Sign In'),
        '/register': (context) => const PlaceholderScreen(title: 'Register'),
        '/choose-role': (context) => const ChooseRolePage(),
        '/receiver-home': (context) => const ReceiverHomePage(),
        '/driver-home': (context) => const DriverHomePage(),
      },
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}