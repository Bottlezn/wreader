import 'package:flutter/material.dart';
import 'package:wreader_flutter_module/values/app_colors.dart';
import 'package:wreader_flutter_module/values/app_dimens.dart';


class AppTvStyles {
  static TextStyle buildTextStyle(Color color, double fontSize, bool bold) {
    return TextStyle(
        color: color,
        fontSize: fontSize,
        decoration: TextDecoration.none,
        fontWeight: !bold ? FontWeight.normal : FontWeight.bold);
  }

  static TextStyle textStyle10ColorWhite([bool bold = false]) {
    return buildTextStyle(Colors.white, AppSps.txtSize10, bold);
  }

  static TextStyle textStyle12ColorWhite([bool bold = false]) {
    return buildTextStyle(Colors.white, AppSps.txtSize12, bold);
  }

  static TextStyle textStyle14ColorWhite([bool bold = false]) {
    return buildTextStyle(Colors.white, AppSps.txtSize14, bold);
  }

  static TextStyle textStyle16ColorWhite([bool bold = false]) {
    return buildTextStyle(Colors.white, AppSps.txtSize16, bold);
  }

  static TextStyle textStyle18ColorWhite([bool bold = false]) {
    return buildTextStyle(Colors.white, AppSps.txtSize18, bold);
  }

  static TextStyle textStyle20ColorWhite([bool bold = false]) {
    return buildTextStyle(Colors.white, AppSps.txtSize20, bold);
  }

  static TextStyle textStyle22ColorWhite([bool bold = false]) {
    return buildTextStyle(Colors.white, AppSps.txtSize22, bold);
  }

  static TextStyle textStyle10Color63([bool bold = false]) {
    return buildTextStyle(AppColors.COLOR_63, AppSps.txtSize10, bold);
  }

  static TextStyle textStyle12Color63([bool bold = false]) {
    return buildTextStyle(AppColors.COLOR_63, AppSps.txtSize12, bold);
  }

  static TextStyle textStyle14Color63([bool bold = false]) {
    return buildTextStyle(AppColors.COLOR_63, AppSps.txtSize14, bold);
  }

  static TextStyle textStyle16Color63([bool bold = false]) {
    return buildTextStyle(AppColors.COLOR_63, AppSps.txtSize16, bold);
  }

  static TextStyle textStyle18Color63([bool bold = false]) {
    return buildTextStyle(AppColors.COLOR_63, AppSps.txtSize18, bold);
  }

  static TextStyle textStyle20Color63([bool bold = false]) {
    return buildTextStyle(AppColors.COLOR_63, AppSps.txtSize20, bold);
  }

  static TextStyle textStyle22Color63([bool bold = false]) {
    return buildTextStyle(AppColors.COLOR_63, AppSps.txtSize22, bold);
  }

  static TextStyle textStyle10Color66([bool bold = false]) {
    return buildTextStyle(AppColors.COLOR_66, AppSps.txtSize10, bold);
  }

  static TextStyle textStyle12Color66([bool bold = false]) {
    return buildTextStyle(AppColors.COLOR_66, AppSps.txtSize12, bold);
  }

  static TextStyle textStyle14Color66([bool bold = false]) {
    return buildTextStyle(AppColors.COLOR_66, AppSps.txtSize14, bold);
  }

  static TextStyle textStyle16Color66([bool bold = false]) {
    return buildTextStyle(AppColors.COLOR_66, AppSps.txtSize16, bold);
  }

  static TextStyle textStyle18Color66([bool bold = false]) {
    return buildTextStyle(AppColors.COLOR_66, AppSps.txtSize18, bold);
  }

  static TextStyle textStyle20Color66([bool bold = false]) {
    return buildTextStyle(AppColors.COLOR_66, AppSps.txtSize20, bold);
  }

  static TextStyle textStyle22Color66([bool bold = false]) {
    return buildTextStyle(AppColors.COLOR_66, AppSps.txtSize22, bold);
  }

  static TextStyle textStyle10Color69([bool bold = false]) {
    return buildTextStyle(AppColors.COLOR_69, AppSps.txtSize10, bold);
  }

  static TextStyle textStyle12Color69([bool bold = false]) {
    return buildTextStyle(AppColors.COLOR_69, AppSps.txtSize12, bold);
  }

  static TextStyle textStyle14Color69([bool bold = false]) {
    return buildTextStyle(AppColors.COLOR_69, AppSps.txtSize14, bold);
  }

  static TextStyle textStyle16Color69([bool bold = false]) {
    return buildTextStyle(AppColors.COLOR_69, AppSps.txtSize16, bold);
  }

  static TextStyle textStyle18Color69([bool bold = false]) {
    return buildTextStyle(AppColors.COLOR_69, AppSps.txtSize18, bold);
  }

  static TextStyle textStyle20Color69([bool bold = false]) {
    return buildTextStyle(AppColors.COLOR_69, AppSps.txtSize20, bold);
  }

  static TextStyle textStyle22Color69([bool bold = false]) {
    return buildTextStyle(AppColors.COLOR_69, AppSps.txtSize22, bold);
  }

  static TextStyle textStyle10Color6e([bool bold = false]) {
    return buildTextStyle(AppColors.COLOR_6E, AppSps.txtSize10, bold);
  }

  static TextStyle textStyle12Color6e([bool bold = false]) {
    return buildTextStyle(AppColors.COLOR_6E, AppSps.txtSize12, bold);
  }

  static TextStyle textStyle14Color6e([bool bold = false]) {
    return buildTextStyle(AppColors.COLOR_6E, AppSps.txtSize14, bold);
  }

  static TextStyle textStyle16Color6e([bool bold = false]) {
    return buildTextStyle(AppColors.COLOR_6E, AppSps.txtSize16, bold);
  }

  static TextStyle textStyle18Color6e([bool bold = false]) {
    return buildTextStyle(AppColors.COLOR_6E, AppSps.txtSize18, bold);
  }

  static TextStyle textStyle20Color6e([bool bold = false]) {
    return buildTextStyle(AppColors.COLOR_6E, AppSps.txtSize20, bold);
  }

  static TextStyle textStyle22Color6e([bool bold = false]) {
    return buildTextStyle(AppColors.COLOR_6E, AppSps.txtSize22, bold);
  }

  static TextStyle textStyle10ColorMain([bool bold = false]) {
    return buildTextStyle(AppColors.COLOR_MAIN, AppSps.txtSize10, bold);
  }

  static TextStyle textStyle12ColorMain([bool bold = false]) {
    return buildTextStyle(AppColors.COLOR_MAIN, AppSps.txtSize12, bold);
  }

  static TextStyle textStyle14ColorMain([bool bold = false]) {
    return buildTextStyle(AppColors.COLOR_MAIN, AppSps.txtSize14, bold);
  }

  static TextStyle textStyle16ColorMain([bool bold = false]) {
    return buildTextStyle(AppColors.COLOR_MAIN, AppSps.txtSize16, bold);
  }

  static TextStyle textStyle18ColorMain([bool bold = false]) {
    return buildTextStyle(AppColors.COLOR_MAIN, AppSps.txtSize18, bold);
  }

  static TextStyle textStyle20ColorMain([bool bold = false]) {
    return buildTextStyle(AppColors.COLOR_MAIN, AppSps.txtSize20, bold);
  }

  static TextStyle textStyle22ColorMain([bool bold = false]) {
    return buildTextStyle(AppColors.COLOR_MAIN, AppSps.txtSize22, bold);
  }

  static TextStyle textStyle10SpecColor(Color color, [bool bold = false]) {
    return buildTextStyle(color, AppSps.txtSize10, bold);
  }

  static TextStyle textStyle12SpecColor(Color color, [bool bold = false]) {
    return buildTextStyle(color, AppSps.txtSize12, bold);
  }

  static TextStyle textStyle14SpecColor(Color color, [bool bold = false]) {
    return buildTextStyle(color, AppSps.txtSize14, bold);
  }

  static TextStyle textStyle16SpecColor(Color color, [bool bold = false]) {
    return buildTextStyle(color, AppSps.txtSize16, bold);
  }

  static TextStyle textStyle18SpecColor(Color color, [bool bold = false]) {
    return buildTextStyle(color, AppSps.txtSize18, bold);
  }

  static TextStyle textStyle20SpecColor(Color color, [bool bold = false]) {
    return buildTextStyle(color, AppSps.txtSize20, bold);
  }

  static TextStyle textStyle22SpecColor(Color color, [bool bold = false]) {
    return buildTextStyle(color, AppSps.txtSize22, bold);
  }
}
