import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart';
import 'package:wreader_flutter_module/consts/authencation_way.dart';
import 'package:wreader_flutter_module/values/app_strings.dart';
import 'package:wreader_flutter_module/widget/text_selector.dart';

class RepoConfigState implements Cloneable<RepoConfigState> {
  TextEditingController gitUriController = TextEditingController();
  TextEditingController gitTargetDirController = TextEditingController();
  TextEditingController accountController = TextEditingController();
  TextEditingController pwdController = TextEditingController();
  TextEditingController priKeyController = TextEditingController();
  TextEditingController pubKeyController = TextEditingController();
  TextEditingController priPassController = TextEditingController();
  SelectedController gitRootDirController = SelectedController();
  SelectedController authenticateController = SelectedController();
  int authenticationWay = AuthenticationWay.KEY_PAIR;

  ///焦点控制，不让输入框自动弹出
  FocusNode gitUriFocus = FocusNode();
  FocusNode gitTargetDirFocus = FocusNode();
  FocusNode accountFocus = FocusNode();
  FocusNode pwdFocus = FocusNode();
  FocusNode priKeyFocus = FocusNode();
  FocusNode pubKeyFocus = FocusNode();
  FocusNode priPassFocus = FocusNode();
  FocusNode lastFocus;

  @override
  RepoConfigState clone() {
    return RepoConfigState()
      ..gitUriController = this.gitUriController
      ..gitTargetDirController = this.gitTargetDirController
      ..accountController = this.accountController
      ..pwdController = this.pwdController
      ..priKeyController = this.priKeyController
      ..pubKeyController = this.pubKeyController
      ..priPassController = this.priPassController
      ..gitRootDirController = this.gitRootDirController
      ..authenticateController = this.authenticateController
      ..authenticationWay = this.authenticationWay
      ..gitUriFocus = this.gitUriFocus
      ..lastFocus = this.lastFocus
      ..gitTargetDirFocus = this.gitTargetDirFocus
      ..accountFocus = this.accountFocus
      ..pwdFocus = this.pwdFocus
      ..priKeyFocus = this.priKeyFocus
      ..pubKeyFocus = this.pubKeyFocus
      ..priPassFocus = this.priPassFocus;
  }
}

RepoConfigState initState(Map<String, dynamic> args) {
  return RepoConfigState()
    ..authenticateController
        .setText(StrsAuthenticationWay.way(AuthenticationWay.KEY_PAIR))
    ..gitRootDirController.setText('text');
}
