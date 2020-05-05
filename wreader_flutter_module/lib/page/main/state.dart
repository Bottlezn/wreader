import 'package:wreader_flutter_module/db/sqlite_helper.dart';
import 'package:wreader_flutter_module/global_store/global_base_state.dart';



///本项目由于使用了Fluro管理Route，再使用FishRedux的PageRoute去管理
///全局变量就显得有点麻烦了，这里直接用MainState的全局变量去管理环境配置。
///不是FishRedux的State全局管理正确实践，但是省事
class MainState extends GlobalState{

  int createdTime = DateTime.now().millisecondsSinceEpoch;


  ///作为全局缓存使用，去数据库拿数据太慢了
  ///简单页面也不想太依赖FishRedux
  static int globalBrightnessMode;

  ///作为全局缓存使用，去数据库拿数据太慢了
  ///简单页面也不想太依赖FishRedux
  static String globalLanguageCode;

  ///作为全局缓存使用，去数据库拿数据太慢了
  ///简单页面也不想太依赖FishRedux
  static String myWord;

  ///作为全局缓存使用，去数据库拿数据太慢了
  ///简单页面也不想太依赖FishRedux
  static String versionName;

  ///作为全局缓存使用，去数据库拿数据太慢了
  ///简单页面也不想太依赖FishRedux
  static int versionCode;

  @override
  MainState clone() {
    var newState = MainState()
      ..brightnessMode = brightnessMode
      ..languageCode = languageCode;
    return newState;
  }

  @override
  String toString() {
    return 'MainState{brightnessMode: $brightnessMode, languageCode: $languageCode, createdTime: $createdTime, action: $action}';
  }
}

MainState initState(Map<String, dynamic> args) {
  int mode = args['brightnessMode'] ?? -1;
  MainState.globalBrightnessMode =
      mode == -1 ? EnvironmentConst.MODE_LIGHT : mode;
  MainState.globalLanguageCode = args['languageCode'];
  return MainState()
    ..brightnessMode = MainState.globalBrightnessMode
    ..languageCode = MainState.globalLanguageCode;
}
