import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Login Events
  Future<void> logLogin(String loginMethod) async {
    await _analytics.logLogin(loginMethod: loginMethod);
  }

  Future<void> logSignUp(String signUpMethod) async {
    await _analytics.logSignUp(signUpMethod: signUpMethod);
  }

  // Screen View Events
  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenName,
    );
  }

  // Custom Events
  Future<void> logCustomEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  // Content Events
  Future<void> logSelectContent(String contentType, String itemId) async {
    await _analytics.logSelectContent(
      contentType: contentType,
      itemId: itemId,
    );
  }

  Future<void> logShare(String contentType, String itemId) async {
    await _analytics.logShare(
      contentType: contentType,
      itemId: itemId,
      method: 'tv_app_share',
    );
  }

  // Search Events
  Future<void> logSearch(String searchTerm) async {
    await _analytics.logSearch(
      searchTerm: searchTerm,
    );
  }

  // Video Events
  Future<void> logVideoStart(String videoId, String videoTitle) async {
    await _analytics.logEvent(
      name: 'video_start',
      parameters: {
        'video_id': videoId,
        'video_title': videoTitle,
        'content_type': 'video',
      },
    );
  }

  Future<void> logVideoComplete(String videoId, String videoTitle) async {
    await _analytics.logEvent(
      name: 'video_complete',
      parameters: {
        'video_id': videoId,
        'video_title': videoTitle,
        'content_type': 'video',
      },
    );
  }

  // User Properties
  Future<void> setUserProperty(String name, String? value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  Future<void> setUserId(String? id) async {
    await _analytics.setUserId(id: id);
  }

  // App Events
  Future<void> logAppOpen() async {
    await _analytics.logAppOpen();
  }

  // Navigation Events
  Future<void> logNavigateToScreen(String from, String to) async {
    await _analytics.logEvent(
      name: 'navigate_to_screen',
      parameters: {
        'from_screen': from,
        'to_screen': to,
      },
    );
  }

  // Error Events
  Future<void> logError(String error, String context) async {
    await _analytics.logEvent(
      name: 'app_error',
      parameters: {
        'error_message': error,
        'error_context': context,
      },
    );
  }

  // TV-specific Events
  Future<void> logTVInteraction(String interactionType, String element) async {
    await _analytics.logEvent(
      name: 'tv_interaction',
      parameters: {
        'interaction_type': interactionType,
        'element': element,
        'platform': 'tv',
      },
    );
  }

  Future<void> logRemoteControlAction(String action) async {
    await _analytics.logEvent(
      name: 'remote_control_action',
      parameters: {
        'action': action,
        'input_method': 'remote',
      },
    );
  }
}