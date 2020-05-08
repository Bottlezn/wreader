import 'dart:io';

import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:wreader_flutter_module/consts/authencation_way.dart';
import 'package:wreader_flutter_module/utils/size/size_util.dart';
import 'package:wreader_flutter_module/values/app_colors.dart';
import 'package:wreader_flutter_module/values/app_strings.dart';
import 'package:wreader_flutter_module/widget/common_decoration.dart';
import 'package:wreader_flutter_module/widget/common_styles.dart';
import 'package:wreader_flutter_module/widget/ez_app_bar.dart';
import 'package:wreader_flutter_module/widget/ez_selector.dart';
import 'package:wreader_flutter_module/widget/text_selector.dart';

import 'action.dart';
import 'state.dart';

Widget buildView(
    RepoConfigState state, Dispatch dispatch, ViewService viewService) {
  return Scaffold(
    appBar: EzAppBar.buildCenterTitleAppBar(
        StrsRepoConf.title(), viewService.context,
        actions: _obtainAction(state, dispatch, viewService)),
    body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _buildCommonGap(),
          _buildGitUriInput(state, dispatch, viewService),
          _buildCommonGap(),
          _buildGitLocalRepoNameInput(state, dispatch, viewService),
          _buildCommonGap(),
          //鉴权方式选择提示文本
          Container(
            margin: EdgeInsets.fromLTRB(30.px2Dp, 0, 30.px2Dp, 0.0),
            width: double.maxFinite,
            child: Text(
              StrsRepoConf.localPath(),
              style: AppTvStyles.textStyle14Color69(),
            ),
          ),
          _buildLocalPathSelectBar(state, dispatch, viewService),
          _buildCommonGap(),
          Container(
            margin: EdgeInsets.fromLTRB(30.px2Dp, 0, 30.px2Dp, 0.0),
            width: double.maxFinite,
            child: Text(
              StrsRepoConf.selectAuthenticate(),
              style: AppTvStyles.textStyle14Color69(),
            ),
          ),
          _buildAuthenticateSelectBar(state, dispatch, viewService),
          _buildCommonGap(),
          _buildAccountAndPwd(state, dispatch, viewService),
          _buildKeyPair(state, dispatch, viewService)
        ],
      ),
    ),
  );
}

_buildCommonGap() {
  return SizedBox(
    height: 20.px2Dp,
  );
}

_buildGitLocalRepoNameInput(
    RepoConfigState state, Dispatch dispatch, ViewService viewService) {
  return Container(
    height: 90.px2Dp,
    width: double.infinity,
    margin: EdgeInsets.fromLTRB(30.px2Dp, 0, 30.px2Dp, 0),
    child: TextField(
      focusNode: state.gitTargetDirFocus,
      controller: state.gitTargetDirController,
      keyboardType: TextInputType.url,
      decoration: InputDecoration(
          hintText: StrsRepoConf.inputGitLocalRepo(),
          contentPadding: EdgeInsets.all(12.px2Dp),
          border: _buildInputBorder()),
      maxLines: 1,
      minLines: 1,
      style: AppTvStyles.textStyle16ColorMain(),
    ),
  );
}

///git地址的输入框
_buildGitUriInput(
    RepoConfigState state, Dispatch dispatch, ViewService viewService) {
  return Container(
    width: SizeUtil.deviceWidth,
    height: 140.px2Dp,
    margin: EdgeInsets.fromLTRB(30.px2Dp, 0, 30.px2Dp, 0),
    child: TextField(
      controller: state.gitUriController,
      focusNode: state.gitUriFocus,
      keyboardType: TextInputType.url,
      decoration: InputDecoration(
          hintText: StrsRepoConf.gitUriHint(),
          contentPadding: EdgeInsets.all(12.px2Dp),
          border: _buildInputBorder()),
      maxLines: 3,
      minLines: 3,
      style: AppTvStyles.textStyle16ColorMain(),
    ),
  );
}

///git本地仓库存放地址选择栏
_buildLocalPathSelectBar(
    RepoConfigState state, Dispatch dispatch, ViewService viewService) {
  Text(
    state.gitRootDirController.getText(),
    style: AppTvStyles.textStyle14Color66(),
    maxLines: 3,
    textAlign: TextAlign.left,
    overflow: TextOverflow.ellipsis,
    softWrap: true,
  );
  return Container(
    width: double.infinity,
    alignment: Alignment(-1, 0),
    height: 140.px2Dp,
    padding: EdgeInsets.all(12.px2Dp),
    color: AppColors.COLOR_EDIT_BG,
    margin: EdgeInsets.fromLTRB(30.px2Dp, 6.px2Dp, 30.px2Dp, 0),
    child: Text(
      state.gitRootDirController.getText(),
      style: AppTvStyles.textStyle16ColorMain(),
      maxLines: 3,
      textAlign: TextAlign.left,
      overflow: TextOverflow.ellipsis,
      softWrap: true,
    ),
  );
}

///键值对验证
_buildKeyPair(
    RepoConfigState state, Dispatch dispatch, ViewService viewService) {
  return Offstage(
    child: Container(
      width: double.infinity,
      margin: EdgeInsets.only(left: 30.px2Dp, right: 30.px2Dp),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: 140.px2Dp,
            width: double.infinity,
            child: TextField(
              focusNode: state.priKeyFocus,
              controller: state.priKeyController,
              maxLines: 10000,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                  hintText: StrsRepoConf.inputPriKey(),
                  contentPadding: EdgeInsets.all(12.px2Dp),
                  border: _buildInputBorder()),
              style: AppTvStyles.textStyle16ColorMain(),
            ),
          ),
          _buildCommonGap(),
          Container(
            height: 140.px2Dp,
            width: double.infinity,
            child: TextField(
              maxLines: 10000,
              focusNode: state.pubKeyFocus,
              controller: state.pubKeyController,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                  hintText: StrsRepoConf.inputPubKey(),
                  contentPadding: EdgeInsets.all(12.px2Dp),
                  border: _buildInputBorder()),
              style: AppTvStyles.textStyle16ColorMain(),
            ),
          ),
          _buildCommonGap(),
          Container(
            height: 90.px2Dp,
            width: double.infinity,
            child: TextField(
              maxLines: 1,
              focusNode: state.priPassFocus,
              obscureText: true,
              controller: state.priPassController,
              decoration: InputDecoration(
                  hintText: StrsRepoConf.inputKeyPassphrase(),
                  contentPadding: EdgeInsets.all(12.px2Dp),
                  border: _buildInputBorder()),
              keyboardType: TextInputType.url,
              style: AppTvStyles.textStyle16ColorMain(),
            ),
          ),
          _buildCommonGap(),
        ],
      ),
    ),
    offstage: state.authenticationWay != 2,
  );
}

///账号密码登录
_buildAccountAndPwd(
    RepoConfigState state, Dispatch dispatch, ViewService viewService) {
  return Offstage(
    child: Container(
      margin: EdgeInsets.only(left: 30.px2Dp, right: 30.px2Dp),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: 90.px2Dp,
            width: double.infinity,
            child: TextField(
              focusNode: state.accountFocus,
              controller: state.accountController,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                  hintText: StrsRepoConf.inputAccount(),
                  contentPadding: EdgeInsets.all(12.px2Dp),
                  border: _buildInputBorder()),
              style: AppTvStyles.textStyle16ColorMain(),
            ),
          ),
          _buildCommonGap(),
          Container(
            height: 90.px2Dp,
            width: double.infinity,
            child: TextField(
              focusNode: state.pwdFocus,
              keyboardType: TextInputType.url,
              controller: state.pwdController,
              obscureText: true,
              maxLines: 1,
              decoration: InputDecoration(
                  hintText: StrsRepoConf.inputPwd(),
                  contentPadding: EdgeInsets.all(12.px2Dp),
                  border: _buildInputBorder()),
              style: AppTvStyles.textStyle16ColorMain(),
            ),
          ),
          _buildCommonGap(),
        ],
      ),
    ),
    offstage: state.authenticationWay != 1,
  );
}

///鉴权方式展示栏
_buildAuthenticateSelectBar(
    RepoConfigState state, Dispatch dispatch, ViewService viewService) {
  return Container(
    width: SizeUtil.deviceWidth,
    height: 80.px2Dp,
    margin: EdgeInsets.fromLTRB(30.px2Dp, 6.px2Dp, 30.px2Dp, 0.px2Dp),
    alignment: Alignment(-1, 0),
    child: TextSelector(
      state.authenticateController,
      onPress: () {
        _selectAuthenticate(state, dispatch, viewService);
      },
      alignment: Alignment(-1, 0),
      defaultStyle: AppTvStyles.textStyle16ColorMain(),
      padding: EdgeInsets.only(left: 10.px2Dp, right: 10.px2Dp),
      defaultColor: AppColors.COLOR_EDIT_BG,
      pressingColor: AppColors.COLOR_6E,
    ),
  );
}

///选择鉴权方式
_selectAuthenticate(
    RepoConfigState state, Dispatch dispatch, ViewService viewService) {
  ///记录选择鉴权方式前的输入法焦点
  state.lastFocus =
      _getLastFocusNode(state, dispatch, viewService, state.authenticationWay);
  showDialog(
    context: viewService.context,
    builder: _buildAuthWay,
  ).then((index) {
    if (index == null || !(index is int)) {
      return;
    }
    final int flag = index;
    dispatch(RepoConfigActionCreator.changeAuthWay(index));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.authenticationWay == flag) {
        dispatch(RepoConfigActionCreator.clearFocus());
        dispatch(RepoConfigActionCreator.reopenKeyboard());
      }
    });
  });
}

///构建鉴权方式的选择方式
Widget _buildAuthWay(BuildContext context) {
  return Center(
    child: Container(
      width: SizeUtil.deviceWidth,
      margin: EdgeInsets.only(left: 30.px2Dp, right: 30.px2Dp),
      padding: EdgeInsets.all(20.px2Dp),
      decoration: CommonDecoration.commonRoundDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          FlatButton(
            child: Container(
              width: double.infinity,
              child: Text(
                  StrsAuthenticationWay.way(AuthenticationWay.CLONE_DIRECT),
                  style: AppTvStyles.textStyle14ColorMain()),
            ),
            onPressed: () {
              Navigator.pop(context, AuthenticationWay.CLONE_DIRECT);
            },
          ),
          Container(
            width: double.maxFinite,
            color: Colors.grey,
            height: 1.px2Dp,
          ),
          FlatButton(
            child: Container(
                width: double.infinity,
                child: Text(
                    StrsAuthenticationWay.way(AuthenticationWay.KEY_PAIR),
                    style: AppTvStyles.textStyle14ColorMain())),
            onPressed: () {
              Navigator.pop(context, AuthenticationWay.KEY_PAIR);
            },
          ),
          Container(
            width: double.maxFinite,
            color: Colors.grey,
            height: 1.px2Dp,
          ),
          FlatButton(
            child: Container(
                width: double.infinity,
                child: Text(
                  StrsAuthenticationWay.way(AuthenticationWay.ACCOUNT_AND_PWD),
                  style: AppTvStyles.textStyle14ColorMain(),
                )),
            onPressed: () {
              Navigator.pop(context, AuthenticationWay.ACCOUNT_AND_PWD);
            },
          ),
        ],
      ),
    ),
  );
}

FocusNode _getLastFocusNode(RepoConfigState state, Dispatch dispatch,
    ViewService viewService, int index) {
  if (state.gitUriFocus.hasFocus) {
    return state.gitUriFocus;
  }
  if (state.gitTargetDirFocus.hasFocus) {
    return state.gitTargetDirFocus;
  }
  switch (index) {
    case AuthenticationWay.ACCOUNT_AND_PWD:
      if (state.accountFocus.hasFocus) {
        return state.accountFocus;
      }
      if (state.pwdFocus.hasFocus) {
        return state.pwdFocus;
      }
      return null;
    case AuthenticationWay.KEY_PAIR:
      if (state.priKeyFocus.hasFocus) {
        return state.priKeyFocus;
      }
      if (state.pubKeyFocus.hasFocus) {
        return state.pubKeyFocus;
      }
      if (state.priPassFocus.hasFocus) {
        return state.priPassFocus;
      }
      return null;
    default:
      return null;
  }
}

_obtainAction(
    RepoConfigState state, Dispatch dispatch, ViewService viewService) {
  if (Platform.isIOS) {
    return <Widget>[
      SizedBox(
        height: 98.px2Dp,
        child: EzSelector(
          Padding(
            padding: EdgeInsets.only(left: 20.px2Dp, right: 20.px2Dp),
            child: Image.asset(
              'assets/images/icon_save.png',
              width: 38.px2Dp,
              height: 38.px2Dp,
            ),
          ),
          () {
            _saveRepoConf(state, dispatch, viewService);
          },
          defaultColor: Colors.transparent,
          pressColor: AppColors.COLOR_TRANS_20,
        ),
      )
    ];
  } else if (Platform.isAndroid) {
    return <Widget>[
      SizedBox(
        height: 98.px2Dp,
        child: EzSelector(
          Padding(
            padding: EdgeInsets.only(left: 20.px2Dp, right: 20.px2Dp),
            child: Image.asset(
              'assets/images/icon_import_git_config.png',
              width: 38.px2Dp,
              height: 38.px2Dp,
            ),
          ),
          () {
            _getGitUriConfFile(state, dispatch, viewService);
          },
          defaultColor: Colors.transparent,
          pressColor: AppColors.COLOR_TRANS_20,
        ),
      ),
      SizedBox(
        height: 98.px2Dp,
        child: EzSelector(
          Padding(
            padding: EdgeInsets.only(left: 20.px2Dp, right: 20.px2Dp),
            child: Image.asset(
              'assets/images/icon_save.png',
              width: 38.px2Dp,
              height: 38.px2Dp,
            ),
          ),
          () {
            _saveRepoConf(state, dispatch, viewService);
          },
          defaultColor: Colors.transparent,
          pressColor: AppColors.COLOR_TRANS_20,
        ),
      )
    ];
  } else {
    return null;
  }
}

_buildInputBorder() {
  return OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.px2Dp)));
}

_saveRepoConf(
    RepoConfigState state, Dispatch dispatch, ViewService viewService) {
  dispatch(RepoConfigActionCreator.clone());
}

_getGitUriConfFile(
    RepoConfigState state, Dispatch dispatch, ViewService viewService) {
  dispatch(RepoConfigActionCreator.getGitConfigFile());
}
