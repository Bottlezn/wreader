import 'package:fish_redux/fish_redux.dart';

import 'action.dart';
import 'state.dart';

Reducer<SearchReadingRecordState> buildReducer() {
  return asReducer(
    <Object, Reducer<SearchReadingRecordState>>{
      SearchReadingRecordAction.searchFinish: _searchFinish,
    },
  );
}

/// {'readingRecord': readingRecord, 'taskIndex': taskIndex}
SearchReadingRecordState _searchFinish(
    SearchReadingRecordState state, Action action) {
  final int taskIndex = action.payload['taskIndex'];
  if (taskIndex != state.taskIndex) {
    return state;
  }
  final List<Map<String, dynamic>> list = action.payload['readingRecord'];
  return state.clone()..readingRecord = list;
}
