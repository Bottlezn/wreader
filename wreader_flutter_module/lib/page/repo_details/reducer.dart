import 'package:fish_redux/fish_redux.dart';
import 'package:wreader_flutter_module/db/sqlite_helper.dart';

import 'action.dart';
import 'state.dart';

Reducer<RepoDetailsState> buildReducer() {
  return asReducer(
    <Object, Reducer<RepoDetailsState>>{
      RepoDetailsAction.initFileListSuccess: _initFileListSuccess,
      RepoDetailsAction.initFileListFail: _onAction,
      RepoDetailsAction.showLoading: _switchBranch,
      RepoDetailsAction.nextPage: _nextPage,
      RepoDetailsAction.forwardPage: _forwardPage,
      RepoDetailsAction.notClean: _notClean,
    },
  );
}

///仓库文件被修改，提示用户回滚当前分支或者不做出任何改变
RepoDetailsState _notClean(RepoDetailsState state, Action action) {
  final RepoDetailsState newState = state.clone();
  return newState;
}

RepoDetailsState _nextPage(RepoDetailsState state, Action action) {
  final RepoDetailsState newState = state.clone();
  newState.forwardList = newState.currentFileList;
  newState.currentFileList = action.payload;
  return newState;
}

RepoDetailsState _forwardPage(RepoDetailsState state, Action action) {
  final RepoDetailsState newState = state.clone();
  var forwardTmp = newState.forwardList;
  newState.currentFileList = forwardTmp;
  newState.forwardList = forwardTmp.first.preList;
  return newState;
}

RepoDetailsState _switchBranch(RepoDetailsState state, Action action) {
  final RepoDetailsState newState = state.clone();
  newState.loadingFinish = false;
  return newState;
}

///初始化文件列表成功
RepoDetailsState _initFileListSuccess(RepoDetailsState state, Action action) {
  println('Reducer._initFileListSuccess');
  final RepoDetailsState newState = state.clone();
  newState.loadingFinish = true;
  Map<String, dynamic> payload = action.payload;
  Map<String, dynamic> repoInfo = payload['repoInfo'];
  List<dynamic> tmpTags = payload['allTagList'];
  println(payload);
  List<String> allTags = [];
  if (tmpTags != null && tmpTags.isNotEmpty) {
    tmpTags.forEach((tag) {
      allTags.add("$tag");
    });
  }
  newState.repoDetailsBean.fileInfo = payload['fileInfo'];
  println(payload['allBranch']);
  println(allTags);
  List<dynamic> allBranchPayload = payload['allBranch'];
  newState.repoDetailsBean.allBranch = List<String>();
  for (var branch in allBranchPayload) {
    newState.repoDetailsBean.allBranch.add(branch.toString());
  }
//  _handleAllBranchInfo(newState.repoDetailsBean.allBranch,
//      repoInfo[RepoConfConst.CURRENT_BRANCH]);
  newState.repoDetailsBean.id = repoInfo[RepoConfConst.ID];
  newState.repoDetailsBean.currentBranch =
      repoInfo[RepoConfConst.CURRENT_BRANCH];
  newState.repoDetailsBean.authenticationInfo =
      repoInfo[RepoConfConst.AUTHENTICATION_INFO];
  newState.repoDetailsBean.authenticationWay =
      repoInfo[RepoConfConst.AUTHENTICATION_WAY];
  newState.repoDetailsBean.id = repoInfo[RepoConfConst.ID];
  newState.repoDetailsBean.allTag = allTags;
  newState.currentFileList = payload['fileInfo'].childList;
  RepoDetailsState.globalRepoDetailsBean = newState.repoDetailsBean;
  return newState;
}

/// 加入 checkout tag 功能,该方法废弃
///处理所有branch，因为不支持本地编辑，也就没有本地新增分支等功能，故分支显示要特殊处理下
///heading与remotes的同名分支合并为一个
///[refs/heads/master, refs/remotes/origin/master, refs/remotes/origin/study]
_handleAllBranchInfo(List<String> allBranch, String currentBranch) {
  var fullCurrentBranchName = "refs/heads/$currentBranch";
  println("fullCurrentBranchName = $fullCurrentBranchName");
  var currentBranchIndex = allBranch.indexOf(fullCurrentBranchName);
  allBranch.removeAt(currentBranchIndex);
  allBranch.insert(0, fullCurrentBranchName);
  //所有本地项目，以fullBranchName为key，branchShortName为value
  Map<String, String> allLocalBranch = Map<String, String>();
  //需要allBranch删除的项目
  List<String> removeRemoteStrs = List<String>();
  int index = 0;
  for (var branch in allBranch) {
    //以refs/heads/开头，认为是本地项目,
    //本地项目优先排布在集合前边，有一个不是本地项目就break
    if (branch.startsWith('refs/heads/')) {
      allLocalBranch[branch] = branch.substring(11, branch.length);
      removeRemoteStrs.add(branch);
    } else {
      break;
    }
    index++;
  }
  final int maxIndex = index - 1;
  index = 0;
  int size = allBranch.length;
  List<String> newAllBranch = List<String>();
  allLocalBranch.forEach((key, value) {
    var exp = RegExp("refs/remotes/.+?/$value");
    for (var i = maxIndex; i < size; i++) {
      if (exp.hasMatch(allBranch[i])) {
        newAllBranch.add("$key\n${allBranch[i]}");
        removeRemoteStrs.add(allBranch[i]);
        break;
      }
    }
  });
  removeRemoteStrs.forEach((removeRemoteBranch) {
    allBranch.remove(removeRemoteBranch);
  });
  allBranch.insertAll(0, newAllBranch);
}

RepoDetailsState _onAction(RepoDetailsState state, Action action) {
  final RepoDetailsState newState = state.clone();
  return newState;
}
