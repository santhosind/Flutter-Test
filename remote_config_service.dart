import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  static RemoteConfigService get instance => _instance;
  RemoteConfigService._internal();

  late FirebaseRemoteConfig _remoteConfig;

  Future<void> initialize() async {
    try {
      _remoteConfig = FirebaseRemoteConfig.instance;
      
      // Set config settings
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      
      // Set default values
      await _remoteConfig.setDefaults(_getDefaults());
      
      // Fetch and activate
      await fetchAndActivate();
      
      print('Remote Config initialized successfully');
    } catch (e) {
      print('Error initializing Remote Config: $e');
      throw e;
    }
  }

  Map<String, dynamic> _getDefaults() {
    return {
      // App Configuration
      'app_name': 'Flutter TV App',
      'app_version': '1.0.0',
      'maintenance_mode': false,
      'force_update': false,
      'minimum_supported_version': '1.0.0',
      
      // Feature Flags
      'enable_dark_mode': true,
      'enable_offline_mode': true,
      'enable_social_features': true,
      'enable_live_streaming': false,
      'enable_downloads': true,
      'enable_recommendations': true,
      'enable_parental_controls': true,
      
      // UI Configuration
      'primary_color': '#2196F3',
      'secondary_color': '#FF4081',
      'home_screen_layout': 'grid',
      'max_concurrent_streams': 3,
      'video_quality_default': 'auto',
      'autoplay_enabled': true,
      
      // Content Configuration
      'featured_content_count': 10,
      'trending_content_count': 20,
      'recommendations_count': 15,
      'search_results_limit': 50,
      'content_categories': [
        'Action',
        'Comedy',
        'Drama',
        'Horror',
        'Romance',
        'Sci-Fi',
        'Documentary'
      ],
      
      // TV-specific Configuration
      'remote_navigation_enabled': true,
      'voice_control_enabled': false,
      'channel_guide_enabled': true,
      'live_tv_enabled': true,
      'dvr_enabled': false,
      
      // Analytics Configuration
      'analytics_enabled': true,
      'crash_reporting_enabled': true,
      'performance_monitoring_enabled': true,
      
      // Subscription Configuration
      'free_trial_days': 7,
      'subscription_tiers': [
        {'name': 'Basic', 'price': 9.99, 'features': ['HD', 'Mobile']},
        {'name': 'Premium', 'price': 15.99, 'features': ['4K', 'TV', 'Downloads']},
        {'name': 'Family', 'price': 19.99, 'features': ['4K', 'TV', 'Downloads', '6 Profiles']}
      ],
      
      // API Configuration
      'api_timeout_seconds': 30,
      'max_retry_attempts': 3,
      'cache_duration_minutes': 60,
      
      // Notification Configuration
      'push_notifications_enabled': true,
      'marketing_notifications_enabled': false,
      'update_notifications_enabled': true,
    };
  }

  Future<bool> fetchAndActivate() async {
    try {
      bool updated = await _remoteConfig.fetchAndActivate();
      if (updated) {
        print('Remote Config values updated');
      }
      return updated;
    } catch (e) {
      print('Error fetching Remote Config: $e');
      throw e;
    }
  }

  // String values
  String getString(String key) {
    return _remoteConfig.getString(key);
  }

  // Boolean values
  bool getBool(String key) {
    return _remoteConfig.getBool(key);
  }

  // Integer values
  int getInt(String key) {
    return _remoteConfig.getInt(key);
  }

  // Double values
  double getDouble(String key) {
    return _remoteConfig.getDouble(key);
  }

  // App Configuration
  String get appName => getString('app_name');
  String get appVersion => getString('app_version');
  bool get isMaintenanceMode => getBool('maintenance_mode');
  bool get forceUpdate => getBool('force_update');
  String get minimumSupportedVersion => getString('minimum_supported_version');

  // Feature Flags
  bool get isDarkModeEnabled => getBool('enable_dark_mode');
  bool get isOfflineModeEnabled => getBool('enable_offline_mode');
  bool get areSocialFeaturesEnabled => getBool('enable_social_features');
  bool get isLiveStreamingEnabled => getBool('enable_live_streaming');
  bool get areDownloadsEnabled => getBool('enable_downloads');
  bool get areRecommendationsEnabled => getBool('enable_recommendations');
  bool get areParentalControlsEnabled => getBool('enable_parental_controls');

  // UI Configuration
  String get primaryColor => getString('primary_color');
  String get secondaryColor => getString('secondary_color');
  String get homeScreenLayout => getString('home_screen_layout');
  int get maxConcurrentStreams => getInt('max_concurrent_streams');
  String get defaultVideoQuality => getString('video_quality_default');
  bool get isAutoplayEnabled => getBool('autoplay_enabled');

  // Content Configuration
  int get featuredContentCount => getInt('featured_content_count');
  int get trendingContentCount => getInt('trending_content_count');
  int get recommendationsCount => getInt('recommendations_count');
  int get searchResultsLimit => getInt('search_results_limit');

  // TV-specific Configuration
  bool get isRemoteNavigationEnabled => getBool('remote_navigation_enabled');
  bool get isVoiceControlEnabled => getBool('voice_control_enabled');
  bool get isChannelGuideEnabled => getBool('channel_guide_enabled');
  bool get isLiveTVEnabled => getBool('live_tv_enabled');
  bool get isDVREnabled => getBool('dvr_enabled');

  // Analytics Configuration
  bool get isAnalyticsEnabled => getBool('analytics_enabled');
  bool get isCrashReportingEnabled => getBool('crash_reporting_enabled');
  bool get isPerformanceMonitoringEnabled => getBool('performance_monitoring_enabled');

  // Subscription Configuration
  int get freeTrialDays => getInt('free_trial_days');

  // API Configuration
  int get apiTimeoutSeconds => getInt('api_timeout_seconds');
  int get maxRetryAttempts => getInt('max_retry_attempts');
  int get cacheDurationMinutes => getInt('cache_duration_minutes');

  // Notification Configuration
  bool get arePushNotificationsEnabled => getBool('push_notifications_enabled');
  bool get areMarketingNotificationsEnabled => getBool('marketing_notifications_enabled');
  bool get areUpdateNotificationsEnabled => getBool('update_notifications_enabled');

  // Listen to config updates
  Stream<RemoteConfigUpdate> get onConfigUpdated => _remoteConfig.onConfigUpdated;

  // Get all values
  Map<String, RemoteConfigValue> getAllValues() {
    return _remoteConfig.getAll();
  }

  // Check if a feature is enabled with fallback
  bool isFeatureEnabled(String featureKey, {bool defaultValue = false}) {
    try {
      return getBool(featureKey);
    } catch (e) {
      print('Error getting feature flag $featureKey: $e');
      return defaultValue;
    }
  }

  // Get configuration as JSON
  Map<String, dynamic> getConfigAsMap() {
    Map<String, dynamic> config = {};
    Map<String, RemoteConfigValue> allValues = getAllValues();
    
    for (String key in allValues.keys) {
      RemoteConfigValue value = allValues[key]!;
      // Try to parse as different types
      try {
        // Try boolean first
        config[key] = value.asBool();
      } catch (e) {
        try {
          // Try int
          config[key] = value.asInt();
        } catch (e) {
          try {
            // Try double
            config[key] = value.asDouble();
          } catch (e) {
            // Default to string
            config[key] = value.asString();
          }
        }
      }
    }
    
    return config;
  }

  // Force refresh config
  Future<void> refresh() async {
    try {
      await _remoteConfig.fetch();
      await _remoteConfig.activate();
      print('Remote Config refreshed');
    } catch (e) {
      print('Error refreshing Remote Config: $e');
      throw e;
    }
  }
}