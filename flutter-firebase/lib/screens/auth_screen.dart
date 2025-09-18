import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/analytics_service.dart';
import '../providers/app_state_provider.dart';
import '../utils/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _smsController = TextEditingController();
  
  bool _isLogin = true;
  bool _isLoading = false;
  bool _isPhoneAuth = false;
  String? _verificationId;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    appState.setCurrentScreen('auth');
  }

  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final analytics = AnalyticsService();

    try {
      if (_isLogin) {
        await authService.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        await authService.createUserWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      await analytics.logError(e.toString(), 'email_auth');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final analytics = AnalyticsService();

    try {
      await authService.signInWithGoogle();
      
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      await analytics.logError(e.toString(), 'google_auth');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handlePhoneAuth() async {
    if (_phoneController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a phone number';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final analytics = AnalyticsService();

    try {
      await authService.verifyPhoneNumber(
        phoneNumber: _phoneController.text.trim(),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await authService.signInWithPhoneNumber(
            credential.verificationId!,
            credential.smsCode!,
          );
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _errorMessage = e.message ?? 'Phone verification failed';
            _isLoading = false;
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _isLoading = false;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _verificationId = verificationId;
          });
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      await analytics.logError(e.toString(), 'phone_auth');
    }
  }

  Future<void> _verifySMSCode() async {
    if (_smsController.text.trim().isEmpty || _verificationId == null) {
      setState(() {
        _errorMessage = 'Please enter the SMS code';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final analytics = AnalyticsService();

    try {
      await authService.signInWithPhoneNumber(
        _verificationId!,
        _smsController.text.trim(),
      );
      
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      await analytics.logError(e.toString(), 'sms_verification');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleAnonymousSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final analytics = AnalyticsService();

    try {
      await authService.signInAnonymously();
      
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      await analytics.logError(e.toString(), 'anonymous_auth');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _smsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.gradientBackground,
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 500,
              margin: const EdgeInsets.all(AppTheme.spacingL),
              padding: const EdgeInsets.all(AppTheme.spacingXL),
              decoration: AppTheme.cardDecoration,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo and Title
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                      ),
                    ),
                    child: const Icon(
                      Icons.tv,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacingL),
                  
                  Text(
                    'Welcome to Flutter TV',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: AppTheme.spacingM),
                  
                  Text(
                    _isLogin ? 'Sign in to continue' : 'Create your account',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: AppTheme.spacingXL),
                  
                  // Error Message
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingM),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingL),
                  ],
                  
                  // Auth Form
                  if (!_isPhoneAuth)
                    _buildEmailAuthForm()
                  else
                    _buildPhoneAuthForm(),
                  
                  const SizedBox(height: AppTheme.spacingL),
                  
                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
                        child: Text(
                          'OR',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white60,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  
                  const SizedBox(height: AppTheme.spacingL),
                  
                  // Social Sign In Buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _handleGoogleSignIn,
                      icon: const Icon(Icons.g_mobiledata),
                      label: const Text('Continue with Google'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacingM),
                  
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : () {
                        setState(() {
                          _isPhoneAuth = !_isPhoneAuth;
                          _verificationId = null;
                          _errorMessage = null;
                        });
                      },
                      icon: Icon(_isPhoneAuth ? Icons.email : Icons.phone),
                      label: Text(_isPhoneAuth ? 'Use Email Instead' : 'Use Phone Number'),
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacingM),
                  
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _isLoading ? null : _handleAnonymousSignIn,
                      child: const Text('Continue as Guest'),
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacingL),
                  
                  // Toggle Sign In / Sign Up
                  if (!_isPhoneAuth)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                          _errorMessage = null;
                        });
                      },
                      child: Text(
                        _isLogin
                            ? "Don't have an account? Sign up"
                            : "Already have an account? Sign in",
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailAuthForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          
          const SizedBox(height: AppTheme.spacingL),
          
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (!_isLogin && value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          
          const SizedBox(height: AppTheme.spacingXL),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _verifySMSCode,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Verify Code'),
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingM),
          
          TextButton(
            onPressed: () {
              setState(() {
                _verificationId = null;
                _smsController.clear();
                _errorMessage = null;
              });
            },
            child: const Text('Change Phone Number'),
          ),
        ],
      ],
    );
  }
}infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleEmailAuth,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Text(_isLogin ? 'Sign In' : 'Sign Up'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneAuthForm() {
    return Column(
      children: [
        if (_verificationId == null) ...[
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: Icon(Icons.phone),
              hintText: '+1 234 567 8900',
            ),
            keyboardType: TextInputType.phone,
          ),
          
          const SizedBox(height: AppTheme.spacingXL),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handlePhoneAuth,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Send Verification Code'),
            ),
          ),
        ] else ...[
          Text(
            'Enter the verification code sent to ${_phoneController.text}',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppTheme.spacingL),
          
          TextFormField(
            controller: _smsController,
            decoration: const InputDecoration(
              labelText: 'Verification Code',
              prefixIcon: Icon(Icons.message),
            ),
            keyboardType: TextInputType.number,
            maxLength: 6,
          ),
          
          const SizedBox(height: AppTheme.spacingL),
          
          SizedBox(
            width: double.