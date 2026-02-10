import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sociord/provider/user_provider.dart';
import 'package:sociord/utils/routes.dart';
import 'package:sociord/widgets/option_selector.dart';

class GenderSelection extends ConsumerStatefulWidget {
  final PageController? pageController;

  const GenderSelection({super.key, this.pageController});

  @override
  ConsumerState<GenderSelection> createState() => _GenderSelectionState();
}

class _GenderSelectionState extends ConsumerState<GenderSelection> {
  bool get isOtherGenderSelected {
    final gender = ref.watch(userNotifierProvider).gender;
    final otherIdentity = ref.watch(userNotifierProvider).otherIdentity;
    // If gender is "Other" and otherIdentity is set, then other gender is selected
    return gender == 'Other' && otherIdentity != null && otherIdentity.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final userNotifier = ref.read(userNotifierProvider.notifier);
    final userState = ref.watch(userNotifierProvider);

    final gender = userState.gender ?? '';

    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Please select one option',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          OptionSelector(
            title: 'Male',
            isSelected: gender == 'Male',
            onTap: () {
              setState(() {
                userNotifier.setGender('Male');
                // Clear otherIdentity and pronouns when selecting Male/Female
                userNotifier.setOtherIdentity(null);
                userNotifier.setPronouns(null);
              });
            },
          ),
          const SizedBox(height: 20),
          OptionSelector(
            title: 'Female',
            isSelected: gender == 'Female',
            onTap: () {
              setState(() {
                userNotifier.setGender('Female');
                // Clear otherIdentity and pronouns when selecting Male/Female
                userNotifier.setOtherIdentity(null);
                userNotifier.setPronouns(null);
              });
            },
          ),
          const SizedBox(height: 20),
          OptionSelector(
            title: isOtherGenderSelected 
                ? ref.watch(userNotifierProvider).otherIdentity ?? 'Other'
                : 'Other',
            isSelected: gender == 'Other' || isOtherGenderSelected,
            onTap: () => setState(() => userNotifier.setGender('Other')),
          ),
          const SizedBox(height: 40),
          if (gender.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final currentUserState = ref.read(userNotifierProvider);
                  
                  // If Other is selected but data is not filled, navigate to other gender screen
                  if (gender == 'Other' && 
                      (currentUserState.otherIdentity == null || 
                       currentUserState.otherIdentity!.isEmpty ||
                       currentUserState.pronouns == null ||
                       currentUserState.pronouns!.isEmpty)) {
                    // Navigate to other gender screen to get custom identity and pronouns
                    await context.push(otherGenderRoute);
                    // After returning, check if data is now filled and proceed
                    final updatedUserState = ref.read(userNotifierProvider);
                    if (updatedUserState.otherIdentity != null && 
                        updatedUserState.otherIdentity!.isNotEmpty &&
                        updatedUserState.pronouns != null &&
                        updatedUserState.pronouns!.isNotEmpty &&
                        widget.pageController != null) {
                      widget.pageController!.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    }
                  } else if (gender == 'Other' && isOtherGenderSelected) {
                    // Other is selected and data is filled, proceed to next screen
                    if (widget.pageController != null) {
                      widget.pageController!.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    }
                  } else {
                    // For Male/Female, just proceed to next screen
                    if (widget.pageController != null) {
                      widget.pageController!.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    }
                  }
                },
                child: Text(
                  'Continue',
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
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
