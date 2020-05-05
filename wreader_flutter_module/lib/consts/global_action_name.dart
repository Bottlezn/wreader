import 'package:wreader_flutter_module/page/main/state.dart';

///配合[MainState]与[GlobalActionName]改变全局亮暗模式与语言配置
class GlobalActionName {
  static const LOAD_ENV = 'load_env';
  static const SWITCH_LANGUAGE_CODE = 'switch_language_code';
  static const SWITCH_BRIGHTNESS_MODE = 'switch_brightness_mode';
}
