// lib/widgets/onboarding/onboarding_carousel.dart
import 'package:flutter/material.dart';
import 'package:sociord/utils/asset_path_constants.dart';

class OnboardingCarousel extends StatefulWidget {
  final ValueChanged<String>? onTextChanged;

  const OnboardingCarousel({super.key, this.onTextChanged});

  @override
  State<OnboardingCarousel> createState() => _OnboardingCarouselState();
}

class _OnboardingCarouselState extends State<OnboardingCarousel> {
  final List<Map<String, String>> _onboardData = [
    {"image": kOnboardingImage1, "text": "Cre"},
    {"image": kOnboardingImage2, "text": "Communic"},
    {"image": kOnboardingImage3, "text": "Innov"},
    {"image": kOnboardingImage4, "text": "Rel"},
  ];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Notify parent of initial text
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onTextChanged?.call(_onboardData[_currentIndex]['text']!);
    });
    Future.delayed(const Duration(seconds: 2), _rotateCarousel);
  }

  void _rotateCarousel() {
    if (!mounted) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % _onboardData.length;
    });
    // Notify parent of text change
    widget.onTextChanged?.call(_onboardData[_currentIndex]['text']!);
    Future.delayed(const Duration(seconds: 2), _rotateCarousel);
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.9,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left side preview
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Opacity(
                opacity: 0.5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Image.asset(
                    _onboardData[(_currentIndex - 1 + _onboardData.length) %
                        _onboardData.length]['image']!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
          ),
          // Center main image with fade animation
          Expanded(
            flex: 16,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: ClipRRect(
                key: ValueKey(_currentIndex),
                borderRadius: BorderRadius.circular(20.0),
                child: Image.asset(
                  _onboardData[_currentIndex]['image']!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ),
          // Right side preview
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Opacity(
                opacity: 0.5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Image.asset(
                    _onboardData[(_currentIndex + 1) %
                        _onboardData.length]['image']!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get currentTitle => _onboardData[_currentIndex]['text']!;
}
