# Android Build Setup for Pamildori

This guide explains how to set up and build the Pamildori app for Android.

## Prerequisites

- Flutter SDK (3.x or newer)
- Android Studio with Android SDK
- Java Development Kit (JDK) 11 or newer

## Setup Steps

### 1. Set Up Android Studio

1. Download and install [Android Studio](https://developer.android.com/studio)
2. During installation, make sure to install:
   - Android SDK
   - Android SDK Platform
   - Android Virtual Device
3. Accept all license agreements when prompted

### 2. Configure Flutter for Android Development

1. Ensure Android Studio is properly installed
2. Run the following command to verify Flutter can find your Android installation:
   ```
   flutter doctor --android-licenses
   ```
3. Accept all licenses when prompted

### 3. Create a Keystore for Signing

For releasing to the Google Play Store, you need a signing keystore:

1. Create a keystore using the `keytool` command:
   ```
   keytool -genkey -v -keystore ~/pamildori.keystore -alias pamildori -keyalg RSA -keysize 2048 -validity 10000
   ```
2. Follow the prompts to set a password and provide details

### 4. Configure App Signing

1. Create a file at `android/key.properties` with your keystore information:
   ```
   storePassword=<your-keystore-password>
   keyPassword=<your-key-password>
   keyAlias=pamildori
   storeFile=<path-to-your-keystore-file>
   ```

2. Update `android/app/build.gradle` to use the keystore for signing:
   ```gradle
   def keystoreProperties = new Properties()
   def keystorePropertiesFile = rootProject.file('key.properties')
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
   }

   android {
       // ... existing config ...

       signingConfigs {
           release {
               keyAlias keystoreProperties['keyAlias']
               keyPassword keystoreProperties['keyPassword']
               storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
               storePassword keystoreProperties['storePassword']
           }
       }

       buildTypes {
           release {
               signingConfig signingConfigs.release
               // ... other release settings ...
           }
       }
   }
   ```

### 5. Configure Firebase for Android

1. Go to the Firebase Console
2. Open your project
3. Add an Android app to your Firebase project:
   - Android package name: `com.example.pamildori` (or your custom package name)
   - App nickname: "Pamildori Android"
   - Debug signing certificate: optional for development
4. Download the `google-services.json` file
5. Place the file in `android/app/`
6. Add the following to your `android/build.gradle`:
   ```gradle
   buildscript {
       dependencies {
           // ... other dependencies
           classpath 'com.google.gms:google-services:4.3.15'
       }
   }
   ```
7. Add the following to your `android/app/build.gradle`:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

### 6. Building the APK

1. Build a release APK:
   ```
   flutter build apk --release
   ```

2. The APK will be generated at `build/app/outputs/flutter-apk/app-release.apk`

### 7. Building App Bundle for Play Store

1. Build an Android App Bundle (preferred for Play Store):
   ```
   flutter build appbundle --release
   ```

2. The bundle will be generated at `build/app/outputs/bundle/release/app-release.aab`

## Testing on Physical Device

1. Enable USB debugging on your Android device:
   - Go to Settings > About phone
   - Tap "Build number" seven times to enable Developer options
   - Go back to Settings > System > Developer options
   - Enable USB debugging

2. Connect your device via USB

3. Run the app on your device:
   ```
   flutter run --release
   ```

## Publishing to Google Play Store

1. Create a [Google Play Developer account](https://play.google.com/console/signup) ($25 one-time fee)

2. Create a new app in the Google Play Console

3. Fill in all required information:
   - App details
   - Store listing
   - Content rating
   - Pricing & distribution

4. Upload your AAB file in the "Production" track (or any other track)

5. Submit for review

## Troubleshooting

- **Build Errors**: Make sure you have the latest Flutter SDK
- **Firebase Integration Issues**: Ensure `google-services.json` is correctly placed
- **Signing Problems**: Double-check keystore configuration 