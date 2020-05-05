import 'package:fish_redux/fish_redux.dart';
import 'package:wreader_flutter_module/bean/repo_preview_item.dart';

enum HomeAction {
  initSuccess,
  initFailure,
  deleteFinish,
  refreshSuccess,
  doRefresh,
  showRefresh,
}

class HomeActionCreator {
  static Action initSuccess(
      List<RepoPreviewItem> repoList, List<Map<String, dynamic>> readingList) {
    return Action(HomeAction.initSuccess, payload: {
      'repoList': repoList,
      'readingList': readingList,
    });
  }

  static Action refreshSuccess(
      List<RepoPreviewItem> repoList, List<Map<String, dynamic>> readingList) {
    return Action(HomeAction.refreshSuccess, payload: {
      'repoList': repoList,
      'readingList': readingList,
    });
  }

  static Action deleteFinish(int index) {
    return Action(HomeAction.deleteFinish, payload: {'index': index});
  }

  static Action doRefresh() {
    return Action(HomeAction.doRefresh);
  }

  static Action showRefresh() {
    return Action(HomeAction.showRefresh);
  }

}
