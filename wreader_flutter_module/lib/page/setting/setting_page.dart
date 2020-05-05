import 'package:flutter/material.dart';
import 'package:wreader_flutter_module/consts/language_code_const.dart';
import 'package:wreader_flutter_module/db/sqlite_helper.dart';
import 'package:wreader_flutter_module/page/main/state.dart';
import 'package:wreader_flutter_module/routers/fluro_routers.dart';
import 'package:wreader_flutter_module/utils/channel/trans_bridge_channel.dart';
import 'package:wreader_flutter_module/utils/size/size_util.dart';
import 'package:wreader_flutter_module/values/app_colors.dart';
import 'package:wreader_flutter_module/values/app_strings.dart';
import 'package:wreader_flutter_module/widget/common_decoration.dart';
import 'package:wreader_flutter_module/widget/common_styles.dart';
import 'package:wreader_flutter_module/widget/environment_con_helper.dart';
import 'package:wreader_flutter_module/widget/ez_selector.dart';

/// Created on 2020/5/4.
/// @author 悟笃笃
/// description: 设置页面,使用 HomeDrawer 一堆问题  ,直接打开新页面

class SettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() =>
      _SettingState(MainState.globalBrightnessMode);
}

class _SettingState extends State<SettingPage> {
  int mode;

  _SettingState(this.mode);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        key: Key("${DateTime.now()}"),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildTopBar(),
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(10.px2Dp),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    _buildLanguageCode(),
                    _buildDivider(),
                    _buildCleanInvalidRepo(),
                    _buildDivider(),
                    _buildManageRepo(),
                    _buildDivider(),
                    _buildLogListEntrance(),
                    _buildDivider(),
                    _buildAboutInfo(),
                    _buildDivider(),
                    _exitSetting(),
                    _buildDivider(),
                    _buildExitApp(),
                    _buildDivider(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildLogListEntrance() {
    return EzSelector(
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(10.px2Dp, 30.px2Dp, 10.px2Dp, 30.px2Dp),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                StrsSetting.logList(),
                style: AppTvStyles.textStyle16Color69(),
              ),
              Icon(
                Icons.keyboard_arrow_right,
                size: 48.px2Dp,
              )
            ],
          ),
        ), () {
      FluroRouter.navigateTo(context, RouteNames.LOG_LIST);
    });
  }

  ///关闭App
  _buildAboutInfo() {
    return EzSelector(
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(10.px2Dp, 30.px2Dp, 10.px2Dp, 30.px2Dp),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                StrsSetting.aboutWReader(),
                style: AppTvStyles.textStyle16Color69(),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      "${MainState.versionName ?? 'unknown'}",
                      style: AppTvStyles.textStyle16Color69(),
                    ),
                    Icon(
                      Icons.keyboard_arrow_right,
                      size: 48.px2Dp,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        _gotoAboutMe);
  }

  _gotoAboutMe() {
    FluroRouter.navigateTo(context, RouteNames.ABOUT);
  }

  ///退出页面
  _exitSetting() {
    return EzSelector(
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(10.px2Dp, 30.px2Dp, 10.px2Dp, 30.px2Dp),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                StrsSetting.exitSetting(),
                style: AppTvStyles.textStyle16Color69(),
              ),
              Icon(
                Icons.keyboard_arrow_right,
                size: 48.px2Dp,
              )
            ],
          ),
        ), () {
      Navigator.pop(context);
    });
  }

  ///关闭App
  _buildExitApp() {
    return EzSelector(
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(10.px2Dp, 30.px2Dp, 10.px2Dp, 30.px2Dp),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                StrsSetting.exitApp(),
                style: AppTvStyles.textStyle16Color69(),
              ),
              Icon(
                Icons.close,
                size: 48.px2Dp,
                color: AppColors.COLOR_MAIN,
              )
            ],
          ),
        ), () {
      TransBridgeChannel.exitApp();
    });
  }

  ///删除无效仓库
  _buildCleanInvalidRepo() {
    return EzSelector(
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(10.px2Dp, 30.px2Dp, 10.px2Dp, 30.px2Dp),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                StrsSetting.cleanInvalidRepo(),
                style: AppTvStyles.textStyle16Color69(),
              ),
              Icon(
                Icons.keyboard_arrow_right,
                size: 48.px2Dp,
              )
            ],
          ),
        ),
        _clearInvalidRepo);
  }

  ///清理无效的仓库
  _clearInvalidRepo() {
    TransBridgeChannel.clearInvalidRepo().then((_) {
      if (_ != null && _.isNotEmpty) {
        TransBridgeChannel.showToast(_);
      }
    });
  }

  ///去管理仓库
  _buildManageRepo() {
    return EzSelector(
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(10.px2Dp, 30.px2Dp, 10.px2Dp, 30.px2Dp),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                StrsSetting.manageRepo(),
                style: AppTvStyles.textStyle16Color69(),
              ),
              Icon(
                Icons.keyboard_arrow_right,
                size: 48.px2Dp,
              )
            ],
          ),
        ), () {
      FluroRouter.navigateTo(context, RouteNames.MANAGE_REPO);
    });
  }

  _buildLanguageCode() {
    return EzSelector(
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(10.px2Dp, 30.px2Dp, 10.px2Dp, 30.px2Dp),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                StrsSetting.displayLanguage(),
                style: AppTvStyles.textStyle16Color69(),
              ),
              Text(
                _obtainDisplayName(),
                style: AppTvStyles.textStyle16Color69(),
              )
            ],
          ),
        ),
        _showSelectLanguageCodeDialog);
  }

  _obtainDisplayName() {
    if (MainState.globalLanguageCode == null ||
        MainState.globalLanguageCode == LanguageCodeConsts.FOLLOW_SYSTEM) {
      return StrsSetting.followSystem();
    } else if (MainState.globalLanguageCode == LanguageCodeConsts.ZH_CN) {
      return '中文';
    } else {
      return 'English';
    }
  }

  _showSelectLanguageCodeDialog() {
    showDialog(context: context, builder: _buildAuthWay).then((index) {
      if (index != null && index is int) {
        _switchLanguageCode(index);
      }
    });
  }

  _buildDivider() => Container(
        height: 2.px2Dp,
        width: double.infinity,
        color: AppColors.COLOR_BG,
      );

  ///构建鉴权方式的选择方式
  Widget _buildAuthWay(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(20.px2Dp),
        margin: EdgeInsets.all(40),
        decoration: CommonDecoration.commonRoundDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
                width: double.infinity,
                child: FlatButton(
                  child: Text(StrsSetting.followSystem(),
                      style: AppTvStyles.textStyle14ColorMain()),
                  onPressed: () {
                    Navigator.pop(context, 0);
                  },
                )),
            _buildDivider(),
            Container(
              width: double.infinity,
              child: FlatButton(
                child: Text('中文', style: AppTvStyles.textStyle14ColorMain()),
                onPressed: () {
                  Navigator.pop(context, 1);
                },
              ),
            ),
            _buildDivider(),
            Container(
              width: double.infinity,
              child: FlatButton(
                child: Text(
                  'English',
                  style: AppTvStyles.textStyle14ColorMain(),
                ),
                onPressed: () {
                  Navigator.pop(context, 2);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  _switchLanguageCode(index) async {
    String code = LanguageCodeConsts.FOLLOW_SYSTEM;
    switch (index) {
      case 1:
        code = LanguageCodeConsts.ZH_CN;
        break;
      case 2:
        code = LanguageCodeConsts.EN_US;
        break;
      default:
        break;
    }
    await EnvironmentConfHelper.switchLanguageCode(context, code);
    FluroRouter.navigateTo(context, "${RouteNames.HOME}?openDrawer=1",
        replace: true);
  }

  _buildTopBar() {
    return Container(
      height: 210.px2Dp + SizeUtil.padding.top,
      color: AppColors.MAIN,
      alignment: Alignment(-1, 0),
      padding: EdgeInsets.only(top: SizeUtil.padding.top),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          EzSelector(
            Container(
              height: double.infinity,
              padding:
                  EdgeInsets.fromLTRB(10.px2Dp, 20.px2Dp, 10.px2Dp, 20.px2Dp),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/images/icon_wreader_mid.png',
                    width: 120.px2Dp,
                    height: 120.px2Dp,
                  ),
                  Text(
                    '悟笃笃',
                    style: AppTvStyles.textStyle12ColorWhite(),
                  ),
                ],
              ),
            ),
            _gotoAboutMe,
            defaultColor: Colors.transparent,
            pressColor: AppColors.COLOR_TRANS_20,
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 20.px2Dp,
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    alignment: Alignment(-1, 0),
                    width: double.infinity,
                    height: double.infinity,
                    padding: EdgeInsets.only(left: 12.px2Dp),
                    margin: EdgeInsets.only(right: 20.px2Dp),
                    child: GestureDetector(
                      child: Text(
                        MainState.myWord ?? '空想无益，躬行笃履',
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: AppTvStyles.textStyle18ColorWhite(true),
                      ),
                      onTap: _showInputMyWord,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    EzSelector(
                      Container(
                        height: 98.px2Dp,
                        child: Image.asset(
                          mode == EnvironmentConst.MODE_LIGHT
                              ? 'assets/images/icon_mode_light.png'
                              : 'assets/images/icon_mode_dark.png',
                          width: 44.px2Dp,
                          height: 44.px2Dp,
                        ),
                        padding:
                            EdgeInsets.only(left: 10.px2Dp, right: 10.px2Dp),
                      ),
                      _switchBrightnessMode,
                      defaultColor: Colors.transparent,
                      pressColor: AppColors.COLOR_TRANS_20,
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  ///切换日夜模式
  _switchBrightnessMode() async {
    mode = mode == EnvironmentConst.MODE_LIGHT
        ? EnvironmentConst.MODE_DARK
        : EnvironmentConst.MODE_LIGHT;
    await EnvironmentConfHelper.switchBrightness(mode);
    setState(() {});
  }

  ///修改展示文本
  _showInputMyWord() {
    final TextEditingController controller = TextEditingController();
    controller.text = MainState.myWord;
    showDialog(
        context: context,
        builder: (_) {
          return GestureDetector(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Container(
                  height: 300.px2Dp,
                  margin: EdgeInsets.all(30.px2Dp),
                  decoration: CommonDecoration.commonRoundDecoration(),
                  padding: EdgeInsets.all(20.px2Dp),
                  alignment: AlignmentDirectional(0, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        height: 140.px2Dp,
                        alignment: Alignment(0, 0),
                        child: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                              hintText: StrsSetting.myWordHint(),
                              contentPadding: EdgeInsets.all(10.px2Dp)),
                          maxLength: 16,
                          maxLines: 1,
                          autofocus: true,
                          minLines: 1,
                        ),
                      ),
                      SizedBox(
                        height: 20.px2Dp,
                      ),
                      SizedBox(
                        height: 80.px2Dp,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: RaisedButton(
                                child: Text(StrsSetting.cancel()),
                                onPressed: _cancelEditMyWord,
                              ),
                            ),
                            SizedBox(
                              width: 20.px2Dp,
                            ),
                            Expanded(
                              flex: 1,
                              child: RaisedButton(
                                child: Text(StrsSetting.save()),
                                onPressed: () {
                                  _saveEditMyWord(controller.text);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            onTap: _cancelEditMyWord,
          );
        });
  }

  _saveEditMyWord(String text) async {
    if (text == null || text.trim().isEmpty) {
      TransBridgeChannel.showToast(StrsToast.emptyTextWarn());
      return;
    }
    await WReaderSqlHelper.modifyEnvironmentConfig(myWord: text);
    MainState.myWord = text;
    Navigator.pop(context);
    setState(() {});
  }

  _cancelEditMyWord() {
    Navigator.pop(context);
  }
}
