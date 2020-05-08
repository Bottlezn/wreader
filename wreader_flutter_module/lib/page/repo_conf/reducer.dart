import 'package:fish_redux/fish_redux.dart';
import 'package:wreader_flutter_module/consts/authencation_way.dart';
import 'package:wreader_flutter_module/utils/channel/trans_bridge_channel.dart';
import 'package:wreader_flutter_module/utils/common/base64_util.dart';
import 'package:wreader_flutter_module/values/app_strings.dart';

import 'action.dart';
import 'state.dart';

Reducer<RepoConfigState> buildReducer() {
  return asReducer(
    <Object, Reducer<RepoConfigState>>{
      RepoConfigAction.getGitRootDirSuccess: _getGitRootDirSuccess,
      RepoConfigAction.getGitRootDirFail: _getGitRootDirFail,
      RepoConfigAction.changeAuthWay: _changeAuthWay,
      RepoConfigAction.fillGitConfig: _fillGitConfig,
    },
  );
}

RepoConfigState _changeAuthWay(RepoConfigState state, Action action) {
  return state.clone()
    ..authenticationWay = action.payload
    ..authenticateController
        .setText(StrsAuthenticationWay.way(state.authenticationWay));
}

RepoConfigState _fillGitConfig(RepoConfigState state, Action action) {
  final RepoConfigState newState = state.clone();
  _fillGitConf(newState, action.payload);
  return newState
    ..authenticateController
        .setText(StrsAuthenticationWay.way(state.authenticationWay));
}

_fillGitConf(RepoConfigState state, Map<String, dynamic> map) {
  try {
    state.gitUriController.text = map['gitUri'];
    state.gitTargetDirController.text = map['targetDir'];
    int way = map['authenticationWay'];
    if (way == AuthenticationWay.CLONE_DIRECT) {
      state.authenticationWay = way;
      state.gitUriController.text = map['gitUri'];
      TransBridgeChannel.showToast(StrsToast.fillConfFileSuccess());
    } else if (way == AuthenticationWay.KEY_PAIR) {
      state.priKeyController.text = Base64Util.decodeBase64(map['priKey']);
      state.pubKeyController.text = Base64Util.decodeBase64(map['pubKey']);
      state.priPassController.text =
          Base64Util.decodeBase64(map['priKeyPassword']);
      state.authenticationWay = way;
      TransBridgeChannel.showToast(StrsToast.fillConfFileSuccess());
    } else if (way == AuthenticationWay.ACCOUNT_AND_PWD) {
      state.accountController.text = Base64Util.decodeBase64(map['account']);
      state.pwdController.text = Base64Util.decodeBase64(map['pwd']);
      state.authenticationWay = way;
      TransBridgeChannel.showToast(StrsToast.fillConfFileSuccess());
    } else {
      TransBridgeChannel.showToast(
          "${StrsToast.parseFail()}：map['authenticationWay'] = $way");
    }
  } catch (e) {
    println(e);
    TransBridgeChannel.showToast("${StrsToast.parseFail()}：$e");
  }
}

RepoConfigState _getGitRootDirSuccess(RepoConfigState state, Action action) {
  return state.clone()..gitRootDirController.setText(action.payload);
}

RepoConfigState _getGitRootDirFail(RepoConfigState state, Action action) {
  return state.clone()
    ..gitRootDirController.setText(StrsRepoConf.errorLocalPath());
}
