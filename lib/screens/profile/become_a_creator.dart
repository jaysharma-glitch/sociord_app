import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sociord/screens/personality/personality_flow.dart';
import 'package:sociord/screens/profile/apply_final.dart';
import 'package:sociord/screens/profile/payment_preference.dart';
import 'package:sociord/screens/profile/pick_category.dart';
import 'package:sociord/screens/profile/price_selection.dart';
import 'package:sociord/constants/ui.dart';

import 'package:sociord/utils/asset_path_constants.dart';
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
  bool categoryNotFound = false;
  final List<bool> categorySelectedOptions =
      List.generate(12, (index) => false);

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
          largeText: false,
          title: "Pick Your category",
          subtitle: "Choose the category that fits your content.",
          content: PickCategory(
              selectedOptions: categorySelectedOptions,
              categoryNotFound: categoryNotFound,
              pageController: _pageController)),
      PersonalityPage(
          largeText: false,
          title: "Pick your payment preference",
          subtitle: "How do we pay you?",
          content: PaymentPreference(pageController: _pageController)),
      PersonalityPage(
          largeText: false,
          title: "Set your pricing",
          subtitle: "How much should subscribers pay ?",
          content: PriceSelection(pageController: _pageController)),
      PersonalityPage(
          largeText: false,
          content: ApplyFinal(pageController: _pageController))
    ];

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 70,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0, top: 5),
                    child: GoBackButton(
                      title: _currentPage == 0 ? "Cancel" : "Go back",
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
                ),
              ),
              Image.asset(kLogoText),
              Expanded(child: SizedBox()),
            ],
          ),
          const SizedBox(
            height: 30,
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
          _currentPage == 0 && !categoryNotFound
              ? SizedBox(
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
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 100),
                          curve: Curves.easeIn,
                        );
                      }
                    },
                    child: isLoading
                        ? kLoadingIndicator
                        : Text(
                            'Continue',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                  ),
                )
              : SizedBox()
        ],
      ),
    );
  }
}
