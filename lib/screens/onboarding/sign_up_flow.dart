import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sociord/provider/user_provider.dart';
import 'package:sociord/screens/onboarding/birthday_picker.dart';
import 'package:sociord/screens/onboarding/gender_selection.dart';
import 'package:sociord/screens/onboarding/location_page.dart';
import 'package:sociord/screens/onboarding/other_gender.dart';
import 'package:sociord/screens/onboarding/user_name.dart';
import 'package:sociord/screens/onboarding/user_type.dart';
import 'package:sociord/utils/app_constants.dart';
import 'package:sociord/widgets/go_back_btn.dart';
import 'package:sociord/screens/onboarding/otp.dart';
import 'package:sociord/screens/onboarding/registration_page.dart';
import 'package:sociord/widgets/selection_widget.dart';

class SignUpFlow extends ConsumerStatefulWidget {
  static const routeName = '/signUpFlow';
  const SignUpFlow({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignUpFlowState createState() => _SignUpFlowState();
}

class _SignUpFlowState extends ConsumerState<SignUpFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userNotifierProvider);
    final List<Widget> _pages = [
      OnboardingPage(
        title: "What account are you creating today?",
        content: Column(
          children: [
            const SizedBox(height: 20),
            SelectionWidget(),
            const SizedBox(
              height: 70,
            ),
            if (userState.profileType != '')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (userState.profileType != '') {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    }
                  },
                  child: Text(
                    'Continue',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),
          ],
        ),
      ),
      OnboardingPage(
          title: "Create your account",
          subtitle: "Crea8. Appreci8. Celebr8",
          content: RegisterWidget(pageController: _pageController)),

      OnboardingPage(
          title: "Enter the OTP sent to ${userState.phoneNumber}",
          subtitle: "Crea8. Appreci8. Celebr8",
          content: Otp(pageController: _pageController)),
      OnboardingPage(
          title: "Your location, please ?",
          subtitle: "Your location is needed to access all app features",
          content: LocationPage(pageController: _pageController)),
      OnboardingPage(
          title: "Glad to have you, ${userState.firstName}",
          subtitle: "Let's pick your unique identification",
          content: SetUsernameWidget(pageController: _pageController)),
      OnboardingPage(
          title: "What is your gender?",
          subtitle: "Help us create an inclusive experience",
          content: GenderSelection(pageController: _pageController)),
      // OnboardingPage(
      //     title: "How do you identify?",
      //     subtitle: "We want to express yourself freely",
      //     content: OtherGenderDes(pageController: _pageController)),
      OnboardingPage(
          title: "What is your birthdate ?",
          subtitle: "We'd love to help you find relatable content",
          content: BirthdayPicker(pageController: _pageController)),
      OnboardingPage(
          title: "What is your pick?",
          subtitle: "Are you here to primarily create content or to enjoy it?",
          content: UserType(pageController: _pageController)),
      // Add other pages here
    ];
    var height = MediaQuery.of(context).viewPadding.top;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: height,
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LinearProgressIndicator(
              value: (_currentPage + 1) / _pages.length,
              borderRadius: BorderRadius.circular(20),
              backgroundColor: kAppGreay,
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: GoBackButton(
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
          if (_currentPage == 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("Already have an account? ",
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith()),
                GestureDetector(
                  onTap: () {
                    // Handle Sign Up navigation
                    ref.read(userNotifierProvider.notifier).setCountryCode('');
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text('Login',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: kAppPurple, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(
                  width: 25,
                )
              ],
            ),
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
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget content;

  const OnboardingPage(
      {super.key, required this.title, this.subtitle, required this.content});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 50,
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 5),
            subtitle != null
                ? Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          color: kAppPurple,
                          fontSize: 15,
                        ),
                  )
                : const SizedBox(),
            content
          ],
        ),
      ),
    );
  }
}
