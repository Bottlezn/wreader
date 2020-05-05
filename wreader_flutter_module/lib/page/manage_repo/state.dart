import 'package:fish_redux/fish_redux.dart';
import 'package:wreader_flutter_module/bean/repo_preview_item.dart';

class ManageGitRepoState implements Cloneable<ManageGitRepoState> {
  List<RepoPreviewItem> repoItems = <RepoPreviewItem>[];
  bool isLoading = true;

  @override
  ManageGitRepoState clone() {
    return ManageGitRepoState()
      ..repoItems.addAll(this.repoItems)
      ..isLoading = this.isLoading;
  }
}

ManageGitRepoState initState(Map<String, dynamic> args) {
  return ManageGitRepoState();
}
