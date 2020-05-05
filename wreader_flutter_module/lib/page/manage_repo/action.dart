import 'package:fish_redux/fish_redux.dart';
import 'package:wreader_flutter_module/bean/repo_preview_item.dart';

enum ManageGitRepoAction { loadRepoItem, reloadRepoItem ,showLoading}

class ManageGitRepoActionCreator {
  static Action reloadRepoItem() {
    return Action(ManageGitRepoAction.reloadRepoItem);
  }

  static Action showLoading() {
    return Action(ManageGitRepoAction.showLoading);
  }

  static Action loadRepoItem(List<RepoPreviewItem> list) {
    return Action(ManageGitRepoAction.loadRepoItem, payload: list);
  }
}
