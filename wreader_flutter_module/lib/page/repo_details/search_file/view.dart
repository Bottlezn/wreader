import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:wreader_flutter_module/bean/file_info.dart';
import 'package:wreader_flutter_module/bean/repo_details_bean.dart';
import 'package:wreader_flutter_module/page/main/state.dart';
import 'package:wreader_flutter_module/page/repo_details/helper/repo_file_helper.dart';
import 'package:wreader_flutter_module/utils/common/file_type_helper.dart';
import 'package:wreader_flutter_module/utils/common/string_utils.dart';
import 'package:wreader_flutter_module/utils/size/size_util.dart';
import 'package:wreader_flutter_module/values/app_colors.dart';
import 'package:wreader_flutter_module/values/app_strings.dart';
import 'package:wreader_flutter_module/widget/common_styles.dart';
import 'package:wreader_flutter_module/widget/ez_app_bar.dart';

import 'action.dart';
import 'state.dart';

Widget buildView(
    SearchRepoFileState state, Dispatch dispatch, ViewService viewService) {
  return Scaffold(
    appBar: _buildAppBar(state, dispatch, viewService),
    body: Container(
      key: Key("${state.brightnessMode}"),
      child: _buildComeBackContent(state, viewService, dispatch),
    ),
  );
}

_buildAppBar(
    SearchRepoFileState state, Dispatch dispatch, ViewService viewService) {
  return EzAppBar.buildCommonAppBar(
      Container(
        width: double.infinity,
        height: 80.px2Dp,
        padding: EdgeInsets.only(right: 30.px2Dp),
        child: TextField(
          maxLines: 1,
          autofocus: true,
          focusNode: state.searchFocusNode,
          controller: state.searchController,
          onChanged: (key) {
            int taskIndex = ++state.taskIndex;
            if (taskIndex >= 1024 * 1024) {
              state.taskIndex = 0;
              taskIndex = 0;
            }
            dispatch(SearchRepoFileActionCreator.search(key, taskIndex));
          },
          textAlign: TextAlign.left,
          style: AppTvStyles.textStyle14ColorWhite(),
          decoration: InputDecoration(
            hintText: StrsSearchReadingRecord.hint(),
          ),
        ),
      ),
      viewService.context);
}

///有仓库列表，展示最近阅读列表或者仓库列表
Widget _buildComeBackContent(
    SearchRepoFileState state, ViewService viewService, Dispatch dispatch) {
  return state.fileInfoList != null && state.fileInfoList.isNotEmpty
      ? _buildListView(state, dispatch, viewService)
      : Container(
          key: Key("${MainState.globalBrightnessMode}"),
          height: double.infinity,
          alignment: Alignment(0, -0.3),
          child: Text(
            state.fileInfoList.isEmpty != null &&
                    state.fileInfoList.isEmpty &&
                    StringUtil.isEmpty(state.searchController.text)
                ? ''
                : StrsSearchReadingRecord.noResult(),
            style: AppTvStyles.textStyle18ColorMain(),
          ),
        );
}

_buildListView(
    SearchRepoFileState state, Dispatch dispatch, ViewService viewService) {
  return ListView.separated(
      key: Key("${state.brightnessMode}"),
      itemBuilder: (context, index) {
        return RepoFileHelper.buildInfoItem(
            state.fileInfoList[index],
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
      itemCount: state.fileInfoList.length ?? 0);
}

_onPress(FileInfo info, RepoDetailsBean repo, Dispatch dispatch,
    ViewService viewService, BuildContext context, int index) {
  String fileType = FileTypeHelper.getBizType(info.absoultPath);
  //打开文件
  dispatch(SearchRepoFileActionCreator.openFile(info.absoultPath, repo.gitUri,
      repo.currentBranch, repo.targetDir, fileType));
}
