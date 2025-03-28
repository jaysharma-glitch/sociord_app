import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';

class TextFieldWithSubmit extends StatefulWidget {
  const TextFieldWithSubmit({super.key});

  @override
  _TextFieldWithSubmitState createState() => _TextFieldWithSubmitState();
}

class _TextFieldWithSubmitState extends State<TextFieldWithSubmit> {
  final TextEditingController _controller = TextEditingController();
  bool _isButtonActive = false;

  void _onTextChanged(String text) {
    setState(() {
      _isButtonActive = text.isNotEmpty;
    });
  }

  void _onSubmit() {
    if (_isButtonActive) {
      // Handle submission logic here
      print("Submitted: ${_controller.text}");

      // Clear the text field after submitting
      _controller.clear();
      setState(() {
        _isButtonActive = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25), // ✅ Fully rounded corners
        border: Border.all(color: kBorderGreay.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          // Text Field
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 15),
              child: TextField(
                controller: _controller,
                onChanged: _onTextChanged,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 12,
                    color: kAppBlack,
                    fontWeight: FontWeight.w400),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Start typing..",
                  hintStyle: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                          fontSize: 12,
                          color: kAppBlack,
                          fontWeight: FontWeight.w300),
                  isDense: true, // ✅ Reduces default height
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),

          // Submit Button
          GestureDetector(
            onTap: _onSubmit,
            child: Container(
              height: double.infinity,
              width: 80, // ✅ Adjust width as needed
              decoration: BoxDecoration(
                color: _isButtonActive ? kAppPurple : kBorderGreay,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              alignment: Alignment.center,
              child: Text("Submit",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: 12,
                      )),
            ),
          ),
        ],
      ),
    );
  }
}
