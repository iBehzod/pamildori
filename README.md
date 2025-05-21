# Pamildori

A beautiful, feature-rich Pomodoro timer application built with Flutter.

## Features

- Clean, modern UI optimized for focus
- Customizable pomodoro, short break, and long break durations
- Task management with pomodoro tracking
- Sound notifications for different events
- Statistics tracking
- Dark mode support
- Cross-platform (Linux, Android, iOS)

## Building from Source

### Prerequisites

- Flutter SDK (3.x or newer)
- Linux: `clang`, `cmake`, `ninja-build`, `pkg-config`, `libgtk-3-dev`
- Android: Android Studio, Android SDK
- iOS: macOS with Xcode, Apple Developer account

### Cloud Setup (Optional)

For cloud sync functionality, you need to set up Firebase:

1. Create a Firebase project in the [Firebase Console](https://console.firebase.google.com/)
2. Configure Authentication and Firestore
3. Update Firebase configuration in the app

Detailed instructions can be found in [Firebase Setup Guide](docs/firebase_setup.md)

### Linux Build and Installation

1. Clone this repository:
   ```
   git clone https://github.com/yourusername/pamildori.git
   cd pamildori
   ```

2. Get dependencies:
   ```
   flutter pub get
   ```

3. Build for Linux:
   ```
   flutter build linux --release
   ```

4. Install (requires root):
   ```
   sudo ./linux/packaging/install.sh
   ```

5. Launch the app from your application menu or run:
   ```
   pamildori
   ```

### Uninstallation

To uninstall:
```
sudo ./linux/packaging/uninstall.sh
```

### Android Build

1. Set up Android development environment
2. Configure app signing and Firebase
3. Build APK or App Bundle for Google Play Store

Detailed instructions can be found in [Android Setup Guide](docs/android_setup.md)

### iOS Build

1. Set up iOS development environment (requires macOS)
2. Configure code signing and Firebase
3. Build and distribute via App Store or TestFlight

Detailed instructions can be found in [iOS Setup Guide](docs/ios_setup.md)

## Development

### Running in Development Mode

```
flutter run -d linux
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.