import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sociord/provider/user_provider.dart';
import 'package:sociord/constants/ui.dart';
import 'package:sociord/constants/color.dart';

class OtherGenderDes extends ConsumerStatefulWidget {
  final PageController? pageController;
  const OtherGenderDes({super.key, this.pageController});

  @override
  _OtherGenderDesState createState() => _OtherGenderDesState();
}

class _OtherGenderDesState extends ConsumerState<OtherGenderDes> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _identity = TextEditingController();
  late TextEditingController _pronouns = TextEditingController();

  @override
  void initState() {
    super.initState();
    final userState = ref.read(userNotifierProvider);
    _identity = TextEditingController(
        text: userState.gender == 'Others' ? '' : userState.gender);
    _pronouns = TextEditingController(text: userState.otherIdenty);
  }

  @override
  void dispose() {
    _identity.dispose();
    _pronouns.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userNotifier = ref.read(userNotifierProvider.notifier);
    final userState = ref.watch(userNotifierProvider);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How do you identify?',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 5),
              Text(
                'We want to express yourself freely',
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      color: kAppPurple,
                      fontSize: 15,
                    ),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                'Type in how you identify',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: _identity,
                decoration: InputDecoration(
                  labelText: 'Trans Man',
                  labelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: kAppLightBlack, fontWeight: FontWeight.w300),
                  border: kTextFormFieldBorderStyles,
                  enabledBorder: kTextFormFieldBorderStyles,
                  suffixIcon: _identity.text.isNotEmpty
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: kAppDarkGreen,
                          size: 20,
                        )
                      : null,
                ),
                onChanged: (value) {
                  userNotifier.setGender(value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
                style: TextStyle(color: Colors.black),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                'What are you pronouns?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: _pronouns,
                decoration: InputDecoration(
                  labelText: 'She/Her',
                  labelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: kAppLightBlack, fontWeight: FontWeight.w300),
                  border: kTextFormFieldBorderStyles,
                  enabledBorder: kTextFormFieldBorderStyles,
                  suffixIcon: _pronouns.text.isNotEmpty
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: kAppDarkGreen,
                          size: 20,
                        )
                      : null,
                ),
                onChanged: (value) {
                  userNotifier.setOtherIdenty(value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 40,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      // Navigator.pop(context, userState.otherIdenty);
                      context.pop(userState.otherIdenty);
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
      ),
    );
  }
}
