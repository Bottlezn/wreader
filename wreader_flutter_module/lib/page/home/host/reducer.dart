import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:wreader_flutter_module/utils/size/size_util.dart';

import 'action.dart';
import 'state.dart';

Reducer<HomeState> buildReducer() {
  return asReducer(
    <Object, Reducer<HomeState>>{
      HomeAction.initSuccess: _initSuccess,
      HomeAction.deleteFinish: _deleteFinish,
      HomeAction.refreshSuccess: _refreshSuccess,
      HomeAction.showRefresh: _showRefresh,
    },
  );
}

HomeState _showRefresh(HomeState state, Action action) {
  return state.clone()..isInit = false;
}

HomeState _refreshSuccess(HomeState state, Action action) {
  return state.clone()
    ..repoList = action.payload['repoList']
    ..readingRecord = action.payload['readingList']
    ..isInit = true;
}

///初始化成功
/// {
///     'repoList': repoList,
///     'readingList': readingList,
///   }
HomeState _initSuccess(HomeState state, Action action) => state.clone()
  ..sliverDelegate = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 0.8,
      mainAxisSpacing: 20.px2Dp,
      crossAxisSpacing: 20.px2Dp)
  ..repoList = action.payload['repoList']
  ..readingRecord = action.payload['readingList']
  ..isInit = true;

HomeState _deleteFinish(HomeState state, Action action) =>
    state.clone()..readingRecord.removeAt(action.payload['index']);
