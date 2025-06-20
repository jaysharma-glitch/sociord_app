import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/constants/ui.dart';
import 'package:sociord/provider/user_provider.dart';

class OtherGenderDes extends ConsumerStatefulWidget {
  final PageController? pageController;
  const OtherGenderDes({super.key, this.pageController});

  @override
  ConsumerState<OtherGenderDes> createState() => _OtherGenderDesState();
}

class _OtherGenderDesState extends ConsumerState<OtherGenderDes> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _identityController;
  late final TextEditingController _pronounsController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userNotifierProvider);
    _identityController = TextEditingController(
      text: user.gender == 'Others' ? '' : user.gender,
    );
    _pronounsController = TextEditingController(text: user.otherIdenty);
  }

  @override
  void dispose() {
    _identityController.dispose();
    _pronounsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userNotifier = ref.read(userNotifierProvider.notifier);
    final user = ref.watch(userNotifierProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 100),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('How do you identify?',
                  style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 5),
              Text(
                'We want to express yourself freely',
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      color: kAppPurple,
                      fontSize: 15,
                    ),
              ),
              const SizedBox(height: 30),
              Text('Type in how you identify',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 10),
              TextFormField(
                controller: _identityController,
                decoration: InputDecoration(
                  labelText: 'Trans Man',
                  labelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: kAppLightBlack,
                        fontWeight: FontWeight.w300,
                      ),
                  border: kTextFormFieldBorderStyles,
                  enabledBorder: kTextFormFieldBorderStyles,
                  suffixIcon: _identityController.text.isNotEmpty
                      ? const Icon(Icons.check_circle_rounded,
                          color: kAppDarkGreen, size: 20)
                      : null,
                ),
                onChanged: userNotifier.setGender,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your identity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 25),
              Text('What are your pronouns?',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 10),
              TextFormField(
                controller: _pronounsController,
                decoration: InputDecoration(
                  labelText: 'She/Her',
                  labelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: kAppLightBlack,
                        fontWeight: FontWeight.w300,
                      ),
                  border: kTextFormFieldBorderStyles,
                  enabledBorder: kTextFormFieldBorderStyles,
                  suffixIcon: _pronounsController.text.isNotEmpty
                      ? const Icon(Icons.check_circle_rounded,
                          color: kAppDarkGreen, size: 20)
                      : null,
                ),
                onChanged: userNotifier.setOtherIdenty,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your pronouns';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      context.pop(user.otherIdenty);
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
        ),
      ),
    );
  }
}
