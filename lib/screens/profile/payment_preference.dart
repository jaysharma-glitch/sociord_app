import 'package:flutter/material.dart';
import 'package:sociord/widgets/option_selector.dart';

class PaymentPreference extends StatefulWidget {
  final pageController;
  const PaymentPreference({super.key, this.pageController});

  @override
  State<PaymentPreference> createState() => _PaymentPreferenceState();
}

class _PaymentPreferenceState extends State<PaymentPreference> {
  var selectedOption = '';
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OptionSelector(
            title: 'Bank Transfer',
            isSelected: selectedOption == 'Bank Transfer' ? true : false,
            onTap: () {
              setState(() {
                selectedOption = 'Bank Transfer';
              });
            },
            isSizeLarge: false,
          ),
          const SizedBox(
            height: 20,
          ),
          OptionSelector(
              isSizeLarge: false,
              title: 'UPI',
              isSelected: selectedOption == 'UPI' ? true : false,
              onTap: () {
                setState(() {
                  selectedOption = 'UPI';
                });
              }),
          const SizedBox(
            height: 20,
          ),
          OptionSelector(
              isSizeLarge: false,
              title: 'Paypal',
              isSelected: selectedOption == 'Paypal' ? true : false,
              onTap: () {
                setState(() {
                  selectedOption = 'Paypal';
                });
              }),
          const SizedBox(
            height: 40,
          ),
          if (selectedOption != '')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  widget.pageController!.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                },
                child: Text(
                  'Continue',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
