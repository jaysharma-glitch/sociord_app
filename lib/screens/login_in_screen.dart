import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sociord/provider/user_provider.dart';
import 'package:sociord/utils/app_constants.dart';
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/widgets/bottom_sheet_signUp.dart';
import 'package:sociord/widgets/custom_snack_bar.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const routeName = '/login';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  var loginUser = 'personal';
  bool userNotFound = false;
  bool isLoading = false;

  late TextEditingController _phoneNumberController;

  @override
  void initState() {
    super.initState();
    final userState = ref.read(userNotifierProvider);
    _phoneNumberController = TextEditingController(text: userState.phoneNumber);
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
    var height = MediaQuery.of(context).viewPadding.top;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: height,
            ),
            const SizedBox(height: 20),
            // Toggle between Personal and Business
            Container(
              decoration: BoxDecoration(
                color: kAppLightPurple,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Handle Personal tab click
                        setState(() {
                          loginUser = 'personal';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: loginUser == 'personal'
                                ? kAppPurple
                                : kAppLightPurple),
                        child: Center(
                          child: Text(
                            'Personal',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    color: loginUser == 'personal'
                                        ? kAppWhite
                                        : kAppBlack),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Handle Business tab click
                        setState(() {
                          loginUser = 'business';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: loginUser == 'business'
                              ? kAppPurple
                              : kAppLightPurple,
                        ),
                        child: Center(
                          child: Text(
                            'Business',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    color: loginUser == 'business'
                                        ? kAppWhite
                                        : kAppBlack),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Sign Up text

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("Don't have an account? ",
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith()),
                GestureDetector(
                  onTap: () {
                    // Handle Sign Up navigation
                    Navigator.pushNamed(context, '/signUpFlow');
                  },
                  child: Text('Sign up',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: kAppPurple, fontWeight: FontWeight.w800)),
                ),
              ],
            ),

            const SizedBox(height: 30),
            // Login header

            Text(
              'Login to your account',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 5),
            Text(
              'Crea8. Apprecia8. Celebr8',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(color: kAppPurple, fontSize: 15),
            ),
            const SizedBox(height: 30),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: kBorderGreay, // Border color
                        width: 1.0, // Border width
                      ),
                      borderRadius: BorderRadius.circular(
                          10.0), // Border radius (optional)
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: CountryCodePicker(
                            onChanged: (value) {
                              userNotifier.setCountryCode(
                                  value.toString().split('+')[1] ?? '');
                            },
                            showFlag: false,
                            initialSelection: 'IN',
                            favorite: ['+91', 'IN'],
                            showCountryOnly: true,
                            showOnlyCountryWhenClosed: false,
                            alignLeft: true,
                            textStyle: Theme.of(context).textTheme.bodyLarge,
                            searchStyle: Theme.of(context).textTheme.bodyLarge,
                            dialogTextStyle:
                                Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Image.asset(kDropDown),
                        SizedBox(
                          width: 15,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: _phoneNumberController,
                    decoration: InputDecoration(
                      labelText: 'Mobile Number',
                      labelStyle: Theme.of(context).textTheme.bodyLarge,
                      border: kTextFormFieldBorderStyles,
                      enabledBorder: kTextFormFieldBorderStyles,
                      prefixText: userState.countryCode!.isNotEmpty
                          ? userState.countryCode
                          : '',
                      prefixStyle: TextStyle(fontSize: 18),
                      suffixIcon: userState.phoneNumber!.length == 10
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: kAppDarkGreen,
                              size: 20,
                            )
                          : GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return BottomSheetContent();
                                    });
                              },
                              child: const Icon(
                                Icons.help_outline,
                                size: 20,
                              ),
                            ),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    keyboardType: TextInputType.phone,
                    onChanged: (value) {
                      userNotifier.setPhoneNumber(value);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length < 10) {
                        return 'Please enter your mobile number';
                      }
                      return null;
                    },
                  ),
                  if (userNotFound)
                    Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: Text(
                        'Phone number is not registered',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: kAppRed),
                      ),
                    ),
                  const SizedBox(
                    height: 50,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState?.validate() == true) {
                          setState(() {
                            userNotFound = false;
                          });
                          // Process data!
                          try {
                            setState(() {
                              isLoading = true;
                            });
                            var result = await userNotifier.userLogin();
                            setState(() {
                              isLoading = false;
                            });
                            if (result != null) {
                              Navigator.pushNamed(context, '/login-otp');
                            } else {
                              setState(() {
                                userNotFound = true;
                              });
                            }
                          } catch (e) {
                            setState(() {
                              isLoading = false;
                            });
                            if (e.toString().contains('Connection refused')) {
                              setState(() {
                                userNotFound = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                  CustomSnackBar().build(context));
                            } else {
                              setState(() {
                                userNotFound = true;
                              });
                              print(e
                                  .toString()
                                  .contains('Phone number not registered'));
                            }
                          }
                        } else {
                          setState(() {
                            userNotFound = false;
                          });
                          // Show a message or handle the case where conditions aren't met
                        }
                      },
                      child: isLoading
                          ? kLoadingIndicator
                          : Text(
                              'Create your account',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
