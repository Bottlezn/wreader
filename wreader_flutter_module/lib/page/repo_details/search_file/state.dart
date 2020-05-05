import 'package:flutter/material.dart';
import 'package:wreader_flutter_module/bean/file_info.dart';
import 'package:wreader_flutter_module/bean/repo_details_bean.dart';
import 'package:wreader_flutter_module/global_store/global_base_state.dart';
import 'package:wreader_flutter_module/page/repo_details/state.dart';

class SearchRepoFileState extends GlobalState {
  RepoDetailsBean repoDetailsBean;

  ///任务顺序,用于放弃掉一些之前触发的搜索.每次搜索都会自增 1 ,如果返回值不是当前的值清空数据
  int taskIndex = 0;
  TextEditingController searchController;
  FocusNode searchFocusNode;
  List<FileInfo> fileInfoList = [];

  @override
  SearchRepoFileState clone() {
    return SearchRepoFileState()
      ..repoDetailsBean = this.repoDetailsBean
      ..taskIndex = this.taskIndex
      ..searchController = this.searchController
      ..fileInfoList = this.fileInfoList
      ..brightnessMode = this.brightnessMode
      ..languageCode = this.languageCode
      ..action = this.action
      ..searchFocusNode = this.searchFocusNode;
  }
}

SearchRepoFileState initState(Map<String, dynamic> args) {
  return SearchRepoFileState()
    ..repoDetailsBean = RepoDetailsState.globalRepoDetailsBean
    ..searchController = TextEditingController()
    ..searchFocusNode = FocusNode();
}
