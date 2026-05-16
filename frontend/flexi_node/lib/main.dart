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
import 'screens/qr_scanner_page.dart';
import 'screens/driver_qr_page.dart';
import 'screens/receiver_qr_page.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // REAL FIREBASE CONFIG
  // Use this for deployed Firebase / real phone testing.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // FIREBASE EMULATOR CONFIG
  // Only use this if you are testing with Firebase Emulator locally.
  //
  // 1. Uncomment this import if needed:
  // import 'package:cloud_firestore/cloud_firestore.dart';
  //
  // 2. Uncomment this import if needed:
  // import 'package:flutter/foundation.dart';
  //
  // 3. Then uncomment this block:
  //
  // const String host = kIsWeb ? '127.0.0.1' : '10.0.2.2';
  //
  // FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  // await FirebaseAuth.instance.useAuthEmulator(host, 9099);
  //
  // Note:
  // - 10.0.2.2 works for Android Emulator.
  // - For a real phone, use your laptop Wi-Fi IP instead, for example:
  //   const String host = '192.168.1.10';
  // - Start emulator with:
  //   firebase emulators:start --host 0.0.0.0

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

        '/notifications': (context) => const NotificationsPage(),
        '/profile': (context) => const ProfilePage(),
        '/partner-dashboard': (context) => const PartnerDashboardPage(),

        '/driver-qr': (context) => const DriverQrPage(),
        '/receiver-qr': (context) => const ReceiverQrPage(),
      },

      onGenerateRoute: (settings) {
        if (settings.name == '/qr-scanner') {
          final args = settings.arguments as Map<String, dynamic>?;

          return MaterialPageRoute(
            builder: (context) => QrScannerPage(
              expectedType: args?['expectedType'] as String?,
              title: args?['title'] as String? ?? 'Scan QR',
            ),
          );
        }

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
        return MaterialPageRoute(builder: (context) => const LandingPage());
      },
    );
  }
}
