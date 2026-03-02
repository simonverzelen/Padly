import 'package:flutter/material.dart';

import '../constants.dart';

ElevatedButtonThemeData elevatedButtonThemeData = ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.all(defaultPadding),
    backgroundColor: primaryColor,
    foregroundColor: backgroundColor,
    iconColor: backgroundColor,
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: backgroundColor,
    ),
    minimumSize: const Size(double.infinity, 32),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(defaultBorderRadious)),
    ),
  ),
);

OutlinedButtonThemeData outlinedButtonTheme({
  Color borderColor = whiteColor,
}) {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      textStyle: const TextStyle(
        color: backgroundColor,
      ),
      padding: const EdgeInsets.all(defaultPadding),
      minimumSize: const Size(double.infinity, 32),
      side: BorderSide(width: 1.5, color: borderColor),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(defaultBorderRadious)),
      ),
    ),
  );
}

final textButtonThemeData = TextButtonThemeData(
  style: TextButton.styleFrom(
      foregroundColor: primaryColor,
      textStyle: const TextStyle(
        color: backgroundColor,
      )),
);
