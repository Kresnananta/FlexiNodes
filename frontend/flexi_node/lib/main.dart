import 'package:flutter/material.dart';

import 'screens/choose_role_page.dart';
import 'screens/confirmation_page.dart';
import 'screens/delivery_details_page.dart';
import 'screens/driver_home_page.dart';
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

        '/tracking': (context) => const TrackingPage(),
        '/flexi-offer': (context) => const FlexiPickupOfferPage(),
        '/nearby-nodes': (context) => const NearbyNodesPage(),
        '/confirmation': (context) => const ConfirmationPage(),
        '/vouchers': (context) => const VouchersPage(),
        '/orders': (context) => const OrdersPage(),

        '/delivery-details': (context) => const DeliveryDetailsPage(),
        '/rerouted-navigation': (context) => const ReroutedNavigationPage(),

        '/notifications': (context) => const NotificationsPage(),
        '/profile': (context) => const ProfilePage(),
        '/partner-dashboard': (context) => const PartnerDashboardPage(),
      },
    );
  }
}
