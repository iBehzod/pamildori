import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/auth_model.dart'; // Add import for AuthData
import '../core/constants/app_constants.dart';
import '../core/config/firebase_config.dart';

class FirebaseRestService {
  // Firebase API endpoints
  final String _apiKey = FirebaseConfig.apiKey;
  final String _signUpUrl = FirebaseConfig.signUpUrl;
  final String _signInUrl = FirebaseConfig.signInUrl;
  final String _refreshTokenUrl = FirebaseConfig.refreshTokenUrl;
  final String _firestoreBaseUrl = FirebaseConfig.firestoreBaseUrl;
  
  // Sign up with email and password
  Future<AuthData> signUpWithEmailPassword(String email, String password, String name) async {
    try {
      final response = await http.post(
        Uri.parse('$_signUpUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode != 200) {
        throw _handleAuthError(responseData);
      }
      
      // Create user data in Firestore
      final userId = responseData['localId'];
      final user = User(
        id: userId,
        name: name,
        displayName: name,
        email: email,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      
      await _createUserDocument(user, responseData['idToken']);
      
      // Return AuthData
      return _createAuthData(responseData, user);
    } catch (e) {
      rethrow;
    }
  }
  
  // Sign in with email and password
  Future<AuthData> signInWithEmailPassword(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_signInUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode != 200) {
        throw _handleAuthError(responseData);
      }
      
      // Get user data from Firestore
      final userId = responseData['localId'];
      final user = await _getUserDocument(userId, responseData['idToken']);
      
      // Update last login time
      await _updateLastLogin(userId, responseData['idToken']);
      
      // Return AuthData
      return _createAuthData(responseData, user);
    } catch (e) {
      rethrow;
    }
  }
  
  // Refresh token
  Future<AuthData> refreshToken(String refreshToken, User currentUser) async {
    try {
      final response = await http.post(
        Uri.parse('$_refreshTokenUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
        }),
      );
      
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode != 200) {
        throw Exception('Failed to refresh token');
      }
      
      // Create new auth data with refreshed token
      final expiresIn = int.parse(responseData['expires_in']);
      final expiryDate = DateTime.now().add(Duration(seconds: expiresIn));
      
      return AuthData(
        accessToken: responseData['id_token'],
        refreshToken: responseData['refresh_token'],
        expiresAt: expiryDate,
        user: currentUser,
      );
    } catch (e) {
      rethrow;
    }
  }
  
  // Create user document in Firestore
  Future<void> _createUserDocument(User user, String idToken) async {
    try {
      final url = '$_firestoreBaseUrl/users/${user.id}';
      
      await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'fields': {
            'name': {'stringValue': user.name},
            'displayName': {'stringValue': user.displayName},
            'email': {'stringValue': user.email},
            'createdAt': {'timestampValue': user.createdAt.toIso8601String()},
            'lastLoginAt': {'timestampValue': user.lastLoginAt.toIso8601String()},
            'isPremium': {'booleanValue': false},
          }
        }),
      );
    } catch (e) {
      debugPrint('Error creating user document: $e');
    }
  }
  
  // Get user document from Firestore
  Future<User> _getUserDocument(String userId, String idToken) async {
    try {
      final url = '$_firestoreBaseUrl/users/$userId';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to get user data');
      }
      
      final responseData = jsonDecode(response.body);
      final fields = responseData['fields'];
      
      return User(
        id: userId,
        name: fields['name']['stringValue'],
        displayName: fields['name']['stringValue'],
        email: fields['email']['stringValue'],
        createdAt: DateTime.parse(fields['createdAt']['timestampValue']),
        lastLoginAt: DateTime.parse(fields['lastLoginAt']['timestampValue']),
      );
    } catch (e) {
      // If user document doesn't exist yet, return a basic user
      return User(
        id: userId,
        name: 'User',
        displayName: 'User',
        email: '',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
    }
  }
  
  // Update last login time
  Future<void> _updateLastLogin(String userId, String idToken) async {
    try {
      final url = '$_firestoreBaseUrl/users/$userId';
      
      await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'fields': {
            'lastLoginAt': {'timestampValue': DateTime.now().toIso8601String()},
          }
        }),
      );
    } catch (e) {
      debugPrint('Error updating last login: $e');
    }
  }
  
  // Handle Firebase Auth error responses
  Exception _handleAuthError(Map<String, dynamic> errorResponse) {
    final error = errorResponse['error'];
    if (error == null) {
      return Exception('Authentication failed');
    }
    
    final code = error['message'];
    switch (code) {
      case 'EMAIL_EXISTS':
        return Exception('Email already exists');
      case 'OPERATION_NOT_ALLOWED':
        return Exception('Password sign-in is disabled');
      case 'TOO_MANY_ATTEMPTS_TRY_LATER':
        return Exception('Too many attempts. Try again later');
      case 'EMAIL_NOT_FOUND':
        return Exception('Email not found');
      case 'INVALID_PASSWORD':
        return Exception('Invalid password');
      case 'USER_DISABLED':
        return Exception('User has been disabled');
      default:
        return Exception(error['message'] ?? 'Authentication failed');
    }
  }
  
  // Create AuthData from API response
  AuthData _createAuthData(Map<String, dynamic> responseData, User user) {
    final expiresIn = int.parse(responseData['expiresIn']);
    final expiryDate = DateTime.now().add(Duration(seconds: expiresIn));
    
    return AuthData(
      accessToken: responseData['idToken'],
      refreshToken: responseData['refreshToken'],
      expiresAt: expiryDate,
      user: user,
    );
  }
  
  // Save task data to Firestore
  Future<void> saveTask(String taskId, Map<String, dynamic> taskData, String idToken) async {
    try {
      final url = '$_firestoreBaseUrl/users/${taskData['userId']}/tasks/$taskId';
      
      // Convert task data to Firestore format
      Map<String, dynamic> firestoreData = {
        'fields': {}
      };
      
      taskData.forEach((key, value) {
        if (value is String) {
          firestoreData['fields'][key] = {'stringValue': value};
        } else if (value is int) {
          firestoreData['fields'][key] = {'integerValue': value};
        } else if (value is bool) {
          firestoreData['fields'][key] = {'booleanValue': value};
        } else if (value is DateTime) {
          firestoreData['fields'][key] = {'timestampValue': value.toIso8601String()};
        }
      });
      
      await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode(firestoreData),
      );
    } catch (e) {
      debugPrint('Error saving task: $e');
      rethrow;
    }
  }
  
  // Get tasks from Firestore
  Future<List<Map<String, dynamic>>> getTasks(String userId, String idToken) async {
    try {
      final url = '$_firestoreBaseUrl/users/$userId/tasks';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to get tasks');
      }
      
      final responseData = jsonDecode(response.body);
      
      if (!responseData.containsKey('documents')) {
        return [];
      }
      
      final List<dynamic> documents = responseData['documents'];
      return documents.map<Map<String, dynamic>>((doc) {
        final Map<String, dynamic> result = {'id': doc['name'].split('/').last};
        
        doc['fields'].forEach((key, value) {
          if (value.containsKey('stringValue')) {
            result[key] = value['stringValue'];
          } else if (value.containsKey('integerValue')) {
            result[key] = int.parse(value['integerValue']);
          } else if (value.containsKey('booleanValue')) {
            result[key] = value['booleanValue'];
          } else if (value.containsKey('timestampValue')) {
            result[key] = DateTime.parse(value['timestampValue']);
          }
        });
        
        return result;
      }).toList();
    } catch (e) {
      debugPrint('Error getting tasks: $e');
      return [];
    }
  }
}