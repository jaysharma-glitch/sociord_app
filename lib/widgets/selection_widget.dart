import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sociord/provider/user_provider.dart';
import 'package:sociord/constants/color.dart';

class SelectionWidget extends ConsumerStatefulWidget {
  const SelectionWidget({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SelectionWidgetState createState() => _SelectionWidgetState();
}

class _SelectionWidgetState extends ConsumerState<SelectionWidget> {
  String selectedOption = '';

  void selectOption(String option) {
    setState(() {
      selectedOption = option;
    });

    // Set the profile type in the user provider
    ref.read(userNotifierProvider.notifier).setProfileType(option);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Get the initial value of profileType from the provider

    final user = ref.read(userNotifierProvider);
    print(user.profileType);
    selectedOption = user.profileType ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        children: [
          buildOption(
            icon: Icons.person_outline,
            title: 'Personal',
            description: 'Connect with friends, view, or create content',
            subtext: 'This option is for everyone',
            isSelected: selectedOption == 'Personal',
            onTap: () => selectOption('Personal'),
          ),
          const SizedBox(height: 16),
          buildOption(
            icon: Icons.business_outlined,
            title: 'Business',
            description:
                'Create a brand page, list products, or showcase services',
            subtext: 'Ideal for businesses',
            isSelected: selectedOption == 'Business',
            onTap: () => selectOption('Business'),
          ),
        ],
      ),
    );
  }

  Widget buildOption({
    required IconData icon,
    required String title,
    required String description,
    required String subtext,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kAppLightGreay,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.purple : Colors.grey.shade300,
            width: isSelected ? 1 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (isSelected)
              const Positioned(
                  top: 0,
                  right: 0,
                  child: Icon(Icons.check_circle_rounded, color: Colors.purple))
            else
              Positioned(
                  top: 0,
                  right: 0,
                  child: Icon(Icons.radio_button_unchecked,
                      color: Colors.grey.shade300)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Icon(icon, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Text(title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(color: kAppBlack)),
                      Text(description,
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: kAppBlack,
                                  )),
                      const SizedBox(height: 8),
                      Text(subtext,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(color: kAppPurple, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
