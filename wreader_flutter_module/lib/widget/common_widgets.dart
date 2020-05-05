import 'package:flutter/material.dart';
import 'package:wreader_flutter_module/utils/size/size_util.dart';
import 'package:wreader_flutter_module/values/app_colors.dart';
import 'package:wreader_flutter_module/widget/common_decoration.dart';

class CommonWidgets {
  ///构建出来一个加载中的页面
  static Widget buildLoadingPage() {
    return Container(
      child: Center(
        child: SizedBox(
          width: SizeUtil.getAdaptiveDpFromPx(80),
          height: SizeUtil.getAdaptiveDpFromPx(80),
          child: CircularProgressIndicator(
            value: null,
            backgroundColor: AppColors.COLOR_MAIN,
            valueColor: AlwaysStoppedAnimation(AppColors.COLOR_6E),
          ),
        ),
      ),
    );
  }

  static Widget buildDivider({double height, Color color, EdgeInsets margin}) {
    return Container(
      height: height ?? 2.px2Dp,
      color: color ?? AppColors.COLOR_BG,
      margin: margin,
    );
  }

  ///[cancelable]等于false时，必须手动调用[Navigator.pop(context)]关闭dialog
  static Widget buildLoadingDialog({String hint, bool cancelable = true}) {
    //offstage等于false时显示文本，等于true时不显示
    final bool offstage = hint == null || hint.isEmpty;
    return WillPopScope(
        child: Center(
          child: Container(
            decoration: CommonDecoration.commonRoundDecoration(),
            padding: EdgeInsets.all(20.px2Dp),
            margin: EdgeInsets.all(30.px2Dp),
            alignment: Alignment(0, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: SizeUtil.getAdaptiveDpFromPx(80),
                  height: SizeUtil.getAdaptiveDpFromPx(80),
                  child: CircularProgressIndicator(
                    value: null,
                    backgroundColor: AppColors.COLOR_MAIN,
                    valueColor: AlwaysStoppedAnimation(AppColors.COLOR_6E),
                  ),
                ),
                Offstage(
                  offstage: !offstage,
                  child: SizedBox(
                    height: 20.px2Dp,
                  ),
                ),
                Offstage(
                  offstage: !offstage,
                  child: Text(hint ?? ''),
                ),
              ],
            ),
          ),
        ),
        onWillPop: () {
          return Future.value(cancelable);
        });
  }
}
