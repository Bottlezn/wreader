import 'package:fish_redux/fish_redux.dart';

/// Created on 2020/5/4.
/// @author 悟笃笃
/// description:

enum GlobalActionEnum { switchBrightnessMode, switchLanguageCode, reloadEnvConf }

class GlobalActionCreator {
  static Action switchBrightnessMode(int brightnessMode) {
    return Action(GlobalActionEnum.switchBrightnessMode, payload: brightnessMode);
  }

  static Action reloadEnvConf(int brightnessMode, String languageCode) {
    Map<String, dynamic> map = Map();
    map['brightnessMode'] = brightnessMode;
    map['languageCode'] = languageCode;
    return Action(GlobalActionEnum.reloadEnvConf, payload: map);
  }

  static Action switchLanguageCode(String languageCode) {
    return Action(GlobalActionEnum.switchLanguageCode, payload: languageCode);
  }
}
