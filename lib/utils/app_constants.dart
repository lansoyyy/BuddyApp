class AppConstants {
  // App Information
  static const String appName = 'BuddyApp';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = 'https://api.workflowcamera.com';
  static const String apiVersion = 'v1';
  static const String apiTimeout = '30';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String settingsKey = 'app_settings';
  static const String selectedJobKey = 'selected_job';
  static const String cameraSettingsKey = 'camera_settings';

  // Screen Routes
  static const String splashRoute = '/splash';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String forgotPasswordRoute = '/forgot-password';
  static const String dashboardRoute = '/dashboard';
  static const String cameraRoute = '/camera';
  static const String photoReviewRoute = '/photo-review';
  static const String photoTaggingRoute = '/photo-tagging';
  static const String uploadConfirmationRoute = '/upload-confirmation';
  static const String uploadProgressRoute = '/upload-progress';
  static const String workOrderRoute = '/work-order';
  static const String jobDetailsRoute = '/job-details';
  static const String reportGenerationRoute = '/report-generation';
  static const String settingsRoute = '/settings';
  static const String profileRoute = '/profile';

  // Process Stages
  static const List<String> processStages = [
    'Receiving',
    'Inspection',
    'Disassembly',
    'Assembly',
    'Testing',
    'Quality Control',
    'Packaging',
    'Shipping'
  ];

  // User Roles
  static const List<String> userRoles = [
    'Receiver',
    'Office Staff',
    'Technician',
    'QC Inspector',
    'Shipping Staff',
    'Client'
  ];

  // Photo Categories
  static const List<String> photoCategories = [
    'Waybill',
    'Damage',
    'Component',
    'Assembly',
    'Test Result',
    'Quality Check',
    'Packaging',
    'Final Product',
    'Other'
  ];

  // Image Quality Settings
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1080;
  static const double imageQuality = 0.8;
  static const int maxImageSizeMB = 10;

  // Camera Settings
  static const double defaultZoomLevel = 1.0;
  static const double maxZoomLevel = 5.0;
  static const int autoFocusDelay = 2000;
  static const int captureDelay = 500;

  // Upload Settings
  static const int maxConcurrentUploads = 3;
  static const int uploadRetryAttempts = 3;
  static const int uploadTimeoutSeconds = 60;
  static const int chunkSizeKB = 1024;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 8.0;
  static const double cardBorderRadius = 12.0;
  static const double dialogBorderRadius = 16.0;

  // Animation Durations
  static const int shortAnimationDuration = 200;
  static const int mediumAnimationDuration = 300;
  static const int longAnimationDuration = 500;

  // Debounce Times
  static const int searchDebounceMs = 500;
  static const int inputDebounceMs = 300;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache Settings
  static const int maxCacheSize = 50;
  static const Duration cacheExpiration = Duration(hours: 24);

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int maxFileNameLength = 255;
  static const int maxDescriptionLength = 500;
  static const int maxTagLength = 50;
  static const int maxTagsCount = 10;

  // File Formats
  static const List<String> supportedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp',
    'bmp',
    'gif'
  ];

  static const List<String> supportedDocumentFormats = [
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'ppt',
    'pptx'
  ];

  // Error Messages
  static const String networkErrorMessage =
      'Network error. Please check your connection.';
  static const String serverErrorMessage =
      'Server error. Please try again later.';
  static const String unauthorizedMessage =
      'You are not authorized to perform this action.';
  static const String sessionExpiredMessage =
      'Your session has expired. Please login again.';
  static const String genericErrorMessage =
      'Something went wrong. Please try again.';

  // Success Messages
  static const String loginSuccessMessage = 'Login successful!';
  static const String logoutSuccessMessage = 'Logged out successfully!';
  static const String uploadSuccessMessage = 'Photos uploaded successfully!';
  static const String saveSuccessMessage = 'Changes saved successfully!';
  static const String deleteSuccessMessage = 'Item deleted successfully!';

  // Confirmation Messages
  static const String deleteConfirmationMessage =
      'Are you sure you want to delete this item?';
  static const String logoutConfirmationMessage =
      'Are you sure you want to logout?';
  static const String discardChangesMessage =
      'Are you sure you want to discard changes?';

  // Date Formats
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayDateTimeFormat = 'MMM dd, yyyy HH:mm';
  static const String apiDateFormat = 'yyyy-MM-dd';
  static const String apiDateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String timeFormat = 'HH:mm:ss';
  static const String shortTimeFormat = 'HH:mm';

  // Regex Patterns
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^[+]?[0-9]{10,15}$';
  static const String passwordPattern =
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';
  static const String workOrderPattern = r'^[A-Z]{2,4}-\d{4,6}$';

  // Notification Channels
  static const String uploadNotificationChannel = 'upload_channel';
  static const String syncNotificationChannel = 'sync_channel';
  static const String reminderNotificationChannel = 'reminder_channel';

  // Feature Flags
  static const bool isOCREnabled = true;
  static const bool isOfflineModeEnabled = true;
  static const bool isBiometricAuthEnabled = true;
  static const bool isDarkModeEnabled = false;
  static const bool isDebugModeEnabled = false;
}
