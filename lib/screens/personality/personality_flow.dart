import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sociord/provider/onboarding_provider.dart';
import 'package:sociord/provider/auth_notifier.dart';
import 'package:sociord/provider/user_personality_provider.dart';
import 'package:sociord/provider/user_provider.dart';
import 'package:sociord/screens/personality/connect_selection.dart';
import 'package:sociord/screens/personality/movie_selection.dart';
import 'package:sociord/screens/personality/pet_selection.dart';
import 'package:sociord/screens/personality/soundtrack_selection_screen.dart';
import 'package:sociord/screens/personality/weekend_selection_screen.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/widgets/custom_snack_bar.dart';
import 'package:sociord/widgets/dashed_progress_indicator.dart';
import 'package:sociord/widgets/go_back_btn.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

class PersonalityFlow extends ConsumerStatefulWidget {
  static const routeName = '/personality-flow';
  const PersonalityFlow({super.key});

  @override
  _PersonalityFlowState createState() => _PersonalityFlowState();
}

class _PersonalityFlowState extends ConsumerState<PersonalityFlow> {
  late PageController _pageController;
  int _currentPage = 0;
  bool isLoading = false;
  bool showSuccess = false;

  final List<bool> soundtrackSelectedOptions = List.generate(11, (_) => false);
  final List<bool> weekendSelectedOptions = List.generate(11, (_) => false);
  final List<bool> connectionSelectedOptions = List.generate(6, (_) => false);
  final List<bool> movieSelectedOptions = List.generate(12, (_) => false);
  final List<bool> petSelectedOptions = List.generate(5, (_) => false);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    // Debug: Check userId when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userState = ref.read(userNotifierProvider);
      print('=== Personality Flow Init ===');
      print('User ID on init: ${userState.userId}');
      print('User ID is empty: ${userState.userId?.isEmpty ?? true}');
      print('============================');
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> handleContinueClick() async {
    // Prevent multiple clicks while processing
    if (isLoading) return;

    final notifier = ref.read(userPersonalityNotifierProvider.notifier);
    final state = ref.read(userPersonalityNotifierProvider);

    // Get userId - try both watch and read
    final userState = ref.watch(userNotifierProvider);
    final userId = userState.userId;

    // Debug logging
    print('=== Personality Flow Debug ===');
    print('User State: $userState');
    print('User ID: $userId');
    print('User ID is null: ${userId == null}');
    print('User ID is empty: ${userId?.isEmpty ?? true}');
    print('=============================');

    // Validate userId exists - use the one we got or try direct access
    String? finalUserId = userId;
    if (finalUserId == null || finalUserId.isEmpty) {
      // Try to get it from the notifier directly
      final directUserId = ref.read(userNotifierProvider).userId;
      print('Direct User ID check: $directUserId');

      if (directUserId == null || directUserId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User ID not found. Please login again.'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
      finalUserId = directUserId;
    }

    // Use finalUserId for the rest of the function
    // At this point, finalUserId is guaranteed to be non-null and non-empty
    final String actualUserId = finalUserId;

    try {
      setState(() {
        isLoading = true;
        showSuccess = false;
      });

      List<String> selectedIds = [];
      List<bool> selectedOptions = [];
      List<dynamic> options = [];
      Future<String?> Function(String, List<String>)? submitFn;

      // Determine which page we're on and get the corresponding data
      switch (_currentPage) {
        case 0: // Soundtrack selection
          selectedOptions = soundtrackSelectedOptions;
          options = state.soundTrackOption;
          submitFn = notifier.addUserSoundtrackSelection;
          break;
        case 1: // Weekend selection
          selectedOptions = weekendSelectedOptions;
          options = state.weekendOption;
          submitFn = notifier.addUserWeekendSelection;
          break;
        case 2: // Connect selection
          selectedOptions = connectionSelectedOptions;
          options = state.connectOption;
          submitFn = notifier.addUserConnectSelection;
          break;
        case 3: // Movie/Binge watch selection
          selectedOptions = movieSelectedOptions;
          options = state.bingeWatchOption;
          submitFn = notifier.addUserBingeWatchSelection;
          break;
        case 4: // Pet selection (last page)
          selectedOptions = petSelectedOptions;
          options = state.petOption;
          submitFn = notifier.addUserPetSelection;
          break;
        default:
          setState(() => isLoading = false);
          return;
      }

      // Check if options are loaded
      if (options.isEmpty) {
        // If options aren't loaded yet, try to load them
        switch (_currentPage) {
          case 0:
            options = await notifier.getSoundtrackOptions();
            break;
          case 1:
            options = await notifier.getWeekendOption();
            break;
          case 2:
            options = await notifier.getConnectOption();
            break;
          case 3:
            options = await notifier.getBingeWatchOption();
            break;
          case 4:
            options = await notifier.getPetOption();
            break;
        }
      }

      // Collect selected option IDs
      for (int i = 0; i < selectedOptions.length && i < options.length; i++) {
        if (selectedOptions[i] && options[i] != null) {
          selectedIds.add(options[i]!.id);
        }
      }

      // Validate that at least one option is selected
      if (selectedIds.isEmpty) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one option to continue.'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      // Save selection to backend
      // submitFn is guaranteed to be non-null after the switch statement
      final result = await submitFn(actualUserId, selectedIds);

      if (!mounted) return;

      if (result != null && result.isNotEmpty) {
        // Brief success state with checkmark before navigating
        setState(() {
          isLoading = false;
          showSuccess = true;
        });

        await Future.delayed(const Duration(milliseconds: 400));

        if (!mounted) return;

        if (_currentPage < 4) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeIn,
          );
        } else {
          // Final step of onboarding: log user in, mark onboarding complete, then go to profile
          await ref.read(authProvider.notifier).login(token: actualUserId);
          ref.read(onboardingProvider.notifier).setDone(true);
          context.go('/profile');
        }

        // Reset button back to normal for next screen
        setState(() {
          showSuccess = false;
        });
      } else {
        setState(() {
          isLoading = false;
          showSuccess = false;
        });
        // If save failed, show error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save selection. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          showSuccess = false;
        });
      }
      print('Error in handleContinueClick: $e');

      if (e.toString().contains('Connection refused') ||
          e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(CustomSnackBar().build(context));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      PersonalityPage(
        title: "What's your soundtrack?",
        subtitle: "Pick atleast 1 option that defines your vibe",
        content: SoundtrackSelectionScreen(
          pageController: _pageController,
          selectedOptions: soundtrackSelectedOptions,
        ),
      ),
      PersonalityPage(
        title: "What's your ideal weekend?",
        subtitle: "Select at least one way you prefer to spend your free time",
        content: WeekendSelectionScreen(
          pageController: _pageController,
          selectedOptions: weekendSelectedOptions,
        ),
      ),
      PersonalityPage(
        title: "How do you connect?",
        subtitle: "Pick the kind of interaction you prefer",
        content: ConnectSelectionScreen(
          pageController: _pageController,
          selectedOptions: connectionSelectedOptions,
        ),
      ),
      PersonalityPage(
        title: "What's your binge watch made of?",
        subtitle: "Select the types of stories you love",
        content: MovieSelectionScreen(
          pageController: _pageController,
          selectedOptions: movieSelectedOptions,
        ),
      ),
      PersonalityPage(
        title: "Which mythical pet would you want?",
        subtitle: "Might sound odd, but please humor us.",
        content: PetSelectionScreen(
          pageController: _pageController,
          selectedOptions: petSelectedOptions,
        ),
      ),
    ];

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child:
                _currentPage > 0
                    ? GoBackButton(
                      onPressedFunction: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      },
                    )
                    : const SizedBox(),
          ),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DashedProgressIndicator(
              totalSteps: pages.length,
              currentStep: _currentPage + 1,
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (int page) {
                setState(() => _currentPage = page);
              },
              itemCount: pages.length,
              itemBuilder: (_, index) => pages[index],
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: const RoundedRectangleBorder(),
              ),
              // Keep button visually enabled; guard inside handler instead
              onPressed: handleContinueClick,
              child:
                  showSuccess
                      ? const Icon(Icons.check_circle, color: Colors.white)
                      : isLoading
                      ? Shimmer.fromColors(
                        baseColor: Colors.white,
                        highlightColor: Colors.white70,
                        child: Text(
                          '...',
                          style: Theme.of(context).textTheme.headlineSmall!
                              .copyWith(color: Colors.white),
                        ),
                      )
                      : Text(
                        'Continue',
                        style: Theme.of(context).textTheme.headlineSmall!
                            .copyWith(color: Colors.white),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}

class PersonalityPage extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget content;
  final bool largeText;

  const PersonalityPage({
    super.key,
    this.title,
    this.subtitle,
    required this.content,
    this.largeText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: largeText ? 50 : 40),
        if (title != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              title!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style:
                  largeText
                      ? Theme.of(context).textTheme.headlineLarge
                      : Theme.of(
                        context,
                      ).textTheme.headlineLarge!.copyWith(fontSize: 18),
            ),
          ),
        SizedBox(height: largeText ? 5 : 3),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              subtitle!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                color: kAppPurple,
                fontSize: largeText ? 15 : 12,
              ),
            ),
          ),
        Expanded(child: content),
      ],
    );
  }
}
