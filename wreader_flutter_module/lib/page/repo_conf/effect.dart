import 'dart:collection';
import 'dart:io';

import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:wreader_flutter_module/consts/authencation_way.dart';
import 'package:wreader_flutter_module/consts/channel_about.dart';
import 'package:wreader_flutter_module/db/sqlite_helper.dart';
import 'package:wreader_flutter_module/routers/fluro_routers.dart';
import 'package:wreader_flutter_module/utils/channel/trans_bridge_channel.dart';
import 'package:wreader_flutter_module/utils/common/json_util.dart';
import 'package:wreader_flutter_module/utils/size/size_util.dart';
import 'package:wreader_flutter_module/values/app_strings.dart';
import 'package:wreader_flutter_module/widget/common_decoration.dart';
import 'package:wreader_flutter_module/widget/common_styles.dart';

import 'action.dart';
import 'state.dart';

Effect<RepoConfigState> buildEffect() {
  return combineEffects(<Object, Effect<RepoConfigState>>{
    Lifecycle.initState: _initState,
    RepoConfigAction.clearFocus: _clearFocus,
    RepoConfigAction.reopenKeyboard: _reopenKeyboard,
    RepoConfigAction.getGitConfigFile: _getGitConfigFile,
    RepoConfigAction.clone: _clone,
  });
}

bool _inputCheck(RepoConfigState state) {
  if (state.gitUriController.text.trim().isEmpty ||
      !(state.gitUriController.text.trim().endsWith('.git'))) {
    TransBridgeChannel.showToast(StrsRepoConf.illegalGitUri());
    return false;
  }
  if (state.authenticationWay == AuthenticationWay.CLONE_DIRECT &&
      (!state.gitUriController.text.trim().startsWith('https://') &&
          !state.gitUriController.text.trim().startsWith('http://'))) {
    TransBridgeChannel.showToast(StrsRepoConf.noAuthCloneUnSupport());
    return false;
  }
  if (state.authenticationWay == AuthenticationWay.ACCOUNT_AND_PWD) {
    if (state.accountController.text.trim().isEmpty ||
        state.pwdController.text.trim().isEmpty) {
      TransBridgeChannel.showToast(StrsRepoConf.illegalAccountAndPwd());
      return false;
    }
  }
  if (state.authenticationWay == AuthenticationWay.KEY_PAIR) {
    if (state.priKeyController.text.trim().isEmpty ||
        state.pubKeyController.text.trim().isEmpty) {
      TransBridgeChannel.showToast(StrsRepoConf.illegalKeyPair());
      return false;
    }
  }
  return true;
}

///显示正在加载中的dialog
_showConfLoading(context) {
  showDialog(
      context: context,
      builder: (_) {
        return WillPopScope(
            child: Center(
              child: Container(
                color: Colors.transparent,
                width: double.infinity,
                margin: EdgeInsets.only(left: 30.px2Dp, right: 30.px2Dp),
                height: 120.px2Dp,
              ),
            ),
            onWillPop: () {
              return Future.value(false);
            });
      });
}

_dismissCloneLoading(context) {
  Navigator.pop(context);
}

//提示用户删除无效仓库或者 重新输入仓库名称
_showDeleteInvalid(Context<RepoConfigState> ctx) {
  final context = ctx.context;
  final state = ctx.state;
  showDialog(
      context: context,
      builder: (_) {
        return Center(
          child: Container(
            width: double.infinity,
            decoration: CommonDecoration.commonRoundDecoration(),
            margin: EdgeInsets.all(30.px2Dp),
            padding: EdgeInsets.all(20.px2Dp),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  StrsRepoConf.gitTargetDirExisted(),
                  style: AppTvStyles.textStyle16ColorMain(),
                  textAlign: TextAlign.left,
                ),
                SizedBox(
                  height: 20.px2Dp,
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: RaisedButton(
                        onPressed: () async {
                          await TransBridgeChannel.clearInvalidRepo();
                          Navigator.pop(context, true);
                        },
                        child: Text(StrsManageRepo.delete()),
                      ),
                    ),
                    SizedBox(
                      width: 30.px2Dp,
                    ),
                    Expanded(
                      flex: 1,
                      child: RaisedButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        child: Text(StrsManageRepo.cancel()),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      }).then((_) {
    if (_ == null || _ == false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        TransBridgeChannel.showToast(
            'git target dir already existed,please input a new target dir.');
        _clearFocusHandle(state);
        _requestFocus(ctx, state.gitTargetDirFocus);
      });
    }
  });
}

void _clone(Action action, Context<RepoConfigState> ctx) async {
  final state = ctx.state;
  final context = ctx.context;
  _showConfLoading(context);
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    //检查输入信息是否有误
    if (!_inputCheck(state)) {
      _dismissCloneLoading(context);
      return;
    }
    //判断检出方式是否支持
    if (state.authenticationWay < AuthenticationWay.CLONE_DIRECT ||
        state.authenticationWay > AuthenticationWay.KEY_PAIR) {
      TransBridgeChannel.showToast("UnSupport authentication way!!!");
      _dismissCloneLoading(context);
      return;
    }
    //查询 gitUri 或者 本地存放目录是否存在
    bool gitUriExisted = await WReaderSqlHelper.queryGitUriExists(
        state.gitUriController.text.trim());
    if (gitUriExisted) {
      TransBridgeChannel.showToast(StrsRepoConf.alreadyExistedUri());
      _dismissCloneLoading(context);
      return;
    }
    String gitLocalDirExisted = await TransBridgeChannel.checkGitExists(
        state.gitUriController.text.trim(),
        state.gitRootDirController.getText().trim(),
        state.gitTargetDirController.text.trim());
    if ('notExists' == gitLocalDirExisted) {
      switch (state.authenticationWay) {
        case AuthenticationWay.CLONE_DIRECT:
          _cloneDir(ctx);
          break;
        case AuthenticationWay.KEY_PAIR:
          _cloneUseKeyPair(ctx);
          break;
        case AuthenticationWay.ACCOUNT_AND_PWD:
          _cloneUseAccountAndPwd(ctx);
          break;
        default:
          return;
      }
    } else {
      _dismissCloneLoading(context);
      _showDeleteInvalid(ctx);
    }
  });
}

/// 直接 clone 项目，支持 https://xxx.git http://xxx.git 格式
_cloneDir(Context<RepoConfigState> ctx) async {
  final state = ctx.state;
  dynamic result = await TransBridgeChannel.cloneDirect(
      state.gitUriController.text.trim(),
      state.gitRootDirController.getText().trim(),
      state.gitTargetDirController.text.trim());
  Map<String, dynamic> map = JsonUtil.decode(result);
  _dismissCloneLoading(ctx.context);
  if ('success' == map['result']) {
    await _saveRepoConf2Db(state, ctx.context,
        AuthenticationWay.ACCOUNT_AND_PWD, map['currentBranch']);
    TransBridgeChannel.showToast(StrsToast.cloneSuccess());
  } else {
    TransBridgeChannel.showToast("${StrsToast.parseFail()}:${map['result']}");
  }
}

/// 使用密钥对clone项目
_cloneUseKeyPair(Context<RepoConfigState> ctx) async {
  final state = ctx.state;
  dynamic result = await TransBridgeChannel.cloneUseKeyPair(
      state.gitUriController.text.trim(),
      state.gitRootDirController.getText().trim(),
      state.priKeyController.text.trim(),
      state.pubKeyController.text.trim(),
      repoName: state.gitTargetDirController.text.trim(),
      priKeyPass: state.priPassController.text.trim());
  Map<String, dynamic> map = JsonUtil.decode(result);
  _dismissCloneLoading(ctx.context);
  if ('success' == map['result']) {
    await _saveRepoConf2Db(state, ctx.context,
        AuthenticationWay.KEY_PAIR, map['currentBranch']);
    TransBridgeChannel.showToast(StrsToast.cloneSuccess());
  } else {
    TransBridgeChannel.showToast("${StrsToast.parseFail()}:${map['result']}");
  }
}

/// 使用账号密码clone项目
_cloneUseAccountAndPwd(Context<RepoConfigState> ctx) async {
  final state = ctx.state;
  String result = await TransBridgeChannel.cloneUseAccountAndPwd(
      state.gitUriController.text.trim(),
      state.gitRootDirController.getText().trim(),
      state.accountController.text.trim(),
      state.pwdController.text.trim(),
      repoName: state.gitTargetDirController.text.trim());
  print("result = $result");
  Map<String, dynamic> map = JsonUtil.decode(result);
  _dismissCloneLoading(ctx.context);
  if ('success' == map['result']) {
    await _saveRepoConf2Db(state, ctx.context,
        AuthenticationWay.ACCOUNT_AND_PWD, map['currentBranch']);
    TransBridgeChannel.showToast(StrsToast.cloneSuccess());
  } else {
    TransBridgeChannel.showToast("${StrsToast.parseFail()}:${map['result']}");
  }
}

_saveRepoConf2Db(RepoConfigState state, BuildContext context,
    int authenticationWay, String currentBranch) async {
  Map<String, dynamic> map = HashMap();
  if (authenticationWay == AuthenticationWay.ACCOUNT_AND_PWD) {
    //String gitUrl, String localPath，String repoName,String priKey,String pubKey,String priKeyPass
    map['account'] = state.accountController.text.trim();
    map['pwd'] = state.pwdController.text.trim();
  } else if (authenticationWay == AuthenticationWay.KEY_PAIR) {
    //String gitUrl, String localPath，String repoName,String priKey,String pubKey,String priKeyPass
    map['priKey'] = state.priKeyController.text.trim();
    map['pubKey'] = state.pubKeyController.text.trim();
    map['priKeyPass'] = state.priPassController.text.trim();
  }
  var targetDir = state.gitTargetDirController.text.trim();
  var gitUri = state.gitUriController.text.trim();
  if (targetDir.isEmpty) {
    targetDir =
        gitUri.substring(gitUri.lastIndexOf('/') + 1, gitUri.lastIndexOf('.'));
  }
  bool isInserted = await WReaderSqlHelper.insertRepoConf(
      state.gitUriController.text.trim(),
      state.gitRootDirController.getText().trim(),
      "$targetDir",
      authenticationWay,
      JsonUtil.encode(map),
      currentBranch);
  _dismissCloneLoading(context);
  if (isInserted) {
    TransBridgeChannel.showToast(StrsToast.saveSuccess());
    FluroRouter.navigateTo(
      context,
      "${RouteNames.REPO_DETAILS}?"
      "gitLocalDir=${Uri.encodeComponent("${state.gitRootDirController.getText().trim()}/$targetDir")}"
      "&gitUri=${Uri.encodeComponent("${state.gitUriController.text.trim()}")}",
    );
  } else {
    TransBridgeChannel.showToast(StrsToast.repoDbDataInsertFail());
  }
}

void _getGitConfigFile(Action action, Context<RepoConfigState> ctx) async {
  _clearFocusHandle(ctx.state);
  var path = await TransBridgeChannel.getGitConfFile();
  println("path = $path");
  if (path == null || path is! String) {
    TransBridgeChannel.showToast(StrsToast.cancelConfFileSelected());
  } else {
    try {
      if (!path.endsWith("json")) {
        TransBridgeChannel.showToast("Illegale File Type:$path");
        return;
      }
      String jsonStr = await File(path).readAsString();
      println("jsonStr:\n$jsonStr");
      Map<String, dynamic> map = JsonUtil.decode(jsonStr);
      println("map:\n$map");
      ctx.dispatch(RepoConfigActionCreator.fillGitConfig(map));
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          final context = ctx.context;
          if (context != null && ModalRoute.of(context).isCurrent) {
            _clearFocusHandle(ctx.state);
          }
        } catch (e) {
          println(e);
        }
      });
    } catch (e) {
      TransBridgeChannel.showToast(
          "${StrsToast.parseConfFileError()}：${e.toString()}");
    }
  }
}

_requestFocus(Context<RepoConfigState> ctx, FocusNode node) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    try {
      final context = ctx.context;
      if (context != null && ModalRoute.of(context).isCurrent) {
        FocusScope.of(context).requestFocus(node);
      }
    } catch (e) {
      println(e);
    }
  });
}

void _initState(Action action, Context<RepoConfigState> ctx) {
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    dynamic localGitRootDir = await TransBridgeChannel.CHANNEL
        .invokeMethod(ChannelOutMethod.GET_GIT_ROOT_PATH);
    if (localGitRootDir != null && localGitRootDir is String) {
      ctx.dispatch(
          RepoConfigActionCreator.getGitRootDirSuccess(localGitRootDir));
    } else {
      ctx.dispatch(RepoConfigActionCreator.getGitRootDirFail());
    }
    _requestFocus(ctx, ctx.state.gitUriFocus);
  });
}

void _clearFocus(Action action, Context<RepoConfigState> ctx) {
  _clearFocusHandle(ctx.state);
}

void _reopenKeyboard(Action action, Context<RepoConfigState> ctx) {
  _reopenKeyboardHandle(ctx.state, ctx.context);
}

///重新打开软键盘
_reopenKeyboardHandle(RepoConfigState state, BuildContext context) {
  final index = state.authenticationWay;
  if (state.lastFocus != null) {
    if (state.lastFocus == state.gitUriFocus ||
        state.lastFocus == state.gitTargetDirFocus) {
      FocusScope.of(context).requestFocus(state.lastFocus);
    } else {
      switch (index) {
        case AuthenticationWay.ACCOUNT_AND_PWD:
          if (state.lastFocus == state.accountFocus ||
              state.lastFocus == state.pwdFocus) {
            FocusScope.of(context).requestFocus(state.lastFocus);
          } else {
            FocusScope.of(context).requestFocus(state.accountFocus);
          }
          break;
        case AuthenticationWay.KEY_PAIR:
          if (state.lastFocus != state.accountFocus &&
              state.lastFocus != state.pwdFocus) {
            FocusScope.of(context).requestFocus(state.lastFocus);
          } else {
            FocusScope.of(context).requestFocus(state.priKeyFocus);
          }
          break;
        default:
          FocusScope.of(context).requestFocus(state.lastFocus);
          FocusScope.of(context).requestFocus(state.gitUriFocus);
          break;
      }
    }
  } else {
    switch (index) {
      case AuthenticationWay.ACCOUNT_AND_PWD:
        FocusScope.of(context).requestFocus(state.accountFocus);
        break;
      case AuthenticationWay.KEY_PAIR:
        FocusScope.of(context).requestFocus(state.priKeyFocus);
        break;
      default:
        break;
    }
  }
}

_clearFocusHandle(RepoConfigState state) {
  try {
    //清空所有焦点，优化交互体验
    state.gitUriFocus.unfocus();
    state.gitTargetDirFocus.unfocus();
    state.accountFocus.unfocus();
    state.pwdFocus.unfocus();

    state.priKeyFocus.unfocus();
    state.pubKeyFocus.unfocus();
    state.priPassFocus.unfocus();
  } catch (e) {
    println(e);
  }
}
