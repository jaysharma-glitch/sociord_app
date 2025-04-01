import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:sociord/provider/user_provider.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/screens/onboarding/widget/tandc_checkbox.dart';
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/widgets/bottom_sheet_signUp.dart';
import '../../widgets/custom_snack_bar.dart';
import 'package:sociord/constants/ui.dart';

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
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'First Name',
                labelStyle: Theme.of(context).textTheme.bodyLarge,
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
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'[a-zA-Z ]')), // Allow only letters and spaces
              ],
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: _lastNameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Last Name',
                labelStyle: Theme.of(context).textTheme.bodyLarge,
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
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'[a-zA-Z ]')), // Allow only letters and spaces
              ],
              style: Theme.of(context).textTheme.bodyLarge,
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
                        print(value);
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
                      dialogTextStyle: Theme.of(context).textTheme.bodyMedium,
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
              style: Theme.of(context).textTheme.bodyLarge,
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
            TandCCheckBox(
              isChecked: _tAndCAgreed,
              onChanged: (value) => setState(() => _tAndCAgreed = value!),
            ),
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
                  // if (_formKey.currentState?.validate() == true &&
                  //     _tAndCAgreed) {
                  //   setState(() {
                  //     tAndCErr = false;
                  //     sameNumberErr = false;
                  //   });
                  //   // Process data!
                  //   try {
                  //     setState(() {
                  //       isLoading = true;
                  //     });
                  //     var result = await userNotifier.createUser();
                  //     setState(() {
                  //       isLoading = false;
                  //     });
                  //     if (result == true) {
                  //       widget.pageController.nextPage(
                  //         duration: Duration(milliseconds: 300),
                  //         curve: Curves.easeIn,
                  //       );
                  //     }
                  //   } catch (e) {
                  //     setState(() {
                  //       isLoading = false;
                  //     });
                  //     if (e.toString().contains('Connection refused')) {
                  //       setState(() {
                  //         sameNumberErr = false;
                  //       });
                  //       ScaffoldMessenger.of(context)
                  //           .showSnackBar(CustomSnackBar().build(context));
                  //     } else {
                  //       setState(() {
                  //         sameNumberErr = true;
                  //       });
                  //       print(e);
                  //     }
                  //   }
                  // } else {
                  //   setState(() {
                  //     tAndCErr = true;
                  //     sameNumberErr = false;
                  //   });
                  // }
                  widget.pageController!.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                },
                child: isLoading
                    ? kLoadingIndicator
                    : Text(
                        'Create your account',
                        style:
                            Theme.of(context).textTheme.headlineSmall!.copyWith(
                                  color: Colors.white,
                                ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
