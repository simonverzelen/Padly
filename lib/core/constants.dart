import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

// Just for demo
const productDemoImg1 = "https://i.imgur.com/CGCyp1d.png";
const productDemoImg2 = "https://i.imgur.com/AkzWQuJ.png";
const productDemoImg3 = "https://i.imgur.com/J7mGZ12.png";
const productDemoImg4 = "https://i.imgur.com/q9oF9Yq.png";
const productDemoImg5 = "https://i.imgur.com/MsppAcx.png";
const productDemoImg6 = "https://i.imgur.com/JfyZlnO.png";

// End For demo

const grandisExtendedFont = "Grandis Extended";

// On color 80, 60.... those means opacity

const Color primaryColor = Color(0xFFDCF800);
Color cardBackgroundColor = const Color(0xFFF8F8F8).withOpacity(0.03);
Color scrollBackgroundColor = const Color(0xFFF8F8F8).withOpacity(0.1);
Color cardFeaturedBackgroundColor = const Color(0xFFDCF800).withOpacity(0.1);
const Color cardBackgroundWithOpacity = Color(0xFF353535);
const Color backgroundColor = Color(0xFF1F1F1F);
const Color pillBackgroundColor = Color(0xFF555A2E);
const Color borderColor = Color(0xFF161800);
const Color borderColorWhite = Color(0xFFF8F8F8);

const MaterialColor primaryMaterialColor =
    MaterialColor(0xFFDCF800, <int, Color>{
  50: Color(0xFFfbfee5),
  100: Color(0xFFf4fcb2),
  200: Color(0xFFedfb7f),
  300: Color(0xFFe6fa4c),
  400: Color(0xFFe3f932),
  500: Color(0xFFDCF800),
  600: Color(0xFFb0c600),
  700: Color(0xFF849400),
  800: Color(0xFF586300),
  900: Color(0xFF2c3100),
});

const Color blackColor = Color(0xFF16161E);
const Color blackColor80 = Color(0xFF45454B);
const Color blackColor60 = Color(0xFF737378);
const Color blackColor40 = Color(0xFFA2A2A5);
const Color blackColor20 = Color(0xFFD0D0D2);
const Color blackColor10 = Color(0xFFE8E8E9);
const Color blackColor5 = Color(0xFFF3F3F4);

const Color whiteColor = Colors.white;
const Color whiteColor80 = Color(0xFFCCCCCC);
const Color whiteColor60 = Color(0xFF999999);
const Color whiteColor40 = Color(0xFF666666);
const Color whiteColor20 = Color(0xFF333333);
const Color whiteColor10 = Color(0xFF191919);
const Color whiteColor5 = Color(0xFF0D0D0D);

const Color greyColor = Color(0xFFB8B5C3);
const Color lightGreyColor = Color(0xFFF8F8F9);
const Color darkGreyColor = Color(0xFF1C1C25);
// const Color greyColor80 = Color(0xFFC6C4CF);
// const Color greyColor60 = Color(0xFFD4D3DB);
// const Color greyColor40 = Color(0xFFE3E1E7);
// const Color greyColor20 = Color(0xFFF1F0F3);
// const Color greyColor10 = Color(0xFFF8F8F9);
// const Color greyColor5 = Color(0xFFFBFBFC);

const Color purpleColor = Color(0xFF7B61FF);
const Color successColor = Color(0xFF2ED573);
const Color warningColor = Color(0xFFFFBE21);
const Color errorColor = Color(0xFFEA5B5B);

const double defaultPadding = 16.0;
const double defaultBorderRadious = 32.0;
const Duration defaultDuration = Duration(milliseconds: 300);

final passwordValidator = MultiValidator([
  RequiredValidator(errorText: 'Password is required'),
  MinLengthValidator(8, errorText: 'password must be at least 8 digits long'),
  PatternValidator(r'(?=.*?[#?!@$%^&*-])',
      errorText: 'passwords must have at least one special character')
]);

final emaildValidator = MultiValidator([
  RequiredValidator(errorText: 'Email is required'),
  EmailValidator(errorText: "Enter a valid email address"),
]);

const pasNotMatchErrorText = "passwords do not match";
