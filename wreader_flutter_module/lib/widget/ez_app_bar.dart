import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wreader_flutter_module/utils/size/size_util.dart';
import 'package:wreader_flutter_module/values/app_colors.dart';
import 'package:wreader_flutter_module/values/app_dimens.dart';
import 'package:wreader_flutter_module/widget/common_styles.dart';
import 'package:wreader_flutter_module/widget/ez_selector.dart';
import 'package:wreader_flutter_module/widget/text_selector.dart';

///返回前的事件，如果返回true退出页面，返回false不会退出页面。
typedef BeforeCallback = bool Function(BuildContext context);

class EzAppBar {
  static Widget buildCommonAppBar(Widget titleWidget, BuildContext context,
      {bool showBack = true,
      double height,
      double elevation = 0,
      bool center = false,
      Widget leading,
      BeforeCallback callback,
      Color backgroundColor = AppColors.MAIN,
      ShapeBorder shape,
      List<Widget> actions}) {
    return PreferredSize(
        child: AppBar(
          title: titleWidget,
          centerTitle: center,
          elevation: elevation,
          shape: shape,
          backgroundColor: backgroundColor,
          actions: actions,
          leading: showBack
              ? leading ??
                  _buildDefaultLeading(
                      context, callback, height ?? AppDimens.appBarHeight)
              : null,
        ),
        preferredSize:
            Size(SizeUtil.deviceWidth, height ?? AppDimens.appBarHeight));
  }

  ///通用的构建appBar的函数
  static Widget buildCenterTitleAppBar(String title, BuildContext context,
      {bool showBack = true,
      double height,
      double elevation = 0,
      Widget leading,
      BeforeCallback callback,
      Color backgroundColor = AppColors.MAIN,
      TextStyle titleStyle,
      ShapeBorder shape,
      List<Widget> actions}) {
    return buildCommonAppBar(
        Text(
          title ?? 'WReader',
          style: titleStyle ?? AppTvStyles.textStyle22ColorWhite(true),
        ),
        context,
        showBack: showBack,
        height: height,
        elevation: elevation,
        center: true,
        leading: leading,
        callback: callback,
        backgroundColor: backgroundColor,
        shape: shape,
        actions: actions);
//    return PreferredSize(
//        child: AppBar(
//          title: Text(
//            title ?? 'WReader',
//            style: titleStyle ?? AppTvStyles.textStyle22ColorWhite(true),
//          ),
//          centerTitle: true,
//          elevation: elevation,
//          shape:
//              shape /* ??
//              Border(
//                  bottom: BorderSide(
//                      color: AppColors.COLOR_BG,
//
//                      width: SizeUtil.getAdaptiveDpFromPx(0)))*/
//          ,
//          backgroundColor: backgroundColor,
//          actions: actions,
//          leading: showBack
//              ? leading ??
//                  _buildDefaultLeading(
//                      context, callback, height ?? AppDimens.appBarHeight)
//              : null,
//        ),
//        preferredSize:
//            Size(SizeUtil.deviceWidth, height ?? AppDimens.appBarHeight));
  }

  ///构建一个公用的退出按钮
  static _buildDefaultLeading(
      BuildContext context, BeforeCallback callback, double height) {
    return EzSelector(
      Container(
        height: height ?? AppDimens.appBarHeight,
        padding: EdgeInsets.only(left: SizeUtil.getAdaptiveDpFromPx(30)),
        alignment: Alignment(-1.0, 0.0),
        child: Icon(
          Icons.arrow_back_ios,
          size: 48.px2Dp,
          color: Colors.white,
        ),
      ),
      () {
        if (callback != null && !callback(context)) {
          //不能退出当前页面
          return;
        }
        _exitCurrentPage(context);
      },
      defaultColor: Colors.transparent,
      pressColor: AppColors.COLOR_TRANS_20,
    );
  }

  ///退出事件
  static _exitCurrentPage(BuildContext context) {
    if (Navigator.canPop(context)) {
      //关闭当前页面
      Navigator.pop(context);
    } else {
      //直接退出app
      SystemNavigator.pop();
    }
  }

  static Widget _wrapButton(SimpleAppBarAction action) {
    var controller = SelectedController();
    controller.setText(action.actionName);
    return Container(
      margin: EdgeInsets.only(
        left: SizeUtil.getAdaptiveDpFromPx(12),
      ),
      child: TextSelector(
        controller,
        height: SizeUtil.getAdaptiveDpFromPx(90),
        defaultStyle: AppTvStyles.textStyle16ColorWhite(),
        padding: EdgeInsets.only(
            left: SizeUtil.getAdaptiveDpFromPx(20),
            right: SizeUtil.getAdaptiveDpFromPx(20)),
        defaultColor: Colors.transparent,
        pressingColor: AppColors.COLOR_TRANS_20,
        radiusAll: SizeUtil.getAdaptiveDpFromPx(6),
        onPress: action.callback,
      ),
    );
  }

  ///构建右侧按钮列表，单个按钮请使用该方法，简单易用
  static List<Widget> ezBuildSingleAction(String actionName, Function callback,
      {Widget button}) {
    List<Widget> actions = List();
    actions.add(_wrapButton(SimpleAppBarAction(actionName, callback, button)));
    return actions;
  }

  ///构建右侧按钮列表
  static List<Widget> buildActionList(List<SimpleAppBarAction> list) {
    List<Widget> actions = List();
    list.forEach((e) {
      actions.add(_wrapButton(e));
    });
    return actions;
  }
}

///简单的右侧按钮信息bean
class SimpleAppBarAction {
  String actionName;
  Function callback;
  Widget button;

  SimpleAppBarAction(this.actionName, this.callback, this.button);
}
