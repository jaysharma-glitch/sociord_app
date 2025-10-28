import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/constants/text_styles.dart';
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/mock_data/explore_mock_data.dart';
import 'package:sociord/models/explore_models.dart';
import 'package:sociord/screens/explore/immersive_mode_screen.dart';
import 'package:sociord/mock_data/immersive_mock_data.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  // Track which category is selected
  String? selectedCategory = 'for_arjun'; // Default to "For Arjun"

  // Content management
  final List<ExploreContentCard> _currentContent = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  // Search and immersive mode
  bool _isSearchVisible = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadContent();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMoreContent();
    }
  }

  void _loadContent() {
    setState(() {
      _isLoading = true;
      _currentContent.clear();
    });

    // Simulate loading delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _loadContentDirectly();
    });
  }

  void _loadContentDirectly() {
    // Loading content for category: $selectedCategory
    List<ExploreContentCard> newContent = _getContentForCategory(
      selectedCategory!,
    );
    // Loaded ${newContent.length} items

    setState(() {
      _currentContent.addAll(newContent);
      _isLoading = false;
    });
    // Content loaded. Total items: ${_currentContent.length}
  }

  void _loadMoreContent() {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    Future.delayed(const Duration(milliseconds: 800), () {
      List<ExploreContentCard> newContent = _getContentForCategory(
        selectedCategory!,
      );

      setState(() {
        _currentContent.addAll(newContent);
        _isLoading = false;
      });
    });
  }

  List<ExploreContentCard> _getContentForCategory(String category) {
    // Getting content for category: $category
    final content = ExploreMockData.getContentForCategory(category);
    // Raw content length: ${content.length}

    // Convert to ExploreContentCard list, handling both content cards and user profiles
    final result =
        content.map((item) {
          if (item is ExploreContentCard) {
            // Found content card: ${item.title}
            return item;
          } else if (item is ExploreUserProfile) {
            // Found user profile: ${item.handle}
            // Convert user profile to content card for display
            return ExploreContentCard(
              id: item.id,
              title: item.handle,
              imageUrl: item.profileImageUrl,
              category: item.category,
              contentType: 'Profile',
              isPremium: false,
            );
          }
          return item as ExploreContentCard;
        }).toList();

    // Converted to ${result.length} content cards
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppWhite,
      body: Stack(
        children: [
          // Main content area
          SafeArea(
            child: Column(
              children: [
                // Spacer for header height
                const SizedBox(height: kToolbarHeight),

                // Category Filters Row
                _buildCategoryFilters(context),

                // Content Feed
                Expanded(child: _buildContentFeed()),
              ],
            ),
          ),

          // Header overlay
          _buildHeader(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child:
            _isSearchVisible
                ? _buildSearchHeader()
                : Container(
                  height: kToolbarHeight,
                  color: kAppWhite,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildNormalHeader(),
                ),
      ),
    );
  }

  Widget _buildNormalHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(kLogoText, height: 28),
        const SizedBox(width: 5),
        Image.asset(kChevronDown),
        const Spacer(),
        GestureDetector(
          onTap: () {
            setState(() {
              _isSearchVisible = true;
            });
            // Focus the search field after the widget rebuilds
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _searchFocusNode.requestFocus();
            });
          },
          child: const Icon(Icons.search, color: kAppBlack, size: 24),
        ),
        const SizedBox(width: 15),
        GestureDetector(
          onTap: () {
            _openImmersiveMode();
          },
          child: Image.asset(kImmersiv, height: 24),
        ),
      ],
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: kBorderGreay,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Search icon
          SizedBox(
            width: 20,
            height: 20,
            child: Icon(Icons.search, color: Colors.grey, size: 16),
          ),
          const SizedBox(width: 8),
          // Search input field
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: const InputDecoration(
                hintText: 'What would you like to see ?',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              style: const TextStyle(color: Colors.black, fontSize: 16),
              onSubmitted: (value) {
                // TODO: Handle search
                print('Searching for: $value');
              },
            ),
          ),
          // Close button
          GestureDetector(
            onTap: () {
              setState(() {
                _isSearchVisible = false;
                _searchController.clear();
              });
              _searchFocusNode.unfocus();
            },
            child: SizedBox(
              width: 20,
              height: 20,
              child: Icon(Icons.close, color: Colors.black, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters(BuildContext context) {
    if (_isSearchVisible) {
      return _buildSearchSuggestions();
    }

    // Define categories with their data
    final categories = [
      {'name': 'For Arjun', 'icon': kForYou, 'key': 'for_arjun'},
      {'name': 'Elite Circle', 'icon': kEliteCircle, 'key': 'elite_circle'},
      {'name': 'Categories', 'icon': kCategories, 'key': 'categories'},
      {'name': 'Near Me', 'icon': kNearMe, 'key': 'near_me'},
      {'name': 'Find Buddies', 'icon': kFindBuddies, 'key': 'find_buddies'},
    ];

    // Reorder: selected category first, then others
    final orderedCategories = <Map<String, dynamic>>[];

    // Add selected category first (if any)
    if (selectedCategory != null) {
      final selected = categories.firstWhere(
        (cat) => cat['key'] == selectedCategory,
      );
      orderedCategories.add(selected);
    }

    // Add all unselected categories
    for (final category in categories) {
      if (category['key'] != selectedCategory) {
        orderedCategories.add(category);
      }
    }

    return SizedBox(
      height: 30,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            const SizedBox(width: 8),
            ...orderedCategories.map(
              (category) => Padding(
                padding: const EdgeInsets.only(right: 5),
                child: _buildCategoryPill(
                  context,
                  category['name'] as String,
                  category['icon'] as String,
                  category['key'] == selectedCategory,
                  category['key'] as String,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPill(
    BuildContext context,
    String name,
    String assetImage,
    bool isSelected,
    String categoryKey,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: () {
          setState(() {
            if (selectedCategory == categoryKey) {
              // If clicking the already selected category, deselect it
              selectedCategory = null;
            } else {
              // Select the new category
              selectedCategory = categoryKey;
              // Reload content for new category
              _loadContent();
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            gradient:
                isSelected
                    ? const LinearGradient(
                      colors: [kAppPurple, kAppOrange], // Purple to Orange
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                    : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: isSelected ? Colors.transparent : kBorderGreay,
              width: 1,
            ),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: kAppPurple.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Show cross icon when selected, original icon when not selected
              isSelected
                  ? const Icon(Icons.close, size: 14, color: Colors.white)
                  : Image.asset(assetImage, height: 14, color: kAppBlack),
              const SizedBox(width: 8),
              Text(
                name,
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : kAppBlack,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // New methods for enhanced functionality
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'What would you like to see?',
          hintStyle: kBodyMediumBlack.copyWith(color: kAppLightBlack),
          prefixIcon: const Icon(Icons.search, color: kAppBlack),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear, color: kAppBlack),
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kBorderGreay),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kAppPurple),
          ),
          filled: true,
          fillColor: kAppWhite,
        ),
      ),
    );
  }

  Widget _buildContentFeed() {
    // Show Elite Circle view when selected
    if (selectedCategory == 'elite_circle') {
      return _buildEliteCircleView();
    }

    // Building content feed. Content length: ${_currentContent.length}, Loading: $_isLoading

    if (_currentContent.isEmpty && _isLoading) {
      // Showing loading indicator
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(kAppPurple),
        ),
      );
    }

    if (_currentContent.isEmpty && !_isLoading) {
      // No content and not loading - showing empty state
      return const Center(
        child: Text(
          'No content available',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadContent();
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First grid: First 6 quickies
            _buildQuickiesGrid(0, 6),

            // Vertical Images Slider
            _buildVerticalSlider(),

            // Horizontal Images Slider
            _buildHorizontalSlider(),

            const SizedBox(height: 15),

            // Second grid: Remaining 6 quickies
            _buildQuickiesGrid(6, 12),

            // Loading indicator for infinite scroll
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(kAppPurple),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    final searchSuggestions = [
      'Chicken Pot Pie',
      'How to jive',
      'How to build muscle',
      'Date Ideas',
      'Style Snapshots',
      'Weekend Wonders',
      'The Snack Attack',
      'Behind the Lens',
      'Chill Beats, Hot Vibes',
      'Snack-Sized Stories',
    ];

    return SizedBox(
      height: 30,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            const SizedBox(width: 8),
            ...searchSuggestions.map(
              (suggestion) => Padding(
                padding: const EdgeInsets.only(right: 5),
                child: GestureDetector(
                  onTap: () {
                    _searchController.text = suggestion;
                    // TODO: Handle search suggestion tap
                    print('Searching for: $suggestion');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: kBorderGreay, width: 1),
                    ),
                    child: Text(
                      suggestion,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: kAppBlack,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickiesGrid(int startIndex, int endIndex) {
    final quickiesImages = [
      kExploreQuickies1,
      kExploreQuickies2,
      kExploreQuickies3,
      kExploreQuickies4,
      kExploreQuickies5,
      kExploreQuickies6,
      kExploreQuickies7,
      kExploreQuickies8,
      kExploreQuickies9,
      kExploreQuickies10,
      kExploreQuickies11,
      kExploreQuickies12,
    ];

    final quickiesTitles = [
      'Style Snapshots',
      'Weekend Wonders',
      'The Snack Attack...',
      'Behind the Lens',
      'Chill Beats, Hot Vib...',
      'Snack-Sized Stories',
      'Art in a Flash',
      'Glow Up Guide 101',
      'Zen in 10',
      'Morning Mood..',
      'Kitchen Chronicles',
      'Breaking up',
    ];

    final items = <Widget>[];
    for (int i = startIndex; i < endIndex && i < quickiesImages.length; i++) {
      items.add(_buildQuickieCard(quickiesTitles[i], quickiesImages[i]));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 0,
        childAspectRatio: 0.59,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return items[index];
      },
    );
  }

  Widget _buildVerticalSlider() {
    final verticalImages = [
      kExploreCollectionVertical1,
      kExploreCollectionVertical2,
      kExploreCollectionVertical3,
      kExploreCollectionVertical4,
    ];

    final verticalTitles = [
      'Style Snapshots',
      'Weekend Wonders',
      'The First Exploration - Part 1',
      'The First Exploration - Part 2',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title with subscribe badge
        Row(
          children: [
            Text(
              'Get in the Holiday Mood',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),

              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(kExploreLockIcon, width: 12, height: 12),
                  const SizedBox(width: 4),
                  Column(
                    children: [
                      SizedBox(height: 1),
                      Text(
                        'Subscribe',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall!.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: kAppYellow,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Vertical images slider
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: verticalImages.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _openImmersiveMode(),
                child: Container(
                  width: 100,
                  height: 160,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Image with fixed aspect ratio
                        AspectRatio(
                          aspectRatio: 0.8,
                          child: Image.asset(
                            verticalImages[index],
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.error),
                              );
                            },
                          ),
                        ),
                        // Title - NO BACKGROUND COLOR
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(
                            verticalTitles[index],
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall!.copyWith(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalSlider() {
    final horizontalImages = [
      kExploreCollectionHorizontal1,
      kExploreCollectionHorizontal2,
    ];

    final horizontalTitles = ['Deck the Wardr..', 'Santa\'s Secret Sp..'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title with subscribe badge
        Row(
          children: [
            Text(
              'Horizontal Collection',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),

              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(kExploreLockIcon, width: 12, height: 12),
                  const SizedBox(width: 4),
                  Column(
                    children: [
                      SizedBox(height: 1),
                      Text(
                        'Subscribe',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall!.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: kAppYellow,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Horizontal images slider
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: horizontalImages.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _openImmersiveMode(),
                child: Container(
                  width: 220,
                  height: 160,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Image with fixed aspect ratio
                        AspectRatio(
                          aspectRatio: 1.6,
                          child: Image.asset(
                            horizontalImages[index],
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.error),
                              );
                            },
                          ),
                        ),
                        // Title - NO BACKGROUND COLOR
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(
                            horizontalTitles[index],
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall!.copyWith(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickieCard(String title, String imagePath) {
    return GestureDetector(
      onTap: () => _openImmersiveMode(),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image with fixed aspect ratio
              AspectRatio(
                aspectRatio: 0.7, // Square images
                child: Image.asset(
                  imagePath,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              // Title - NO BACKGROUND COLOR
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEliteCircleView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 16, left: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Regional favourites
          _buildEliteSection('Regional favourites', _getRegionalFavourites()),

          // Best in their genre
          _buildEliteSection('Best in their genre', _getBestInGenre()),

          // New and rising stars
          _buildEliteSection('New and rising stars', _getNewAndRising()),

          // All-Time Favourites
          _buildEliteSection('All-Time Favourites', _getAllTimeFavourites()),

          // Promotional collaboration picks
          _buildEliteSection(
            'Promotional collaboration picks',
            _getPromotionalPicks(),
          ),
          const SizedBox(height: 24), // Extra spacing at bottom
        ],
      ),
    );
  }

  Widget _buildEliteSection(String title, List<Map<String, String>> creators) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: creators.length,
            itemBuilder: (context, index) {
              return _buildCreatorCard(creators[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCreatorCard(Map<String, String> creator) {
    return GestureDetector(
      onTap: () => _navigateToCreatorProfile(creator['username']!),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 8),
        child: Column(
          children: [
            // Profile image
            Container(
              width: 100,
              height: 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: AssetImage(creator['profileImage']!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 2),
            // Username
            Text(
              '@${creator['username']}',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCreatorProfile(String username) {
    // TODO: Navigate to creator profile page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening @$username profile...'),
        backgroundColor: kAppPurple,
      ),
    );
  }

  // Mock data methods
  List<Map<String, String>> _getRegionalFavourites() {
    return [
      {'username': 'mumbai_creator', 'profileImage': kExploreProfile1},
      {'username': 'delhi_artist', 'profileImage': kExploreProfile2},
      {'username': 'bangalore_creator', 'profileImage': kExploreProfile3},
      {'username': 'chennai_artist', 'profileImage': kExploreProfile4},
      {'username': 'kolkata_creator', 'profileImage': kExploreProfile5},
      {'username': 'pune_artist', 'profileImage': kExploreProfile6},
    ];
  }

  List<Map<String, String>> _getBestInGenre() {
    return [
      {'username': 'comedy_king', 'profileImage': kExploreProfile7},
      {'username': 'dance_queen', 'profileImage': kExploreProfile8},
      {'username': 'music_maestro', 'profileImage': kExploreProfile9},
      {'username': 'art_genius', 'profileImage': kExploreProfile10},
      {'username': 'fitness_guru', 'profileImage': kExploreProfile11},
      {'username': 'food_critic', 'profileImage': kExploreProfile12},
    ];
  }

  List<Map<String, String>> _getNewAndRising() {
    return [
      {'username': 'rising_star1', 'profileImage': kExploreProfile13},
      {'username': 'new_talent2', 'profileImage': kExploreProfile14},
      {'username': 'fresh_face3', 'profileImage': kExploreProfile15},
      {'username': 'upcoming4', 'profileImage': kExploreProfile16},
      {'username': 'budding5', 'profileImage': kExploreProfile17},
      {'username': 'emerging6', 'profileImage': kExploreProfile18},
    ];
  }

  List<Map<String, String>> _getAllTimeFavourites() {
    return [
      {'username': 'legend1', 'profileImage': kExploreProfile19},
      {'username': 'icon2', 'profileImage': kExploreProfile20},
      {'username': 'classic3', 'profileImage': kExploreProfile21},
      {'username': 'timeless4', 'profileImage': kExploreProfile22},
      {'username': 'evergreen5', 'profileImage': kExploreProfile23},
      {'username': 'eternal6', 'profileImage': kExploreProfile24},
    ];
  }

  List<Map<String, String>> _getPromotionalPicks() {
    return [
      {'username': 'brand_ambassador1', 'profileImage': kExploreProfile1},
      {'username': 'sponsored2', 'profileImage': kExploreProfile2},
      {'username': 'collab_king3', 'profileImage': kExploreProfile3},
      {'username': 'partnership4', 'profileImage': kExploreProfile4},
      {'username': 'endorsement5', 'profileImage': kExploreProfile5},
      {'username': 'promo_star6', 'profileImage': kExploreProfile6},
    ];
  }

  void _openImmersiveMode() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => ImmersiveModeScreen(
              initialIndex: 0,
              posts: ImmersiveMockData.getImmersivePosts(),
            ),
        transitionDuration: const Duration(milliseconds: 100),
        reverseTransitionDuration: const Duration(milliseconds: 100),
        opaque: false, // Make it transparent during transition
        barrierDismissible: true,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Create a more dramatic scale and fade effect
          var scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          );

          var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          );

          // Add a slight rotation for more dynamic feel
          var rotationAnimation = Tween<double>(begin: 0.05, end: 0.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          );

          return FadeTransition(
            opacity: fadeAnimation,
            child: Transform.scale(
              scale: scaleAnimation.value,
              child: Transform.rotate(
                angle: rotationAnimation.value,
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }
}
