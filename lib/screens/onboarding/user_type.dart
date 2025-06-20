import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sociord/provider/user_provider.dart';
import 'package:sociord/utils/routes.dart';

import 'package:sociord/widgets/custom_snack_bar.dart';
import 'package:sociord/widgets/option_selector.dart';
import 'package:sociord/constants/ui.dart';

class UserType extends ConsumerStatefulWidget {
  final PageController? pageController;
  const UserType({super.key, this.pageController});

  @override
  _GenderSelectionState createState() => _GenderSelectionState();
}

class _GenderSelectionState extends ConsumerState<UserType> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userNotifierProvider);
    final userNotifier = ref.read(userNotifierProvider.notifier);

    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pick one. You\'re free to explore both roles at any time.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(
            height: 20,
          ),
          OptionSelector(
              title: 'Creator',
              isSelected: userState.contentType == 'Creator' ? true : false,
              onTap: () {
                setState(() {
                  userNotifier.setContentType('Creator');
                });
              }),
          const SizedBox(
            height: 20,
          ),
          OptionSelector(
              title: 'Explorer',
              isSelected: userState.contentType == 'Explorer' ? true : false,
              onTap: () {
                setState(() {
                  userNotifier.setContentType('Explorer');
                });
              }),
          const SizedBox(
            height: 40,
          ),
          if (userState.contentType != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // try {
                  //   setState(() {
                  //     isLoading = true;
                  //   });

                  //   var result = await userNotifier.completeOnboarding();

                  //   setState(() {
                  //     isLoading = false;
                  //   });
                  //   if (result != null) {
                  //     context.go(finalOnboardingRoute);
                  //   }
                  // } catch (e) {
                  //   setState(() {
                  //     isLoading = false;
                  //   });
                  //   if (e.toString().contains('Connection refused')) {
                  //     ScaffoldMessenger.of(context)
                  //         .showSnackBar(CustomSnackBar().build(context));
                  //   } else {
                  //     print(e.toString());
                  //   }
                  // }
                  context.go(finalOnboardingRoute);
                },
                child: isLoading
                    ? kLoadingIndicator
                    : Text(
                        'Contnue',
                        style:
                            Theme.of(context).textTheme.headlineSmall!.copyWith(
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
