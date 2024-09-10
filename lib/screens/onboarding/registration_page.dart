import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:sociord/provider/user_provider.dart';
import 'package:sociord/utils/app_constants.dart';
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/widgets/bottom_sheet_signUp.dart';
import '../../widgets/custom_snack_bar.dart';

class RegisterWidget extends ConsumerStatefulWidget {
  final PageController pageController;

  RegisterWidget({super.key, required this.pageController});

  @override
  _RegisterWidgetState createState() => _RegisterWidgetState();
}

class _RegisterWidgetState extends ConsumerState<RegisterWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneNumberController;
  bool _tAndCAgreed = false;
  bool tAndCErr = false;
  bool sameNumberErr = false;
  bool isLoading = false;

  void checkClick(value) {
    setState(() {
      _tAndCAgreed = value!;
    });
  }

  @override
  void initState() {
    super.initState();
    final userState = ref.read(userNotifierProvider);
    _firstNameController = TextEditingController(text: userState.firstName);
    _lastNameController = TextEditingController(text: userState.lastName);
    _phoneNumberController = TextEditingController(text: userState.phoneNumber);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userNotifierProvider);
    final userNotifier = ref.read(userNotifierProvider.notifier);

    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: 'First Name',
                border: kTextFormFieldBorderStyles,
                enabledBorder: kTextFormFieldBorderStyles,
                suffixIcon: userState.firstName!.isNotEmpty
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: kAppDarkGreen,
                        size: 20,
                      )
                    : null,
              ),
              onChanged: (value) {
                userNotifier.setFirstName(value);
                print(userState.firstName);
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
            TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: 'Last Name',
                border: kTextFormFieldBorderStyles,
                enabledBorder: kTextFormFieldBorderStyles,
                suffixIcon: userState.lastName!.isNotEmpty
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: kAppDarkGreen,
                        size: 20,
                      )
                    : null,
              ),
              onChanged: (value) {
                userNotifier.setLastName(value);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your last name';
                }
                return null;
              },
            ),
            const SizedBox(
              height: 20,
            ),
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
                borderRadius:
                    BorderRadius.circular(10.0), // Border radius (optional)
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
                      textStyle: const TextStyle(
                        fontSize: 18,
                        color: kAppBlack,
                      ),
                      searchStyle: const TextStyle(
                        fontSize: 15,
                        color: kAppBlack,
                      ),
                      dialogTextStyle: const TextStyle(
                        fontSize: 15,
                        color: kAppBlack,
                      ),
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
            if (sameNumberErr)
              Padding(
                padding: EdgeInsets.only(top: 15),
                child: Text(
                  'User with the same phone number already exsists',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: kAppRed),
                ),
              ),
            const SizedBox(
              height: 15,
            ),
            TandCCheckBox(isChecked: _tAndCAgreed, clickFunc: checkClick),
            Visibility(
              visible: tAndCErr,
              child: Center(
                child: Text(
                  'Kindly agree to the T&C to proceed',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: kAppRed),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
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
                      var result = await userNotifier.createUser();
                      setState(() {
                        isLoading = false;
                      });
                      if (result == true) {
                        widget.pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      }
                    } catch (e) {
                      setState(() {
                        isLoading = false;
                      });
                      if (e.toString().contains('Connection refused')) {
                        setState(() {
                          sameNumberErr = false;
                        });
                        ScaffoldMessenger.of(context)
                            .showSnackBar(CustomSnackBar().build(context));
                      } else {
                        setState(() {
                          sameNumberErr = true;
                        });
                        print(e.toString().contains(
                            'User with the same phone number already exists'));
                      }
                    }
                  } else {
                    setState(() {
                      tAndCErr = true;
                      sameNumberErr = false;
                    });
                    // Show a message or handle the case where conditions aren't met
                  }
                  // widget.pageController!.nextPage(
                  //   duration: Duration(milliseconds: 300),
                  //   curve: Curves.easeIn,
                  // );
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
    );
  }
}

class TandCCheckBox extends StatefulWidget {
  final bool isChecked;
  final clickFunc;
  const TandCCheckBox(
      {super.key, required this.isChecked, required this.clickFunc});

  @override
  State<TandCCheckBox> createState() => _TandCCheckBoxState();
}

class _TandCCheckBoxState extends State<TandCCheckBox> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Checkbox(
          value: widget.isChecked,
          onChanged: (value) {
            widget.clickFunc(value);
          },
        ),
        Text(
          'I agree to Sociord\'s ',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        GestureDetector(
          onTap: () {
            // Open terms and conditions
          },
          child: Text(
            'Terms and Conditions',
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}
