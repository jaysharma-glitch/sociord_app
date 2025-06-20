import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sociord/models/user_personality_model.dart';
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
import 'package:sociord/constants/ui.dart';
import 'package:go_router/go_router.dart';

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
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> handleContinueClick() async {
    final notifier = ref.read(userPersonalityNotifierProvider.notifier);
    final state = ref.read(userPersonalityNotifierProvider);
    final userId = ref.read(userNotifierProvider).userId;

    _pageController.nextPage(
        duration: Duration(milliseconds: 200), curve: Curves.easeIn);

    // try {
    //   setState(() => isLoading = true);

    //   List<String> selectedIds = [];
    //   List<bool> selectedOptions = [];
    //   List<dynamic> options = [];
    //   Future<dynamic> Function(String, List<String>)? submitFn;

    //   switch (_currentPage) {
    //     case 0:
    //       selectedOptions = soundtrackSelectedOptions;
    //       options = state.soundTrackOption;
    //       submitFn = notifier.addUserSoundtrackSelection;
    //       break;
    //     case 1:
    //       selectedOptions = weekendSelectedOptions;
    //       options = state.weekendOption;
    //       submitFn = notifier.addUserWeekendSelection;
    //       break;
    //     case 2:
    //       selectedOptions = connectionSelectedOptions;
    //       options = state.connectOption;
    //       submitFn = notifier.addUserConnectSelection;
    //       break;
    //     case 3:
    //       selectedOptions = movieSelectedOptions;
    //       options = state.bingeWatchOption;
    //       submitFn = notifier.addUserBingeWatchSelection;
    //       break;
    //     case 4:
    //       selectedOptions = petSelectedOptions;
    //       options = state.petOption;
    //       submitFn = notifier.addUserPetSelection;
    //       break;
    //   }

    //   for (int i = 0; i < selectedOptions.length; i++) {
    //     if (selectedOptions[i]) selectedIds.add(options[i]!.id);
    //   }

    //   final result = await submitFn!(userId!, selectedIds);
    //   setState(() => isLoading = false);

    //   if (result != null) {
    //     if (_currentPage < 4) {
    //       _pageController.nextPage(
    //           duration: Duration(milliseconds: 200), curve: Curves.easeIn);
    //     } else {
    //       context.go('/home'); // Adjust as per next step after personality
    //     }
    //   }
    // } catch (e) {
    //   setState(() => isLoading = false);
    //   if (e.toString().contains('Connection refused')) {
    //     ScaffoldMessenger.of(context)
    //         .showSnackBar(CustomSnackBar().build(context));
    //   } else {
    //     print(e);
    //   }
    // }
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
            child: _currentPage > 0
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
              onPressed: handleContinueClick,
              child: isLoading
                  ? kLoadingIndicator
                  : Text(
                      'Continuee',
                      style:
                          Theme.of(context).textTheme.headlineSmall!.copyWith(
                                color: Colors.white,
                              ),
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
              style: largeText
                  ? Theme.of(context).textTheme.headlineLarge
                  : Theme.of(context)
                      .textTheme
                      .headlineLarge!
                      .copyWith(fontSize: 18),
            ),
          ),
        SizedBox(height: largeText ? 5 : 3),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              subtitle!,
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: kAppPurple,
                    fontSize: largeText ? 15 : 12,
                  ),
            ),
          ),
        content,
      ],
    );
  }
}
