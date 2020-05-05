import 'dart:async';

import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:wreader_flutter_module/bean/file_info.dart';
import 'package:wreader_flutter_module/db/sqlite_helper.dart';
import 'package:wreader_flutter_module/routers/fluro_routers.dart';
import 'package:wreader_flutter_module/utils/channel/trans_bridge_channel.dart';
import 'package:wreader_flutter_module/utils/common/file_helper.dart';
import 'package:wreader_flutter_module/utils/common/file_type_helper.dart';
import 'package:wreader_flutter_module/utils/common/json_util.dart';
import 'package:wreader_flutter_module/utils/reading/reading.dart';
import 'package:wreader_flutter_module/utils/size/size_util.dart';
import 'package:wreader_flutter_module/values/app_strings.dart';
import 'package:wreader_flutter_module/widget/common_decoration.dart';
import 'package:wreader_flutter_module/widget/common_styles.dart';
import 'package:wreader_flutter_module/widget/environment_con_helper.dart';

import 'action.dart';
import 'state.dart';

Effect<RepoDetailsState> buildEffect() {
  return combineEffects(<Object, Effect<RepoDetailsState>>{
    Lifecycle.initState: _loadRepoDetails,
    RepoDetailsAction.switchNewBranch: _switchNewBranch,
    RepoDetailsAction.switchExistedBranch: _switchExistedBranch,
    RepoDetailsAction.pull: _pull,
    RepoDetailsAction.reset: _reset,
    RepoDetailsAction.fetch: _fetch,
    RepoDetailsAction.openFile: _openFile,
    RepoDetailsAction.checkoutTag: _checkoutTag,
    Lifecycle.didChangeAppLifecycleState: _didChangeAppLifecycleState
  });
}

_checkoutTag(Action action, Context<RepoDetailsState> ctx) async {
  var map = ctx.state.repoDetailsBean.toJson();
  map['fileInfo'] = null;
  var result = await TransBridgeChannel.checkoutTag(action.payload, map);
  Map<String, dynamic> resultMap = JsonUtil.decode(result);
  bool updateResult = await WReaderSqlHelper.updateRepoConfTable(
      ctx.state.repoDetailsBean.id, <String, dynamic>{
    RepoConfConst.CURRENT_BRANCH: resultMap['currentBranchShortName'],
  });
  if ('success' == resultMap['result'] && updateResult) {
    TransBridgeChannel.showToast(StrsToast.switchSuccessAndReload());
    //切换分支成功
    FluroRouter.navigateTo(
        ctx.context,
        "${RouteNames.REPO_DETAILS}?"
        "gitLocalDir=${Uri.encodeComponent("${ctx.state.repoDetailsBean.fullDir}")}"
        "&gitUri=${Uri.encodeComponent("${ctx.state.repoDetailsBean.gitUri}")}",
        replace: true);
  } else {
    //回滚分支
    TransBridgeChannel.showToast(StrsToast.operationFail());
    //切换分支成功
    FluroRouter.navigateTo(
        ctx.context,
        "${RouteNames.REPO_DETAILS}?"
        "gitLocalDir=${Uri.encodeComponent("${ctx.state.repoDetailsBean.fullDir}")}"
        "&gitUri=${Uri.encodeComponent("${ctx.state.repoDetailsBean.gitUri}")}",
        replace: true);
  }
}

_didChangeAppLifecycleState(
    Action action, Context<RepoDetailsState> ctx) async {
  if (AppLifecycleState.resumed == action.payload) {
    bool isChange = await EnvironmentConfHelper.checkBrightness();
    println("_didChangeAppLifecycleState:$isChange");
    if (isChange) {
      ctx.dispatch(RepoDetailsActionCreator.changeMode());
    }
  }
}

/// {
///     'fileAbsolutePath': fileAbsolutePath,
///     'gitUri': gitUri,
///     'currentBranch': currentBranch,
///     'gitTargetDir': gitTargetDir,
///     'bizFileType': bizFileType,
///   }
_openFile(Action action, Context<RepoDetailsState> ctx) async {
  Map<String, dynamic> payload = action.payload;
  println(payload);
  showLoadingAndRead(
      ctx.context,
      payload['fileAbsolutePath'],
      payload['gitUri'],
      payload['currentBranch'],
      payload['gitTargetDir'],
      payload['bizFileType']);
}

_fetch(Action action, Context<RepoDetailsState> ctx) async {
  var map = ctx.state.repoDetailsBean.toJson();
  map['fileInfo'] = null;
  var result = await TransBridgeChannel.fetch(map);
  println("result = $result");
  Map<String, dynamic> resultMap = JsonUtil.decode(result);
  if ('success' == resultMap['result']) {
    TransBridgeChannel.showToast(StrsToast.successOperationAndReload(), 1);
  } else {
    TransBridgeChannel.showToast(
        "${StrsToast.operationFail()}：${resultMap['reason']}\n${StrsToast.reloadPage()}",
        1);
  }
  FluroRouter.navigateTo(
      ctx.context,
      "${RouteNames.REPO_DETAILS}?"
      "gitLocalDir=${Uri.encodeComponent("${ctx.state.repoDetailsBean.fullDir}")}"
      "&gitUri=${Uri.encodeComponent("${ctx.state.repoDetailsBean.gitUri}")}",
      replace: true);
}

_reset(Action action, Context<RepoDetailsState> ctx) async {
  var map = ctx.state.repoDetailsBean.toJson();
  map['fileInfo'] = null;
  var result = await TransBridgeChannel.reset(action.payload, map);
  println("result = $result");
  Map<String, dynamic> resultMap = JsonUtil.decode(result);
  if ('success' == resultMap['result']) {
    TransBridgeChannel.showToast(StrsToast.successOperationAndReload(), 1);
  } else {
    TransBridgeChannel.showToast(
        "${StrsToast.operationFail()}：${resultMap['reason']}\n${StrsToast.reloadPage()}",
        1);
  }
  //Cancel operation，重新加载当前页面
  FluroRouter.navigateTo(
      ctx.context,
      "${RouteNames.REPO_DETAILS}?"
      "gitLocalDir=${Uri.encodeComponent("${ctx.state.repoDetailsBean.fullDir}")}"
      "&gitUri=${Uri.encodeComponent("${ctx.state.repoDetailsBean.gitUri}")}",
      replace: true);
}

_showNotCleanHint(Action action, Context<RepoDetailsState> ctx,
    Map<String, dynamic> resultMap) {
  showDialog(
      context: ctx.context,
      builder: (context) {
        return WillPopScope(
          child: Center(
            child: Container(
              margin: EdgeInsets.only(left: 30.px2Dp, right: 30.px2Dp),
              padding: EdgeInsets.all(20.px2Dp),
              decoration: CommonDecoration.commonRoundDecoration(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    resultMap['additionalInfo'] ?? 'repo not clean!',
                    maxLines: 6,
                    style:
                        AppTvStyles.buildTextStyle(Colors.redAccent, 18, true),
                  ),
                  SizedBox(
                    width: 10.px2Dp,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: RaisedButton(
                          child: Text('Cancel!'),
                          onPressed: () {
                            Navigator.of(context).pop(0);
                          },
                        ),
                      ),
                      SizedBox(
                        width: 20.px2Dp,
                      ),
                      Expanded(
                        flex: 1,
                        child: RaisedButton(
                          child: Text('Reset!'),
                          onPressed: () {
                            Navigator.of(context).pop(1);
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          onWillPop: () {
            return Future.value(false);
          },
        );
      }).then((index) {
    println(index);
    if (1 == index) {
      //Reset
      TransBridgeChannel.showToast(StrsToast.tryToResetRepo());
      ctx.dispatch(RepoDetailsActionCreator.reset(
          ctx.state.repoDetailsBean.allBranch.first));
    } else {
      //Cancel operation，重新加载当前页面
      FluroRouter.navigateTo(
          ctx.context,
          "${RouteNames.REPO_DETAILS}?"
          "gitLocalDir=${Uri.encodeComponent("${ctx.state.repoDetailsBean.fullDir}")}"
          "&gitUri=${Uri.encodeComponent("${ctx.state.repoDetailsBean.gitUri}")}",
          replace: true);
    }
  });
}

///pull代码
_pull(Action action, Context<RepoDetailsState> ctx) async {
  var map = ctx.state.repoDetailsBean.toJson();
  map['fileInfo'] = null;
  var result = await TransBridgeChannel.pull(map);
  println('result = $result');
  Map<String, dynamic> resultMap = JsonUtil.decode(result);
  if (1 == resultMap['isClean']) {
    _showNotCleanHint(action, ctx, resultMap);
    return Future.value(null);
  }
  println('resultMap = $resultMap');
  if ('success' == resultMap['result']) {
    TransBridgeChannel.showToast(StrsToast.pullSuccessAndReload());
  } else {
    TransBridgeChannel.showToast(
        "${StrsToast.pullFail()}:${resultMap['reason']}");
  }
  //切换分支成功
  FluroRouter.navigateTo(
      ctx.context,
      "${RouteNames.REPO_DETAILS}?"
      "gitLocalDir=${Uri.encodeComponent("${ctx.state.repoDetailsBean.fullDir}")}"
      "&gitUri=${Uri.encodeComponent("${ctx.state.repoDetailsBean.gitUri}")}",
      replace: true);
}

_switchExistedBranch(Action action, Context<RepoDetailsState> ctx) async {
  var map = ctx.state.repoDetailsBean.toJson();
  map['fileInfo'] = null;
  var result =
      await TransBridgeChannel.switchExistedBranch(action.payload, map);
  Map<String, dynamic> resultMap = JsonUtil.decode(result);
  if (1 == resultMap['isClean']) {
    _showNotCleanHint(action, ctx, resultMap);
    return Future.value(null);
  }
  if ('success' == resultMap['result'] &&
      await WReaderSqlHelper.updateRepoConfTable(
          ctx.state.repoDetailsBean.id, <String, dynamic>{
        RepoConfConst.CURRENT_BRANCH: resultMap['currentBranchShortName'],
      })) {
    TransBridgeChannel.showToast(StrsToast.switchSuccessAndReload());
    //切换分支成功
    FluroRouter.navigateTo(
        ctx.context,
        "${RouteNames.REPO_DETAILS}?"
        "gitLocalDir=${Uri.encodeComponent("${ctx.state.repoDetailsBean.fullDir}")}"
        "&gitUri=${Uri.encodeComponent("${ctx.state.repoDetailsBean.gitUri}")}",
        replace: true);
  } else {
    //回滚分支
    TransBridgeChannel.showToast(StrsToast.operationFail());
    //切换分支成功
    FluroRouter.navigateTo(
        ctx.context,
        "${RouteNames.REPO_DETAILS}?"
        "gitLocalDir=${Uri.encodeComponent("${ctx.state.repoDetailsBean.fullDir}")}"
        "&gitUri=${Uri.encodeComponent("${ctx.state.repoDetailsBean.gitUri}")}",
        replace: true);
  }
}

///切换分支,本操作是切换branch
_switchNewBranch(Action action, Context<RepoDetailsState> ctx) async {
  var map = ctx.state.repoDetailsBean.toJson();
  map['fileInfo'] = null;
  var result = await TransBridgeChannel.switchNewBranch(action.payload, map);
  println("_switchBranch->result = $result");
  Map<String, dynamic> resultMap = JsonUtil.decode(result);
  println("result = ${resultMap['currentBranchShortName']}");
  if (1 == resultMap['isClean']) {
    _showNotCleanHint(action, ctx, resultMap);
    return Future.value(null);
  }
  if ('success' == resultMap['result'] &&
      await WReaderSqlHelper.updateRepoConfTable(
          ctx.state.repoDetailsBean.id, <String, dynamic>{
        RepoConfConst.CURRENT_BRANCH: resultMap['currentBranchShortName'],
      })) {
    TransBridgeChannel.showToast(StrsToast.switchSuccessAndReload());
    //切换分支成功
    FluroRouter.navigateTo(
        ctx.context,
        "${RouteNames.REPO_DETAILS}?"
        "gitLocalDir=${Uri.encodeComponent("${ctx.state.repoDetailsBean.fullDir}")}"
        "&gitUri=${Uri.encodeComponent("${ctx.state.repoDetailsBean.gitUri}")}",
        replace: true);
  } else {
    //回滚分支
    TransBridgeChannel.showToast(StrsToast.operationFail());
    //切换分支成功
    FluroRouter.navigateTo(
        ctx.context,
        "${RouteNames.REPO_DETAILS}?"
        "gitLocalDir=${Uri.encodeComponent("${ctx.state.repoDetailsBean.fullDir}")}"
        "&gitUri=${Uri.encodeComponent("${ctx.state.repoDetailsBean.gitUri}")}",
        replace: true);
  }
}

///载入仓库信息实际工作函数
_loadRepoDetailsWorker(Action action, Context<RepoDetailsState> ctx) async {
  FileInfo rootInfo;
  var repoPath = ctx.state.repoDetailsBean.fullDir;
  rootInfo = await compute(
      _loadFileInfo, <String, dynamic>{'dirAbsoultPath': repoPath});
  await _sortFileInfo(rootInfo);
  var branchMap = JsonUtil.decode(
      await TransBridgeChannel.getAllBranch(ctx.state.repoDetailsBean.fullDir));
  var tagMap = JsonUtil.decode(
      await TransBridgeChannel.getTagList(ctx.state.repoDetailsBean.fullDir));
  println("tagMap :\n$tagMap");
  println("tagMap :\n${tagMap.runtimeType}");
  var repoInfo =
      await WReaderSqlHelper.queryRepoInfo(ctx.state.repoDetailsBean.gitUri);
  if ('success' == branchMap['result']) {
    ctx.dispatch(RepoDetailsActionCreator.initFileListSuccess({
      'fileInfo': rootInfo,
      'repoInfo': repoInfo,
      'allBranch': branchMap['allBranch'],
      'allTagList': tagMap['allTagList'],
    }));
  } else {
    ctx.dispatch(RepoDetailsActionCreator.initFileListSuccess(
        {'fileInfo': rootInfo, 'repoInfo': repoInfo, 'allBranch': null}));
  }
}

///载入仓库信息
_loadRepoDetails(Action action, Context<RepoDetailsState> ctx) {
  println('Effect._loadRepoDetails');
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadRepoDetailsWorker(action, ctx);
  });
}

FutureOr<FileInfo> _loadFileInfo(dynamic map) async {
  return await FileHelper.loadFileInfos(
      map['dirAbsoultPath'],
      map['ignoreHideItem'] ?? true,
      map['isHideItemFun'] ?? defaultIsHideItemFun);
}

///排序，文件夹在前面，文件在后面，
///文件类型的，markdown在前面，其余根据时间排序
Future<void> _sortFileInfo(FileInfo info) async {
  if (info.isDir && info.childList?.isNotEmpty == true) {
    info.childList.sort((arg1, arg2) {
      if (arg1.isDir && arg2.isDir) {
        //都是文件夹，根据时间排序
        return arg1.modifiedDateTime.compareTo(arg2.modifiedDateTime);
      } else if (!arg1.isDir && !arg2.isDir) {
        if (FileTypeHelper.isMarkdown(arg1.fileType) &&
            FileTypeHelper.isMarkdown(arg2.fileType)) {
          return arg1.modifiedDateTime.compareTo(arg2.modifiedDateTime);
        } else if (!FileTypeHelper.isMarkdown(arg1.fileType) &&
            FileTypeHelper.isMarkdown(arg2.fileType)) {
          return 1;
        } else if (!FileTypeHelper.isMarkdown(arg2.fileType) &&
            FileTypeHelper.isMarkdown(arg1.fileType)) {
          return -1;
        } else {
          //都是文件，根据时间排序
          return arg1.modifiedDateTime.compareTo(arg2.modifiedDateTime);
        }
      } else if (arg1.isDir && !arg2.isDir) {
        //arg1是文件夹，arg2是文件，arg1在前
        return 1;
      } else if (!arg1.isDir && arg2.isDir) {
        //arg2是文件夹，arg1是文件，arg2在前
        return -1;
      } else {
        return arg1.modifiedDateTime.compareTo(arg2.modifiedDateTime);
      }
    });
    //递归排序所有元素
    for (var c in info.childList) {
      if (c.isDir) {
        await _sortFileInfo(c);
      }
    }
  }
  return Future.value(null);
}
