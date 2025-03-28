import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sociord/provider/user_provider.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/widgets/custom_snack_bar.dart';
import 'package:sociord/constants/ui.dart';

class SetUsernameWidget extends ConsumerStatefulWidget {
  final PageController? pageController;
  const SetUsernameWidget({super.key, this.pageController});

  @override
  ConsumerState<SetUsernameWidget> createState() => _SetUsernameWidgetState();
}

class _SetUsernameWidgetState extends ConsumerState<SetUsernameWidget> {
  late TextEditingController _usernameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List suggestions = [];
  bool isButtoVisible = false;
  var isLoading = false;
  var userNameAlredyExsists = false;
  var userNameAccepted = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final userState = ref.read(userNotifierProvider);
    if (userState.userName != null) {
      _usernameController = TextEditingController(text: userState.userName);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userNotifierProvider);
    final userNotifier = ref.read(userNotifierProvider.notifier);

    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set a username for your profile.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _usernameController,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
                CustomInputFormatter()
              ],
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                border: kTextFormFieldBorderStyles,
                enabledBorder: kTextFormFieldBorderStyles,
                errorBorder: kTextFormFieldBorderStyles.copyWith(
                    borderSide: const BorderSide(color: kAppRed)),
                errorText: userNameAlredyExsists
                    ? 'Sorry, this username is taken. Please pick another.'
                    : null,
                suffixIcon: isLoading
                    ? const CircularProgressIndicator.adaptive()
                    : userNameAlredyExsists
                        ? const Icon(
                            Icons.cancel_outlined,
                            color: kAppRed,
                          )
                        : userNameAccepted
                            ? const Icon(
                                Icons.check_circle,
                                color: kAppDarkGreen,
                              )
                            : null,
              ),
              onChanged: (value) async {
                // userNotifier.setUserName(value);
                if (value.length > 2) {
                  try {
                    setState(() {
                      isLoading = false;
                    });
                    print(userState.userId);
                    var result = await userNotifier.checkUserName(value);
                    setState(() {
                      isLoading = false;
                    });
                    if (result != null) {
                      if (result) {
                        final regex = RegExp(r'^[a-zA-Z0-9_.]+$');
                        if (!regex.hasMatch(value)) {
                          setState(() {
                            userNameAccepted = false;
                            userNameAlredyExsists = false;
                            isButtoVisible = false;
                          });
                        } else {
                          setState(() {
                            userNameAccepted = true;
                            userNameAlredyExsists = false;
                            isButtoVisible = true;
                          });
                        }
                      } else {
                        setState(() {
                          userNameAccepted = false;
                          userNameAlredyExsists = true;
                          isButtoVisible = false;
                        });
                        var result = await userNotifier.generateUsernameOptions(
                            value, 'user_123');
                        if (result != null) {
                          setState(() {
                            suggestions = result;
                          });
                        }
                      }
                    }
                  } catch (e) {
                    setState(() {
                      isLoading = false;
                      userNameAccepted = false;
                      userNameAlredyExsists = false;
                      isButtoVisible = false;
                    });
                    if (e.toString().contains('Connection refused')) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(CustomSnackBar().build(context));
                    } else {
                      print(e.toString());
                    }
                  }
                } else {
                  setState(() {
                    suggestions = [];
                    userNameAlredyExsists = false;
                    userNameAccepted = false;
                    isButtoVisible = false;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return null;
                  // return 'Please enter a username';
                }

                // Check if the username contains only alphanumeric characters and underscores
                final regex = RegExp(r'^[a-zA-Z0-9_.]+$');
                if (!regex.hasMatch(value)) {
                  return 'Username can\'t have special characters';
                }

                return null;
              },
            ),
            if (userNameAccepted)
              Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    'Great Pick!',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: kAppDarkGreen),
                  )),
            const SizedBox(height: 30),
            if (suggestions.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Suggestions',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    children: [
                      for (var suggestion in suggestions)
                        ChoiceChip(
                          padding:
                              EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                          label: Text(suggestion),
                          selected: false,
                          labelStyle: Theme.of(context).textTheme.bodySmall,
                          side: BorderSide(width: 0, color: Colors.transparent),
                          backgroundColor: kAppGreay,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12))),
                          onSelected: (selected) {
                            _usernameController.text = suggestion;
                            setState(() {
                              userNameAccepted = true;
                              userNameAlredyExsists = false;
                              isButtoVisible = true;
                            });
                            // userNotifier.setUserName(suggestion);
                          },
                        ),
                      ActionChip(
                        padding:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.refresh,
                              size: 22,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'More',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                        side: BorderSide(width: 0, color: Colors.transparent),
                        backgroundColor: kAppGreay,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12))),
                        onPressed: () async {
                          try {
                            var result =
                                await userNotifier.generateUsernameOptions(
                                    _usernameController.text, 'user_123');
                            if (result != null) {
                              setState(() {
                                suggestions = result;
                              });
                            }
                          } catch (e) {
                            if (e.toString().contains('Connection refused')) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  CustomSnackBar().build(context));
                            } else {
                              print(e.toString());
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            SizedBox(
              height: 20,
            ),
            if (isButtoVisible)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      userNotifier.setUserName(_usernameController.text);

                      widget.pageController!.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
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
    );
  }
}

class CustomInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final String text = newValue.text;

    // Allow lowercase letters, numbers, underscores, and dots
    if (!RegExp(r'^[a-z0-9_.]*$').hasMatch(text)) {
      return oldValue;
    }

    // Prevent two consecutive dots
    if (text.contains('..')) {
      return oldValue;
    }

    return newValue;
  }
}
