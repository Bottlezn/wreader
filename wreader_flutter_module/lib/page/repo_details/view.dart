import 'dart:async';

import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart';
import 'package:wreader_flutter_module/bean/file_info.dart';
import 'package:wreader_flutter_module/bean/repo_details_bean.dart';
import 'package:wreader_flutter_module/page/repo_details/action.dart';
import 'package:wreader_flutter_module/page/repo_details/helper/repo_file_helper.dart';
import 'package:wreader_flutter_module/routers/fluro_routers.dart';
import 'package:wreader_flutter_module/utils/channel/trans_bridge_channel.dart';
import 'package:wreader_flutter_module/utils/common/file_type_helper.dart';
import 'package:wreader_flutter_module/utils/size/size_util.dart';
import 'package:wreader_flutter_module/values/app_colors.dart';
import 'package:wreader_flutter_module/values/app_strings.dart';
import 'package:wreader_flutter_module/widget/common_decoration.dart';
import 'package:wreader_flutter_module/widget/common_styles.dart';
import 'package:wreader_flutter_module/widget/common_widgets.dart';
import 'package:wreader_flutter_module/widget/ez_app_bar.dart';
import 'package:wreader_flutter_module/widget/ez_selector.dart';

import 'state.dart';

Widget buildView(
    RepoDetailsState state, Dispatch dispatch, ViewService viewService) {
  String currentDir = "../${state.repoDetailsBean.targetDir ?? ''}";
  if (state.currentFileList != null && state.currentFileList.isNotEmpty) {
    final String tmp = state.currentFileList.first.absoultPath;
    currentDir = tmp.substring(0, tmp.lastIndexOf('/')).replaceAll(
        state.repoDetailsBean.fullDir
            .substring(0, state.repoDetailsBean.fullDir.lastIndexOf('/') + 1),
        '../');
  }
  return WillPopScope(
      child: Scaffold(
        appBar: _buildAppBar(currentDir, viewService, state, dispatch),
        body: _buildBody(state, dispatch, viewService),
        key: Key("${state.brightnessMode}"),
      ),
      onWillPop: () {
        if (!state.loadingFinish) {
          return Future.value(true);
        } else if (state.forwardList == null || state.forwardList.isEmpty) {
          return Future.value(true);
        } else {
          dispatch(RepoDetailsActionCreator.forwardPage());
          return Future.value(false);
        }
      });
}

_buildAppBar(
  String currentDir,
  ViewService viewService,
  RepoDetailsState state,
  Dispatch dispatch,
) {
  return EzAppBar.buildCommonAppBar(
      Container(
        width: double.infinity,
        alignment: Alignment(-1, 0),
        padding: EdgeInsets.only(right: 10.px2Dp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              currentDir,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
              style: AppTvStyles.textStyle14ColorWhite(),
            ),
          ],
        ),
      ),
      viewService.context,
      center: false,
      actions: state.loadingFinish
          ? [
              SizedBox(
                height: 98.px2Dp,
                child: EzSelector(
                  Padding(
                    padding: EdgeInsets.only(left: 20.px2Dp, right: 20.px2Dp),
                    child: Image.asset(
                      'assets/images/icon_search.png',
                      width: 36.px2Dp,
                      height: 36.px2Dp,
                    ),
                  ),
                  () {
                    FluroRouter.navigateTo(
                        viewService.context, RouteNames.SEARCH_REPO_FILE);
                  },
                  defaultColor: Colors.transparent,
                  pressColor: AppColors.COLOR_TRANS_20,
                ),
              )
            ]
          : null);
}

_buildLoading() {
  return CommonWidgets.buildLoadingPage();
}

_buildBody(RepoDetailsState state, Dispatch dispatch, ViewService viewService) {
  return Container(
    key: Key("${state.brightnessMode}"),
    child: !state.loadingFinish
        ? _buildLoading()
        : Container(
            key: Key("${state.brightnessMode}"),
            color: AppColors.commonIdleColor(viewService.context),
            child: Column(
              key: Key("${state.brightnessMode}"),
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.max,
                  key: Key("${state.brightnessMode}"),
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 10.px2Dp,
                    ),
                    Expanded(
                      flex: 1,
                      child: RaisedButton(
                        child: Text(
                          StrsRepoDetails.switchBranch(),
                          style: AppTvStyles.textStyle14Color63(true),
                        ),
                        onPressed: () {
                          _showSwitchOption(state, dispatch, viewService);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 10.px2Dp,
                    ),
                    Expanded(
                      flex: 1,
                      child: RaisedButton(
                        child: Text(
                          'Pull',
                          style: AppTvStyles.textStyle14Color66(true),
                        ),
                        onPressed: () {
                          _pull(state, dispatch);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 10.px2Dp,
                    ),
                    Expanded(
                      flex: 1,
                      child: RaisedButton(
                        child: Text(
                          'Fetch',
                          style: AppTvStyles.textStyle14Color66(true),
                        ),
                        onPressed: () {
                          _fetch(state, dispatch);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 10.px2Dp,
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  alignment: Alignment(-1, 0),
                  padding: EdgeInsets.only(left: 10.px2Dp, right: 10.px2Dp),
                  child: Text(
                    state.repoDetailsBean.currentBranch,
                    style: AppTvStyles.textStyle12ColorMain(),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: _buildListView(state, dispatch, viewService),
                ),
              ],
            ),
          ),
  );
}

_fetch(RepoDetailsState state, Dispatch dispatch) {
  //展示刷新页面，并拉取最新代码
  dispatch(RepoDetailsActionCreator.showLoading());
  dispatch(RepoDetailsActionCreator.fetch());
}

_pull(RepoDetailsState state, Dispatch dispatch) {
  if (state.repoDetailsBean.currentBranch.startsWith(_LOCAL_TAG_PREFIX)) {
    TransBridgeChannel.showToast(StrsRepoDetails.tagBranchCannotUpdate());
    return;
  }
  //展示刷新页面，并拉取最新代码
  dispatch(RepoDetailsActionCreator.showLoading());
  dispatch(RepoDetailsActionCreator.pull());
}

_showSwitchOption(
    RepoDetailsState state, Dispatch dispatch, ViewService viewService) {
  BuildContext context = viewService.context;
  showDialog(
      context: context,
      builder: (_) {
        return Center(
          child: Container(
            width: double.infinity,
            decoration: CommonDecoration.commonRoundDecoration(),
            margin: EdgeInsets.all(20.px2Dp),
            padding: EdgeInsets.all(20.px2Dp),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  alignment: Alignment(-1, 0),
                  child: Text(
                    StrsRepoDetails.switchHint(),
                    style: AppTvStyles.textStyle16ColorMain(),
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(
                  height: 40.px2Dp,
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: RaisedButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                          _showBranchOrTagDialog(
                              state, dispatch, viewService, _LOCAL_BRANCH_TYPE);
                        },
                        child: Text(StrsRepoDetails.fromLocalBranch()),
                      ),
                    ),
                    SizedBox(
                      width: 12.px2Dp,
                    ),
                    Expanded(
                      flex: 1,
                      child: RaisedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          _showBranchOrTagDialog(state, dispatch, viewService,
                              _REMOTE_BRANCH_TYPE);
                        },
                        child: Text(StrsRepoDetails.fromRemoteBranch()),
                      ),
                    ),
                    SizedBox(
                      width: 12.px2Dp,
                    ),
                    Expanded(
                      flex: 1,
                      child: RaisedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          _showBranchOrTagDialog(
                              state, dispatch, viewService, _TAG_BRANCH_TYPE);
                        },
                        child: Text(StrsRepoDetails.fromRemoteTag()),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      });
}

///显示分支或者 tag 的 dialog
/// [type]:0 本地分支, 1 远程分支, 3 tag
_showBranchOrTagDialog(RepoDetailsState state, Dispatch dispatch,
    ViewService viewService, int type) {
  showDialog(
      context: viewService.context,
      builder: (_) {
        return Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                  minHeight: SizeUtil.deviceHeight * 0.1,
                  maxHeight: SizeUtil.deviceHeight * 0.7),
              width: double.infinity,
              margin: EdgeInsets.only(left: 30.px2Dp, right: 30.px2Dp),
              padding: EdgeInsets.all(20.px2Dp),
              decoration: CommonDecoration.commonRoundDecoration(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _buildBranchList(
                    state,
                    type != _TAG_BRANCH_TYPE
                        ? state.repoDetailsBean.allBranch
                        : state.repoDetailsBean.allTag ?? [],
                    type,
                    dispatch,
                    viewService),
              ),
            ),
          ),
        );
      });
}

const _LOCAL_BRANCH_PREFIX = "refs/heads/fromBranch/";
const _LOCAL_TAG_PREFIX = "refs/heads/fromTag/";
const _REMOTE_BRANCH_PREFIX = "refs/remotes/";
const _REMOTE_TAG_PREFIX = "refs/tags/";

const _LOCAL_BRANCH_TYPE = 0;
const _REMOTE_BRANCH_TYPE = 1;
const _TAG_BRANCH_TYPE = 2;

/// 仓库列表:[refs/heads/fromBranch/master, refs/remotes/origin/master, refs/remotes/origin/study]
/// 本地 以 refs/heads/fromBranch/ 开头,远程必定以 refs/remotes/ 开头
/// [refs/tags/test] 远程分支以 refs/tags/ 开头,本编辑器不带编辑功能,所以无需考虑本地分支的问题
/// [type]:0 本地分支, 1 远程分支, 3 tag
_buildBranchList(RepoDetailsState state, List<String> listStr, int type,
    Dispatch dispatch, ViewService viewService) {
  List<Widget> list = [];
  println(listStr);
  listStr.forEach((final name) {
    bool addFlag = false;
    println(name);
    if (type == _LOCAL_BRANCH_TYPE &&
        (name.startsWith(_LOCAL_BRANCH_PREFIX) ||
            name.startsWith(_LOCAL_TAG_PREFIX))) {
      addFlag = true;
    } else if (type == _REMOTE_BRANCH_TYPE &&
        name.startsWith(_REMOTE_BRANCH_PREFIX)) {
      addFlag = true;
    } else if (type == _TAG_BRANCH_TYPE) {
      addFlag = true;
    }
    println(state.repoDetailsBean.currentBranch);
    if (addFlag) {
      if (name == state.repoDetailsBean.currentBranch) {
        list.add(Container(
          width: double.infinity,
          padding: EdgeInsets.all(10.px2Dp),
          child: RaisedButton(
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.only(left: 36.px2Dp),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.star,
                    color: Colors.redAccent,
                    size: 30.px2Dp,
                  ),
                  SizedBox(
                    width: 6.px2Dp,
                  ),
                  Expanded(
                    child: Text(
                      name,
                      style: AppTvStyles.textStyle14Color63(),
                    ),
                  )
                ],
              ),
            ),
            onPressed: () {
              Navigator.pop(viewService.context);
              if (type != _TAG_BRANCH_TYPE) {
                _switchBranch(dispatch, state, name, type);
              }
            },
          ),
        ));
      } else {
        list.add(Container(
          width: double.infinity,
          padding: EdgeInsets.all(10.px2Dp),
          child: RaisedButton(
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.only(left: 36.px2Dp),
              child: Text(
                name,
                style: AppTvStyles.textStyle14Color63(),
              ),
            ),
            onPressed: () {
              Navigator.pop(viewService.context);
              _switchBranch(dispatch, state, name, type);
            },
          ),
        ));
      }

      list.add(Container(
        width: double.infinity,
        height: 2.px2Dp,
        color: AppColors.COLOR_6E,
      ));
    }
  });
  return list;
}

///提取 remote 分支的 short name
var _remoteBranchRegExp = RegExp("^refs/remotes/.*?/(.*?)\$");
var _localBranchRegExp = RegExp("^refs/heads/fromBranch/(.*?)\$");
var _localTagRegExp = RegExp("^refs/heads/fromTag/(.*?)\$");
var _remoteTagRegExp = RegExp("^refs/tags/(.*?)\$");

///切换分支
_switchBranch(Dispatch dispatch, RepoDetailsState state, String selectedBranch,
    int type) {
  dispatch(RepoDetailsActionCreator.showLoading());
  bool isExistedLocal = false;
  String existedLocalBranch;
  if (type == _REMOTE_BRANCH_TYPE) {
    //选择 remote 分支,判断该分支在本地 tracked 的分支
    RegExpMatch remoteMatch = _remoteBranchRegExp.firstMatch(selectedBranch);
    if (remoteMatch != null && remoteMatch.groupCount > 0) {
      final String shortName = remoteMatch.group(1);
      state.repoDetailsBean.allBranch.forEach((branchName) {
        if (branchName.startsWith(_LOCAL_BRANCH_PREFIX)) {
          var localMatch = _localBranchRegExp.firstMatch(branchName);
          if (localMatch != null &&
              localMatch.groupCount > 0 &&
              shortName == localMatch.group(1)) {
            existedLocalBranch = branchName;
            TransBridgeChannel.showToast(StrsRepoDetails.existedRemoteBranch());
            isExistedLocal = true;
            return;
          }
        }
      });
    }
  } else if (type == _TAG_BRANCH_TYPE) {
    //tag ,判断本地是否有该 tag 检出的分支
    //选择 remote 分支,判断该分支在本地 tracked 的分支
    RegExpMatch remoteMatch = _remoteTagRegExp.firstMatch(selectedBranch);
    if (remoteMatch != null && remoteMatch.groupCount > 0) {
      final String shortName = remoteMatch.group(1);
      state.repoDetailsBean.allBranch.forEach((branchName) {
        if (branchName.startsWith(_LOCAL_TAG_PREFIX)) {
          var localMatch = _localTagRegExp.firstMatch(branchName);
          if (localMatch != null &&
              localMatch.groupCount > 0 &&
              shortName == localMatch.group(1)) {
            existedLocalBranch = branchName;
            TransBridgeChannel.showToast(StrsRepoDetails.existedRemoteBranch());
            isExistedLocal = true;
            return;
          }
        }
      });
    }
  }
  if (isExistedLocal) {
    println("isExistedLocal = $isExistedLocal");
    println("existedLocalBranch = $existedLocalBranch");
    //切换分支
    dispatch(RepoDetailsActionCreator.switchExistedBranch(existedLocalBranch));
    return;
  }
  if (type == _LOCAL_BRANCH_TYPE) {
    //切换到已存在的本地分支
    dispatch(RepoDetailsActionCreator.switchExistedBranch(selectedBranch));
  } else if (type == _REMOTE_BRANCH_TYPE) {
    //检出新的远程分支
    dispatch(RepoDetailsActionCreator.switchNewBranch(selectedBranch));
  } else {
    // 检出远程 tag
    dispatch(RepoDetailsActionCreator.checkoutTag(selectedBranch));
  }
}

///构建 文件列表
_buildListView(
    RepoDetailsState state, Dispatch dispatch, ViewService viewService) {
  return ListView.separated(
      key: Key("${state.brightnessMode}"),
      itemBuilder: (context, index) {
        return RepoFileHelper.buildInfoItem(
            state.currentFileList[index],
            state.repoDetailsBean,
            dispatch,
            viewService,
            context,
            index,
            _onPress);
      },
      separatorBuilder: (context, index) => Container(
            width: SizeUtil.deviceWidth,
            height: 1.px2Dp,
            color: AppColors.COLOR_6E,
          ),
      itemCount: state?.currentFileList?.length ?? 0);
}

///文件列表点击事件
_onPress(FileInfo info, RepoDetailsBean repo, Dispatch dispatch,
    ViewService viewService, BuildContext context, int index) {
  if (info.isDir) {
    dispatch(RepoDetailsActionCreator.nextPage(info.childList));
  } else {
    String fileType = FileTypeHelper.getBizType(info.absoultPath);
    //打开文件
    dispatch(RepoDetailsActionCreator.openFile(info.absoultPath, repo.gitUri,
        repo.currentBranch, repo.targetDir, fileType));
  }
}
