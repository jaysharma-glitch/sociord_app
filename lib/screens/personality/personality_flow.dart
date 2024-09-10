import 'package:flutter/material.dart';
import 'package:sociord/screens/personality/connect_selection.dart';
import 'package:sociord/screens/personality/movie_selection.dart';
import 'package:sociord/screens/personality/pet_selection.dart';
import 'package:sociord/screens/personality/soundtrack_selection_screen.dart';
import 'package:sociord/screens/personality/weekend_selection_screen.dart';
import 'package:sociord/utils/app_constants.dart';
import 'package:sociord/widgets/dashed_progress_indicator.dart';
import 'package:sociord/widgets/go_back_btn.dart';

class PersonalityFlow extends StatefulWidget {
  static const routeName = '/personality-flow';
  const PersonalityFlow({super.key});

  @override
  State<PersonalityFlow> createState() => _PersonalityFlowState();
}

class _PersonalityFlowState extends State<PersonalityFlow> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      PersonalityPage(
          title: "What's your soundtrack?",
          subtitle: "Pick atleast 1 option that defines your vibe",
          content: SoundtrackSelectionScreen(pageController: _pageController)),
      PersonalityPage(
          title: "What's your ideal weekend?",
          subtitle:
              "Select at least one way you prefer to spend your free time",
          content: WeekendSelectionScreen(pageController: _pageController)),
      PersonalityPage(
          title: "How do you connect?",
          subtitle: "Pick the kind of interaction you prefer",
          content: ConnectSelectionScreen(pageController: _pageController)),
      PersonalityPage(
          title: "What's your binge watch made of?",
          subtitle: "Select the types of stories you love",
          content: MovieSelectionScreen(pageController: _pageController)),
      PersonalityPage(
          title: "Which mythical pet would you want?",
          subtitle: "Might sound odd, but please humor us.",
          content: PetSelectionScreen(pageController: _pageController)),
      // Add other pages here
    ];
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
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
          ],
        ),
      ),
    );
  }
}

class PersonalityPage extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget content;

  const PersonalityPage(
      {super.key, required this.title, this.subtitle, required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 50,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ),
        const SizedBox(height: 5),
        subtitle != null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      color: kAppPurple,
                      fontSize: 15,
                      fontWeight: FontWeight.w800),
                ),
              )
            : const SizedBox(),
        content
      ],
    );
  }
}
