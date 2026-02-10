// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sociord/provider/user_provider.dart';
import 'package:sociord/provider/auth_notifier.dart';
import 'package:sociord/provider/onboarding_provider.dart';
import 'package:sociord/models/user_model.dart';
import 'package:sociord/models/location_model.dart';
import 'package:sociord/widgets/profile/profile_component.dart';
import 'package:sociord/widgets/profile/homePagePosts/profile_hero.dart';
import 'package:sociord/widgets/profile/profile_posts.dart'
    show UserType, ProfileViewType;
import 'package:sociord/widgets/profile/homePagePosts/profile_hero.dart'
    show RelationshipType;
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/utils/routes.dart';
import 'package:sociord/widgets/skeleton/skeleton_loader_profile.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _loadRequested = false;
  bool _isLoadingUser = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUserIfNeeded());
  }

  Future<void> _loadUserIfNeeded() async {
    if (_isLoadingUser) return;
    var user = ref.read(userNotifierProvider);
    final notifier = ref.read(userNotifierProvider.notifier);

    if (user.userId == null || user.userId!.isEmpty) {
      final authState = await ref.read(authProvider.future);
      final token = authState.token;
      if (token != null && token.isNotEmpty) {
        notifier.setUserId(token);
        user = ref.read(userNotifierProvider);
      } else {
        return;
      }
    }

    if (user.userId == null || user.userId!.isEmpty) return;

    // Claim load immediately so a second schedule (e.g. from build) doesn't run in parallel
    _loadRequested = true;
    if (mounted) setState(() => _isLoadingUser = true);
    try {
      await notifier.getUser();
    } catch (e) {
      // Service/notifier should return null on USER_NOT_FOUND; catch any unexpected throw
      if (mounted) debugPrint('ProfileScreen._loadUserIfNeeded: $e');
    } finally {
      if (mounted) setState(() => _isLoadingUser = false);
    }
  }

  void toggleProfileType() {
    final user = ref.read(userNotifierProvider);
    final currentType = user.profileType ?? 'Personal';
    final newType = currentType == 'Personal' ? 'Creator' : 'Personal';

    ref.read(userNotifierProvider.notifier).setProfileType(newType);
    setState(() {});
  }

  Future<void> _handleLogout() async {
    await ref.read(authProvider.notifier).logout();
    ref.invalidate(userNotifierProvider);
    ref.read(onboardingProvider.notifier).setDone(false);
    if (mounted) {
      context.go(signInSignUpRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userNotifierProvider);
    final authState = ref.watch(authProvider);

    // When we have token but profile data is missing (or no userId yet), trigger load once (e.g. after app restart)
    final hasToken = authState.value?.token != null && authState.value!.token!.isNotEmpty;
    final hasUserId = user.userId != null && user.userId!.isNotEmpty;
    final missingProfileData = (user.firstName == null || user.firstName!.isEmpty);
    final shouldLoad = hasToken && (missingProfileData || !hasUserId) && !_loadRequested && !_isLoadingUser;
    if (shouldLoad) {
      // Schedule once per frame to avoid repeated schedules and glitching
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_loadRequested || _isLoadingUser) return;
        _loadUserIfNeeded();
      });
    }

    if (_isLoadingUser) {
      return const Scaffold(
        body: SingleChildScrollView(
          child: SkeletonLoaderProfile(),
        ),
      );
    }

    // Certified creator status (for buttons / dashboard); banner is driven by intention set during onboarding
    final isCreator = user.isCreator == true;
    // Banner and creator-style UI on profile are based on intention (creator vs explorer), not certified status
    final showCreatorBanner = user.creatorIntention?.toLowerCase() == 'creator';

    final displayGender = _buildGenderLabel(user);
    final ageCohort = (user.ageCohort != null && user.ageCohort!.isNotEmpty)
        ? user.ageCohort!
        : _buildAgeCohort(user.birthDate);
    final locationLabel = _buildLocationLabel(user.location);

    final nameParts = <String>[];
    if (user.firstName != null && user.firstName!.trim().isNotEmpty) {
      nameParts.add(user.firstName!);
    }
    if (user.lastName != null && user.lastName!.trim().isNotEmpty) {
      nameParts.add(user.lastName!);
    }
    final name = nameParts.join(' ').trim();
    final handle = (user.userName != null && user.userName!.trim().isNotEmpty)
        ? '@${user.userName!.trim()}'
        : '';
    final hasHighlights = false; // TODO: from API when highlights endpoint exists

    final userData = ProfileData(
      imageUrl: user.profilePic ?? kProfilePic,
      name: name.isNotEmpty ? name : 'User',
      gender: displayGender,
      age: ageCohort,
      location: locationLabel,
      handle: handle.isNotEmpty ? handle : '—',
      buddies: 0, // TODO: from API when counts exist
      subscriptions: 0,
      following: 0,
      creatorCategory: showCreatorBanner ? (user.contentType ?? '') : null,
      isVerified: false,
      hasHighlightData: hasHighlights,
      highlightImages: null,
      highlightNames: null,
    );

    return ProfileComponent(
      userType: showCreatorBanner ? UserType.creator : UserType.explorer,
      isCertifiedCreator: isCreator,
      viewType: ProfileViewType.own,
      relationship: RelationshipType.none,
      userData: userData,
      onEditProfilePressed: () {
        context.go("/profile/becomeACreator");
      },
      onSettingsPressed: () {
        // Navigate to settings
      },
      onToggleProfileType: toggleProfileType,
      onLogout: _handleLogout,
    );
  }

  String _buildGenderLabel(UserModel user) {
    if ((user.gender ?? '').toLowerCase() == 'other' &&
        (user.otherIdentity != null && user.otherIdentity!.isNotEmpty)) {
      return user.otherIdentity!;
    }
    return user.gender ?? '—';
  }

  String _buildAgeCohort(DateTime? birthDate) {
    if (birthDate == null) return '';
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    final hadBirthdayThisYear = (now.month > birthDate.month) ||
        (now.month == birthDate.month && now.day >= birthDate.day);
    if (!hadBirthdayThisYear) age--;

    if (age >= 57) return 'Boomer';
    if (age >= 41) return 'Gen X';
    if (age >= 27) return 'Millennial';
    if (age >= 12) return 'Gen Z';
    return 'Alpha'; // under 12
  }

  String _buildLocationLabel(LocationModel? location) {
    if (location == null) return '';
    final city = location.city;
    final state = location.state;
    if (city.isNotEmpty && state.isNotEmpty) {
      return '$city, $state';
    }
    return city.isNotEmpty ? city : state;
  }
}
