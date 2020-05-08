import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action;

enum RepoConfigAction {
  action,
  getGitRootDirSuccess,
  getGitRootDirFail,
  requestFocus,
  changeAuthWay,
  reopenKeyboard,
  clearFocus,
  getGitConfigFile,
  fillGitConfig,
  clone,
}

class RepoConfigActionCreator {
  static Action requestFocus(FocusNode node, Context context) {
    return Action(RepoConfigAction.requestFocus, payload: {
      'node': node,
      'context': context,
    });
  }

  static Action clone() {
    return Action(RepoConfigAction.clone);
  }

  static Action getGitConfigFile() {
    return Action(RepoConfigAction.getGitConfigFile);
  }

  static Action fillGitConfig(Map<String, dynamic> config) {
    return Action(RepoConfigAction.fillGitConfig, payload: config);
  }

  static Action changeAuthWay(int index) {
    return Action(RepoConfigAction.changeAuthWay, payload: index);
  }

  static Action getGitRootDirFail() {
    return const Action(RepoConfigAction.getGitRootDirFail);
  }

  static Action clearFocus() {
    return const Action(RepoConfigAction.clearFocus);
  }

  static Action reopenKeyboard() {
    return const Action(RepoConfigAction.reopenKeyboard);
  }

  static Action getGitRootDirSuccess(String dir) {
    return Action(RepoConfigAction.getGitRootDirSuccess, payload: dir);
  }

  static Action onAction() {
    return const Action(RepoConfigAction.action);
  }
}
