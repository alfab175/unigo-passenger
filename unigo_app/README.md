# UNIGO Passenger — GitHub-ready Flutter source

This package is arranged so the Flutter project is at the repository root (no extra `unigo/` folder).

## Build APK from an Android phone

1. Extract this ZIP on your phone.
2. Create an empty GitHub repository.
3. Upload the **contents of this folder** so `pubspec.yaml`, `lib/`, `android/`, and `.github/` are at the repository root.
4. Open **Actions → UNIGO Android APK → Run workflow**.
5. Open the successful workflow run and download the `unigo-passenger-apk` artifact.

## Required before map runtime

Add a GitHub Actions repository secret named `GOOGLE_MAPS_ANDROID_KEY` containing the Android-restricted Google Maps SDK key. Without it, the APK can build but the Google map will not display correctly.

Firebase Android configuration is already included for project `unigo-27b2a` and package `com.unigo.passenger`.

## Important

This is a build-ready source package, not a claim that every external service (Google Maps, Firebase providers, payments, production backend, driver feeds) is already live. Those services require their real credentials, provider configuration, backend/API agreements and release signing.
