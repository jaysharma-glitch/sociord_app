// lib/screens/onboarding/sign_up_flow.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sociord/constants/color.dart';
import 'package:sociord/provider/user_provider.dart';
import 'package:sociord/screens/onboarding/widget/login_row.dart';

import 'package:sociord/screens/onboarding/otp.dart';
import 'package:sociord/screens/onboarding/registration_page.dart';
import 'package:sociord/screens/onboarding/location_page.dart';
import 'package:sociord/screens/onboarding/user_name.dart';
import 'package:sociord/screens/onboarding/user_type.dart';
import 'package:sociord/screens/onboarding/gender_selection.dart';
import 'package:sociord/screens/onboarding/birthday_picker.dart';
import 'package:sociord/screens/onboarding/widget/onboarding_page.dart';
import 'package:sociord/utils/routes.dart';
import 'package:sociord/widgets/go_back_btn.dart';
import 'package:sociord/widgets/selection_widget.dart';

class SignUpFlow extends ConsumerStatefulWidget {
  const SignUpFlow({super.key});

  @override
  ConsumerState<SignUpFlow> createState() => _SignUpFlowState();
}

class _SignUpFlowState extends ConsumerState<SignUpFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Track activity when user is on onboarding pages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateActivity();
    });

    // Listen to page changes to track activity
    _pageController.addListener(() {
      _updateActivity();
    });
  }

  void _updateActivity() {
    final userNotifier = ref.read(userNotifierProvider.notifier);
    userNotifier.updateActivity();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userNotifierProvider);
    final viewTop = MediaQuery.of(context).viewPadding.top;

    final List<Widget> pages = [
      OnboardingPage(
        title: "What account are you creating today?",
        content: Column(
          children: [
            const SizedBox(height: 20),
            const SelectionWidget(),
            const SizedBox(height: 70),
            if (userState.profileType!.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  },
                  child: Text(
                    'Continue',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall!.copyWith(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
      OnboardingPage(
        title: "Create your account",
        subtitle: "Crea8. Appreci8. Celebr8",
        content: RegisterWidget(pageController: _pageController),
      ),
      OnboardingPage(
        title: "Enter the OTP sent to",
        subtitle: "${userState.phoneNumber}",
        content: Otp(pageController: _pageController),
      ),
      OnboardingPage(
        title: "Your location, please ?",
        subtitle: "Your location is needed to access all app features",
        content: LocationPage(pageController: _pageController),
      ),
      OnboardingPage(
        title: "Glad to have you, ${userState.firstName}",
        subtitle: "Let's pick your unique identification",
        content: SetUsernameWidget(pageController: _pageController),
      ),
      OnboardingPage(
        title: "What is your gender?",
        subtitle: "Help us create an inclusive experience",
        content: GenderSelection(pageController: _pageController),
      ),
      OnboardingPage(
        title: "What is your birthdate ?",
        subtitle: "We'd love to help you find relatable content",
        content: BirthdayPicker(pageController: _pageController),
      ),
      OnboardingPage(
        title: "What is your pick?",
        subtitle: "Are you here to primarily create content or to enjoy it?",
        content: UserType(pageController: _pageController),
      ),
    ];

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: viewTop + 20),

          /// Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LinearProgressIndicator(
              value: (_currentPage + 1) / pages.length,
              borderRadius: BorderRadius.circular(20),
              backgroundColor: kAppGreay,
            ),
          ),
          const SizedBox(height: 25),

          /// Back button
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: GoBackButton(
              onPressedFunction: () {
                if (_currentPage == 0) {
                  context.canPop()
                      ? context.pop()
                      : context.go(signInSignUpRoute);
                } else {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                }
              },
            ),
          ),

          /// Already have account login (for Register screen only)
          if (_currentPage == 1) const LoginRow(),

          /// PageView Body
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (int page) => setState(() => _currentPage = page),
              itemCount: pages.length,
              itemBuilder: (_, index) => pages[index],
            ),
          ),
        ],
      ),
    );
  }
}
