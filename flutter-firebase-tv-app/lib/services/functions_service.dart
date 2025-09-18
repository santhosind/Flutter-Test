import 'package:cloud_functions/cloud_functions.dart';

class FunctionsService {
  static final FunctionsService _instance = FunctionsService._internal();
  static FunctionsService get instance => _instance;
  FunctionsService._internal();

  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // Generic function caller
  Future<HttpsCallableResult> callFunction(
    String functionName, {
    Map<String, dynamic>? parameters,
  }) async {
    try {
      HttpsCallable callable = _functions.httpsCallable(functionName);
      HttpsCallableResult result = await callable.call(parameters);
      return result;
    } catch (e) {
      print('Error calling function $functionName: $e');
      throw e;
    }
  }

  // User management functions
  Future<Map<String, dynamic>> createUserProfile(Map<String, dynamic> userData) async {
    try {
      HttpsCallableResult result = await callFunction('createUserProfile', parameters: userData);
      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      print('Error creating user profile: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> getUserRecommendations(String userId) async {
    try {
      HttpsCallableResult result = await callFunction('getUserRecommendations', 
        parameters: {'userId': userId});
      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      print('Error getting user recommendations: $e');
      throw e;
    }
  }

  // Content management functions
  Future<Map<String, dynamic>> processVideoUpload(Map<String, dynamic> videoData) async {
    try {
      HttpsCallableResult result = await callFunction('processVideoUpload', parameters: videoData);
      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      print('Error processing video upload: $e');
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> searchContent(String query, {
    String? category,
    int limit = 10,
  }) async {
    try {
      HttpsCallableResult result = await callFunction('searchContent', parameters: {
        'query': query,
        'category': category,
        'limit': limit,
      });
      return List<Map<String, dynamic>>.from(result.data['results']);
    } catch (e) {
      print('Error searching content: $e');
      throw e;
    }
  }

  // Analytics functions
  Future<Map<String, dynamic>> getViewingAnalytics(String userId, {
    String? period = 'week',
  }) async {
    try {
      HttpsCallableResult result = await callFunction('getViewingAnalytics', parameters: {
        'userId': userId,
        'period': period,
      });
      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      print('Error getting viewing analytics: $e');
      throw e;
    }
  }

  Future<void> trackContentView(Map<String, dynamic> viewData) async {
    try {
      await callFunction('trackContentView', parameters: viewData);
    } catch (e) {
      print('Error tracking content view: $e');
      throw e;
    }
  }

  // Notification functions
  Future<void> sendCustomNotification(Map<String, dynamic> notificationData) async {
    try {
      await callFunction('sendCustomNotification', parameters: notificationData);
    } catch (e) {
      print('Error sending custom notification: $e');
      throw e;
    }
  }

  Future<void> subscribeToContentUpdates(String userId, List<String> categories) async {
    try {
      await callFunction('subscribeToContentUpdates', parameters: {
        'userId': userId,
        'categories': categories,
      });
    } catch (e) {
      print('Error subscribing to content updates: $e');
      throw e;
    }
  }

  // TV-specific functions
  Future<Map<String, dynamic>> getTVChannelGuide({
    String? region,
    DateTime? date,
  }) async {
    try {
      HttpsCallableResult result = await callFunction('getTVChannelGuide', parameters: {
        'region': region ?? 'US',
        'date': date?.toIso8601String() ?? DateTime.now().toIso8601String(),
      });
      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      print('Error getting TV channel guide: $e');
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> getTrendingContent({
    String? category,
    String? region,
    int limit = 20,
  }) async {
    try {
      HttpsCallableResult result = await callFunction('getTrendingContent', parameters: {
        'category': category,
        'region': region,
        'limit': limit,
      });
      return List<Map<String, dynamic>>.from(result.data['content']);
    } catch (e) {
      print('Error getting trending content: $e');
      throw e;
    }
  }

  // Utility functions
  Future<Map<String, dynamic>> validateSubscription(String userId) async {
    try {
      HttpsCallableResult result = await callFunction('validateSubscription', 
        parameters: {'userId': userId});
      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      print('Error validating subscription: $e');
      throw e;
    }
  }

  Future<void> logError(Map<String, dynamic> errorData) async {
    try {
      await callFunction('logError', parameters: errorData);
    } catch (e) {
      print('Error logging error to functions: $e');
      // Don't throw here to avoid infinite error loops
    }
  }

  Future<Map<String, dynamic>> getAppConfiguration() async {
    try {
      HttpsCallableResult result = await callFunction('getAppConfiguration');
      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      print('Error getting app configuration: $e');
      throw e;
    }
  }

  // Batch operations
  Future<List<Map<String, dynamic>>> batchProcessContent(
    List<Map<String, dynamic>> contentList,
  ) async {
    try {
      HttpsCallableResult result = await callFunction('batchProcessContent', 
        parameters: {'content': contentList});
      return List<Map<String, dynamic>>.from(result.data['results']);
    } catch (e) {
      print('Error batch processing content: $e');
      throw e;
    }
  }

  // Admin functions
  Future<Map<String, dynamic>> getAdminDashboardData(String adminId) async {
    try {
      HttpsCallableResult result = await callFunction('getAdminDashboardData', 
        parameters: {'adminId': adminId});
      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      print('Error getting admin dashboard data: $e');
      throw e;
    }
  }

  Future<void> moderateContent(String contentId, Map<String, dynamic> moderationData) async {
    try {
      await callFunction('moderateContent', parameters: {
        'contentId': contentId,
        ...moderationData,
      });
    } catch (e) {
      print('Error moderating content: $e');
      throw e;
    }
  }
}