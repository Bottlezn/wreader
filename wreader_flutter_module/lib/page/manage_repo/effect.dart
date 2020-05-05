import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:wreader_flutter_module/db/sqlite_helper.dart';

import 'action.dart';
import 'state.dart';

Effect<ManageGitRepoState> buildEffect() {
  return combineEffects(<Object, Effect<ManageGitRepoState>>{
    Lifecycle.initState: _initState,
    ManageGitRepoAction.reloadRepoItem: _initState,
  });
}

void _initState(Action action, Context<ManageGitRepoState> ctx) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _getRepoInfo(ctx);
  });
}

_getRepoInfo(Context<ManageGitRepoState> ctx) async {
  var list = await WReaderSqlHelper.queryRepoPreItems();
  ctx.dispatch(ManageGitRepoActionCreator.loadRepoItem(list));
}
