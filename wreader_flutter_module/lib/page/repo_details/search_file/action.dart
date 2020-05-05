import 'package:fish_redux/fish_redux.dart';
import 'package:wreader_flutter_module/bean/file_info.dart';

enum SearchRepoFileAction {
  search,
  searchFinish,

  ///打开文件
  openFile,
}

class SearchRepoFileActionCreator {
  static Action search(String key, int taskIndex) {
    return Action(SearchRepoFileAction.search,
        payload: {'key': key, 'taskIndex': taskIndex});
  }

  static Action searchFinish(List<FileInfo> fileInfoList, int taskIndex) {
    return Action(SearchRepoFileAction.searchFinish,
        payload: {'fileInfoList': fileInfoList, 'taskIndex': taskIndex});
  }

  ///打开文件
  static Action openFile(String fileAbsolutePath, String gitUri,
      String currentBranch, String gitTargetDir, String bizFileType) {
    return Action(SearchRepoFileAction.openFile, payload: {
      'fileAbsolutePath': fileAbsolutePath,
      'gitUri': gitUri,
      'currentBranch': currentBranch,
      'gitTargetDir': gitTargetDir,
      'bizFileType': bizFileType,
    });
  }
}
