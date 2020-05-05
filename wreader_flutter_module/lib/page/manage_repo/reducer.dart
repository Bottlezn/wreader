import 'package:fish_redux/fish_redux.dart';

import 'action.dart';
import 'state.dart';

Reducer<ManageGitRepoState> buildReducer() {
  return asReducer(
    <Object, Reducer<ManageGitRepoState>>{
      ManageGitRepoAction.loadRepoItem: _loadRepoItem,
      ManageGitRepoAction.showLoading: _showLoading,
    },
  );
}

ManageGitRepoState _showLoading(ManageGitRepoState state, Action action) {
  final ManageGitRepoState newState = state.clone();
  newState.isLoading = true;
  newState.repoItems.clear();
  return newState;
}

ManageGitRepoState _loadRepoItem(ManageGitRepoState state, Action action) {
  final ManageGitRepoState newState = state.clone();
  if (action.payload != null) {
    newState.repoItems.addAll(action.payload);
    newState.isLoading = false;
  }
  return newState;
}
