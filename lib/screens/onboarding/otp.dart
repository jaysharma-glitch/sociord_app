import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sociord/provider/user_provider.dart';
import 'package:sociord/utils/app_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sociord/widgets/custom_snack_bar.dart';
import 'package:sms_autofill/sms_autofill.dart';

class Otp extends ConsumerStatefulWidget {
  final pageController;
  final isLogin;
  const Otp({super.key, this.pageController, this.isLogin = false});

  @override
  // ignore: library_private_types_in_public_api
  _OtpState createState() => _OtpState();
}

class _OtpState extends ConsumerState<Otp> with CodeAutoFill {
  TextEditingController _otpController = TextEditingController();
  late Timer _timer;
  int _start = 30;
  bool isLoading = false;
  bool wrongOtp = false;
  String? otpCode;

  @override
  void codeUpdated() {
    setState(() {
      otpCode = code;
      _otpController.text = code!;
    });
  }

  @override
  void initState() {
    super.initState();
    listenForCode();
    unregisterListener();
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    cancel();
    super.dispose();
  }

  void startTimer() {
    _start = 30;
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var userNotifier = ref.read(userNotifierProvider.notifier);

    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PinCodeTextField(
            length: 6,
            obscureText: false,
            animationType: AnimationType.fade,
            pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(12.0),
                fieldHeight: 55,
                fieldWidth: 50,
                activeColor: wrongOtp ? kAppRed : kAppDarkGreen,
                selectedColor: kAppPurple,
                inactiveColor: kBorderGreay,
                inactiveFillColor: kBorderGreay,
                selectedFillColor: kBorderGreay,
                errorBorderColor: kAppRed),
            animationDuration: Duration(milliseconds: 200),
            enableActiveFill: false,
            controller: _otpController,
            onCompleted: (v) {
              print("Completed");
            },
            onChanged: (value) {
              print(value);
              setState(() {
                // Update the UI
              });
            },
            beforeTextPaste: (text) {
              print("Allowing to paste $text");
              return true;
            },
            appContext: context,
          ),
          if (wrongOtp)
            Padding(
              padding: EdgeInsets.only(top: 0),
              child: Text(
                'Wrong OTP',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: kAppRed),
              ),
            ),
          // PinFieldAutoFill(
          //   codeLength: 6,
          //   autoFocus: true,
          //   decoration: UnderlineDecoration(
          //     lineHeight: 2,
          //     lineStrokeCap: StrokeCap.square,
          //     bgColorBuilder: PinListenColorBuilder(
          //         Colors.green.shade200, Colors.grey.shade200),
          //     colorBuilder: const FixedColorBuilder(Colors.transparent),
          //   ),
          // ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                // Handle the OTP submission
                try {
                  setState(() {
                    isLoading = true;
                    wrongOtp = false;
                  });

                  var result =
                      await userNotifier.confirmOtp(_otpController.text);

                  setState(() {
                    isLoading = false;
                  });
                  if (result) {
                    if (widget.isLogin) {
                      try {
                        setState(() {
                          isLoading = true;
                        });
                        var result = await userNotifier.getUser();
                        setState(() {
                          isLoading = false;
                        });
                        if (result != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Login Successful')),
                          );
                        }
                      } catch (e) {
                        setState(() {
                          isLoading = false;
                        });
                        if (e.toString().contains('Connection refused')) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(CustomSnackBar().build(context));
                        } else {
                          print(e.toString());
                          setState(() {
                            wrongOtp = true;
                          });
                        }
                      }
                    } else {
                      widget.pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    }
                  }
                } catch (e) {
                  setState(() {
                    isLoading = false;
                    wrongOtp = false;
                  });
                  if (e.toString().contains('Connection refused')) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(CustomSnackBar().build(context));
                  } else {
                    print(e.toString());
                    setState(() {
                      wrongOtp = true;
                    });
                  }
                }

                // widget.pageController.nextPage(
                //   duration: Duration(milliseconds: 300),
                //   curve: Curves.easeIn,
                // );
              },
              child: isLoading
                  ? kLoadingIndicator
                  : Text('Continue',
                      style: Theme.of(context).textTheme.headlineSmall),
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Text("Didn’t receive it?",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontWeight: FontWeight.w300, fontSize: 15)),
              const SizedBox(
                width: 5,
              ),
              _start == 0
                  ? ElevatedButton(
                      onPressed: () async {
                        try {
                          setState(() {
                            isLoading = true;
                            wrongOtp = false;
                          });
                          startTimer();
                          var result = await userNotifier.resendOtp();
                          setState(() {
                            isLoading = false;
                          });
                        } catch (e) {
                          setState(() {
                            isLoading = false;
                          });
                          if (e.toString().contains('Connection refused')) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(CustomSnackBar().build(context));
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.zero,
                        backgroundColor: kBorderGreay,
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10), // Border radius
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.refresh,
                            color: kAppBlack,
                            size: 20,
                          ),
                          const SizedBox(width: 5),
                          Text('Resend',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(fontWeight: FontWeight.w800)),
                        ],
                      ))
                  : Text("Resend it in 00:$_start",
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(fontWeight: FontWeight.w300, fontSize: 15))
            ],
          )
        ],
      ),
    );
  }
}
