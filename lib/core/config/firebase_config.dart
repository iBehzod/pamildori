class FirebaseConfig {
  // Firebase Web Config
  static const String apiKey = 'YOUR_FIREBASE_API_KEY';
  static const String authDomain = 'your-project-id.firebaseapp.com';
  static const String projectId = 'your-project-id';
  static const String storageBucket = 'your-project-id.appspot.com';
  static const String messagingSenderId = 'your-messaging-sender-id';
  static const String appId = 'your-app-id';
  
  // Firebase REST API URLs
  static const String signUpUrl = 'https://identitytoolkit.googleapis.com/v1/accounts:signUp';
  static const String signInUrl = 'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword';
  static const String refreshTokenUrl = 'https://securetoken.googleapis.com/v1/token';
  
  // Firestore REST API Base URL
  static String get firestoreBaseUrl => 
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents';
} 