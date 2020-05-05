import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n_delegate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:wreader_flutter_module/consts/language_code_const.dart';
import 'package:wreader_flutter_module/db/sqlite_helper.dart';
import 'package:wreader_flutter_module/main.dart';
import 'package:wreader_flutter_module/routers/fluro_routers.dart';
import 'package:wreader_flutter_module/values/app_colors.dart';

import 'state.dart';

Color _getContainBackgroundColor(MainState state) {
  return state.brightnessMode == EnvironmentConst.MODE_LIGHT
      ? Colors.white
      : Colors.grey[800];
}

class GlobalNavigatorObserver extends NavigatorObserver {
  static GlobalNavigatorObserver _instance;

  GlobalNavigatorObserver._();

  static GlobalNavigatorObserver getInstance() {
    if (_instance == null) {
      _instance = GlobalNavigatorObserver._();
    }
    return _instance;
  }
}

Widget buildView(MainState state, Dispatch dispatch, ViewService viewService) {
  MainState.globalBrightnessMode = state.brightnessMode;
  MainState.globalLanguageCode = state.languageCode;
  return MaterialApp(
    navigatorKey: NavigatorService.getInstance().navigatorState,
    navigatorObservers: [GlobalNavigatorObserver.getInstance()],
    title: 'WReader',
    theme: ThemeData(
      primarySwatch: AppColors.MAIN,
      brightness: state.brightnessMode == EnvironmentConst.MODE_LIGHT
          ? Brightness.light
          : Brightness.dark,
      scaffoldBackgroundColor: _getContainBackgroundColor(state),
      backgroundColor: _getContainBackgroundColor(state),
      dialogBackgroundColor: _getContainBackgroundColor(state),
      canvasColor: _getContainBackgroundColor(state),
    ),
    initialRoute: RouteNames.HOME,
    onGenerateRoute: Application.router.generator,
    localizationsDelegates: [
      FlutterI18nDelegate(
          useCountryCode: true,
          path: 'flutter_i18n',
          fallbackFile: LanguageCodeConsts.EN_US),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
  );
}
