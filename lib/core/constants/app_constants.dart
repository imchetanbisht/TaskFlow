class AppConstants {
  static const String appName = 'TaskFlow';
  static const String appTagline = 'Lightweight Project & Task Management';
  
  static const int defaultTokenExpirySeconds = 900; // 15 minutes
  static const int defaultRefreshTokenExpirySeconds = 604800; // 7 days

  // Default pagination / limits
  static const int maxRecentProjects = 5;
  static const int maxRecentTasks = 5;
}
