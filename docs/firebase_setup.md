# Firebase Setup for Linux

This guide explains how to set up Firebase for the Pamildori app on Linux.

## Overview

Since Firebase doesn't have a native SDK for Linux, we use Firebase's REST APIs directly:
- Authentication REST API for user management
- Firestore REST API for data storage

## Setup Steps

### 1. Create a Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" and follow the setup wizard
3. Give your project a name (e.g., "Pamildori")
4. Enable Google Analytics if desired, then click "Create project"

### 2. Enable Authentication

1. In the Firebase Console, navigate to "Authentication"
2. Click "Get started"
3. Enable the "Email/Password" sign-in method
4. Save your changes

### 3. Create Firestore Database

1. In the Firebase Console, navigate to "Firestore Database"
2. Click "Create database"
3. Start in production mode (or test mode for development)
4. Choose a database location close to your users
5. Click "Enable"

### 4. Configure Security Rules

1. Navigate to "Firestore Database" > "Rules" tab
2. Update rules to secure your data, for example:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, update, delete: if request.auth != null && request.auth.uid == userId;
      allow create: if request.auth != null;
      
      match /tasks/{taskId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

3. Click "Publish"

### 5. Get Web API Key

1. In the Firebase Console, navigate to Project Settings (gear icon)
2. Under "General" tab, scroll to "Your apps" section
3. Click the Web icon (</>) to add a web app if you haven't already
4. Enter a nickname (e.g., "Pamildori Web")
5. Register the app
6. Copy the configuration values, especially:
   - apiKey
   - authDomain
   - projectId
   - storageBucket
   - messagingSenderId
   - appId

### 6. Update App Configuration

1. Open `lib/core/config/firebase_config.dart`
2. Replace the placeholder values with your actual Firebase configuration:

```dart
class FirebaseConfig {
  // Firebase Web Config
  static const String apiKey = 'YOUR_ACTUAL_API_KEY';
  static const String authDomain = 'your-actual-project-id.firebaseapp.com';
  static const String projectId = 'your-actual-project-id';
  static const String storageBucket = 'your-actual-project-id.appspot.com';
  static const String messagingSenderId = 'your-actual-messaging-sender-id';
  static const String appId = 'your-actual-app-id';
  
  // Rest of the file...
}
```

## Security Considerations

For production use, consider:

1. **API Key Security**: The API key is visible in the app's code. While this is the same for all Firebase web apps, you should restrict its usage in the Firebase Console:
   - Go to Project Settings > API keys
   - Restrict the key to specific domains or IP addresses

2. **Authentication**: Use secure password requirements and consider adding email verification

3. **Database Rules**: Carefully craft your Firestore security rules to prevent unauthorized access

## Testing

After configuration, test the authentication flow:

1. Run the app on Linux
2. Try to sign up with a new account
3. Try to sign in with the created account
4. Verify in the Firebase Console that the user was created

## Troubleshooting

If you encounter issues:

1. **401/403 Errors**: Check that your API key is correct and not restricted
2. **Network Errors**: Ensure your Linux system has internet access
3. **Firebase Errors**: Check the error message returned from Firebase and consult the [Firebase Authentication REST API docs](https://firebase.google.com/docs/reference/rest/auth) 