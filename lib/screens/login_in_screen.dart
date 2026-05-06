// lib/screens/login/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:country_code_picker/country_code_picker.dart';

import 'package:sociord/constants/color.dart';
import 'package:sociord/constants/ui.dart';
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/utils/routes.dart';
import 'package:sociord/provider/user_provider.dart';
import 'package:sociord/widgets/bottom_sheet_signUp.dart'; 
import 'package:sociord/widgets/custom_snack_bar.dart';
import 'package:sociord/widgets/move_with_keyboard_elevated_btn.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool userNotFound = false;
  bool isLoading = false;
  var loginUser = 'personal';
  late TextEditingController _phoneNumberController;

  @override
  void initState() {
    super.initState();
    final userState = ref.read(userNotifierProvider);
    _phoneNumberController = TextEditingController(text: userState.phoneNumber);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userNotifierProvider);
    final userNotifier = ref.read(userNotifierProvider.notifier);
    final height = MediaQuery.of(context).viewPadding.top;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height + 20),

                /// Toggle Switch
                _LoginToggle(
                  loginUser: loginUser,
                  onChanged: (value) => setState(() => loginUser = value),
                ),
                const SizedBox(height: 30),

                /// Sign Up Prompt
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Don't have an account? ",
                        style: Theme.of(context).textTheme.bodyMedium),
                    GestureDetector(
                      onTap: () => context.push(signUpFlowRoute),
                      child: Text('Sign up',
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: kAppPurple,
                                    fontWeight: FontWeight.w800,
                                  )),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                /// Headers
                Text('Login to your account',
                    style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 5),
                Text('Crea8. Apprecia8. Celebr8',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          color: kAppPurple,
                          fontSize: 15,
                        )),
                const SizedBox(height: 30),

                /// Login Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      /// Country Picker
                      _CountryCodeRow(
                        onChanged: (val) {
                          final parts = val.toString().split('+');
                          userNotifier.setCountryCode(
                              parts.length > 1 ? parts[1] : '');
                        },
                      ),
                      const SizedBox(height: 20),

                      /// Phone Input
                      TextFormField(
                        controller: _phoneNumberController,
                        decoration: InputDecoration(
                          labelText: 'Mobile Number',
                          labelStyle: Theme.of(context).textTheme.bodyLarge,
                          border: kTextFormFieldBorderStyles,
                          enabledBorder: kTextFormFieldBorderStyles,
                          prefixStyle: const TextStyle(fontSize: 18),
                          suffixIcon: userState.phoneNumber!.length == 10
                              ? const Icon(Icons.check_circle_rounded,
                                  color: kAppDarkGreen, size: 20)
                              : GestureDetector(
                                  onTap: () => showModalBottomSheet(
                                    context: context,
                                    builder: (_) => const BottomSheetContent(),
                                  ),
                                  child:
                                      const Icon(Icons.help_outline, size: 20),
                                ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        keyboardType: TextInputType.phone,
                        onChanged: (value) =>
                            userNotifier.setPhoneNumber(value),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.length < 10) {
                            return 'Please enter your mobile number';
                          }
                          return null;
                        },
                      ),

                      if (userNotFound)
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Text(
                            'Phone number is not registered',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(color: kAppRed),
                          ),
                        ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ],
            ),
          ),
            
          /// Bottom CTA
          MoveWithKeyboardElevatedBtn(
            spaceFromBottom: MediaQuery.of(context).size.height * 0.3,
            onPressed: () async {
              if (_formKey.currentState?.validate() != true) {
                setState(() => userNotFound = false);
                return;
              }
              setState(() => userNotFound = false);
              try {
                setState(() => isLoading = true);
                // Check if user exists in DB; returns userId if exists, null otherwise
                final result = await userNotifier.userLogin();
                if (!context.mounted) return;
                setState(() => isLoading = false);
                if (result != null && result.isNotEmpty) {
                  context.push(loginOtpRoute);
                } else {
                  setState(() => userNotFound = true);
                }
              } catch (e) {
                if (context.mounted) setState(() => isLoading = false);
                if (!context.mounted) return;
                if (e.toString().contains('Connection refused')) {
                  setState(() => userNotFound = false);
                  ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar().build(context));
                } else {
                  setState(() => userNotFound = true);
                }
              }
            },
            child: isLoading
                ? kLoadingIndicator
                : Text('Login',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          color: kAppWhite,
                        )),
          ),
        ],
      ),
    );
  }
}

// === ✅ LoginToggle ===
class _LoginToggle extends StatelessWidget {
  final String loginUser;
  final Function(String) onChanged;

  const _LoginToggle({required this.loginUser, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kAppLightPurple,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: ['personal', 'business'].map((type) {
          final isActive = loginUser == type;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(type),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isActive ? kAppPurple : kAppLightPurple,
                ),
                child: Center(
                  child: Text(
                    type[0].toUpperCase() + type.substring(1),
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: isActive ? kAppWhite : kAppBlack,
                        ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// === ✅ CountryCodeRow ===
class _CountryCodeRow extends StatelessWidget {
  final void Function(CountryCode) onChanged;

  const _CountryCodeRow({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: kBorderGreay, width: 1.0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: CountryCodePicker(
              onChanged: onChanged,
              showFlag: false,
              initialSelection: 'IN',
              favorite: ['+91', 'IN'],
              showCountryOnly: true,
              showOnlyCountryWhenClosed: false,
              alignLeft: true,
              textStyle: Theme.of(context).textTheme.bodyLarge,
              searchStyle: Theme.of(context).textTheme.bodyLarge,
              dialogTextStyle: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const ImageIcon(AssetImage(kDropDown), size: 16),
          const SizedBox(width: 15),
        ],
      ),
    );
  }
}
