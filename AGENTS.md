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
- APK via GitHub Actions workflow `android-apk.yml` (auto-runs on push to main; also manual dispatch). Artifact `unigo-passenger-apk` (release, ~26 MB). ✅ Working as of 2026-08-16.
- Requires secret `GOOGLE_MAPS_ANDROID_KEY` (Android-restricted Maps key). `strings.xml` has placeholder replaced at build time.
- Android manifest is v2 embedding (`flutterEmbedding=2`), adaptive launcher icon (`mipmap-anydpi-v26`), styles + launch_background present.
- No Flutter SDK locally assumed; edits made in source. To run tests locally: `flutter test test/route_service_test.dart`.
- **Toolchain versions (CI must match these for a successful APK build):**
  - Flutter 3.47.0 (Dart 3.13.0) — earlier 3.35.2 fails: plugins need KGP ≥ 2.0 (`compilerOptions{}` DSL), only in Flutter ≥ 3.44.
  - Gradle wrapper 8.14.3 (Flutter 3.47 requires Gradle ≥ 8.14.0). `android/gradle/wrapper/gradle-wrapper.properties`.
  - Android Gradle Plugin 8.13.1 (Flutter 3.47 requires AGP ≥ 8.11.1). Declared in `android/settings.gradle` plugins block.
  - Kotlin Gradle Plugin 2.3.20 (Flutter 3.47 recommends ≥ 2.3.20; resolved plugins declare KGP 2.3.x). Registered as `org.jetbrains.kotlin.android` in `settings.gradle` and applied in `android/app/build.gradle`.
  - `compileSdk 36` (package_info_plus requires SDK 36). `targetSdk 35`, `minSdk 23`.
  - `android/gradle.properties` provides `-Xmx4G -XX:MaxMetaspaceSize=1G` for the Gradle daemon (without it the release build dies with GC thrashing / OOM).
  - `android/settings.gradle` `dependencyResolutionManagement.repositories` includes `https://storage.googleapis.com/download.flutter.io` (Flutter engine embedding `io.flutter:flutter_embedding_release` lives there; with `PREFER_SETTINGS` mode the top-level `build.gradle` repos are ignored, so it MUST be in settings).
  - `android/app/build.gradle` sets `compileOptions` Java 17 + `kotlin.compilerOptions.jvmTarget = JVM_17` (otherwise Java=1.8 vs Kotlin=17 mismatch fails `compileReleaseKotlin`).

## Conventions
- Turkish UI strings.
- Compact code style (one-liner widgets common in repo).
- Services injected with optional `FirebaseFirestore`/`FirebaseAuth` for testability.

## 2026-08-19 — v1.9.2 (thoughts + news rebuilt with bug fixes)
- **IMPORTANT incident**: the previous session built "v1.9.1" (versionCode 16) entirely in its runtime and never pushed; that session broke and the source was LOST. v1.9.1 had: flutter_map migration, 8-language i18n, stations, news, thoughts, ride tracking/history, settings screen, premium upgrade flow, Inter fonts. ALWAYS PUSH WORK TO GITHUB at the end of every session.
- Rebuilt on top of main (still google_maps_flutter): `thoughts` feed (share appends; like = one-per-user Firestore transaction over `likedBy` + `likeCount`, tap again to unlike; delete own; report others), `news` feed (⋮ menu: Kaydet via SharedPreferences / Şikayet et → `news_reports`; inline ad card every 3rd article; interstitial ad sheet every 3rd article open; local fallback articles when `news` collection is empty), Apple-style `AppleSegmentedControl`, `AdCard` + `defaultAdCreatives`, Inter fonts (400-800), `formatTimeAgo` util. Home bottom sheet is now `FeedSheet` with tabs [Araçlar|Haberler|Düşünceler]; ad carousel hidden unless tab==0.
- Firestore rules added: `thoughts` (like-fields-only updates for non-authors), `news` (admin write), `thought_reports`, `news_reports`. **Rules must be published in Firebase console** (no deploy from CI).
- Version bumped to 1.9.2+17 to continue from the lost 1.9.1(16).
- Local toolchain for verify: Flutter 3.47.0 at /tmp/flutter (`flutter analyze lib/`, `flutter test`) — SDK is NOT committed.

## 2026-08-22 — Release signing fixed ("invalid package" errors)
- v1.9.2 wouldn't install over v1.9.1: release builds without a signingConfig get signed with each machine's random debug key, and Android rejects updates with a different signer. We now restore a real keystore in CI from secrets (`UNIGO_RELEASE_KEYSTORE_B64`, `UNIGO_KEYSTORE_PASSWORD`, `UNIGO_KEY_PASSWORD`, `UNIGO_KEY_ALIAS`) → `android/key.properties` → `android/unigo-release.jks`; `build.gradle` uses it when present, else falls back to debug. **Permanent signing keys**: local keystore at /tmp/unigo-release.jks (regeneratable but then everyone must reinstall again), passwords only in secrets.
- The first install must be a fresh install (uninstall old UNIGO once); after that updates will install seamlessly.
- `android/key.properties` and `android/*.jks` are git-ignored.
