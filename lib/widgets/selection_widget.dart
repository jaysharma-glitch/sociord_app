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
            icon: Icons.diamond_outlined,
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
    IconData? icon,
    String? iconImage,
    required String title,
    required String description,
    required String subtext,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kAppLightGreay,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isSelected ? kAppPurple : Colors.grey.shade400.withOpacity(0.5),
          width: isSelected ? 2 : 1,
        ),
        boxShadow:
            isSelected
                ? [
                  BoxShadow(
                    color: kAppPurple.withOpacity(0.15),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    spreadRadius: 0,
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: kAppPurple.withOpacity(0.1),
          highlightColor: kAppPurple.withOpacity(0.05),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                top: 0,
                right: 0,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (
                    Widget child,
                    Animation<double> animation,
                  ) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child:
                      isSelected
                          ? Icon(
                            Icons.check_circle_rounded,
                            key: const ValueKey('selected'),
                            color: kAppPurple,
                          )
                          : Icon(
                            Icons.radio_button_unchecked,
                            key: const ValueKey('unselected'),
                            color: Colors.grey.shade300,
                          ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      transform:
                          Matrix4.identity()..scale(isSelected ? 1.05 : 1.0),
                      child:
                          iconImage != null
                              ? Image.asset(
                                iconImage,
                                width: 24,
                                height: 24,
                                fit: BoxFit.contain,
                              )
                              : Icon(icon, size: 30),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          title,
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall!.copyWith(color: kAppBlack),
                        ),
                        Text(
                          description,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                            color: kAppBlack,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          subtext,
                          style: Theme.of(context).textTheme.headlineSmall!
                              .copyWith(color: kAppPurple, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
