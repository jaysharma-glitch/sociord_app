import 'package:flutter/material.dart';
import 'package:sociord/constants/app_constants.dart';

const kTextFormFieldBorderStyles = OutlineInputBorder(
    borderSide: BorderSide(color: kBorderGreay),
    borderRadius: BorderRadius.all(Radius.circular(10.0)));

const kLoadingIndicator = SizedBox(
  height: 25,
  width: 25,
  child: CircularProgressIndicator(
    backgroundColor: Colors.white,
    strokeWidth: 2,
  ),
);
const kSmallLoadingIndicator = SizedBox(
  height: 15,
  width: 15,
  child: CircularProgressIndicator(
    backgroundColor: Colors.white,
    strokeWidth: 2,
  ),
);
