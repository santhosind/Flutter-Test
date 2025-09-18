import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // TV-optimized colors
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color secondaryColor = Color(0xFFFF4081);
  static const Color backgroundColor = Color(0xFF121212);
  static const Color surfaceColor = Color(0xFF1E1E1E);
  static const Color cardColor = Color(0xFF2C2C2C);
  static const Color focusColor = Color(0xFFFFFFFF);
  
  // TV-optimized text sizes
  static const double headlineLarge = 48.0;
  static const double headlineMedium = 36.0;
  static const double headlineSmall = 32.0;
  static const double titleLarge = 28.0;
  static const double titleMedium = 24.0;
  static const double titleSmall = 20.0;
  static const double bodyLarge = 18.0;
  static const double bodyMedium = 16.0;
  static const double bodySmall = 14.0;
  
  static ThemeData get tvTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        background: backgroundColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
        error: Colors.red,
      ),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: titleLarge,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      
      // Card Theme
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(fontSize: bodyLarge),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(fontSize: bodyLarge),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: const BorderSide(color: Colors.white, width: 2),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: bodyLarge),
        ),
      ),
      
      // Focus Theme for TV navigation
      focusTheme: FocusThemeData(
        glowFactor: 0.0,
        glowColor: Colors.transparent,
      ),
      
      // Text Theme optimized for TV viewing
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: headlineLarge,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          fontSize: headlineMedium,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          height: 1.2,
        ),
        headlineSmall: TextStyle(
          fontSize: headlineSmall,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          height: 1.2,
        ),
        titleLarge: TextStyle(
          fontSize: titleLarge,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          height: 1.3,
        ),
        titleMedium: TextStyle(
          fontSize: titleMedium,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          height: 1.3,
        ),
        titleSmall: TextStyle(
          fontSize: titleSmall,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
          height: 1.3,
        ),
        bodyLarge: TextStyle(
          fontSize: bodyLarge,
          color: Colors.white,
          height: 1.4,
        ),
        bodyMedium: TextStyle(
          fontSize: bodyMedium,
          color: Colors.white70,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          fontSize: bodySmall,
          color: Colors.white60,
          height: 1.4,
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.white70, fontSize: bodyMedium),
        hintStyle: const TextStyle(color: Colors.white60, fontSize: bodyMedium),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      // List Tile Theme
      listTileTheme: const ListTileThemeData(
        textColor: Colors.white,
        iconColor: Colors.white70,
        contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: Colors.white,
        size: 28,
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: Colors.white24,
        thickness: 1,
        space: 1,
      ),
      
      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: cardColor,
        titleTextStyle: const TextStyle(
          fontSize: titleLarge,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        contentTextStyle: const TextStyle(
          fontSize: bodyMedium,
          color: Colors.white70,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.white60,
        selectedLabelStyle: TextStyle(fontSize: bodySmall),
        unselectedLabelStyle: TextStyle(fontSize: bodySmall),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
  
  // TV-specific widget styles
  static BoxDecoration get focusedDecoration {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: focusColor, width: 3),
      boxShadow: [
        BoxShadow(
          color: focusColor.withOpacity(0.3),
          blurRadius: 8,
          spreadRadius: 2,
        ),
      ],
    );
  }
  
  static BoxDecoration get cardDecoration {
    return BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
  
  static BoxDecoration get gradientBackground {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          backgroundColor,
          Color(0xFF1A1A1A),
          backgroundColor,
        ],
      ),
    );
  }
  
  // Animation durations optimized for TV
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // TV-specific dimensions
  static const double cardHeight = 200.0;
  static const double cardWidth = 300.0;
  static const double posterHeight = 450.0;
  static const double posterWidth = 300.0;
  static const double bannerHeight = 600.0;
  static const double thumbnailHeight = 120.0;
  static const double thumbnailWidth = 200.0;
  
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
  
  // Border radius
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;
}

// TV-specific custom widgets
class TVFocusableWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool autofocus;
  
  const TVFocusableWidget({
    super.key,
    required this.child,
    this.onTap,
    this.autofocus = false,
  });

  @override
  State<TVFocusableWidget> createState() => _TVFocusableWidgetState();
}

class _TVFocusableWidgetState extends State<TVFocusableWidget> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: widget.autofocus,
      onFocusChange: (focused) {
        setState(() {
          _isFocused = focused;
        });
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppTheme.shortAnimation,
          decoration: _isFocused 
              ? AppTheme.focusedDecoration 
              : const BoxDecoration(),
          child: widget.child,
        ),
      ),
    );
  }
}