import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sociord/screens/personality/personality_flow.dart';
import 'package:sociord/utils/app_constants.dart';
import 'package:sociord/widgets/dashed_progress_indicator.dart';
import 'package:sociord/widgets/go_back_btn.dart';

class BecomeACreator extends StatefulWidget {
  const BecomeACreator({super.key});

  @override
  State<BecomeACreator> createState() => _BecomeACreatorState();
}

class _BecomeACreatorState extends State<BecomeACreator> {
  late PageController _pageController;
  int _currentPage = 0;
  bool isLoading = false;

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

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      PersonalityPage(
          title: "What's your soundtrack?",
          subtitle: "Pick atleast 1 option that defines your vibe",
          content: SizedBox()),
      PersonalityPage(
          title: "What's your ideal weekend?",
          subtitle:
              "Select at least one way you prefer to spend your free time",
          content: SizedBox()),
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
              onPressed: () {},
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
