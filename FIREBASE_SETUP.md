# Firebase setup (safe for sharing)

This repo is configured so you can **use Firebase locally** without committing secrets like:
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

Those files are ignored by `.gitignore`.

## Android

1. Place your Firebase config at:
   - `android/app/google-services.json`

2. Ensure **Firebase Phone Auth is authorized** for your Android app:
   - **Android package name** in Firebase Console must match:
     - `com.pikkar.partner` (this repo’s `applicationId`)
   - Add your **SHA-1** and **SHA-256** to the same Android app in Firebase Console
     - Generate them with:
       - `cd android && ./gradlew signingReport`
   - Download a fresh `google-services.json` after adding SHAs and place it at:
     - `android/app/google-services.json`

2. Run:
   - `flutter clean`
   - `flutter pub get`
   - `flutter run`

If `google-services.json` is missing, the build will still work (Firebase will be skipped).

## iOS (if you build iOS)

1. Add:
   - `ios/Runner/GoogleService-Info.plist`
2. In Xcode, ensure it’s included in the Runner target.

## Recommended: FlutterFire CLI

If you have access to the Firebase project, run:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This will generate platform configs and (optionally) `lib/firebase_options.dart`.

Note: `firebase_options.dart` contains API keys/app IDs; if you want a “safe to share” repo, keep it **out of git** as well.

