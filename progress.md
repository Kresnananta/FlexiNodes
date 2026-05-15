# FlexiNode Project Progress

## Status: Frontend-Firestore Integration Phase

This document tracks the migration of FlexiNode from a hardcoded demo flow toward a Firebase Production-backed demo using Cloud Functions, Firestore, and Flutter Web.

---

## Completed Tasks

### Backend (Cloud Functions & Express)
- [x] Migrated backend logic to Firebase Cloud Functions v2.
- [x] Deployed backend to Firebase project `flexi-nodes`.
- [x] Configured Cloud Run permissions for the `api` function so Flutter Web can call the public API.
- [x] Integrated Gemini through `@google/generative-ai`.
- [x] Added REST endpoints for delivery list, node list, traffic simulation, offer acceptance, and AI chat.
- [x] Added autonomous Firestore trigger for delivery delay detection and reroute offer generation.

### Firestore Data & Rules
- [x] Created Firestore production data structure for `users`, `drivers`, `nodes`, `deliveries`, `AI_message`, and `offers`.
- [x] Exported the current Firestore structure to `backend/firestore-export.json`.
- [x] Deployed Firestore rules allowing authenticated demo clients to read/write delivery, offer, and chat data.
- [x] Updated and deployed Firestore rules so the frontend can read `users` and `drivers` for receiver/driver profiles.
- [x] Updated Firestore rules to allow authenticated demo clients to update only driver live-location fields (`currentLocation`, `lastLocationUpdatedAt`) on `drivers/{driverId}`.
- [x] Created the composite index needed by the AI chat history query.

### Frontend Core Integration
- [x] Updated `demo_delivery_store.dart` to use the production Cloud Run URL `https://api-mw5zqvl2rq-uc.a.run.app`.
- [x] Fixed the previous API URL typo (`mw5zqv12rq` -> `mw5zqvl2rq`).
- [x] Removed automatic dummy data seeding from the frontend so it no longer overwrites production Firestore data.
- [x] Integrated realtime Firestore listeners for:
  - `deliveries`
  - `nodes`
  - `offers`
  - `AI_message`
  - `users`
  - `drivers`
- [x] Updated chat listener to query by `deliveryId`, so AI system messages without `receiverId` are still shown.
- [x] Added robust timestamp/date parsing to avoid fragile Firestore Web casting.
- [x] Added dynamic node list handling, distance calculation, voucher display, and selected-node state from Firestore.

### Frontend User/Receiver Pages
- [x] Replaced hardcoded receiver home data with Firestore-backed state.
- [x] Integrated dynamic receiver name, order ID, delivery status, delay, estimated arrival, and voucher status.
- [x] Updated `Orders` page to render delivery summaries from Firestore.
- [x] Updated `Notifications` page to derive notifications from offer state, voucher state, and `AI_message`.
- [x] Updated `Vouchers` page to show real voucher amount and voucher code from Firestore offers.
- [x] Updated `Profile` page to read receiver profile, email, active order, and home coordinates.
- [x] Updated `Tracking`, `Delivery Details`, and `Confirmation` pages to remove remaining static package/user/driver text.

### Frontend Maps & Partner/Driver Pages
- [x] Updated nearby nodes page to use Firestore node data instead of `availableNodes`.
- [x] Updated live route preview and real route map to use Firestore coordinates for driver, receiver, and selected node.
- [x] Added distinct map marker shapes/colors for driver, receiver, and mitra pickup node.
- [x] Added driver live-location publishing from phone GPS to Firestore every 7 seconds.
- [x] Added realtime driver document listener so receiver/user maps can update the driver marker from `drivers/{driverId}.currentLocation`.
- [x] Throttled route recalculation to about every 30 seconds so marker movement remains realtime without calling Google Routes API on every location update.
- [x] Updated driver header and partner handover timeline to use dynamic store data.
- [x] Added partner dashboard package summary cards for `Paket di Toko`, `Menunggu Diambil`, and `Sedang Diantar`.
- [x] Added `Daftar Penitipan` on the partner dashboard using rerouted/stored/completed package summaries.
- [x] Replaced separate partner scan/show actions with a unified `Scan / Show QR` flow that can be swiped between scanner and mitra QR display.
- [x] Removed partner dashboard shortcuts for `Show Driver QR` and `Show Receiver QR`; those QR pages remain available from their own roles.
- [x] Updated the partner scanner to accept both driver drop-off QR and customer pickup QR in one mode.
- [x] Added driver-side `Scan Mitra QR` handover action from Driver Home, Delivery Details, and Real Route Map.
- [x] Updated mitra QR processing so driver scans of `mitra_node` move the package to `delivered_to_node`.
- [x] Kept customer pickup verification secured with both `orderId` matching and OTP validation.
- [x] Updated receiver-facing `delivered_to_node` label to `Tiba di Mitra`.

### Verification
- [x] Ran `dart format` on modified Flutter files.
- [x] Ran `flutter analyze`; no new compile errors were introduced. Remaining output is existing lint/deprecation info.
- [x] Ran `flutter build web` successfully.
- [x] Previously deployed Firestore rules successfully for the profile/read-access and demo data flows.
- [x] Verified in the in-app browser on `http://localhost:5174/#/receiver-home`.
- [x] Verified the latest web build on local static server `http://localhost:5175/#/partner-dashboard`.
- [x] Verified the latest map marker/live-location build with `flutter build web`; local static server available at `http://localhost:5176/#/driver-home`.
- [x] Confirmed user pages now show Firestore data such as `Budiman`, `SD-1001`, `FLX-DISCOUNT_5-4298`, profile email, and Firestore delivery summaries.

---

## In Progress / Current Notes

### Browser Cache / Service Worker
- [ ] `localhost:5173` may still show an older Flutter bundle because of cache/service worker state.
- [ ] Current verified development URL is `http://localhost:5174/#/receiver-home`.
- [ ] Latest partner/QR work was verified from the built web bundle on `http://localhost:5175/#/partner-dashboard`; hot-reload dev ports such as `localhost:58385` may need refresh/restart to pick up the newest bundle.
- [ ] Latest map/live-location changes were built successfully; deploy the latest Firestore rules before testing phone GPS writes against Firebase production.

### End-to-End Flow
- [ ] Full E2E flow still needs a final manual pass:
  1. Driver taps "Simulate Heavy Traffic".
  2. Backend/Gemini creates pending offer.
  3. Receiver sees offer and accepts pickup.
  4. Driver route changes to selected node.
  5. Driver opens live map on phone and confirms `drivers/{driverId}.currentLocation` updates every few seconds.
  6. Receiver/user map shows the driver marker moving from the realtime driver document.
  7. Driver scans mitra QR to hand over the package and set status to `delivered_to_node` / `Tiba di Mitra`.
  8. Customer shows pickup QR to mitra.
  9. Mitra scans customer pickup QR and verifies `orderId` + OTP.
  10. Delivery reaches `completed`.

### Security & Cleanup
- [ ] Firestore rules are still demo-friendly. Restrict them before handover or production use.
- [ ] Several existing lint infos remain, mostly `withOpacity` deprecation and older UI cleanup items.
- [ ] Some fallback demo constants still exist in `DemoDeliveryStore` as offline/fallback defaults, but primary UI state now comes from Firestore.

---

## Next Steps

1. Deploy the latest Firestore rules so driver phone GPS can write live-location updates.
2. Run the full E2E reroute, live driver-location, and QR handover test against Firebase production data.
3. Clear or unregister the old Flutter service worker for `localhost:5173`, or standardize development on a fresh port.
4. Tighten Firestore rules by role (`receiver`, `driver`, `partner`) before final demo handover.
5. Replace remaining fallback/demo-only labels where a production field should exist, especially formatted addresses and richer delivery metadata.
6. Clean existing Flutter lint/deprecation info when the integration flow is stable.
7. Add manual QA screenshots or short screen recordings for live driver location, driver scan mitra QR, and partner pickup verification flow.

---

*Last updated: May 16, 2026*
