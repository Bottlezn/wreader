import 'package:fish_redux/fish_redux.dart';
import 'package:wreader_flutter_module/db/sqlite_helper.dart';
import 'package:wreader_flutter_module/utils/common/string_utils.dart';

import 'action.dart';
import 'state.dart';

Effect<SearchReadingRecordState> buildEffect() {
  return combineEffects(<Object, Effect<SearchReadingRecordState>>{
    SearchReadingRecordAction.search: _search,
  });
}

/// {'key': key, 'taskIndex': taskIndex}
void _search(Action action, Context<SearchReadingRecordState> ctx) async {
  final String key = action.payload['key'];
  final int taskIndex = action.payload['taskIndex'];
  if (StringUtil.isBlank(key)) {
    ctx.dispatch(SearchReadingRecordActionCreator.searchFinish([], taskIndex));
  } else {
    var readingRecords = await WReaderSqlHelper.querySpecificReadingRecord(key);
    ctx.dispatch(SearchReadingRecordActionCreator.searchFinish(
        readingRecords, taskIndex));
  }
}

