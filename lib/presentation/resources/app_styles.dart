import 'package:flutter/material.dart';
import 'package:webant_gallery_part_two/presentation/resources/app_colors.dart';

import 'app_strings.dart';

class AppStyles {
  static ButtonStyle styleButtonAlreadyHaveAccount = ElevatedButton.styleFrom(
      primary: AppColors.colorWhite,
      side: BorderSide(color: AppColors.mainColor));

  static const Text textAlreadyHaveAccount = Text(
    AppStrings.buttonAlreadyHaveAccount,
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: 14,
      color: Colors.black,
    ),
  );

  static const Text textCreateAccount = Text(
    AppStrings.buttonCreateAccount,
    textAlign: TextAlign.center,
    style: TextStyle(fontSize: 14),
  );

  static ButtonStyle styleButtonCreateAccount =
      ElevatedButton.styleFrom(primary: AppColors.mainColor);

  static const Text textWelcome = Text(
    AppStrings.welcome,
    style: TextStyle(
      fontSize: 25,
      fontWeight: FontWeight.w700,
      color: AppColors.mainColor,
    ),
  );

  static const Text signIn = Text(
    AppStrings.signIn,
    style: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.w700,
      shadows: [Shadow(color: Colors.black, offset: Offset(0, -7))],
      color: Colors.transparent,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.decorationColor,
      decorationThickness: 2,
    ),
  );

  static const textCancel = Text(
    'cancel',
    style: TextStyle(color: AppColors.textTitleCancel, fontSize: 15),
  );

  static OutlineInputBorder borderTextField = OutlineInputBorder(
    borderSide: BorderSide(color: AppColors.mainColorAccent, width: 1.0),
  );
  static const Icon iconMail = Icon(
    Icons.mail_outline,
    color: AppColors.mainColorAccent,
  );
}