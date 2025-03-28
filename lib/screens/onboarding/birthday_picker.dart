import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sociord/provider/user_provider.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/utils/asset_path_constants.dart';

class BirthdayPicker extends ConsumerStatefulWidget {
  final PageController? pageController;
  const BirthdayPicker({super.key, this.pageController});

  @override
  _BirthdayPickerState createState() => _BirthdayPickerState();
}

class _BirthdayPickerState extends ConsumerState<BirthdayPicker> {
  final int currentYear = DateTime.now().year;
  String? dateString;

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')} | ${date.month.toString().padLeft(2, '0')} | ${date.year}";
  }

  @override
  void initState() {
    super.initState();
    final userState = ref.read(userNotifierProvider);
    if (userState.birthDate != null) {
      setState(() {
        dateString = _formatDate(userState.birthDate!);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final userState = ref.watch(userNotifierProvider);
    final userNotifier = ref.read(userNotifierProvider.notifier);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: userState.birthDate != null
          ? userState.birthDate
          : DateTime(
              currentYear - 13,
              DateTime.december,
              31,
            ),
      firstDate: DateTime(currentYear - 100),
      lastDate: DateTime(
        currentYear - 13,
        DateTime.december,
        31,
      ),
    );
    if (picked != null) {
      userNotifier.setBirthDate(picked);
      setState(() {
        dateString = _formatDate(picked);
      });
    }
  }

  Future<void> _selectDateIos(BuildContext context) async {
    final userState = ref.watch(userNotifierProvider);
    final userNotifier = ref.read(userNotifierProvider.notifier);
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 300,
        color: Color.fromARGB(255, 255, 255, 255),
        child: Column(
          children: [
            Container(
              height: 180,
              child: CupertinoDatePicker(
                minimumYear: currentYear - 100,
                maximumYear: currentYear - 13,
                dateOrder: DatePickerDateOrder.dmy,
                initialDateTime: DateTime(
                  currentYear - 13,
                  DateTime.december,
                  31,
                ),
                onDateTimeChanged: (DateTime newDate) {
                  userNotifier.setBirthDate(newDate);
                  setState(() {
                    dateString = _formatDate(newDate);
                  });
                },
                mode: CupertinoDatePickerMode.date,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Done',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userNotifierProvider);
    final userNotifier = ref.read(userNotifierProvider.notifier);

    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Select your birthdate",
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              if (Platform.isIOS) {
                _selectDateIos(context);
                setState(() {});
              } else {
                _selectDate(context);
                setState(() {});
              }
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: kBorderGreay),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(dateString != null ? dateString! : 'DD | MM | YYYY',
                      style: userState.birthDate != null
                          ? Theme.of(context).textTheme.bodyMedium
                          : Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: kAppLightBlack)),
                  Image.asset(kDropDown),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // if (userState.birthDate != null)
          //   Text(userState.birthDate!.toIso8601String()),
          const SizedBox(height: 40),
          if (userState.birthDate != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  widget.pageController!.nextPage(
                    duration: Duration(milliseconds: 300),
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
