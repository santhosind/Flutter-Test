import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/analytics_service.dart';
import '../services/remote_config_service.dart';
import '../providers/app_state_provider.dart';
import '../utils/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeApp();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _textAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    ));

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _textController.forward();
    });
  }

  Future<void> _initializeApp() async {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final analytics = AnalyticsService();

    try {
      appState.setLoading(true);
      appState.setCurrentScreen('splash');

      // Log app open
      await analytics.logAppOpen();

      // Initialize remote config and update app state
      await RemoteConfigService.instance.fetchAndActivate();
      appState.updateFromRemoteConfig();

      // Check for maintenance mode
      if (RemoteConfigService.instance.isMaintenanceMode) {
        _showMaintenanceMode();
        return;
      }

      // Check for force update
      if (RemoteConfigService.instance.forceUpdate) {
        _showForceUpdateDialog();
        return;
      }

      // Simulate loading time for better UX
      await Future.delayed(const Duration(seconds: 2));

      appState.setLoading(false);

      // Navigate based on authentication state
      if (mounted) {
        if (authService.isAuthenticated) {
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          Navigator.of(context).pushReplacementNamed('/auth');
        }
      }
    } catch (error) {
      if (mounted) {
        appState.setError('Failed to initialize app: $error');
        await analytics.logError(error.toString(), 'splash_initialization');
        
        // Show error dialog and retry option
        _showErrorDialog(error.toString());
      }
    }
  }

  void _showMaintenanceMode() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Maintenance Mode'),
        content: const Text(
          'The app is currently under maintenance. Please try again later.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _retryInitialization();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showForceUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Update Required'),
        content: const Text(
          'A new version of the app is available. Please update to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              // In a real app, this would open the app store
              Navigator.of(context).pop();
              _retryInitialization();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Initialization Error'),
        content: Text(
          'Failed to start the app: $error\n\nWould you like to retry?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _retryInitialization();
            },
            child: const Text('Retry'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/auth');
            },
            child: const Text('Continue Offline'),
          ),
        ],
      ),
    );
  }

  void _retryInitialization() {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    appState.clearError();
    _initializeApp();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.gradientBackground,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Logo
              AnimatedBuilder(
                animation: _logoAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoAnimation.value,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.secondaryColor,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.tv,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: AppTheme.spacingXL),
              
              // Animated App Name
              AnimatedBuilder(
                animation: _textAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _textAnimation.value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - _textAnimation.value)),
                      child: Column(
                        children: [
                          Text(
                            RemoteConfigService.instance.appName,
                            style: Theme.of(context).textTheme.headlineLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppTheme.spacingM),
                          Text(
                            'Your Ultimate TV Experience',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: AppTheme.spacingXXL),
              
              // Loading Indicator
              Consumer<AppStateProvider>(
                builder: (context, appState, child) {
                  if (appState.isLoading) {
                    return Column(
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            strokeWidth: 4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingL),
                        Text(
                          'Initializing...',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    );
                  }
                  
                  if (appState.errorMessage != null) {
                    return Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: AppTheme.spacingM),
                        Text(
                          'Initialization Failed',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingL),
                        ElevatedButton(
                          onPressed: _retryInitialization,
                          child: const Text('Retry'),
                        ),
                      ],
                    );
                  }
                  
                  return Container();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}