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
import 'screens/sign_in_page.dart';
import 'screens/tracking_page.dart';
import 'screens/vouchers_page.dart';
import 'screens/real_route_map.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Konfigurasi Firebase Asli untuk flexi-nodes
  const firebaseOptions = FirebaseOptions(
    apiKey: 'AIzaSyDFpk4Rffw3wNnuw--XRw_FeRnh-Z7Y0vM',
    appId: '1:807475730103:web:0c6367e7613e4283ae5f32',
    messagingSenderId: '807475730103',
    projectId: 'flexi-nodes',
    authDomain: 'flexi-nodes.firebaseapp.com',
    storageBucket: 'flexi-nodes.firebasestorage.app',
    measurementId: 'G-V06FPKTNKV',
  );

  await Firebase.initializeApp(options: firebaseOptions);

  // Anonymous login for demo
  try {
    await FirebaseAuth.instance.signInAnonymously();
    debugPrint(
      'Signed in anonymously: ${FirebaseAuth.instance.currentUser?.uid}',
    );
  } catch (e) {
    debugPrint('Error signing in anonymously: $e');
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006E2F),
        ),
      ),
      initialRoute: '/',

      // Normal static routes
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

        '/notifications': (context) => const NotificationsPage(),
        '/profile': (context) => const ProfilePage(),
        '/partner-dashboard': (context) => const PartnerDashboardPage(),
      },

      // Dynamic routes that need arguments
      onGenerateRoute: (settings) {
        if (settings.name == '/real-map' ||
            settings.name == '/real-delivery-map' ||
            settings.name == '/rerouted-navigation') {
          final args = settings.arguments as Map<String, dynamic>?;

          return MaterialPageRoute(
            builder: (context) => RealRouteMapPage(
              mode: args?['mode'] ?? 'receiver',
              usePhoneGpsByDefault: args?['usePhoneGps'] ?? false,
            ),
          );
        }

        return null;
      },

      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const LandingPage(),
        );
      },
    );
  }
}