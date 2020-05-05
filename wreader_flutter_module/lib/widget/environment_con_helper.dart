import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:wreader_flutter_module/consts/language_code_const.dart';
import 'package:wreader_flutter_module/db/sqlite_helper.dart';
import 'package:wreader_flutter_module/global_store/global_action.dart';
import 'package:wreader_flutter_module/global_store/global_store.dart';
import 'package:wreader_flutter_module/page/main/state.dart';
import 'package:wreader_flutter_module/utils/channel/trans_bridge_channel.dart';

///环境配置工具类，可以配置语言、亮暗模式等
class EnvironmentConfHelper {
  ///初始化之后，重新加载数据
  static Future reloadEnvConf(
      BuildContext context, int targetMode, String languageCode,
      {bool updateUi = true, bool updateDb = true}) async {
    int realMode = await _handleMode(targetMode);
    String targetCode = getLanguageCode(languageCode);
    if (updateUi) {
      GlobalStore.store
          .dispatch(GlobalActionCreator.reloadEnvConf(realMode, targetCode));
    }
    if (updateDb) {
      await WReaderSqlHelper.modifyEnvironmentConfig(
          targetMode: realMode, languageCode: targetCode);
    }
    return FlutterI18n.refresh(context, Locale(targetCode));
  }

  static Future<int> _handleMode(int targetMode) async {
    if (targetMode != null) {
      return Future.value(targetMode);
    }
    int currentMode = (await WReaderSqlHelper.getEnvironmentConfig())[
        EnvironmentConst.BRIGHTNESS_MODE];
    if (targetMode == null ||
        (targetMode != EnvironmentConst.MODE_LIGHT &&
            targetMode != EnvironmentConst.MODE_DARK)) {
      //模式切换
      targetMode = currentMode == EnvironmentConst.MODE_LIGHT
          ? EnvironmentConst.MODE_DARK
          : EnvironmentConst.MODE_LIGHT;
    }
    return Future.value(targetMode);
  }

  ///切换亮暗模式
  ///[EnvironmentConst.MODE_LIGHT]
  ///[EnvironmentConst.MODE_DARK]
  static switchBrightness([int targetMode]) async {
    int realMode = await _handleMode(targetMode);
    GlobalStore.store
        .dispatch(GlobalActionCreator.switchBrightnessMode(realMode));
    await WReaderSqlHelper.modifyEnvironmentConfig(targetMode: realMode);
  }

  ///支持中英文
  static String getLanguageCode([final String languageCode]) {
    String target = "$languageCode";
    //只支持中文和英文
    if (languageCode == null ||
        languageCode == LanguageCodeConsts.FOLLOW_SYSTEM) {
      Locale currentLocal = WidgetsBinding.instance.window.locale;
      target = "${currentLocal.languageCode}_${currentLocal.countryCode}";
    }
    println("target = $target");
    if (LanguageCodeConsts.ZH_CN == target) {
      return LanguageCodeConsts.ZH_CN;
    }
    return LanguageCodeConsts.EN_US;
  }

  static Future<bool> checkBrightness() async {
    var map = await WReaderSqlHelper.getEnvironmentConfig();
    if (MainState.globalBrightnessMode !=
        map[EnvironmentConst.BRIGHTNESS_MODE]) {
      switchBrightness(map[EnvironmentConst.BRIGHTNESS_MODE]);
      return Future.value(true);
    }
    return Future.value(false);
  }

  ///切换亮暗模式
  static Future switchLanguageCode(
      BuildContext context, String languageCode) async {
    String targetCode = getLanguageCode(languageCode);
    println("targetCode = $targetCode");
    GlobalStore.store
        .dispatch(GlobalActionCreator.switchLanguageCode(languageCode));
    await WReaderSqlHelper.modifyEnvironmentConfig(languageCode: languageCode);
    await FlutterI18n.refresh(context, Locale(targetCode));
    return TransBridgeChannel.switchLanguage();
  }
}
