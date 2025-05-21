import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/auth_model.dart';
import '../core/constants/app_constants.dart';
import 'storage_service.dart';
import 'firebase_rest_service.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

class AuthService {
  final StorageService _storageService;
  final String _baseUrl = AppConstants.apiBaseUrl;
  FirebaseRestService? _firebaseRestService;
  AuthData? _currentAuth;
  
  AuthService(this._storageService) {
    _init();
    
    // On Linux, initialize Firebase REST service
    if (Platform.isLinux) {
      _firebaseRestService = FirebaseRestService();
    }
  }
  
  void _init() {
    _currentAuth = _storageService.getAuthData();
  }
  
  bool get isAuthenticated => _currentAuth != null && !_currentAuth!.isExpired;
  
  User? get currentUser => _currentAuth?.user;
  
  String? get token => _currentAuth?.accessToken;
  
  Future<User> signIn(String email, String password) async {
    // On Linux, use Firebase REST API
    if (Platform.isLinux && _firebaseRestService != null) {
      try {
        final authData = await _firebaseRestService!.signInWithEmailPassword(email, password);
        await _storageService.saveAuthData(authData);
        _currentAuth = authData;
        return authData.user;
      } catch (e) {
        throw AuthException(e.toString());
      }
    } else {
      // Original implementation for other platforms
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl${AppConstants.apiAuthEndpoint}/signin'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'password': password,
          }),
        );
        
        if (response.statusCode != 200) {
          throw AuthException(_parseErrorResponse(response));
        }
        
        final authData = AuthData.fromJson(jsonDecode(response.body));
        await _storageService.saveAuthData(authData);
        _currentAuth = authData;
        return authData.user;
      } catch (e) {
        if (e is AuthException) rethrow;
        throw AuthException('Failed to sign in: ${e.toString()}');
      }
    }
  }
  
  Future<User> signUp(String name, String email, String password) async {
    // On Linux, use Firebase REST API
    if (Platform.isLinux && _firebaseRestService != null) {
      try {
        final authData = await _firebaseRestService!.signUpWithEmailPassword(email, password, name);
        await _storageService.saveAuthData(authData);
        _currentAuth = authData;
        return authData.user;
      } catch (e) {
        throw AuthException(e.toString());
      }
    } else {
      // Original implementation for other platforms
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl${AppConstants.apiAuthEndpoint}/signup'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': name,
            'email': email,
            'password': password,
          }),
        );
        
        if (response.statusCode != 200 && response.statusCode != 201) {
          throw AuthException(_parseErrorResponse(response));
        }
        
        final authData = AuthData.fromJson(jsonDecode(response.body));
        await _storageService.saveAuthData(authData);
        _currentAuth = authData;
        return authData.user;
      } catch (e) {
        if (e is AuthException) rethrow;
        throw AuthException('Failed to sign up: ${e.toString()}');
      }
    }
  }
  
  Future<void> signOut() async {
    await _storageService.clearAuthData();
    _currentAuth = null;
  }
  
  Future<bool> refreshToken() async {
    if (_currentAuth == null) return false;
    
    // On Linux, use Firebase REST API
    if (Platform.isLinux && _firebaseRestService != null) {
      try {
        final authData = await _firebaseRestService!.refreshToken(
          _currentAuth!.refreshToken,
          _currentAuth!.user,
        );
        await _storageService.saveAuthData(authData);
        _currentAuth = authData;
        return true;
      } catch (e) {
        debugPrint('Failed to refresh token: ${e.toString()}');
        return false;
      }
    } else {
      // Original implementation for other platforms
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl${AppConstants.apiAuthEndpoint}/refresh'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'refreshToken': _currentAuth!.refreshToken,
          }),
        );
        
        if (response.statusCode != 200) {
          return false;
        }
        
        final authData = AuthData.fromJson(jsonDecode(response.body));
        await _storageService.saveAuthData(authData);
        _currentAuth = authData;
        return true;
      } catch (e) {
        debugPrint('Failed to refresh token: ${e.toString()}');
        return false;
      }
    }
  }
  
  Future<User> updateUserProfile({
    String? name,
    String? photoUrl,
  }) async {
    _ensureAuthenticated();
    
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl${AppConstants.apiUsersEndpoint}/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_currentAuth!.accessToken}',
        },
        body: jsonEncode({
          if (name != null) 'name': name,
          if (photoUrl != null) 'photoUrl': photoUrl,
        }),
      );
      
      if (response.statusCode != 200) {
        throw AuthException(_parseErrorResponse(response));
      }
      
      // Update user data in the stored auth data
      final userData = jsonDecode(response.body);
      final updatedUser = User.fromJson(userData);
      
      final updatedAuth = AuthData(
        accessToken: _currentAuth!.accessToken,
        refreshToken: _currentAuth!.refreshToken,
        expiresAt: _currentAuth!.expiresAt,
        user: updatedUser,
      );
      
      await _storageService.saveAuthData(updatedAuth);
      _currentAuth = updatedAuth;
      return updatedUser;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Failed to update profile: ${e.toString()}');
    }
  }
  
  void _ensureAuthenticated() {
    if (!isAuthenticated) {
      throw AuthException('You need to sign in to perform this action.');
    }
  }
  
  String _parseErrorResponse(http.Response response) {
    try {
      final errorBody = jsonDecode(response.body);
      return errorBody['message'] ?? 'Authentication failed';
    } catch (_) {
      return 'Authentication failed (Status: ${response.statusCode})';
    }
  }
  
  // For development and debugging - creates a mock user when API is not available
  Future<User> createMockUser(String name, String email) async {
    final user = User(
      id: 'mock-user-id',
      name: name,
      displayName: name,
      email: email,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
    
    final expiryDate = DateTime.now().add(const Duration(days: 30));
    
    final authData = AuthData(
      accessToken: 'mock-token',
      refreshToken: 'mock-refresh-token',
      expiresAt: expiryDate,
      user: user,
    );
    
    await _storageService.saveAuthData(authData);
    _currentAuth = authData;
    return user;
  }
}