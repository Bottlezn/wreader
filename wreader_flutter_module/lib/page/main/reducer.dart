import 'package:fish_redux/fish_redux.dart';
import 'package:wreader_flutter_module/consts/global_action_name.dart';
import 'package:wreader_flutter_module/global_store/global_action.dart';
import 'package:wreader_flutter_module/global_store/global_base_state.dart';

import 'state.dart';

Reducer<MainState> buildReducer() {
  return asReducer(
    <Object, Reducer<MainState>>{
      GlobalActionEnum.switchBrightnessMode: _switchBrightnessMode,
//      GlobalActionEnum.switchLanguageCode: _switchLanguageCode,
//      GlobalActionEnum.reloadEnvConf: _reloadEnvConf,
    },
  );
}

///重新加载环境变量配置参数
GlobalState _reloadEnvConf(MainState state, Action action) {
  println("MainState -> _reloadEnvConf");
  Map<String, dynamic> map = action.payload;
  final MainState newState = state.clone()
    ..brightnessMode = map['brightnessMode']
    ..languageCode = map['languageCode'];
  newState.action = GlobalActionName.LOAD_ENV;
  return newState;
}

MainState _switchLanguageCode(MainState state, Action action) {
  println("MainState -> _switchLanguageCode");
  final MainState newState = state.clone();
  newState.languageCode = action.payload;
  newState.action = GlobalActionName.SWITCH_LANGUAGE_CODE;
  return newState;
}

MainState _switchBrightnessMode(MainState state, Action action) {
  println("MainState -> _switchBrightnessMode");
  final MainState newState = state.clone();
  newState.brightnessMode = action.payload;
  newState.action = GlobalActionName.SWITCH_BRIGHTNESS_MODE;
  return newState;
}
