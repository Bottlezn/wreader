import 'package:fish_redux/fish_redux.dart';
import 'package:wreader_flutter_module/consts/global_action_name.dart';
import 'package:wreader_flutter_module/global_store/global_action.dart';
import 'package:wreader_flutter_module/global_store/global_base_state.dart';


///复制自fish_redux
/// 建立一个AppStore
/// 目前它的功能只有切换主题
class GlobalStore {
  static Store<GlobalState> _globalStore;

  static Store<GlobalState> get store =>
      _globalStore ??= createStore<GlobalState>(GlobalState(), _buildReducer());
}

Reducer<GlobalState> _buildReducer() {
  return asReducer(
    <Object, Reducer<GlobalState>>{
      GlobalActionEnum.switchBrightnessMode: _switchBrightnessMode,
      GlobalActionEnum.switchLanguageCode: _switchLanguageCode,
      GlobalActionEnum.reloadEnvConf: _reloadEnvConf,
    },
  );
}

///重新加载环境变量配置参数
GlobalState _reloadEnvConf(GlobalState state, Action action) {
  println("GlobalState -> _reloadEnvConf");
  Map<String, dynamic> map = action.payload;
  final GlobalState newState = state.clone()
    ..brightnessMode = map['brightnessMode']
    ..languageCode = map['languageCode'];
  newState.action = GlobalActionName.LOAD_ENV;
  return newState;
}

GlobalState _switchLanguageCode(GlobalState state, Action action) {
  println("GlobalState -> _switchLanguageCode");
  final GlobalState newState = state.clone();
  newState.languageCode = action.payload;
  newState.action = GlobalActionName.SWITCH_LANGUAGE_CODE;
  return newState;
}

GlobalState _switchBrightnessMode(GlobalState state, Action action) {
  println("GlobalState -> _switchBrightnessMode");
  final GlobalState newState = state.clone();
  newState.brightnessMode = action.payload;
  newState.action = GlobalActionName.SWITCH_BRIGHTNESS_MODE;
  return newState;
}
