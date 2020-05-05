import 'package:flutter/material.dart';
import 'package:wreader_flutter_module/db/sqlite_helper.dart';
import 'package:wreader_flutter_module/page/main/state.dart';

class AppColors {
  static const int _mainPrimaryValue = 0xffef5252;

  static const Color COLOR_MAIN = Color(_mainPrimaryValue);
  static const Color COLOR_MAIN_PRESS = Color(0xffef5252);
  static const Color COLOR_LIGHT_PRESS = Color(0x99ef5252);
  static const Color COLOR_63 = Color(0xff333333);
  static const Color COLOR_66 = Color(0xff666666);
  static const Color COLOR_69 = Color(0xff999999);
  static const Color COLOR_6E = Color(0xffeeeeee);
  static const Color COLOR_BG = Color(0xfff6f8fa);
  static const Color COLOR_EDIT_BG = Color(0x11ef5252);
  static const Color COLOR_TRANS_20 = Color(0x22ffffff);

  static Color commonItemColor(BuildContext context) {
    return _isLight()
        ? Colors.white
        : COLOR_69;
  }

  static Color commonIdleColor(BuildContext context) {
    return _isLight()
        ? Colors.white
        : COLOR_69;
  }

  static Color commonPressColor(BuildContext context) {
    //Theme
    //        .of(context)
    //        .brightness == Brightness.light
    return _isLight()
        ? COLOR_6E
        : Color(0xbb999999);
  }

  static bool _isLight() {
    return MainState.globalBrightnessMode == EnvironmentConst.MODE_LIGHT ||
        MainState.globalBrightnessMode == null;
  }

  ///项目主色调
  static const MaterialColor MAIN = MaterialColor(
    _mainPrimaryValue,
    <int, Color>{
      50: Color(_mainPrimaryValue),
      100: Color(_mainPrimaryValue),
      200: Color(_mainPrimaryValue),
      300: Color(_mainPrimaryValue),
      400: Color(_mainPrimaryValue),
      500: Color(_mainPrimaryValue),
      600: Color(_mainPrimaryValue),
      700: Color(_mainPrimaryValue),
      800: Color(_mainPrimaryValue),
      900: Color(_mainPrimaryValue),
    },
  );
}
