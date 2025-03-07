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
import 'package:sociord/utils/app_constants.dart';
import 'package:sociord/widgets/custom_snack_bar.dart';
import 'package:sociord/widgets/dashed_progress_indicator.dart';
import 'package:sociord/widgets/go_back_btn.dart';

class PersonalityFlow extends ConsumerStatefulWidget {
  static const routeName = '/personality-flow';
  const PersonalityFlow({super.key});

  @override
  _PersonalityFlowState createState() => _PersonalityFlowState();
}

class _PersonalityFlowState extends ConsumerState<PersonalityFlow> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool isLoading = false;
  final List<bool> soundtrackSelectedOptions =
      List.generate(11, (index) => false);
  final List<bool> weekendSelectedOptions = List.generate(11, (index) => false);
  final List<bool> connectionSelectedOptions =
      List.generate(6, (index) => false);
  final List<bool> movieSelectedOptions = List.generate(12, (index) => false);
  final List<bool> petSelectedOptions = List.generate(5, (index) => false);

  continueButtonClick(
      {selectedOptions,
      stage,
      userPersonalityStatee,
      userPersonalityNotifierr}) async {
    List<String> selectedIds = [];

    try {
      setState(() {
        isLoading = true;
      });

      var result;
      if (stage == 'soundtrack') {
        // print('aaaaaaaa');
        // print(userPersonalityState.soundTrackOption);
        for (int i = 0; i < selectedOptions.length; i++) {
          if (selectedOptions[i]) {
            // Assuming `id` is an integer, modify if it's another type (e.g. String)
            selectedIds.add(userPersonalityStatee.soundTrackOption[i]!.id);
          }
        }
        // result = await userPersonalityNotifierr.addUserSoundtrackSelection(
        //     'user_m0kjdkalpke', selectedIds);
        result = await userPersonalityNotifierr.addUserSoundtrackSelection(
            ref.watch(userNotifierProvider).userId, selectedIds);
      } else if (stage == 'weekend') {
        for (int i = 0; i < selectedOptions.length; i++) {
          if (selectedOptions[i]) {
            // Assuming `id` is an integer, modify if it's another type (e.g. String)
            selectedIds.add(userPersonalityStatee.weekendOption[i]!.id);
          }
        }
        result = await userPersonalityNotifierr.addUserWeekendSelection(
            ref.watch(userNotifierProvider).userId, selectedIds);
      } else if (stage == 'connect') {
        for (int i = 0; i < selectedOptions.length; i++) {
          if (selectedOptions[i]) {
            // Assuming `id` is an integer, modify if it's another type (e.g. String)
            selectedIds.add(userPersonalityStatee.connectOption[i]!.id);
          }
        }
        result = await userPersonalityNotifierr.addUserConnectSelection(
            ref.watch(userNotifierProvider).userId, selectedIds);
      } else if (stage == 'movie') {
        for (int i = 0; i < selectedOptions.length; i++) {
          if (selectedOptions[i]) {
            // Assuming `id` is an integer, modify if it's another type (e.g. String)
            selectedIds.add(userPersonalityStatee.bingeWatchOption[i]!.id);
          }
        }
        result = await userPersonalityNotifierr.addUserBingeWatchSelection(
            ref.watch(userNotifierProvider).userId, selectedIds);
      } else if (stage == 'pet') {
        for (int i = 0; i < selectedOptions.length; i++) {
          if (selectedOptions[i]) {
            // Assuming `id` is an integer, modify if it's another type (e.g. String)
            selectedIds.add(userPersonalityStatee.petOption[i]!.id);
          }
        }
        result = await userPersonalityNotifierr.addUserPetSelection(
            ref.watch(userNotifierProvider).userId, selectedIds);
      }

      setState(() {
        isLoading = false;
      });
      if (result != null) {
        _pageController.nextPage(
          duration: Duration(milliseconds: 100),
          curve: Curves.easeIn,
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (e.toString().contains('Connection refused')) {
        ScaffoldMessenger.of(context)
            .showSnackBar(CustomSnackBar().build(context));
      } else {
        print(e.toString());
      }
    }

    // widget.pageController.nextPage(
    //   duration: Duration(milliseconds: 300),
    //   curve: Curves.easeIn,
    // );
  }

  @override
  Widget build(BuildContext context) {
    var userPersonalityState;
    ref.listen<UserPersonalityModel>(
      userPersonalityNotifierProvider,
      (previous, next) {
        // Handle updated state here
        userPersonalityState = next;
      },
    );
    var userPersonalityNotifier =
        ref.read(userPersonalityNotifierProvider.notifier);

    final List<Widget> _pages = [
      PersonalityPage(
          title: "What's your soundtrack?",
          subtitle: "Pick atleast 1 option that defines your vibe",
          content: SoundtrackSelectionScreen(
            pageController: _pageController,
            selectedOptions: soundtrackSelectedOptions,
          )),
      PersonalityPage(
          title: "What's your ideal weekend?",
          subtitle:
              "Select at least one way you prefer to spend your free time",
          content: WeekendSelectionScreen(
            pageController: _pageController,
            selectedOptions: weekendSelectedOptions,
          )),
      PersonalityPage(
          title: "How do you connect?",
          subtitle: "Pick the kind of interaction you prefer",
          content: ConnectSelectionScreen(
              pageController: _pageController,
              selectedOptions: connectionSelectedOptions)),
      PersonalityPage(
          title: "What's your binge watch made of?",
          subtitle: "Select the types of stories you love",
          content: MovieSelectionScreen(
              pageController: _pageController,
              selectedOptions: movieSelectedOptions)),
      PersonalityPage(
          title: "Which mythical pet would you want?",
          subtitle: "Might sound odd, but please humor us.",
          content: PetSelectionScreen(
              pageController: _pageController,
              selectedOptions: petSelectedOptions)),
      // Add other pages here
    ];
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 50,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: _currentPage == 0
                ? const SizedBox()
                : GoBackButton(
                    onPressedFunction: () {
                      if (_currentPage == 0) {
                        Navigator.pop(context);
                      } else {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      }
                    },
                  ),
          ),
          const SizedBox(
            height: 25,
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DashedProgressIndicator(
                totalSteps: _pages.length,
                currentStep: _currentPage + 1,
              )),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return _pages[index];
              },
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.only(bottom: 20, top: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0.0),
                ),
              ),
              onPressed: () {
                if (_currentPage == 0) {
                  continueButtonClick(
                      selectedOptions: soundtrackSelectedOptions,
                      stage: 'soundtrack',
                      userPersonalityNotifierr: userPersonalityNotifier,
                      userPersonalityStatee: userPersonalityState);
                } else if (_currentPage == 1) {
                  continueButtonClick(
                      selectedOptions: weekendSelectedOptions,
                      stage: 'weekend',
                      userPersonalityNotifierr: userPersonalityNotifier,
                      userPersonalityStatee: userPersonalityState);
                } else if (_currentPage == 2) {
                  continueButtonClick(
                      selectedOptions: connectionSelectedOptions,
                      stage: 'connect',
                      userPersonalityNotifierr: userPersonalityNotifier,
                      userPersonalityStatee: userPersonalityState);
                } else if (_currentPage == 3) {
                  continueButtonClick(
                      selectedOptions: movieSelectedOptions,
                      stage: 'movie',
                      userPersonalityNotifierr: userPersonalityNotifier,
                      userPersonalityStatee: userPersonalityState);
                } else if (_currentPage == 4) {
                  continueButtonClick(
                      selectedOptions: petSelectedOptions,
                      stage: 'pet',
                      userPersonalityNotifierr: userPersonalityNotifier,
                      userPersonalityStatee: userPersonalityState);
                }
              },
              child: isLoading
                  ? kLoadingIndicator
                  : Text(
                      'Continue',
                      style: Theme.of(context).textTheme.headlineSmall,
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

  const PersonalityPage(
      {super.key,
      this.title,
      this.subtitle,
      required this.content,
      this.largeText = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: largeText ? 50 : 40,
        ),
        title != null
            ? Padding(
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
              )
            : const SizedBox(),
        SizedBox(height: largeText ? 5 : 3),
        subtitle != null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        color: kAppPurple,
                        fontSize: largeText ? 15 : 12,
                      ),
                ),
              )
            : const SizedBox(),
        content
      ],
    );
  }
}
