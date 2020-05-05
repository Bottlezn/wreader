import 'package:flutter/material.dart';
import 'package:wreader_flutter_module/bean/repo_preview_item.dart';
import 'package:wreader_flutter_module/global_store/global_base_state.dart';

class HomeState extends GlobalState {
  ///是否初始化成功
  bool isInit = false;

  ///仓库列表
  List<RepoPreviewItem> repoList = <RepoPreviewItem>[];

  ///最近阅读记录
  List<Map<String, dynamic>> readingRecord = <Map<String, dynamic>>[];

  SliverGridDelegateWithFixedCrossAxisCount sliverDelegate;

  int lastBackTimestamp = -1;

  ///是否打开 homeDrawer
  bool openDrawer = false;

  BuildContext scaffoldContext;

  /// Scaffold 重新 build 时, HomeDrawer 必须手动关闭,好鸡儿坑爹
  static bool isHomeDrawer = false;

  @override
  HomeState clone() {
    return HomeState()
      ..isInit = this.isInit
      ..repoList = this.repoList
      ..readingRecord = this.readingRecord
      ..scaffoldContext = this.scaffoldContext
      ..sliverDelegate = this.sliverDelegate
      ..action = this.action
      ..brightnessMode = this.brightnessMode
      ..languageCode = this.languageCode
      ..openDrawer = this.openDrawer
      ..lastBackTimestamp = this.lastBackTimestamp;
  }

  @override
  String toString() {
    return 'HomeState{isInit: $isInit, repoList: $repoList, readingRecord: $readingRecord, sliverDelegate: $sliverDelegate, lastBackTimestamp: $lastBackTimestamp, openDrawer: $openDrawer, scaffoldContext: $scaffoldContext}';
  }
}

/// 'openDrawer':bool
HomeState initState(Map<String, dynamic> args) {
  HomeState.isHomeDrawer = false;
  return HomeState()..openDrawer = args['openDrawer'] ?? false;
}
