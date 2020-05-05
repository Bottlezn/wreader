import 'dart:io';

import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:wreader_flutter_module/consts/file_type.dart';
import 'package:wreader_flutter_module/db/sqlite_helper.dart';
import 'package:wreader_flutter_module/page/main/state.dart';
import 'package:wreader_flutter_module/utils/common/string_utils.dart';
import 'package:wreader_flutter_module/utils/reading/reading.dart';
import 'package:wreader_flutter_module/utils/size/size_util.dart';
import 'package:wreader_flutter_module/values/app_strings.dart';
import 'package:wreader_flutter_module/widget/common_decoration.dart';
import 'package:wreader_flutter_module/widget/common_styles.dart';
import 'package:wreader_flutter_module/widget/ez_app_bar.dart';

import 'action.dart';
import 'state.dart';

Widget buildView(SearchReadingRecordState state, Dispatch dispatch,
    ViewService viewService) {
  return Scaffold(
    appBar: _buildAppBar(state, dispatch, viewService),
    body: _buildComeBackContent(state, viewService.context, dispatch),
  );
}

_buildAppBar(SearchReadingRecordState state, Dispatch dispatch,
    ViewService viewService) {
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
            dispatch(SearchReadingRecordActionCreator.search(key, taskIndex));
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
    SearchReadingRecordState state, BuildContext context, Dispatch dispatch) {
  //如果阅读记录不为空，显示最近阅读，否则显示仓库列表
  return state.readingRecord != null && state.readingRecord.isNotEmpty
      ? _buildReadingRecordWidget(state, context, dispatch)
      : Container(
          height: double.infinity,
          alignment: Alignment(0, -0.3),
          child: Text(
            state.readingRecord.isEmpty &&
                    StringUtil.isEmpty(state.searchController.text)
                ? ''
                : StrsSearchReadingRecord.noResult(),
            style: AppTvStyles.textStyle18ColorMain(),
          ),
        );
}

///打开最近阅读记录的文件
_openAndRead(SearchReadingRecordState state, BuildContext context,
    Map<String, dynamic> item) {
  showLoadingAndRead(
      context,
      item[ReadingRecordConst.FILE_PATH],
      item[ReadingRecordConst.OWNER_GIT_URI],
      item[ReadingRecordConst.OWNER_GIT_BRANCH],
      item[ReadingRecordConst.OWNER_REPO_LOCAL_DIR],
      item[ReadingRecordConst.BIZ_FILE_TYPE]);
}

///构建最近阅读页面的UI
Widget _buildReadingRecordWidget(
    SearchReadingRecordState state, BuildContext context, Dispatch dispatch) {
  return GridView.builder(
    key:
        Key("${MainState.globalBrightnessMode}${MainState.globalLanguageCode}"),
    gridDelegate: state.sliverDelegate,
    itemCount: state.readingRecord.length,
    itemBuilder: (context, index) {
      Map<String, dynamic> item = state.readingRecord[index];
      return GestureDetector(
        onTap: () {
          _openAndRead(state, context, item);
        },
        child: Container(
          decoration: CommonDecoration.readingRecordDecoration(),
          child: Stack(
            children: <Widget>[
              Container(
                width: double.infinity,
                height: double.infinity,
                padding: EdgeInsets.all(10.px2Dp),
                child: _buildReadingRecordItem(item),
              ),
              Align(
                alignment: AlignmentDirectional(-1, 1),
                child: Container(
                  padding: EdgeInsets.all(10.px2Dp),
                  width: double.infinity,
                  color: Colors.grey[700],
                  child: Text(
                    item[ReadingRecordConst.FILE_NAME] ?? 'error',
                    maxLines: 1,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: AppTvStyles.textStyle10ColorWhite(),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    },
    padding: EdgeInsets.all(20.px2Dp),
  );
}

///构建阅读揭露布局
_buildReadingRecordItem(Map<String, dynamic> item) {
  switch (item[ReadingRecordConst.BIZ_FILE_TYPE]) {
    case FileTypeConst.MD_FILE:
    case FileTypeConst.CODE:
      return Text(
        item[ReadingRecordConst.READING_CACHED] ?? StrsHome.emptyFile(),
        style: AppTvStyles.textStyle10Color69(),
      );
    case FileTypeConst.IMAGE:
      var imgUri = item[ReadingRecordConst.FILE_PATH] as String;
      if (imgUri != null) {
        if (imgUri.startsWith('http://') || imgUri.startsWith('https://')) {
          return Image.network(
            imgUri,
            fit: BoxFit.cover,
          );
        } else if (imgUri.startsWith('/')) {
          return Image.file(
            File(imgUri),
            fit: BoxFit.cover,
          );
        }
      }
      return Image.asset(
        'assets/images/icon_unknown_file.png',
        fit: BoxFit.cover,
      );
    default:
      return Image.asset(
        'assets/images/icon_unknown_file.png',
        fit: BoxFit.cover,
      );
  }
}
