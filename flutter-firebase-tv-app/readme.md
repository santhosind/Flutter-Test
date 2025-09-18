# Flutter TV Firebase App

A comprehensive Flutter TV application with full Firebase integration, designed specifically for television platforms with remote control navigation support.

## Features

### Firebase Services Integration
- **Firebase Analytics** - Complete user analytics and event tracking
- **Firebase Authentication** - Multiple auth methods (Email/Password, Google, Phone, Anonymous)
- **Firebase Realtime Database** - Real-time data synchronization
- **Cloud Firestore** - Scalable document database
- **Cloud Functions** - Serverless backend logic
- **Firebase Cloud Messaging (FCM)** - Push notifications
- **Firebase Remote Config** - Dynamic app configuration
- **Cloud Storage** - File upload and management

### TV-Optimized Features
- **Remote Control Navigation** - Full support for TV remote controls
- **Focus Management** - Intuitive focus handling for TV interfaces
- **Large Text & UI Elements** - Optimized for TV viewing distances
- **Keyboard Shortcuts** - Arrow keys, select, back navigation
- **TV-Specific Analytics** - Track remote control interactions

### App Functionality
- **User Authentication** - Multiple sign-in options
- **Content Management** - Browse movies, shows, and videos
- **Search Functionality** - Real-time content search
- **Recommendations** - Personalized content suggestions
- **Viewing History** - Track and resume content
- **Categories** - Browse by genre and type
- **Responsive Design** - Adapts to different TV screen sizes

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── firebase_options.dart        # Firebase configuration
├── services/                    # Firebase services
│   ├── firebase_service.dart    # Core Firebase setup
│   ├── auth_service.dart        # Authentication service
│   ├── analytics_service.dart   # Analytics tracking
│   ├── database_service.dart    # Realtime DB & Firestore
│   ├── storage_service.dart     # Cloud Storage operations
│   ├── functions_service.dart   # Cloud Functions calls
│   └── remote_config_service.dart # Remote Config
├── providers/                   # State management
│   └── app_state_provider.dart  # App state provider
├── screens/                     # App screens
│   ├── splash_screen.dart       # Loading screen
│   ├── auth_screen.dart         # Authentication
│   └── home_screen.dart         # Main content screen
├── widgets/                     # Reusable widgets
│   ├── content_card.dart        # Content display cards
│   ├── category_selector.dart   # Category navigation
│   └── search_bar.dart          # Search input
└── utils/                       # Utilities
    └── app_theme.dart           # TV-optimized theme
```

## Setup Instructions

### Prerequisites
- Flutter SDK (3.10.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio or VS Code
- Firebase CLI
- A Firebase project

### Firebase Setup

1. **Create Firebase Project**
   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools
   
   # Login to Firebase
   firebase login
   ```

2. **Initialize Firebase in your Flutter project**
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase for your Flutter app
   flutterfire configure
   ```

3. **Update Firebase Configuration**
   - Replace the placeholder values in `lib/firebase_options.dart` with your actual Firebase configuration
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) files

4. **Enable Firebase Services**
   - **Authentication**: Enable Email/Password, Google, Phone, and Anonymous sign-in
   - **Firestore**: Create database in production mode
   - **Realtime Database**: Create database
   - **Storage**: Set up Cloud Storage bucket
   - **Functions**: Deploy the provided Cloud Functions (see Functions Setup below)
   - **Remote Config**: Set up parameters with default values

### Cloud Functions Setup

Create a `functions` folder in your Firebase project and deploy these sample functions:

```javascript
// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// User management
exports.createUserProfile = functions.https.onCall(async (data, context) => {
  // Create user profile logic
});

exports.getUserRecommendations = functions.https.onCall(async (data, context) => {
  // Get user recommendations logic
});

// Content management
exports.searchContent = functions.https.onCall(async (data, context) => {
  // Search content logic
});

exports.getTrendingContent = functions.https.onCall(async (data, context) => {
  // Get trending content logic
});

// Deploy with: firebase deploy --only functions
```

### Flutter Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/santhosind/Flutter-Test.git
   cd Flutter-Test/flutter-firebase-tv-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For Android TV
   flutter run -d android
   
   # For debugging on desktop (with TV simulation)
   flutter run -d windows
   # or
   flutter run -d macos
   ```

## Configuration

### Remote Config Parameters

Set these parameters in Firebase Remote Config:

```json
{
  "app_name": "Flutter TV App",
  "maintenance_mode": false,
  "enable_dark_mode": true,
  "featured_content_count": 10,
  "primary_color": "#2196F3",
  "enable_live_streaming": false,
  "max_concurrent_streams": 3
}
```

### Firebase Security Rules

**Firestore Rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Anyone can read content, only admins can write
    match /content/{document=**} {
      allow read: if true;
      allow write: if request.auth != null && 
        request.auth.token.admin == true;
    }
  }
}
```

**Realtime Database Rules:**
```json
{
  "rules": {
    "users": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    },
    "content": {
      ".read": true,
      ".write": "auth != null && auth.token.admin === true"
    }
  }
}
```

**Storage Rules:**
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profiles/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /content/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && 
        request.auth.token.admin == true;
    }
  }
}
```

## TV Remote Control Support

The app supports standard TV remote control inputs:

- **Arrow Keys**: Navigation between UI elements
- **Select/OK**: Activate focused element
- **Back/Escape**: Navigate back
- **Home**: Return to home screen
- **Menu**: Open context menus

### Adding Custom Remote Control Support

```dart
void _handleKeyEvent(RawKeyEvent event) {
  if (event.runtimeType == RawKeyDownEvent) {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      appState.handleRemoteControlInput('up');
    }
    // Add more key handlers as needed
  }
}
```

## Analytics Events

The app tracks comprehensive analytics:

- **Screen Views**: Track navigation between screens
- **User Actions**: Button taps, content selection
- **Content Interaction**: Play, pause, share events
- **TV-Specific**: Remote control usage patterns
- **Performance**: App load times, error rates

## Architecture

The app uses a layered architecture:

1. **Presentation Layer**: Screens and Widgets
2. **Business Logic Layer**: Providers and Services
3. **Data Layer**: Firebase services
4. **Utils Layer**: Themes, constants, helpers

### State Management

Uses Provider pattern for state management:
- `AppStateProvider`: Global app state
- `AuthService`: Authentication state
- Individual service classes for Firebase operations

## Testing

```bash
# Run unit tests
flutter test

# Run integration tests (if available)
flutter test integration_test/
```

## Deployment

### Android TV
1. Build APK: `flutter build apk --target-platform=android-arm64`
2. Sign the APK for production
3. Upload to Google Play Console

### Fire TV
1. Follow Amazon Fire TV app submission guidelines
2. Test on Fire TV devices
3. Submit to Amazon Appstore

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Troubleshooting

### Common Issues

1. **Firebase connection issues**
   - Verify `google-services.json` is in the correct location
   - Check internet connectivity
   - Ensure Firebase project is active

2. **Authentication not working**
   - Enable authentication providers in Firebase Console
   - Check SHA-1 fingerprints for Android
   - Verify bundle IDs match

3. **Remote control not responding**
   - Ensure focus management is properly implemented
   - Check keyboard listener setup
   - Test on actual TV device

### Performance Optimization

- Use `cached_network_image` for image loading
- Implement proper dispose methods
- Use `const` constructors where possible
- Profile memory usage regularly

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support and questions:
- Create an issue in the GitHub repository
- Check the Firebase documentation
- Review Flutter TV development guidelines

---

**Note**: This is a demo application for testing purposes. Make sure to implement proper security measures, error handling, and testing before deploying to production.
