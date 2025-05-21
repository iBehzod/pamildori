// lib/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  
  // Initialize notification settings for each platform
  Future<void> init() async {
    // Android initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
        
    // iOS initialization
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    // Linux initialization
    final LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(
      defaultActionName: 'Open notification',
      defaultIcon: AssetsLinuxIcon('assets/images/logo.png'),
    );
    
    // Combined initialization settings
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      linux: initializationSettingsLinux,
    );
    
    // Initialize the plugin
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification clicked: ${response.payload}');
      },
    );

    // Request notification permissions for iOS
    if (Platform.isIOS) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
    
    // Request notification permissions for macOS
    if (Platform.isMacOS) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  // Show work session complete notification
  Future<void> showWorkCompleteNotification() async {
    await _showNotification(
      id: 1,
      title: 'Work Session Complete!',
      body: 'Great job! Take a break now.',
      payload: 'work_complete',
    );
  }

  // Show break session complete notification
  Future<void> showBreakCompleteNotification() async {
    await _showNotification(
      id: 2,
      title: 'Break Complete',
      body: 'Ready to get back to work?',
      payload: 'break_complete',
    );
  }

  // Show long break session complete notification
  Future<void> showLongBreakCompleteNotification() async {
    await _showNotification(
      id: 3,
      title: 'Long Break Complete',
      body: 'Hope you feel refreshed! Time to start a new cycle.',
      payload: 'long_break_complete',
    );
  }
  
  // Show custom notification
  Future<void> showCustomNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _showNotification(
      id: 4,
      title: title,
      body: body,
      payload: payload,
    );
  }
  
  // Core notification method
  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    // Android-specific notification details
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'pamildori_channel',
      'Pamildori Notifications',
      channelDescription: 'Notifications for Pamildori app',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Pamildori notification',
      enableLights: true,
      color: Color(0xFFE57373),
      ledColor: Color(0xFFE57373),
      ledOnMs: 1000,
      ledOffMs: 500,
    );
    
    // iOS-specific notification details
    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    // Linux-specific notification details
    const LinuxNotificationDetails linuxNotificationDetails =
        LinuxNotificationDetails(
      urgency: LinuxNotificationUrgency.critical,
      actions: [
        LinuxNotificationAction(
          key: 'open',
          label: 'Open Pamildori',
        ),
      ],
    );
    
    // Combined notification details
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
      linux: linuxNotificationDetails,
    );
    
    // Show the notification
    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}