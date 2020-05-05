import 'package:wreader_flutter_module/bean/file_info.dart';
import 'package:wreader_flutter_module/bean/repo_details_bean.dart';
import 'package:wreader_flutter_module/global_store/global_base_state.dart';

class RepoDetailsState extends GlobalState {
  bool loadingFinish = false;
  RepoDetailsBean repoDetailsBean;

  /// 因为 FluroRoute 只支持 url queryParam 的形式传递传递参数,搞个全局变量吧.
  static RepoDetailsBean globalRepoDetailsBean;
  List<FileInfo> forwardList;
  List<FileInfo> currentFileList;
  int isClean = 0;
  String notCleanReason;

  @override
  RepoDetailsState clone() {
    return RepoDetailsState()
      ..repoDetailsBean = repoDetailsBean
      ..loadingFinish = loadingFinish
      ..forwardList = forwardList
      ..currentFileList = currentFileList
      ..isClean = isClean
      ..brightnessMode = brightnessMode
      ..languageCode = languageCode
      ..action = action
      ..notCleanReason = notCleanReason;
  }
}

RepoDetailsState initState(Map<String, dynamic> args) {
  RepoDetailsBean repoDetailsBean = RepoDetailsBean();
  repoDetailsBean.gitUri = args['gitUri'];
  String localDir = args['gitLocalDir'];
  repoDetailsBean.rootDir = localDir.substring(0, localDir.lastIndexOf('/'));
  repoDetailsBean.targetDir =
      localDir.substring(localDir.lastIndexOf('/') + 1, localDir.length);
  repoDetailsBean.gitUri = args['gitUri'];
  repoDetailsBean.fullDir = localDir;
  return RepoDetailsState()..repoDetailsBean = repoDetailsBean;
}
