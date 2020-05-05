import 'package:flutter/material.dart';
import 'package:wreader_flutter_module/db/sqlite_helper.dart';
import 'package:wreader_flutter_module/page/main/state.dart';
import 'package:wreader_flutter_module/utils/size/size_util.dart';
import 'package:wreader_flutter_module/values/app_colors.dart';

///通用的decoration
class CommonDecoration {
  ///返回一个带有圆角的[BoxDecoration]
  static Decoration commonRoundDecoration() {
    return BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(12.px2Dp)),
        color: MainState.globalBrightnessMode == EnvironmentConst.MODE_LIGHT
            ? Colors.white
            : Colors.grey[800]);
  }

  ///阅读记录显示专用的[BoxDecoration]
  static Decoration readingRecordDecoration() {
    return BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8.px2Dp)),
        border: Border.all(color: AppColors.COLOR_69, width: 1.px2Dp),
        color: MainState.globalBrightnessMode == EnvironmentConst.MODE_LIGHT
            ? Colors.white
            : Colors.grey[800]);
  }
}
