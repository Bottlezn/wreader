import 'package:fish_redux/fish_redux.dart';
import 'package:wreader_flutter_module/bean/file_info.dart';

enum RepoDetailsAction {
  ///初始化给提供仓库的文件列表成功
  initFileListSuccess,

  ///初始化给提供仓库的文件列表失败
  initFileListFail,

  ///展示刷新页面
  showLoading,

  ///切换到新分支
  switchNewBranch,

  ///切换到已有分支
  switchExistedBranch,

  ///检出 tag
  checkoutTag,

  ///下一页
  nextPage,

  ///上一页
  forwardPage,

  ///pull代码
  pull,

  ///仓库文件被修改，提示用户回滚当前分支或者不做出任何改变
  notClean,

  ///回滚当前分支
  reset,

  ///fetch操作
  fetch,

  ///打开文件
  openFile,

  ///亮暗模式被修改
  changeMode,
}

class RepoDetailsActionCreator {
  static Action changeMode() {
    return Action(RepoDetailsAction.changeMode);
  }

  static Action fetch() {
    return Action(RepoDetailsAction.fetch);
  }

  static Action reset(String branch) {
    return Action(RepoDetailsAction.reset, payload: branch);
  }

  static Action notClean(Map<String, dynamic> result) {
    return Action(RepoDetailsAction.notClean);
  }

  static Action pull() {
    return Action(RepoDetailsAction.pull);
  }

  static Action switchNewBranch(String branch) {
    return Action(RepoDetailsAction.switchNewBranch, payload: branch);
  }

  static Action switchExistedBranch(String branch) {
    return Action(RepoDetailsAction.switchExistedBranch, payload: branch);
  }

  static Action checkoutTag(String tag) {
    return Action(RepoDetailsAction.checkoutTag, payload: tag);
  }

  static Action forwardPage() {
    return Action(RepoDetailsAction.forwardPage);
  }

  static Action nextPage(List<FileInfo> children) {
    return Action(RepoDetailsAction.nextPage, payload: children);
  }

  static Action showLoading() {
    return Action(RepoDetailsAction.showLoading);
  }

  static Action initFileListSuccess(Map<String, dynamic> repoDetails) {
    return Action(RepoDetailsAction.initFileListSuccess, payload: repoDetails);
  }

  static Action initFileListFail() {
    return const Action(RepoDetailsAction.initFileListFail);
  }

  ///打开文件
  static Action openFile(String fileAbsolutePath, String gitUri,
      String currentBranch, String gitTargetDir, String bizFileType) {
    return Action(RepoDetailsAction.openFile, payload: {
      'fileAbsolutePath': fileAbsolutePath,
      'gitUri': gitUri,
      'currentBranch': currentBranch,
      'gitTargetDir': gitTargetDir,
      'bizFileType': bizFileType,
    });
  }
}
