import 'package:flutter/material.dart';
import '../services/remote_config_service.dart';
import '../services/analytics_service.dart';

class AppStateProvider extends ChangeNotifier {
  final RemoteConfigService _remoteConfig = RemoteConfigService.instance;
  final AnalyticsService _analytics = AnalyticsService();

  // App State
  bool _isLoading = false;
  String? _errorMessage;
  bool _isDarkMode = false;
  String _currentScreen = 'splash';

  // TV State
  bool _isRemoteControlActive = false;
  Widget? _focusedWidget;
  String _selectedCategory = 'All';
  
  // Content State
  List<Map<String, dynamic>> _featuredContent = [];
  List<Map<String, dynamic>> _trendingContent = [];
  List<Map<String, dynamic>> _recommendations = [];
  List<Map<String, dynamic>> _viewingHistory = [];
  
  // User Preferences
  String _videoQuality = 'auto';
  bool _autoplayEnabled = true;
  bool _notificationsEnabled = true;
  String _language = 'en';
  
  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isDarkMode => _isDarkMode;
  String get currentScreen => _currentScreen;
  
  bool get isRemoteControlActive => _isRemoteControlActive;
  Widget? get focusedWidget => _focusedWidget;
  String get selectedCategory => _selectedCategory;
  
  List<Map<String, dynamic>> get featuredContent => _featuredContent;
  List<Map<String, dynamic>> get trendingContent => _trendingContent;
  List<Map<String, dynamic>> get recommendations => _recommendations;
  List<Map<String, dynamic>> get viewingHistory => _viewingHistory;
  
  String get videoQuality => _videoQuality;
  bool get autoplayEnabled => _autoplayEnabled;
  bool get notificationsEnabled => _notificationsEnabled;
  String get language => _language;

  // App State Management
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void setDarkMode(bool darkMode) {
    _isDarkMode = darkMode;
    _analytics.logCustomEvent(
      name: 'theme_changed',
      parameters: {'theme': darkMode ? 'dark' : 'light'},
    );
    notifyListeners();
  }

  void setCurrentScreen(String screenName) {
    String previousScreen = _currentScreen;
    _currentScreen = screenName;
    _analytics.logScreenView(screenName);
    _analytics.logNavigateToScreen(previousScreen, screenName);
    notifyListeners();
  }

  // TV Remote Control Management
  void setRemoteControlActive(bool active) {
    _isRemoteControlActive = active;
    _analytics.logTVInteraction('remote_control', active ? 'activated' : 'deactivated');
    notifyListeners();
  }

  void setFocusedWidget(Widget? widget) {
    _focusedWidget = widget;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    _analytics.logSelectContent('category', category);
    notifyListeners();
  }

  // Content Management
  void setFeaturedContent(List<Map<String, dynamic>> content) {
    _featuredContent = content;
    notifyListeners();
  }

  void setTrendingContent(List<Map<String, dynamic>> content) {
    _trendingContent = content;
    notifyListeners();
  }

  void setRecommendations(List<Map<String, dynamic>> content) {
    _recommendations = content;
    notifyListeners();
  }

  void addToViewingHistory(Map<String, dynamic> content) {
    _viewingHistory.insert(0, {
      ...content,
      'viewedAt': DateTime.now().toIso8601String(),
    });
    
    // Keep only last 50 items
    if (_viewingHistory.length > 50) {
      _viewingHistory = _viewingHistory.take(50).toList();
    }
    
    _analytics.logSelectContent('video', content['id'] ?? 'unknown');
    notifyListeners();
  }

  void clearViewingHistory() {
    _viewingHistory.clear();
    _analytics.logCustomEvent(name: 'viewing_history_cleared');
    notifyListeners();
  }

  // User Preferences
  void setVideoQuality(String quality) {
    _videoQuality = quality;
    _analytics.logCustomEvent(
      name: 'video_quality_changed',
      parameters: {'quality': quality},
    );
    notifyListeners();
  }

  void setAutoplayEnabled(bool enabled) {
    _autoplayEnabled = enabled;
    _analytics.logCustomEvent(
      name: 'autoplay_toggled',
      parameters: {'enabled': enabled},
    );
    notifyListeners();
  }

  void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
    _analytics.logCustomEvent(
      name: 'notifications_toggled',
      parameters: {'enabled': enabled},
    );
    notifyListeners();
  }

  void setLanguage(String language) {
    _language = language;
    _analytics.logCustomEvent(
      name: 'language_changed',
      parameters: {'language': language},
    );
    notifyListeners();
  }

  // Remote Config Integration
  void updateFromRemoteConfig() {
    try {
      // Update app settings from remote config
      _isDarkMode = _remoteConfig.isDarkModeEnabled;
      _autoplayEnabled = _remoteConfig.isAutoplayEnabled;
      _notificationsEnabled = _remoteConfig.arePushNotificationsEnabled;
      _videoQuality = _remoteConfig.defaultVideoQuality;
      
      notifyListeners();
    } catch (e) {
      setError('Failed to update from remote config: $e');
    }
  }

  // Content Filtering
  List<Map<String, dynamic>> getFilteredContent(String category) {
    if (category == 'All') {
      return _trendingContent;
    }
    
    return _trendingContent
        .where((content) => content['category'] == category)
        .toList();
  }

  List<Map<String, dynamic>> searchContent(String query) {
    if (query.isEmpty) return [];
    
    String lowercaseQuery = query.toLowerCase();
    List<Map<String, dynamic>> allContent = [
      ..._featuredContent,
      ..._trendingContent,
      ..._recommendations,
    ];
    
    return allContent
        .where((content) {
          String title = (content['title'] ?? '').toString().toLowerCase();
          String description = (content['description'] ?? '').toString().toLowerCase();
          List<String> genres = List<String>.from(content['genres'] ?? []);
          
          return title.contains(lowercaseQuery) ||
                 description.contains(lowercaseQuery) ||
                 genres.any((genre) => genre.toLowerCase().contains(lowercaseQuery));
        })
        .toList();
  }

  // TV-specific features
  void handleRemoteControlInput(String input) {
    _analytics.logRemoteControlAction(input);
    
    switch (input) {
      case 'up':
      case 'down':
      case 'left':
      case 'right':
        // Handle navigation
        break;
      case 'select':
      case 'ok':
        // Handle selection
        break;
      case 'back':
        // Handle back navigation
        break;
      case 'home':
        setCurrentScreen('home');
        break;
      case 'menu':
        // Handle menu
        break;
    }
    
    notifyListeners();
  }

  // Utility methods
  void resetAppState() {
    _isLoading = false;
    _errorMessage = null;
    _currentScreen = 'home';
    _selectedCategory = 'All';
    _focusedWidget = null;
    _isRemoteControlActive = false;
    
    notifyListeners();
  }

  Map<String, dynamic> getAppStateSnapshot() {
    return {
      'isLoading': _isLoading,
      'errorMessage': _errorMessage,
      'isDarkMode': _isDarkMode,
      'currentScreen': _currentScreen,
      'selectedCategory': _selectedCategory,
      'videoQuality': _videoQuality,
      'autoplayEnabled': _autoplayEnabled,
      'notificationsEnabled': _notificationsEnabled,
      'language': _language,
      'featuredContentCount': _featuredContent.length,
      'trendingContentCount': _trendingContent.length,
      'recommendationsCount': _recommendations.length,
      'viewingHistoryCount': _viewingHistory.length,
    };
  }

  void logAppStateChange(String action) {
    _analytics.logCustomEvent(
      name: 'app_state_change',
      parameters: {
        'action': action,
        ...getAppStateSnapshot(),
      },
    );
  }
}