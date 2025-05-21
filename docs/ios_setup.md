# iOS Build Setup for Pamildori

This guide explains how to set up and build the Pamildori app for iOS.

## Prerequisites

- Flutter SDK (3.x or newer)
- macOS computer (required for iOS development)
- Xcode (latest version recommended)
- Apple Developer account (required for device testing and App Store submission)

## Setup Steps

### 1. Set Up Xcode

1. Download and install [Xcode](https://developer.apple.com/xcode/) from the Mac App Store
2. Launch Xcode and accept the license agreement
3. Install iOS Simulator and required components when prompted
4. Install Xcode command-line tools:
   ```
   sudo xcode-select --install
   ```

### 2. Configure Flutter for iOS Development

1. Run Flutter doctor to check for any iOS-specific issues:
   ```
   flutter doctor
   ```
2. Fix any issues that appear related to iOS development

### 3. Set Up Code Signing

1. Open Xcode
2. Go to Preferences > Accounts
3. Add your Apple ID
4. Close Preferences
5. Open the Flutter project's iOS module in Xcode:
   ```
   open ios/Runner.xcworkspace
   ```
6. Select the "Runner" project in the Project Navigator
7. Select the "Runner" target
8. Go to the "Signing & Capabilities" tab
9. Choose your Team from the dropdown
10. Make sure "Automatically manage signing" is checked

### 4. Configure Firebase for iOS

1. Go to the Firebase Console
2. Open your project
3. Add an iOS app to your Firebase project:
   - iOS bundle ID: `com.example.pamildori` (or your custom bundle ID)
   - App nickname: "Pamildori iOS"
   - App Store ID: can be left blank initially
4. Download the `GoogleService-Info.plist` file
5. Add this file to your Xcode project:
   - Open Xcode with your iOS project
   - Drag the `GoogleService-Info.plist` file into the Runner directory
   - Ensure "Copy items if needed" is checked
   - Add to target "Runner" is checked
   - Click "Finish"

6. Add Firebase SDK using CocoaPods:
   - Ensure your `ios/Podfile` has the correct platform (iOS 12.0 or higher):
     ```ruby
     platform :ios, '12.0'
     ```
   - Add Firebase pods to your Podfile if not auto-added by Flutter Firebase packages

7. Install the pods:
   ```
   cd ios
   pod install
   ```

### 5. Update iOS Info.plist

1. Open `ios/Runner/Info.plist`
2. Update the following values for your app:
   - CFBundleName (display name on home screen)
   - CFBundleIdentifier (should match your bundle ID)
   - Add any required permission descriptions:
     ```xml
     <key>NSMicrophoneUsageDescription</key>
     <string>Pamildori requires microphone access for sound notification features.</string>
     ```

### 6. Building the App

#### Debug Build for Testing

1. Connect your iOS device or use the simulator
2. Run the app in debug mode:
   ```
   flutter run
   ```

#### Release Build

1. Build a release IPA:
   ```
   flutter build ios --release
   ```
2. Open Xcode to archive and distribute the app:
   ```
   open ios/Runner.xcworkspace
   ```
3. In Xcode, select "Product" > "Archive"
4. Once the archive is created, the Xcode Organizer will open
5. Select your archive and click "Distribute App"

## Testing on Physical Device

1. Connect your iOS device via USB
2. Ensure your device is trusted on your Mac
3. Select your device in Xcode
4. Press the Play button (or Run command) in Xcode

## Publishing to the App Store

1. Create an app record in [App Store Connect](https://appstoreconnect.apple.com/)
2. Fill in all required information:
   - App metadata
   - Screenshots
   - App description
   - Keywords
   - Support URL
   - Privacy policy URL

3. Upload your build from Xcode Organizer:
   - Select your archive
   - Click "Distribute App"
   - Select "App Store Connect"
   - Follow the prompts to upload

4. Submit for review in App Store Connect:
   - Select your uploaded build in the "Build" section
   - Complete the "App Review Information" section
   - Click "Submit for Review"

## TestFlight Distribution

To beta test your app before App Store release:

1. Upload a build to App Store Connect as described above
2. Go to the "TestFlight" tab in App Store Connect
3. Add internal or external testers
4. External testers will need review approval from Apple

## Troubleshooting

- **Code Signing Issues**: Ensure your Apple Developer account is active and properly configured in Xcode
- **Pod Install Problems**: Try deleting `Podfile.lock` and running `pod install` again
- **Build Errors**: Make sure you have the latest Flutter SDK and Xcode
- **Firebase Integration Issues**: Verify that the `GoogleService-Info.plist` file is correctly added to your project
- **Device Testing Problems**: Ensure your iOS device is running a compatible iOS version 