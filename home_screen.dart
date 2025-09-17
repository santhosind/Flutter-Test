import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/functions_service.dart';
import '../services/analytics_service.dart';
import '../providers/app_state_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/content_card.dart';
import '../widgets/category_selector.dart';
import '../widgets/search_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  final TextEditingController _searchController = TextEditingController();
  final AnalyticsService _analytics = AnalyticsService();
  
  bool _isSearchActive = false;
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController = ScrollController();
    _loadContent();
    
    // Listen to remote control inputs
    _setupKeyboardListener();
  }

  void _setupKeyboardListener() {
    RawKeyboard.instance.addListener(_handleKeyEvent);
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event.runtimeType == RawKeyDownEvent) {
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        appState.handleRemoteControlInput('up');
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        appState.handleRemoteControlInput('down');
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        appState.handleRemoteControlInput('left');
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        appState.handleRemoteControlInput('right');
      } else if (event.logicalKey == LogicalKeyboardKey.select) {
        appState.handleRemoteControlInput('select');
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        appState.handleRemoteControlInput('back');
      }
    }
  }

  Future<void> _loadContent() async {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    
    try {
      appState.setLoading(true);
      
      // Load featured content
      final featuredContent = await FunctionsService.instance.getTrendingContent(
        category: 'featured',
        limit: 10,
      );
      appState.setFeaturedContent(featuredContent);
      
      // Load trending content
      final trendingContent = await FunctionsService.instance.getTrendingContent(
        limit: 20,
      );
      appState.setTrendingContent(trendingContent);
      
      // Load user recommendations if authenticated
      if (authService.isAuthenticated) {
        final recommendations = await FunctionsService.instance.getUserRecommendations(
          authService.currentUser!.uid,
        );
        appState.setRecommendations(List<Map<String, dynamic>>.from(
          recommendations['recommendations'] ?? []
        ));
        
        // Load viewing history
        final history = await DatabaseService.instance.getViewingHistory(
          authService.currentUser!.uid,
          limit: 15,
        );
        // Note: viewing history would be set through appState method
      }
      
      await _analytics.logScreenView('home');
      
    } catch (e) {
      appState.setError('Failed to load content: $e');
      await _analytics.logError(e.toString(), 'home_content_load');
    } finally {
      appState.setLoading(false);
    }
  }

  void _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _isSearchActive = false;
        _searchResults = [];
      });
      return;
    }

    final appState = Provider.of<AppStateProvider>(context, listen: false);
    
    try {
      setState(() {
        _isSearchActive = true;
      });
      
      // Search both locally and remotely
      final localResults = appState.searchContent(query);
      final remoteResults = await FunctionsService.instance.searchContent(query);
      
      // Combine and deduplicate results
      final allResults = [...localResults, ...remoteResults];
      final uniqueResults = <String, Map<String, dynamic>>{};
      
      for (final result in allResults) {
        final id = result['id']?.toString() ?? '';
        if (id.isNotEmpty) {
          uniqueResults[id] = result;
        }
      }
      
      setState(() {
        _searchResults = uniqueResults.values.toList();
      });
      
      await _analytics.logSearch(query);
      
    } catch (e) {
      appState.setError('Search failed: $e');
      await _analytics.logError(e.toString(), 'search_error');
    }
  }

  void _onContentTap(Map<String, dynamic> content) async {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    
    appState.addToViewingHistory(content);
    
    if (authService.isAuthenticated) {
      await DatabaseService.instance.saveViewingHistory(
        authService.currentUser!.uid,
        content,
      );
    }
    
    await _analytics.logVideoStart(
      content['id']?.toString() ?? 'unknown',
      content['title']?.toString() ?? 'Unknown Title',
    );
    
    // Navigate to video player (would be implemented)
    _showContentDetails(content);
  }

  void _showContentDetails(Map<String, dynamic> content) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      content['title']?.toString() ?? 'Unknown Title',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingL),
              if (content['thumbnail'] != null)
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radiusL),
                    image: DecorationImage(
                      image: NetworkImage(content['thumbnail']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: AppTheme.spacingL),
              Text(
                content['description']?.toString() ?? 'No description available',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _onContentTap(content);
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Play'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      // Add to watchlist functionality
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Watchlist'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await _analytics.logShare('video', content['id']?.toString() ?? 'unknown');
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    RawKeyboard.instance.removeListener(_handleKeyEvent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.gradientBackground,
        child: Column(
          children: [
            // App Bar with Search
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Row(
                children: [
                  Text(
                    'Flutter TV',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 400,
                    child: CustomSearchBar(
                      controller: _searchController,
                      onChanged: _performSearch,
                      onSubmitted: _performSearch,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingL),
                  Consumer<AuthService>(
                    builder: (context, authService, child) {
                      return PopupMenuButton<String>(
                        icon: CircleAvatar(
                          backgroundImage: authService.currentUser?.photoURL != null
                              ? NetworkImage(authService.currentUser!.photoURL!)
                              : null,
                          child: authService.currentUser?.photoURL == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        onSelected: (value) async {
                          switch (value) {
                            case 'profile':
                              // Navigate to profile
                              break;
                            case 'settings':
                              // Navigate to settings
                              break;
                            case 'logout':
                              await authService.signOut();
                              if (mounted) {
                                Navigator.of(context).pushReplacementNamed('/auth');
                              }
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'profile',
                            child: ListTile(
                              leading: Icon(Icons.person),
                              title: Text('Profile'),
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'settings',
                            child: ListTile(
                              leading: Icon(Icons.settings),
                              title: Text('Settings'),
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'logout',
                            child: ListTile(
                              leading: Icon(Icons.logout),
                              title: Text('Sign Out'),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            
            // Content Area
            Expanded(
              child: _isSearchActive
                  ? _buildSearchResults()
                  : _buildMainContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Center(
        child: Text(
          'No results found',
          style: TextStyle(fontSize: AppTheme.titleLarge),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: AppTheme.spacingL,
        mainAxisSpacing: AppTheme.spacingL,
        childAspectRatio: 0.7,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return ContentCard(
          content: _searchResults[index],
          onTap: () => _onContentTap(_searchResults[index]),
        );
      },
    );
  }

  Widget _buildMainContent() {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        if (appState.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (appState.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: AppTheme.spacingL),
                Text(
                  appState.errorMessage!,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingL),
                ElevatedButton(
                  onPressed: _loadContent,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Selector
              CategorySelector(
                selectedCategory: appState.selectedCategory,
                onCategorySelected: appState.setSelectedCategory,
              ),
              
              const SizedBox(height: AppTheme.spacingL),
              
              // Featured Content Section
              if (appState.featuredContent.isNotEmpty) ...[
                _buildContentSection(
                  'Featured',
                  appState.featuredContent,
                  height: AppTheme.bannerHeight,
                ),
                const SizedBox(height: AppTheme.spacingXL),
              ],
              
              // Trending Content Section
              if (appState.trendingContent.isNotEmpty) ...[
                _buildContentSection(
                  'Trending Now',
                  appState.getFilteredContent(appState.selectedCategory),
                ),
                const SizedBox(height: AppTheme.spacingXL),
              ],
              
              // Recommendations Section
              if (appState.recommendations.isNotEmpty) ...[
                _buildContentSection(
                  'Recommended for You',
                  appState.recommendations,
                ),
                const SizedBox(height: AppTheme.spacingXL),
              ],
              
              // Continue Watching Section
              if (appState.viewingHistory.isNotEmpty) ...[
                _buildContentSection(
                  'Continue Watching',
                  appState.viewingHistory.take(10).toList(),
                ),
                const SizedBox(height: AppTheme.spacingXL),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildContentSection(
    String title,
    List<Map<String, dynamic>> content, {
    double height = AppTheme.cardHeight,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        SizedBox(
          height: height,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
            itemCount: content.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(right: AppTheme.spacingM),
                width: height == AppTheme.bannerHeight ? 500 : AppTheme.cardWidth,
                child: ContentCard(
                  content: content[index],
                  onTap: () => _onContentTap(content[index]),
                  isFeatured: height == AppTheme.bannerHeight,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}