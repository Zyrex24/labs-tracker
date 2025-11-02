class AppConstants {
  // App info
  static const String appName = 'Labs Tracker';
  static const String appVersion = '1.0.0';
  
  // Database
  static const String dbName = 'labs_tracker.db';
  static const int dbVersion = 2;
  
  // Notifications
  static const String notificationChannelId = 'lab_sessions';
  static const String notificationChannelName = 'Lab Sessions';
  static const String notificationChannelDesc = 'Notifications for upcoming lab sessions';
  static const int defaultNotificationWindowHours = 2;
  
  // Backup
  static const String backupFileName = 'labs_tracker_backup.zip';
  static const String backupDataFile = 'data.json';
  static const String backupAttachmentsFolder = 'attachments';
  
  // Settings keys
  static const String settingsKeyNotificationWindow = 'notification_window_hours';
  static const String settingsKeyThemeMode = 'theme_mode';
  static const String settingsKeySampleDataLoaded = 'sample_data_loaded';
  
  // User ID (single local user)
  static const String defaultUserId = 'local_user';
  static const String defaultUserName = 'Student';
  static const String defaultSemester = 'Fall 2024';
}

