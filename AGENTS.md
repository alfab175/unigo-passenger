# UNIGO Passenger — Repository Memory

## Project
- **Repo**: `alfab175/unigo-passenger` (GitHub, public). Clone with `GITHUB_TOKEN`/`gh`.
- **Type**: Flutter passenger app (`com.unigo.passenger`), Firebase project `unigo-27b2a`.
- **Source layout**: repo root has `pubspec.yaml`, `lib/`, `android/`, `.github/workflows/android-apk.yml`.

## Vision / Business Model (per founder)
1. **Aggregator**: all ride apps (Martı, BiTaksi, Uber...) in one place. User finds the closest taxi across providers without installing each app. Driver registered in 2 providers shown only once (dedup).
2. **Revenue #1 — In-app ads**: carousel ads on home screen (non-intrusive, swipeable, scroll past).
3. **Revenue #2 — Per-call service fee**: route ≥2 km = ₺25, <2 km = ₺20. If user can't pay now → recorded as debt, charged on next balance top-up; if unpaid → account blocked.
4. **Revenue #3 — Premium subscription**: ₺250/month unlimited calls (long-ride fee discounted).
5. **Pre-call fare estimate**: based on route distance, show MAXIMUM legal fare the driver may charge so user knows cost before calling and can defend against overcharging.
6. **Ride tracking**: live route tracking; show expected fare during ride.
7. **Driver follow / favorites**: "Takip ettiklerim" tab — followed drivers with live distance (m/km) + call button.
8. **Reviews**: user rates driver after ride.
9. **B2B partnerships**: need official API from providers; marketplace/affiliate legal framing ("carrier is responsible, we are marketplace").

## Current Implementation Status
- **Auth**: Firebase auth, Google sign-in, auth_state gate → MainShell. ✅
- **MainShell**: bottom nav — Home (Ara), Profile, Premium. ✅
- **Home** (`lib/screens/home/home_screen.dart`): REAL `GoogleMap` with tap-to-mark, green polyline route, collapsible left (drivers) / right (diger) side panels, ad carousel (hidden when a panel is open), proximity filter (default 5 km, configurable via `AppConfig.defaultProximityKm`), favorites pinned to top, sort by distance/price/rating. ✅
- **Services**: `driver_service`, `ride_service`, `auth_service`, `profile_service`, `settings_service`, `route_service` (geocoding + Haversine distance + polyline decode), `favorite_service` (SharedPreferences).
- **Widgets**: `driver_side_panel` (collapsible), `driver_avatar`, `ad_carousel`, `unigo_logo`, `primary_button`.
- **Models**: driver (with `distanceKm`, `isFavorite`), unigo_user, app_settings (premium/standard ride fee fields).
- **Config** (`lib/core/config.dart`): `defaultProximityKm=5.0`, `serviceFeeShort=20` (<2km), `serviceFeeLong=25` (≥2km), `premiumMonthlyTry=250` — matches founder vision.
- **Tests**: `test/route_service_test.dart` — distance/parse/format (7 tests, passing).
- **Lint**: `flutter analyze lib/` — no errors/warnings (only 4 prefer_const info hints on Positioned widgets that depend on runtime state).

## Known Gaps vs Vision
- Google Map requires `GOOGLE_MAPS_ANDROID_KEY` secret at build/runtime (map renders blank otherwise).
- No debt handling / blocking / payment integration.
- Premium subscription flow is static (PremiumScreen) — no IAP/Play Billing.
- No live ride tracking UI / fare-during-ride.
- Reviews/ratings submission UI not yet built.

## Build
- APK via GitHub Actions workflow `android-apk.yml` (auto-runs on push to main; also manual dispatch). Artifact `unigo-passenger-apk`.
- Requires secret `GOOGLE_MAPS_ANDROID_KEY` (Android-restricted Maps key). `strings.xml` has placeholder replaced at build time.
- Android manifest is v2 embedding (`flutterEmbedding=2`), adaptive launcher icon (`mipmap-anydpi-v26`), styles + launch_background present.
- No Flutter SDK locally assumed; edits made in source. To run tests locally: `flutter test test/route_service_test.dart`.

## Conventions
- Turkish UI strings.
- Compact code style (one-liner widgets common in repo).
- Services injected with optional `FirebaseFirestore`/`FirebaseAuth` for testability.
