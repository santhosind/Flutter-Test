import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class CategorySelector extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static const List<String> categories = [
    'All',
    'Action',
    'Comedy',
    'Drama',
    'Horror',
    'Romance',
    'Sci-Fi',
    'Documentary',
    'Animation',
    'Thriller',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;
          
          return Container(
            margin: const EdgeInsets.only(right: AppTheme.spacingM),
            child: TVFocusableWidget(
              onTap: () => onCategorySelected(category),
              child: AnimatedContainer(
                duration: AppTheme.shortAnimation,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingL,
                  vertical: AppTheme.spacingM,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : Colors.white24,
                    width: 2,
                  ),
                ),
                child: Text(
                  category,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

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