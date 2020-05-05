import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:wreader_flutter_module/db/sqlite_helper.dart';
import 'package:wreader_flutter_module/init.dart';
import 'package:wreader_flutter_module/page/main/state.dart';
import 'package:wreader_flutter_module/utils/channel/trans_bridge_channel.dart';
import 'package:wreader_flutter_module/widget/environment_con_helper.dart';

import 'action.dart';
import 'state.dart';

Effect<HomeState> buildEffect() {
  return combineEffects(<Object, Effect<HomeState>>{
    Lifecycle.initState: _initState,
    Lifecycle.didChangeAppLifecycleState: _didChangeAppLifecycleState,
    Lifecycle.deactivate: _deactivate,
    HomeAction.doRefresh: _doRefresh,
  });
}

void _doRefresh(Action action, Context<HomeState> ctx) async {
  _triggerRefresh(ctx);
}

void _deactivate(Action action, Context<HomeState> ctx) async {
  println("host : HomePage>_deactivate");

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (ctx.context != null && ModalRoute.of(ctx.context).isCurrent) {
      _triggerRefresh(ctx);
    }
  });
}

_triggerRefresh(Context<HomeState> ctx) async {
  ctx.dispatch(HomeActionCreator.showRefresh());
  var repoList = await WReaderSqlHelper.queryRepoPreItems();
  var readingList = await WReaderSqlHelper.getAllReadingRecord();
  ctx.dispatch(HomeActionCreator.refreshSuccess(repoList, readingList));
}

///主要监听 resume 事件
void _didChangeAppLifecycleState(Action action, Context<HomeState> ctx) async {
  println("action.payload : ${action.payload}");
  if (AppLifecycleState.resumed == action.payload) {
    //重新回到 Flutter 的 Host 页面，查询亮暗模式是否更改
    EnvironmentConfHelper.checkBrightness();
    _triggerRefresh(ctx);
  }
}

///初始化页面数据
void _initState(Action action, Context<HomeState> ctx) {
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await _runInitModuleFun(ctx);
  });
}

///刷新 语言配置，初始化项目尺寸适配，查询默认配置数据等
_runInitModuleFun(Context<HomeState> ctx) async {
  await FlutterI18n.refresh(
      ctx.context,
      Locale(
          EnvironmentConfHelper.getLanguageCode(MainState.globalLanguageCode)));
  await initModule(ctx.context);
  MainState.myWord =
      (await WReaderSqlHelper.getEnvironmentConfig())[EnvironmentConst.MY_WORD];
  var versionInfo = await TransBridgeChannel.getVersionInfo();
  MainState.versionName = versionInfo['versionName'];
  MainState.versionCode = versionInfo['versionCode'];
  var repoList = await WReaderSqlHelper.queryRepoPreItems();
  var readingList = await WReaderSqlHelper.getAllReadingRecord();
  ctx.dispatch(HomeActionCreator.initSuccess(repoList, readingList));
}
