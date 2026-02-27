import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:sociord/provider/user_provider.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/screens/onboarding/widget/tandc_checkbox.dart';
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/utils/routes.dart';
import 'package:sociord/widgets/bottom_sheet_signUp.dart';
import 'package:sociord/widgets/custom_snack_bar.dart';
import 'package:sociord/constants/ui.dart';

class RegisterWidget extends ConsumerStatefulWidget {
  final PageController pageController;

  const RegisterWidget({super.key, required this.pageController});

  @override
  _RegisterWidgetState createState() => _RegisterWidgetState();
}

class _RegisterWidgetState extends ConsumerState<RegisterWidget> {
  final _formKey = GlobalKey<FormState>();
  final _countryPickerKey = GlobalKey();
  final _phoneNumberFocusNode = FocusNode();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneNumberController;
  bool _tAndCAgreed = false;
  bool tAndCErr = false;
  bool sameNumberErr = false;
  bool isLoading = false;
  bool _isPhoneNumberFocused = false;

  void checkClick(value) {
    setState(() {
      _tAndCAgreed = value!;
    });
  }

  // Check if number might be a WhatsApp business number
  // This is a basic validation - you may want to use a phone number validation API
  bool _isWhatsAppBusinessNumber(String phoneNumber) {
    // Common patterns that might indicate business numbers
    // Note: This is a simple heuristic and may need refinement
    // WhatsApp Business API numbers often have specific patterns
    // You might want to integrate with a service like Twilio's Lookup API
    // or NumVerify API to check if it's a business number

    // For now, we'll do a basic check - you can enhance this later
    // Some business numbers might have patterns like repeated digits
    // or specific prefixes, but this varies by country

    // This is a placeholder - implement proper validation based on your needs
    return false; // Return false for now until proper validation is added
  }

  @override
  void initState() {
    super.initState();
    final userState = ref.read(userNotifierProvider);
    _firstNameController = TextEditingController(text: userState.firstName);
    _lastNameController = TextEditingController(text: userState.lastName);
    _phoneNumberController = TextEditingController(text: userState.phoneNumber);

    _phoneNumberFocusNode.addListener(() {
      setState(() {
        _isPhoneNumberFocused = _phoneNumberFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _phoneNumberFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userNotifierProvider);
    final userNotifier = ref.read(userNotifierProvider.notifier);

    return Padding(
      padding: const EdgeInsets.only(top: 25.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _firstNameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'First Name',
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: kAppDarkGreay,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                floatingLabelStyle: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(
                  color: kAppPurple,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: kAppBlack,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 20.0,
                ),
                border: kTextFormFieldBorderStyles,
                enabledBorder: kTextFormFieldBorderStyles,
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: kAppPurple, width: 1.5),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                suffixIcon:
                    userState.firstName!.isNotEmpty
                        ? const Padding(
                          padding: EdgeInsets.only(right: 12.0),
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: kAppDarkGreen,
                            size: 20,
                          ),
                        )
                        : null,
              ),
              onChanged: (value) {
                userNotifier.setFirstName(value);
                setState(() {}); // Trigger rebuild to update label color
                print(userState.firstName);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your first name';
                }
                return null;
              },
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'[a-zA-Z ]'),
                ), // Allow only letters and spaces
              ],
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _lastNameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Last Name',
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: kAppDarkGreay,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                floatingLabelStyle: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(
                  color: kAppPurple,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: kAppBlack,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 20.0,
                ),
                border: kTextFormFieldBorderStyles,
                enabledBorder: kTextFormFieldBorderStyles,
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: kAppPurple, width: 1.5),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                suffixIcon:
                    userState.lastName!.isNotEmpty
                        ? const Padding(
                          padding: EdgeInsets.only(right: 12.0),
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: kAppDarkGreen,
                            size: 20,
                          ),
                        )
                        : null,
              ),
              onChanged: (value) {
                userNotifier.setLastName(value);
                setState(() {}); // Trigger rebuild to update label color
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your last name';
                }
                return null;
              },
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'[a-zA-Z ]'),
                ), // Allow only letters and spaces
              ],
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            // DropdownSearch<String>(
            //   mode: Mode.MENU,
            //   showSelectedItems: true,
            //   items: countries
            //       .map((country) => country['name'] as String)
            //       .toList(),
            //   label: "Country",
            //   onChanged: (value) {
            //     setState(() {
            //       _country = value ?? '';
            //     });
            //   },
            //   validator: (value) {
            //     if (value == null || value.isEmpty) {
            //       return 'Please select your country';
            //     }
            //     return null;
            //   },
            // ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: kBorderGreay, // Border color
                  width: 1.0, // Border width
                ),
                borderRadius: BorderRadius.circular(
                  10.0,
                ), // Border radius (optional)
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // Make entire area tappable - tap will open CountryCodePicker
                  },
                  borderRadius: BorderRadius.circular(10.0),
                  child: Stack(
                    children: [
                      SizedBox(
                        height: 56,
                        width: double.infinity,
                        child: Localizations.override(
                          context: context,
                          locale:
                              Localizations.localeOf(context).languageCode ==
                                      'hi'
                                  ? const Locale('en', 'US')
                                  : Localizations.localeOf(context),
                          child: CountryCodePicker(
                            key: _countryPickerKey,
                            onChanged: (value) {
                              print(value);
                              final parts = value.toString().split('+');
                              userNotifier.setCountryCode(
                                parts.length > 1 ? parts[1] : '',
                              );
                              setState(
                                () {},
                              ); // Trigger rebuild to update display
                            },
                            showFlag: false,
                            initialSelection: 'IN',
                            favorite: ['+91', 'IN'],
                            showCountryOnly: false,
                            showOnlyCountryWhenClosed: false,
                            alignLeft: true,
                            padding: EdgeInsets.zero,
                            builder: (country) {
                              if (country == null) {
                                return const SizedBox.shrink();
                              }
                              final countryName = country.name ?? '';
                              final dialCode = country.dialCode ?? '';
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                    vertical: 20.0,
                                  ),
                                  child: Text(
                                    '$countryName ( $dialCode )',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: kAppBlack,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              );
                            },
                            textStyle: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: kAppBlack,
                            ),
                            searchStyle: Theme.of(context).textTheme.bodyLarge,
                            dialogTextStyle:
                                Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: IgnorePointer(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 18.0),
                            child: Center(
                              child: Image.asset(
                                kDropDown,
                                width: 20,
                                height: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _phoneNumberController,
              focusNode: _phoneNumberFocusNode,
              decoration: InputDecoration(
                label: Text(
                  'Mobile Number',
                  style:
                      _isPhoneNumberFocused ||
                              _phoneNumberController.text.isNotEmpty
                          ? Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: kAppPurple,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          )
                          : Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: kAppDarkGreay,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                ),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                floatingLabelStyle: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(
                  color: kAppPurple,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: kAppBlack,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 20.0,
                ),
                border: kTextFormFieldBorderStyles,
                enabledBorder: kTextFormFieldBorderStyles,
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: kAppPurple, width: 1.5),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                prefixStyle: TextStyle(fontSize: 18),
                suffixIcon:
                    userState.phoneNumber!.length == 10
                        ? const Padding(
                          padding: EdgeInsets.only(right: 12.0),
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: kAppDarkGreen,
                            size: 20,
                          ),
                        )
                        : InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              barrierColor: Colors.black.withOpacity(0.5),
                              builder: (context) {
                                return Stack(
                                  children: [
                                    // Glassmorphism backdrop
                                    Positioned.fill(
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                          sigmaX: 15,
                                          sigmaY: 15,
                                        ),
                                        child: Container(
                                          color: Colors.black.withOpacity(0.3),
                                        ),
                                      ),
                                    ),
                                    // Modal content - fully opaque white
                                    DraggableScrollableSheet(
                                      initialChildSize: 0.5,
                                      minChildSize: 0.4,
                                      maxChildSize: 0.7,
                                      builder: (context, scrollController) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                  top: Radius.circular(20),
                                                ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.2,
                                                ),
                                                blurRadius: 30,
                                                spreadRadius: 5,
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                  top: Radius.circular(20),
                                                ),
                                            child: SingleChildScrollView(
                                              controller: scrollController,
                                              child: const BottomSheetContent(),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: Icon(
                              Icons.help_outline,
                              size: 20,
                              color:
                                  (_isPhoneNumberFocused ||
                                          _phoneNumberController
                                              .text
                                              .isNotEmpty)
                                      ? kAppPurple
                                      : kAppDarkGreay,
                            ),
                          ),
                        ),
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              keyboardType: TextInputType.phone,
              onChanged: (value) {
                userNotifier.setPhoneNumber(value);
                setState(() {}); // Trigger rebuild to update label color
              },
              validator: (value) {
                if (value == null || value.isEmpty || value.length < 10) {
                  return 'Please enter your mobile number';
                }
                // Check for WhatsApp business number patterns
                if (_isWhatsAppBusinessNumber(value)) {
                  return 'WhatsApp business numbers are not allowed. Please use your personal mobile number.';
                }
                return null;
              },
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            if (sameNumberErr)
              Padding(
                padding: EdgeInsets.only(top: 15),
                child: Text(
                  'User with the same phone number already exsists',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall!.copyWith(color: kAppRed),
                ),
              ),
            const SizedBox(height: 15),
            TandCCheckBox(
              isChecked: _tAndCAgreed,
              onChanged: (value) => setState(() => _tAndCAgreed = value!),
            ),
            Visibility(
              visible: tAndCErr,
              child: Center(
                child: Text(
                  'Kindly agree to the T&C to proceed',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall!.copyWith(color: kAppRed),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() == true &&
                      _tAndCAgreed) {
                    setState(() {
                      tAndCErr = false;
                      sameNumberErr = false;
                    });
                    // Process data!
                    try {
                      setState(() {
                        isLoading = true;
                      });
                      print('=== Creating User ===');
                      print('Profile Type: ${userState.profileType}');
                      print('First Name: ${userState.firstName}');
                      print('Last Name: ${userState.lastName}');
                      print('Country Code: ${userState.countryCode}');
                      print('Phone Number: ${userState.phoneNumber}');

                      var result = await userNotifier.createUser();

                      print('Create User Result: $result');
                      print(
                        'User ID after creation: ${ref.read(userNotifierProvider).userId}',
                      );
                      print('=====================');

                      setState(() {
                        isLoading = false;
                      });
                      if (result == true) {
                        // Verify userId was set
                        final createdUserId =
                            ref.read(userNotifierProvider).userId;
                        print('User ID before navigation: $createdUserId');
                        if (createdUserId == null || createdUserId.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Failed to create user. Please try again.',
                              ),
                              duration: Duration(seconds: 3),
                            ),
                          );
                          return;
                        }
                        widget.pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Failed to create user. Please try again.',
                            ),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    } catch (e) {
                      setState(() {
                        isLoading = false;
                      });
                      if (e.toString().contains('already registered') || 
                          e.toString().contains('phone number') ||
                          e.toString().contains('only be used')) {
                        setState(() {
                          sameNumberErr = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'This phone number is already registered. Each number can only be used for one account.',
                            ),
                            duration: Duration(seconds: 4),
                          ),
                        );
                      } else if (e.toString().contains('sign in') || 
                          e.toString().contains('incomplete onboarding') ||
                          e.toString().contains('INCOMPLETE_ONBOARDING')) {
                        setState(() {
                          sameNumberErr = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'An account with this phone number already exists. Please sign in to continue where you left off.',
                            ),
                            duration: const Duration(seconds: 5),
                            action: SnackBarAction(
                              label: 'Sign In',
                              textColor: Colors.white,
                              onPressed: () {
                                // Navigate to login screen
                                Navigator.of(context).pop();
                                context.push(loginRoute);
                              },
                            ),
                          ),
                        );
                      } else if (e.toString().contains('expired') ||
                          e.toString().contains('EXPIRED_ONBOARDING')) {
                        setState(() {
                          sameNumberErr = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Your previous signup expired. Please try creating your account again.',
                            ),
                            duration: Duration(seconds: 4),
                          ),
                        );
                      } else if (e.toString().contains('Connection refused') ||
                          e.toString().contains('SocketException') ||
                          e.toString().contains('Failed host lookup')) {
                        setState(() {
                          sameNumberErr = false;
                        });
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(CustomSnackBar().build(context));
                      } else {
                        setState(() {
                          sameNumberErr = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to create account: ${e.toString()}'),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                        print(e);
                      }
                    }
                  } else {
                    setState(() {
                      tAndCErr = !_tAndCAgreed;
                      sameNumberErr = false;
                    });
                  }
                },
                child:
                    isLoading
                        ? kLoadingIndicator
                        : Text(
                          'Create your account',
                          style: Theme.of(context).textTheme.headlineSmall!
                              .copyWith(color: Colors.white),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
