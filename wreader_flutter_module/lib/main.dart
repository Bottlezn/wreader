/// @author 悟笃笃(王展鸿)
/// create on 2020-2-3

import 'dart:async';
import 'dart:ui';

import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart';
import 'package:wreader_flutter_module/consts/language_code_const.dart';
import 'package:wreader_flutter_module/page/main/page.dart';
import 'package:wreader_flutter_module/routers/fluro_routers.dart';
import 'package:wreader_flutter_module/utils/channel/trans_bridge_channel.dart';

void main() {
  NavigatorService._sInstance = NavigatorService._();
  _configFluroRoutes();
  var conf = _extractEnvConf();
  FlutterError.onError = (details) {
    if (isDebug()) {
      //输出并记录
      FlutterError.dumpErrorToConsole(details);
    }
    Zone.current.handleUncaughtError(details.exception, details.stack);
  };
  runZoned<Future<Null>>(() async {
    runApp(MyApp(conf['brightnessMode'],
        conf['languageCode'] ?? LanguageCodeConsts.FOLLOW_SYSTEM));
  }, onError: (error, stack) async {
    _reportToNative(error, stack);
  });
}

_reportToNative(dynamic error, StackTrace stack) async {
  await TransBridgeChannel.reportErrorToNative(
      error.toString(), stack.toString());
}

///配置Fluro路由
_configFluroRoutes() {
  println("window.defaultRouteName  = ${window.defaultRouteName}");
  //规定初始Route格式 `/home?brightnessMode=-1&languageCode=null`
  Application.configRouter();
}

///规定初始Route格式 `/home?brightnessMode=-1&languageCode=null`
Map<String, dynamic> _extractEnvConf() {
  //规定初始Route格式 `/home?brightnessMode=-1&languageCode=null`
  RegExp exp = RegExp(
      "^${RouteNames.HOME}\\?brightnessMode=([-\\d]{1,2})&languageCode=([\\w]+)\$");
  var matcher = exp.firstMatch(window.defaultRouteName);
  int brightnessMode = -1;
  String languageCode;
  if (matcher != null && matcher.groupCount > 1) {
    brightnessMode = int.parse(matcher.group(1));
    languageCode = matcher.group(2);
    println("mode = $brightnessMode");
    println("languageCode = $languageCode");
  }
  return {
    'brightnessMode': brightnessMode,
    'languageCode': languageCode,
  };
}

///获取全局的BuildContext使用滴
class NavigatorService {
  GlobalKey<NavigatorState> navigatorState = GlobalKey();

  NavigatorService._();

  static NavigatorService _sInstance;

  static NavigatorService getInstance() => _sInstance;
}

class MyApp extends StatelessWidget {
  final int _brightnessMode;
  final String _languageCode;

  const MyApp(this._brightnessMode, this._languageCode, {Key key})
      : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MainPage().buildPage(
        {'brightnessMode': _brightnessMode, 'languageCode': _languageCode});
  }
}
