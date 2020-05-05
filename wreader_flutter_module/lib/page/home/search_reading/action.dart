import 'package:fish_redux/fish_redux.dart';

enum SearchReadingRecordAction { search, searchFinish }

class SearchReadingRecordActionCreator {
  static Action search(String key, int taskIndex) {
    return Action(SearchReadingRecordAction.search,
        payload: {'key': key, 'taskIndex': taskIndex});
  }

  static Action searchFinish(
      List<Map<String, dynamic>> readingRecord, int taskIndex) {
    return Action(SearchReadingRecordAction.searchFinish,
        payload: {'readingRecord': readingRecord, 'taskIndex': taskIndex});
  }
}
