import 'package:wreader_flutter_module/utils/size/size_util.dart';

///根据设计稿的px值，返回设备的dp值
_getDpFromPx(px) {
  double tmp = 0;
  if (px is int) {
    tmp = px.toDouble();
  } else {
    tmp = px;
  }
  return SizeUtil.getAdaptiveDpFromPx(tmp);
}

///根据设计稿的sp值，返回设备的dp值
_getSp(sp) {
  double tmp = 0;
  if (sp is int) {
    tmp = sp.toDouble();
  } else {
    tmp = sp;
  }
  return SizeUtil.getAdaptiveSp(tmp);
}

///根据设计稿的dp值，返回设备的dp值
_getDpFromDp(dp) {
  double tmp = 0;
  if (dp is int) {
    tmp = dp.toDouble();
  } else {
    tmp = dp;
  }
  return SizeUtil.getAdaptiveDpFromPx(tmp);
}

///文本大小相关的
class AppSps {
  ///文本字体大小相关
  static final txtSize10 = _getSp(10.0);
  static final txtSize12 = _getSp(12.0);
  static final txtSize14 = _getSp(14.0);
  static final txtSize16 = _getSp(16.0);
  static final txtSize18 = _getSp(18.0);
  static final txtSize20 = _getSp(20.0);
  static final txtSize22 = _getSp(22.0);
  static final txtSize24 = _getSp(24.0);
}

///设计稿上的值，像素值。这里定义的常量值必须是dp值
class AppDimens {
  ///标题栏高度
  static final appBarHeight = _getDpFromPx(90.0);

  ///返回按钮的大小
  static final appBarBackIconSize = _getDpFromPx(48);

  ///通用logo显示大小
  static final homeLogoSize = _getDpFromPx(144);

  ///appBar的padding
  static final appBarActionPadding = _getDpFromPx(12);

  ///通用的30像素宽度的值
  static final commPaddingMarginPx30 = _getDpFromPx(30);
}
