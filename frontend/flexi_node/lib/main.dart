import 'package:flutter/material.dart';

import 'screens/choose_role_page.dart';
import 'screens/confirmation_page.dart';
import 'screens/delivery_details_page.dart';
import 'screens/driver_home_page.dart';
import 'screens/flexi_ai_chat_page.dart';
import 'screens/flexi_pickup_offer_page.dart';
import 'screens/landing_page.dart';
import 'screens/nearby_nodes_page.dart';
import 'screens/notifications_page.dart';
import 'screens/orders_page.dart';
import 'screens/partner_dashboard_page.dart';
import 'screens/profile_page.dart';
import 'screens/receiver_home_page.dart';
import 'screens/register_page.dart';
import 'screens/rerouted_navigation_page.dart';
import 'screens/sign_in_page.dart';
import 'screens/tracking_page.dart';
import 'screens/vouchers_page.dart';
import 'screens/real_delivery_map_page.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Dummy options for local emulator
  const emulatorOptions = FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:1234567890:web:1234567890',
    messagingSenderId: '1234567890',
    projectId: 'demo-no-project',
  );

  await Firebase.initializeApp(options: emulatorOptions);

  // Connect to local emulators
  const String host = kIsWeb ? '127.0.0.1' : '10.0.2.2';
  FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  await FirebaseAuth.instance.useAuthEmulator(host, 9099);

  // Anonymous login for Demo
  try {
    await FirebaseAuth.instance.signInAnonymously();
    print("Signed in anonymously: ${FirebaseAuth.instance.currentUser?.uid}");
  } catch (e) {
    print("Error signing in anonymously: $e");
  }

  runApp(const FlexiNodesApp());
}

class FlexiNodesApp extends StatelessWidget {
  const FlexiNodesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flexi Nodes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF006E2F)),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingPage(),
        '/sign-in': (context) => const SignInPage(),
        '/register': (context) => const RegisterPage(),
        '/choose-role': (context) => const ChooseRolePage(),

        '/receiver-home': (context) => const ReceiverHomePage(),
        '/driver-home': (context) => const DriverHomePage(),

        '/ai-chat': (context) => const FlexiAiChatPage(),
        '/tracking': (context) => const TrackingPage(),
        '/flexi-offer': (context) => const FlexiPickupOfferPage(),
        '/nearby-nodes': (context) => const NearbyNodesPage(),
        '/confirmation': (context) => const ConfirmationPage(),
        '/vouchers': (context) => const VouchersPage(),
        '/orders': (context) => const OrdersPage(),

        '/delivery-details': (context) => const DeliveryDetailsPage(),
        '/rerouted-navigation': (context) => const ReroutedNavigationPage(),
        '/real-delivery-map': (context) => const RealDeliveryMapPage(),

        '/notifications': (context) => const NotificationsPage(),
        '/profile': (context) => const ProfilePage(),
        '/partner-dashboard': (context) => const PartnerDashboardPage(),
      },
    );
  }
}
