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
    return gender != null &&
        gender != 'Male' &&
        gender != 'Female' &&
        gender != 'Others';
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
            onTap: () => setState(() => userNotifier.setGender('Male')),
          ),
          const SizedBox(height: 20),
          OptionSelector(
            title: 'Female',
            isSelected: gender == 'Female',
            onTap: () => setState(() => userNotifier.setGender('Female')),
          ),
          const SizedBox(height: 20),
          OptionSelector(
            title: isOtherGenderSelected ? gender : 'Others',
            isSelected: gender == 'Others' || isOtherGenderSelected,
            onTap: () => setState(() => userNotifier.setGender('Others')),
          ),
          const SizedBox(height: 40),
          if (gender.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (gender == 'Others' || isOtherGenderSelected) {
                    final result = await context.push(otherGenderRoute);
                    if (result != null && widget.pageController != null) {
                      widget.pageController!.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    }
                  } else {
                    widget.pageController!.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
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
