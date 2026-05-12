# Flexi Nodes hardcoded demo layer

This adds a local hardcoded demo flow before backend integration.

## Add these files

```text
lib/data/demo_delivery_store.dart
lib/screens/flexi_ai_chat_page.dart
```

## Replace these existing files

```text
lib/screens/driver_home_page.dart
lib/screens/flexi_pickup_offer_page.dart
lib/screens/confirmation_page.dart
lib/screens/rerouted_navigation_page.dart
```

## Update main.dart

Copy the route additions from:

```text
lib/main_hardcoded_demo_example.dart
```

Important new route:

```text
/ai-chat
```

## Demo flow

1. Open Driver Home
2. Press "Simulate Heavy Traffic"
3. Open AI Chat
4. Open Receiver Offer
5. Press "Accept & Pick Up"
6. Open Driver Reroute
7. Press "Confirm Drop-off"
8. View Confirmation
