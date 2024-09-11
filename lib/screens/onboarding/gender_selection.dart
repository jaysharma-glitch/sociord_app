import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sociord/provider/user_provider.dart';
import 'package:sociord/widgets/option_selector.dart';

class GenderSelection extends ConsumerStatefulWidget {
  final PageController? pageController;
  const GenderSelection({super.key, this.pageController});

  @override
  // ignore: library_private_types_in_public_api
  _GenderSelectionState createState() => _GenderSelectionState();
}

class _GenderSelectionState extends ConsumerState<GenderSelection> {
  @override
  Widget build(BuildContext context) {
    final userNotifier = ref.read(userNotifierProvider.notifier);
    final userState = ref.watch(userNotifierProvider);
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Please select one option',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(
            height: 20,
          ),
          OptionSelector(
              title: 'Male',
              isSelected: userState.gender == 'Male' ? true : false,
              onTap: () {
                setState(() {
                  userNotifier.setGender('Male');
                });
              }),
          const SizedBox(
            height: 20,
          ),
          OptionSelector(
              title: 'Female',
              isSelected: userState.gender == 'Female' ? true : false,
              onTap: () {
                setState(() {
                  userNotifier.setGender('Female');
                });
              }),
          const SizedBox(
            height: 20,
          ),
          OptionSelector(
              title: userState.gender != null
                  ? userState.gender != 'Male' &&
                          userState.gender != 'Female' &&
                          userState.gender != 'Others'
                      ? userState.gender!
                      : 'Others'
                  : 'Others',
              isSelected: userState.gender == 'Others'
                  ? true
                  : userState.gender != 'Male' &&
                          userState.gender != 'Female' &&
                          userState.gender != 'Others' &&
                          userState.gender != null
                      ? true
                      : false,
              onTap: () {
                setState(() {
                  userNotifier.setGender('Others');
                });
              }),
          const SizedBox(
            height: 40,
          ),
          if (userState.gender != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (userState.gender == 'Others' ||
                      userState.gender != 'Male' &&
                          userState.gender != 'Female' &&
                          userState.gender != 'Others') {
                    Navigator.pushNamed(context, '/otherGender').then((value) {
                      if (value != null) {
                        widget.pageController!.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      }
                    });
                  } else {
                    widget.pageController!.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  }
                },
                child: Text(
                  'Contnue',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
