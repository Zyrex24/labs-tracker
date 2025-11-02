import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../utils/date_utils.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initialize notification service and timezone
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize with callback for notification taps
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for iOS
    await _requestPermissions();

    // Create Android notification channel
    await _createAndroidChannel();

    _initialized = true;
  }

  /// Request notification permissions (iOS)
  Future<void> _requestPermissions() async {
    final plugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (plugin != null) {
      await plugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    final dynamic androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      try {
        await androidPlugin.requestPermission();
      } on NoSuchMethodError {
        try {
          await androidPlugin.requestNotificationsPermission();
        } on NoSuchMethodError {
          // ignore when the underlying platform implementation does not expose
          // either permission request API (older Android versions).
        }
      }
    }
  }

  /// Create Android notification channel
  Future<void> _createAndroidChannel() async {
    const channel = AndroidNotificationChannel(
      'labs_tracker_channel',
      'Lab Sessions',
      description: 'Notifications for upcoming lab sessions',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(channel);
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      // Deep-link to session detail
      // This will be handled by AppRouter.navigateToSession(sessionId)
      // For now, just print the payload
      print('Notification tapped with payload: $payload');
    }
  }

  /// Schedule notification for a lab session
  Future<void> scheduleSessionNotification({
    required String sessionId,
    required String subjectName,
    required DateTime sessionTime,
    required int windowHours,
  }) async {
    if (!_initialized) await initialize();

    // Calculate notification time (windowHours before session)
    final notificationTime = sessionTime.subtract(Duration(hours: windowHours));

    // Only schedule if notification time is in the future
    if (notificationTime.isBefore(DateTime.now())) {
      return;
    }

    final id = sessionId.hashCode;

    const androidDetails = AndroidNotificationDetails(
      'labs_tracker_channel',
      'Lab Sessions',
      channelDescription: 'Notifications for upcoming lab sessions',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      'Lab Session Due',
      '$subjectName session is coming up at ${AppDateUtils.formatTime(sessionTime)}',
      tz.TZDateTime.from(notificationTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: sessionId,
    );
  }

  /// Cancel notification for a session
  Future<void> cancelSessionNotification(String sessionId) async {
    if (!_initialized) await initialize();
    final id = sessionId.hashCode;
    await _notifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    if (!_initialized) await initialize();
    await _notifications.cancelAll();
  }

  /// Show immediate notification (for testing)
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'labs_tracker_channel',
      'Lab Sessions',
      channelDescription: 'Notifications for upcoming lab sessions',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      details,
      payload: payload,
    );
  }
}

