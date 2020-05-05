import 'package:fish_redux/fish_redux.dart';
import 'package:wreader_flutter_module/bean/file_info.dart';

import 'action.dart';
import 'state.dart';

Reducer<SearchRepoFileState> buildReducer() {
  return asReducer(
    <Object, Reducer<SearchRepoFileState>>{
      SearchRepoFileAction.searchFinish: _searchFinish,
    },
  );
}

///{'fileInfoList': fileInfoList, 'taskIndex': taskIndex}
SearchRepoFileState _searchFinish(SearchRepoFileState state, Action action) {
  final int taskIndex = action.payload['taskIndex'];
  if (taskIndex != state.taskIndex) {
    return state;
  }
  List<FileInfo> list = action.payload['fileInfoList'];
  return state.clone()..fileInfoList = list;
}
