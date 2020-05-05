import 'dart:async';

import 'package:fish_redux/fish_redux.dart';
import 'package:wreader_flutter_module/bean/file_info.dart';
import 'package:wreader_flutter_module/utils/common/string_utils.dart';
import 'package:wreader_flutter_module/utils/reading/reading.dart';

import 'action.dart';
import 'state.dart';

Effect<SearchRepoFileState> buildEffect() {
  return combineEffects(<Object, Effect<SearchRepoFileState>>{
    SearchRepoFileAction.openFile: _openFile,
    SearchRepoFileAction.search: _search,
  });
}

_search(Action action, Context<SearchRepoFileState> ctx) async {
  final String key = action.payload['key'];
  final int taskIndex = action.payload['taskIndex'];
  if (StringUtil.isBlank(key)) {
    ctx.dispatch(SearchRepoFileActionCreator.searchFinish([], taskIndex));
    return;
  }
  var list = await _loadFileInfo(
      {'rootFileInfo': ctx.state.repoDetailsBean.fileInfo, 'key': key});
  ctx.dispatch(SearchRepoFileActionCreator.searchFinish(list, taskIndex));
}

FutureOr<List<FileInfo>> _loadFileInfo(dynamic map) async {
  List<FileInfo> result = [];
  FileInfo rootInfo = map['rootFileInfo'];
  final String key = map['key'];
  if (rootInfo.childList != null && rootInfo.childList.isNotEmpty) {
    for (var info in rootInfo.childList) {
      if (info.isDir && info.childList != null && info.childList.isNotEmpty) {
        loopSearch(info, result, key);
      } else {
        //人肉忽略大小写
        if (info.fileName.toLowerCase().contains(key.toLowerCase())) {
          result.add(info);
        }
      }
    }
  }
  return result;
}

void loopSearch(FileInfo dir, List<FileInfo> result, String key) {
  for (var info in dir.childList) {
    if (info.isDir && info.childList != null && info.childList.isNotEmpty) {
      loopSearch(info, result, key);
    } else {
      //人肉忽略大小写
      if (info.fileName.toLowerCase().contains(key.toLowerCase())) {
        result.add(info);
      }
    }
  }
}

_openFile(Action action, Context<SearchRepoFileState> ctx) async {
  Map<String, dynamic> payload = action.payload;
  println(payload);
  showLoadingAndRead(
      ctx.context,
      payload['fileAbsolutePath'],
      payload['gitUri'],
      payload['currentBranch'],
      payload['gitTargetDir'],
      payload['bizFileType']);
}
