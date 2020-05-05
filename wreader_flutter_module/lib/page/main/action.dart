import 'package:fish_redux/fish_redux.dart';

enum MainAction { switchBrightnessMode, switchLanguageCode, reloadEnvConf }

class MainActionCreator {
  static Action switchBrightnessMode(int brightnessMode) {
    return Action(MainAction.switchBrightnessMode, payload: brightnessMode);
  }

  static Action reloadEnvConf(int brightnessMode, String languageCode) {
    Map<String, dynamic> map = Map();
    map['brightnessMode'] = brightnessMode;
    map['languageCode'] = languageCode;
    return Action(MainAction.reloadEnvConf, payload: map);
  }

  static Action switchLanguageCode(String languageCode) {
    return Action(MainAction.switchLanguageCode, payload: languageCode);
  }
}
