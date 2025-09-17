import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? hintText;

  const CustomSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onSubmitted,
    this.hintText,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (focused) {
        setState(() {
          _isFocused = focused;
        });
      },
      child: AnimatedContainer(
        duration: AppTheme.shortAnimation,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          border: Border.all(
            color: _isFocused ? AppTheme.primaryColor : Colors.white24,
            width: _isFocused ? 2 : 1,
          ),
          boxShadow: _isFocused ? [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ] : null,
        ),
        child: TextField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: widget.hintText ?? 'Search movies, shows...',
            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white60,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: Colors.white70,
            ),
            suffixIcon: widget.controller.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      widget.controller.clear();
                      widget.onChanged?.call('');
                    },
                    icon: const Icon(
                      Icons.clear,
                      color: Colors.white70,
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingL,
              vertical: AppTheme.spacingM,
            ),
          ),
        ),
      ),
    );
  }
}