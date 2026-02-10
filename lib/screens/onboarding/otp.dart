import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sms_autofill/sms_autofill.dart';

import 'package:sociord/constants/color.dart';
import 'package:sociord/provider/user_provider.dart';
import 'package:sociord/widgets/custom_snack_bar.dart';

class Otp extends ConsumerStatefulWidget {
  final PageController? pageController;
  final bool isLogin;

  const Otp({super.key, this.pageController, this.isLogin = false});

  @override
  ConsumerState<Otp> createState() => _OtpState();
}

class _OtpState extends ConsumerState<Otp> with CodeAutoFill {
  final TextEditingController _otpController = TextEditingController();

  Timer? _timer;
  int _start = 30;
  bool isLoading = false;
  bool wrongOtp = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    listenForCode();
    _startTimer();
  }

  @override
  void codeUpdated() {
    _otpController.text = code ?? '';
  }

  void _startTimer() {
    _start = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        timer.cancel();
      } else {
        setState(() => _start--);
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    cancel(); // sms autofill
    super.dispose();
  }

  Future<void> _handleOtpSubmit(BuildContext context) async {
    final userNotifier = ref.read(userNotifierProvider.notifier);

    ///Comment the code from here to remove otp checking
    // try {
    //   setState(() {
    //     isLoading = true;
    //     wrongOtp = false;
    //   });
    //   final result = await userNotifier.confirmOtp(_otpController.text);
    //   setState(() => isLoading = false);
    //   if (result) {
    ///Comment the code till here to remove otp checking

    if (widget.isLogin) {
      try {
        setState(() => isLoading = true);
        final result = await userNotifier.getUser();
        setState(() => isLoading = false);

        if (result != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Login Successful')));
        }
      } catch (e) {
        setState(() => isLoading = false);
        if (e.toString().contains('Connection refused')) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(CustomSnackBar().build(context));
        } else {
          setState(() => wrongOtp = true);
        }
      }
    } else {
      widget.pageController?.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }

    ///Comment the code from here to remove otp checking
    //   }
    // } catch (e) {
    //   setState(() {
    //     isLoading = false;
    //     wrongOtp = true;
    //   });
    //   if (e.toString().contains('Connection refused')) {
    //     ScaffoldMessenger.of(context)
    //         .showSnackBar(CustomSnackBar().build(context));
    //   }
    // }
    ///Comment the code till here to remove otp checking
  }

  Future<void> _resendOtp() async {
    final userNotifier = ref.read(userNotifierProvider.notifier);
    try {
      setState(() {
        wrongOtp = false;
      });
      _startTimer();
      await userNotifier.resendOtp();
    } catch (e) {
      if (e.toString().contains('Connection refused')) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(CustomSnackBar().build(context));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          _buildPinCodeField(context),
          if (wrongOtp) _buildWrongOtpError(context),
          const SizedBox(height: 20),
          _buildSubmitButton(context),
          const SizedBox(height: 20),
          _buildResendSection(context),
        ],
      ),
    );
  }

  Widget _buildPinCodeField(BuildContext context) {
    return PinCodeTextField(
      appContext: context,
      controller: _otpController,
      length: 6,
      animationType: AnimationType.fade,
      enableActiveFill: false,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      beforeTextPaste: (text) {
        // Allow pasting if the text contains only digits and has 6 characters
        if (text != null && text.length == 6) {
          return RegExp(r'^\d+$').hasMatch(text);
        }
        return false;
      },
      onChanged: (value) {
        setState(() {
          wrongOtp = false;
        });
      },
      onCompleted: (value) {
        // Auto-submit when OTP is complete (optional)
        // Uncomment if you want auto-submit on completion
        // _handleOtpSubmit(context);
      },
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(12),
        fieldHeight: 55,
        fieldWidth: 50,
        inactiveColor: kBorderGreay,
        selectedColor: kAppPurple,
        activeColor: wrongOtp ? kAppRed : kAppDarkGreen,
      ),
      animationDuration: const Duration(milliseconds: 200),
    );
  }

  Widget _buildWrongOtpError(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        'Wrong OTP',
        style: Theme.of(context).textTheme.bodySmall!.copyWith(color: kAppRed),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : () => _handleOtpSubmit(context),
        child: Text(
          'Continue',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall!.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildResendSection(BuildContext context) {
    return Row(
      children: [
        Text(
          "Didn’t receive it?",
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.w300,
            fontSize: 15,
          ),
        ),
        const SizedBox(width: 5),
        _start == 0
            ? ElevatedButton(
              onPressed: _resendOtp,
              style: ElevatedButton.styleFrom(
                minimumSize: Size.zero,
                backgroundColor: kBorderGreay,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.refresh, color: kAppBlack, size: 20),
                  const SizedBox(width: 5),
                  Text(
                    'Resend',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            )
            : Text(
              "Resend it in 00:$_start",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w300,
                fontSize: 15,
              ),
            ),
      ],
    );
  }
}
