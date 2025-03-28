// lib/widgets/onboarding/onboarding_carousel.dart
import 'package:carousel_slider/carousel_slider.dart' as cs;
import 'package:flutter/material.dart';
import 'package:sociord/utils/asset_path_constants.dart';

class OnboardingCarousel extends StatefulWidget {
  const OnboardingCarousel({super.key});

  @override
  State<OnboardingCarousel> createState() => _OnboardingCarouselState();
}

class _OnboardingCarouselState extends State<OnboardingCarousel> {
  final List<Map<String, String>> _onboardData = [
    {"image": kOnboardingImage1, "title": "Cre8"},
    {"image": kOnboardingImage2, "title": "Communic8"},
    {"image": kOnboardingImage3, "title": "Innov8"},
    {"image": kOnboardingImage4, "title": "Rel8"},
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), _rotateCarousel);
  }

  void _rotateCarousel() {
    if (!mounted) return;
    setState(() {
      _onboardData.add(_onboardData.removeAt(0));
    });
    Future.delayed(const Duration(seconds: 2), _rotateCarousel);
  }

  @override
  Widget build(BuildContext context) {
    return cs.CarouselSlider(
      options: cs.CarouselOptions(
        aspectRatio: 0.9,
        viewportFraction: 0.85,
        enableInfiniteScroll: false,
        scrollPhysics: const NeverScrollableScrollPhysics(),
      ),
      items: _onboardData.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Image.asset(
              item['image']!,
              fit: BoxFit.fill,
            ),
          ),
        );
      }).toList(),
    );
  }

  String get currentTitle => _onboardData.first['title']!;
}
