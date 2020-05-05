import 'package:flutter/material.dart';
import 'package:wreader_flutter_module/bean/repo_preview_item.dart';
import 'package:wreader_flutter_module/routers/fluro_routers.dart';
import 'package:wreader_flutter_module/utils/size/size_util.dart';
import 'package:wreader_flutter_module/values/app_colors.dart';
import 'package:wreader_flutter_module/widget/common_styles.dart';
import 'package:wreader_flutter_module/widget/ez_selector.dart';

///构建公共仓库列表的帮助类
class CommonRepoListViewHelper {
  static Widget buildCommonRepoListView(List<RepoPreviewItem> items) {
    return ListView.separated(
        key: Key(DateTime.now().toString()),
        itemBuilder: (context, index) {
          return _buildItem(context, items, index);
        },
        separatorBuilder: _separatorBuilder,
        itemCount: items.length);
  }

  static Widget _buildItem(
      BuildContext context, List<RepoPreviewItem> items, int index) {
    return EzSelector(
      Container(
        width: SizeUtil.deviceWidth,
        padding: EdgeInsets.all(20.px2Dp),
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
                    "${items[index].rootDir}/${items[index].targetDir}",
                    style: AppTvStyles.textStyle14Color63(),
                    softWrap: true,
                  ),
                  SizedBox(
                    height: 10.px2Dp,
                  ),
                  Text(
                    "${items[index].gitUri}",
                    softWrap: true,
                    style: AppTvStyles.textStyle12Color66(),
                  ),
                  Text("currentBranch：${items[index].currentBranch}",
                      softWrap: true, style: AppTvStyles.textStyle12Color66()),
                ],
              ),
            )
          ],
        ),
      ),
      () {
        FluroRouter.navigateTo(
            context,
            "${RouteNames.REPO_DETAILS}?"
            "gitLocalDir=${Uri.encodeComponent("${items[index].rootDir}/${items[index].targetDir}")}"
            "&gitUri=${Uri.encodeComponent("${items[index].gitUri}")}",
            replace: false);
      },
      defaultColor: AppColors.commonIdleColor(context),
      pressColor: AppColors.commonPressColor(context),
    );
  }

  static Widget _separatorBuilder(BuildContext context, int index) {
    return Container(
      width: SizeUtil.deviceWidth,
      height: 1.px2Dp,
      color: AppColors.COLOR_6E,
    );
  }
}
