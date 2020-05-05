import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart';
import 'package:wreader_flutter_module/bean/repo_preview_item.dart';
import 'package:wreader_flutter_module/db/sqlite_helper.dart';
import 'package:wreader_flutter_module/page/manage_repo/action.dart';
import 'package:wreader_flutter_module/utils/channel/trans_bridge_channel.dart';
import 'package:wreader_flutter_module/utils/size/size_util.dart';
import 'package:wreader_flutter_module/values/app_colors.dart';
import 'package:wreader_flutter_module/values/app_strings.dart';
import 'package:wreader_flutter_module/widget/common_decoration.dart';
import 'package:wreader_flutter_module/widget/common_styles.dart';
import 'package:wreader_flutter_module/widget/common_widgets.dart';
import 'package:wreader_flutter_module/widget/ez_app_bar.dart';

import 'state.dart';

Widget buildView(
    ManageGitRepoState state, Dispatch dispatch, ViewService viewService) {
  return Scaffold(
    appBar: EzAppBar.buildCenterTitleAppBar(
        StrsManageRepo.title(), viewService.context),
    body: state.isLoading
        ? CommonWidgets.buildLoadingPage()
        : _buildContent(state, dispatch, viewService),
  );
}

Widget _buildRepoItem(
  BuildContext context,
  int index,
  RepoPreviewItem item,
  Dispatch dispatch,
) {
  return Dismissible(
    key: Key("${item.gitUri}"),
    child: Container(
      width: SizeUtil.deviceWidth,
      padding: EdgeInsets.all(20.px2Dp),
      color: AppColors.commonItemColor(context),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Image.asset(
            'assets/images/icon_folder.png',
            width: 80.px2Dp,
            height: 80.px2Dp,
          ),
          SizedBox(
            width: 10.px2Dp,
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "${item.rootDir}/${item.targetDir}",
                  style: AppTvStyles.textStyle14Color63(),
                  softWrap: true,
                ),
                SizedBox(
                  height: 10.px2Dp,
                ),
                Text(
                  "${item.gitUri}",
                  softWrap: true,
                  style: AppTvStyles.textStyle12Color66(),
                ),
                Text("${StrsManageRepo.currentBranch()}：${item.currentBranch}",
                    softWrap: true, style: AppTvStyles.textStyle12Color66()),
              ],
            ),
          )
        ],
      ),
    ),
    onDismissed: (direction) {
      dispatch(ManageGitRepoActionCreator.showLoading());
      dispatch(ManageGitRepoActionCreator.reloadRepoItem());
      return Future.value(true);
    },
    background: Container(
        color: AppColors.MAIN,
        child: Center(
          child: Text(
            StrsManageRepo.delete(),
            textAlign: TextAlign.start,
            style: AppTvStyles.textStyle20ColorWhite(),
          ),
        )),
    confirmDismiss: (direction) {
      return _deleteConfirm(context, item);
    },
  );
}

///删除确认
Future<bool> _deleteConfirm(BuildContext context, RepoPreviewItem item) async {
  return await showDialog(
      context: context,
      builder: (_) {
        return Center(
          child: Container(
            decoration: CommonDecoration.commonRoundDecoration(),
            width: SizeUtil.deviceWidth,
            margin: EdgeInsets.all(30.px2Dp),
            padding: EdgeInsets.all(20.px2Dp),
            constraints: BoxConstraints(maxHeight: 460.px2Dp),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("${StrsManageRepo.deleteConfirm()}${item.gitUri}?",
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    maxLines: 4,
                    style: AppTvStyles.textStyle16ColorMain()),
                SizedBox(
                  height: 20.px2Dp,
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: RaisedButton(
                        child: Text(
                          StrsManageRepo.delete(),
                        ),
                        onPressed: () async {
                          String result =
                              await TransBridgeChannel.clearSpecifiedRepo(
                                  ["${item.rootDir}/${item.targetDir}"]);
                          if ('success' == result) {
                            var result = await WReaderSqlHelper.deleteRepoConf(
                                item.gitUri);
                            TransBridgeChannel.showToast(
                                StrsManageRepo.deleteSuccess());
                            Navigator.pop(context, result);
                          } else {
                            TransBridgeChannel.showToast(result);
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      width: 20.px2Dp,
                    ),
                    Expanded(
                      flex: 1,
                      child: RaisedButton(
                        child: Text(StrsManageRepo.cancel()),
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
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

_buildContent(
    ManageGitRepoState state, Dispatch dispatch, ViewService viewService) {
  if (state.repoItems.isNotEmpty) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(10.px2Dp),
          color: AppColors.COLOR_LIGHT_PRESS,
          width: double.infinity,
          child: Text(
            StrsManageRepo.swipeToDelete(),
            style: AppTvStyles.textStyle10ColorWhite(),
          ),
        ),
        Expanded(
          flex: 1,
          child: ListView.separated(
              itemBuilder: (BuildContext context, int index) {
                RepoPreviewItem item = state.repoItems[index];
                return _buildRepoItem(context, index, item, dispatch);
              },
              separatorBuilder: (BuildContext context, int index) {
                return Container(
                  width: double.infinity,
                  height: 1.px2Dp,
                  color: AppColors.COLOR_BG,
                );
              },
              itemCount: state.repoItems.length),
        )
      ],
    );
  } else {
    return Container(
      alignment: Alignment(0, -1),
      padding: EdgeInsets.all(20.px2Dp),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 80.px2Dp,
          ),
          Image.asset(
            'assets/images/icon_welcome.png',
            width: 260.px2Dp,
            height: 260.px2Dp,
          ),
          Text(
            StrsManageRepo.empty(),
            style: AppTvStyles.textStyle18Color69(),
          ),
        ],
      ),
    );
  }
}
