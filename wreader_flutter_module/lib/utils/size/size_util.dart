import 'dart:math';

import 'package:flutter/material.dart';

///设备尺寸工具类，项目运行前请调用[init]。
///函数中没有包含px后缀的返回的都是dp值，标有px的返回的才是绝对像素值
///初始化函数需要传入需要适配的设计稿宽*高像素值、设计稿基准设备屏幕英寸数值。
///例如iPhone7 plus，宽高分辨率是 1080*1910，屏幕5.5英寸，像素密度是
/// √(1080^2+1920^2)/5.5=400，单位是ppi
///那么iphone7 1dp=(400/160)px ，就是2.5个像素点
///在Android中定义好默认的几个等级的适配基数，
///  基准符号  l      m      h      xh     xxh     xxxh
///  像素密度  120    160    240    320    480     640
///  缩放比率  0.75   1.0    1.5    2.0    3.0     4.0
///
class SizeUtil {
  SizeUtil._();

  static Size _size;

  ///设备宽度dp值
  static double _deviceWidthDp;

  ///设备宽度像素
  static double _deviceWidthPx;

  ///设备高度dp值
  static double _deviceHeightDp;

  ///设备高度像素
  static double _deviceHeightPx;

  ///状态栏高度dp值
  static double _statusBarHeightDp;

  ///导航栏高度dp值
  static double _navigationBarHeightDp;

  ///相当于Android中density，1个dp等于_devicePixelRatio像素
  static double _devicePixelRatio;

  ///文本缩放比率，相当于Android里面sp换算的比率
  static double _textScaleFactor;

  ///窗口大小和实际屏幕的padding
  static EdgeInsets _padding;

  ///设计稿宽度像素值
  static double _designsWidthPx;

  ///设计稿高度像素值
  static double _designsHeightPx;

  ///设计稿中设备的density
  static double _designsPixelRatio;

  ///设计稿中设备的density
  static double _designsPixelPpi;

  ///该值等于 _devicePixelRatio/_designsPixelRatio
  static double _adaptiveFactor;

  ///项目尺寸适配，传入BuildContext对象获取设备屏幕相关属性
  ///传入设计稿宽度像素和高度像素值，用于适配
  ///UI同事给的适配值如果是dp值就使用获取dp的函数
  ///给的适配值如果是px值，就使用获取px的函数
  ///[context]上下文
  ///[designsWidthPx]设计稿宽度，像素值
  ///[designsHeightPx]设计稿高度，像素值
  ///[designsDeviceSize]设计稿的设备屏幕尺寸，英寸值。用于计算像素密度
  static init(context, designsWidthPx, designsHeightPx, designsDeviceSize) {
    MediaQueryData data = MediaQuery.of(context);
    _size = data.size;
    _deviceWidthDp = _size.width;
    _deviceHeightDp = _size.height;
    _padding = MediaQuery.of(context).padding;
    _navigationBarHeightDp = _padding.bottom;
    _statusBarHeightDp = _padding.top;
    _devicePixelRatio = data.devicePixelRatio;
    _textScaleFactor = data.textScaleFactor;
    _deviceWidthPx = _deviceWidthDp * _devicePixelRatio;
    _deviceHeightPx = _deviceHeightDp * _devicePixelRatio;
    _designsWidthPx = designsWidthPx;
    _designsHeightPx = designsHeightPx;
    _designsPixelPpi = double.parse(
        (sqrt((pow(_designsWidthPx, 2) + pow(_designsHeightPx, 2))) /
                designsDeviceSize)
            .toStringAsFixed(2));
    _designsPixelRatio =
        double.parse((_designsPixelPpi / 160).toStringAsFixed(2));
    _adaptiveFactor = double.parse(
        (_devicePixelRatio / _designsPixelRatio).toStringAsFixed(2));
    print("设备dp宽高值：$_deviceWidthDp * $_deviceHeightDp");
    print("设备px宽高值：$_deviceWidthPx * $_deviceHeightPx");
    print("设备的每个逻辑像素的设备像素数(dp与px的换算)：$_devicePixelRatio ");
    print("设计稿px宽高值：$_designsWidthPx * $_designsHeightPx");
    print("设计稿ppi：$_designsPixelPpi ");
    print("设计稿的每个逻辑像素的设备像素数(dp与px的换算) =  ：$_designsPixelRatio");
    print("缩放因子 =  ：$_adaptiveFactor");
  }

  ///传入一个设计稿上面标注的sp值，返回一个当前设备的sp值
  static double getAdaptiveSp(double designsSp) {
    return designsSp;
  }

  ///返回适配用的dp值，传入值是ui设计稿中的dp值
  static double getAdaptiveDpFromDp(double designsDp) {
    //先转换成设计稿对应的像素值X
    //乘于缩放因素，转换成当前设备展示的像素值
    //最后除于设备的缩放比值。等到设备的dp值
    return double.parse(
        (designsDp * _designsPixelRatio * _adaptiveFactor / _devicePixelRatio)
            .toStringAsFixed(2));
  }

  ///返回适配用的dp值，传入值是ui设计稿中的px值
  static double getAdaptiveDpFromPx(double designsPx) {
    return double.parse(
        (designsPx * _adaptiveFactor / _devicePixelRatio).toStringAsFixed(2));
  }

  ///返回当前设备的px值，传入值是ui设计稿中的dp值
  static double getDevicePxFromDp(double designsDp) {
    return double.parse((getAdaptiveDpFromDp(designsDp) * _devicePixelRatio)
        .toStringAsFixed(2));
  }

  ///返回当前设备的px值，传入值是ui设计稿中的px值
  static double getDevicePxFromPx(double designsPx) {
    return double.parse((getAdaptiveDpFromPx(designsPx) * _devicePixelRatio)
        .toStringAsFixed(2));
  }

  static double get designsWidthPx => _designsWidthPx;

  static EdgeInsets get padding => _padding;

  static double get navigationBarHeight => _navigationBarHeightDp;

  static double get statusBarHeight => _statusBarHeightDp;

  static double get deviceHeight => _deviceHeightDp;

  static double get deviceWidth => _deviceWidthDp;

  static Size get size => _size;

  static double get devicePixelRatio => _devicePixelRatio;

  static double get textScaleFactor => _textScaleFactor;

  static double get designsHeightPx => _designsHeightPx;

  static String getInfo() {
    return "_deviceWidth = $_deviceWidthDp _deviceHeight = $_deviceHeightDp _statusBarHeight = $_statusBarHeightDp _navigationBarHeight = $_navigationBarHeightDp devicePixelRatio = $devicePixelRatio _textScaleFactor = $_textScaleFactor";
  }
}

///将设计稿的px适配成当前设备的dp值
double wrapPx(double px) {
  return SizeUtil.getAdaptiveDpFromPx(px);
}

///将设计稿的dp适配成当前设备的dp值
double wrapDp(double dp) {
  return SizeUtil.getAdaptiveDpFromDp(dp);
}

extension NumExtension on num {
  ///将设计稿的px适配成当前设备的dp值
  double get px2Dp {
    return wrapPx(this.toDouble());
  }

  ///将设计稿的px适配成当前设备的dp值
  double get dp2Dp {
    return wrapDp(this.toDouble());
  }
}
