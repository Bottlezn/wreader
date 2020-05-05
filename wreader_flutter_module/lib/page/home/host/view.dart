import 'dart:io';

import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart';
import 'package:wreader_flutter_module/consts/file_type.dart';
import 'package:wreader_flutter_module/db/sqlite_helper.dart';
import 'package:wreader_flutter_module/page/main/state.dart';
import 'package:wreader_flutter_module/routers/fluro_routers.dart';
import 'package:wreader_flutter_module/utils/channel/trans_bridge_channel.dart';
import 'package:wreader_flutter_module/utils/common/file_helper.dart';
import 'package:wreader_flutter_module/utils/reading/reading.dart';
import 'package:wreader_flutter_module/utils/size/size_util.dart';
import 'package:wreader_flutter_module/values/app_colors.dart';
import 'package:wreader_flutter_module/values/app_strings.dart';
import 'package:wreader_flutter_module/widget/common_decoration.dart';
import 'package:wreader_flutter_module/widget/common_styles.dart';
import 'package:wreader_flutter_module/widget/ez_app_bar.dart';
import 'package:wreader_flutter_module/widget/ez_selector.dart';
import 'package:wreader_flutter_module/widget/repo_list_view.dart';

import 'action.dart';
import 'state.dart';

bool _isInitSize = false;
int _lastBackTimestamp = -1;

///退出延迟
const _DELAY_INTERNAL_BACK = 2000;

/// 构建 ViewWidget
Widget buildView(HomeState state, Dispatch dispatch, ViewService viewService) {
  if (!_isInitSize) {
    //我自己瞎鸡儿设计的设计稿，720 X 1280 作为蓝本，屏幕尺寸 5.0 英寸
    _isInitSize = true;
    SizeUtil.init(viewService.context, 720.toDouble(), 1280.toDouble(), 5.0);
  }
  return WillPopScope(
    key: Key("${state.isInit}"),
    onWillPop: () {
      if (_lastBackTimestamp == -1) {
        _lastBackTimestamp = DateTime.now().millisecondsSinceEpoch;
        TransBridgeChannel.showToast(StrsToast.click2HomeHint());
      } else {
        final int now = DateTime.now().millisecondsSinceEpoch;
        if (now - _lastBackTimestamp < _DELAY_INTERNAL_BACK) {
          TransBridgeChannel.gotoHome();
          _lastBackTimestamp = -1;
        } else {
          TransBridgeChannel.showToast(StrsToast.click2HomeHint());
        }
        _lastBackTimestamp = now;
      }
      return Future.value(false);
    },
    child: Scaffold(
      appBar: _appBar(state, viewService.context),
      body: state.isInit
          ? Builder(
              builder: (context) {
                state.scaffoldContext = context;
                if (state.openDrawer) {
                  state.openDrawer = false;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (state.scaffoldContext != null) {
                      _expandSections(state, context);
                    }
                  });
                }
                return _showReadContent(state, context, dispatch);
              },
            )
          : _showLoading(viewService.context),
    ),
  );
}

/// _items.isEmpty ? _buildWelcomeContent() : _buildComeBackContent();
Widget _showReadContent(
        HomeState state, BuildContext context, Dispatch dispatch) =>
    state.repoList.isEmpty
        ? _showGuid(state, context)
        : _buildComeBackContent(state, context, dispatch);

///有仓库列表，展示最近阅读列表或者仓库列表
Widget _buildComeBackContent(
    HomeState state, BuildContext context, Dispatch dispatch) {
  //如果阅读记录不为空，显示最近阅读，否则显示仓库列表
  return state.readingRecord.isNotEmpty
      ? _buildReadingRecordWidget(state, context, dispatch)
      : CommonRepoListViewHelper.buildCommonRepoListView(state.repoList);
}

///构建最近阅读页面的UI
Widget _buildReadingRecordWidget(
    HomeState state, BuildContext context, Dispatch dispatch) {
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
        onLongPress: () {
          _showMoreOperation(state, context, item, index, dispatch);
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

///展示更多操作选项
_showMoreOperation(HomeState state, BuildContext context,
    final Map<String, dynamic> item, final int index, Dispatch dispatch) {
  showDialog(
      context: context,
      builder: (_) {
        return Center(
          child: Container(
            width: double.infinity,
            decoration: CommonDecoration.commonRoundDecoration(),
            margin: EdgeInsets.all(20.px2Dp),
            padding: EdgeInsets.all(20.px2Dp),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  alignment: Alignment(-1, 0),
                  child: Text(
                    "${StrsHome.moreOperate()}",
                    style: AppTvStyles.textStyle16ColorMain(),
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(
                  height: 40.px2Dp,
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: RaisedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          _showDeleteHint(
                              state, context, item, index, dispatch);
                        },
                        child: Text(StrsManageRepo.delete()),
                      ),
                    ),
                    SizedBox(
                      width: 12.px2Dp,
                    ),
                    Expanded(
                      flex: 1,
                      child: RaisedButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                          _openAndRead(state, context, item, useNative: true);
                        },
                        child: Text(StrsHome.openWithNative()),
                      ),
                    ),
                    SizedBox(
                      width: 12.px2Dp,
                    ),
                    Expanded(
                      flex: 1,
                      child: RaisedButton(
                        onPressed: () async {
                          if (Platform.isAndroid) {
                            //{'isSuccess':false,'path':'','reason':''}
                            Map<String, dynamic> map = await TransBridgeChannel
                                .getExportExternalPath();
                            if (map['isSuccess'] ?? false == true) {
                              String rootDir = map['path'];
                              Map<String, dynamic> result =
                                  await FileHelper.exportFile(
                                      item[ReadingRecordConst.FILE_PATH],
                                      rootDir);
                              println(rootDir);
                              println(result);
                              if (result['exported'] ?? false == true) {
                                Navigator.pop(context);
                                _exportSuccess(
                                    context, result['exportAbsolutePath']);
                              } else {
                                TransBridgeChannel.showToast(result['reason'] ??
                                    'Export fail,unknown err!');
                                Navigator.pop(context);
                              }
                            } else {
                              TransBridgeChannel.showToast(
                                  map['reason'] ?? 'Export fail,unknown err!');
                              Navigator.pop(context);
                            }
                          } else {
                            Navigator.pop(context);
                            TransBridgeChannel.showToast(StrsHome.notSupport());
                          }
                        },
                        child: Text(StrsHome.export()),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      });
}

///导出文件成功的提示
_exportSuccess(BuildContext context, String newFilePath) {
  showDialog(
      context: context,
      builder: (_) {
        return Center(
          child: Container(
            width: double.infinity,
            decoration: CommonDecoration.commonRoundDecoration(),
            margin: EdgeInsets.all(30.px2Dp),
            padding: EdgeInsets.all(20.px2Dp),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  "${StrsHome.exportSuccess()}$newFilePath",
                  style: AppTvStyles.textStyle16ColorMain(),
                  textAlign: TextAlign.left,
                ),
                SizedBox(
                  height: 20.px2Dp,
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: RaisedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                        },
                        child: Text(StrsHome.iKnow()),
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

///展示删除提示
_showDeleteHint(HomeState state, BuildContext context,
    final Map<String, dynamic> item, final int index, Dispatch dispatch) {
  showDialog(
      context: context,
      builder: (_) {
        return Center(
          child: Container(
            width: double.infinity,
            decoration: CommonDecoration.commonRoundDecoration(),
            margin: EdgeInsets.all(30.px2Dp),
            padding: EdgeInsets.all(20.px2Dp),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  "${StrsManageRepo.deleteConfirm()}${item[ReadingRecordConst.FILE_PATH]}？",
                  style: AppTvStyles.textStyle16ColorMain(),
                  textAlign: TextAlign.left,
                ),
                SizedBox(
                  height: 20.px2Dp,
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: RaisedButton(
                        onPressed: () async {
                          Navigator.pop(
                              context,
                              await WReaderSqlHelper
                                  .deleteSpecificReadingRecord({
                                ReadingRecordConst.FILE_PATH:
                                    item[ReadingRecordConst.FILE_PATH]
                              }));
                        },
                        child: Text(StrsManageRepo.delete()),
                      ),
                    ),
                    SizedBox(
                      width: 30.px2Dp,
                    ),
                    Expanded(
                      flex: 1,
                      child: RaisedButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        child: Text(StrsManageRepo.cancel()),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      }).then((_) {
    if (_ != null && _) {
      _triggerRefresh(dispatch);
    }
  });
}

_triggerRefresh(Dispatch dispatch) {
  dispatch(HomeActionCreator.showRefresh());
  dispatch(HomeActionCreator.doRefresh());
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

///打开最近阅读记录的文件
_openAndRead(HomeState state, BuildContext context, Map<String, dynamic> item,
    {bool useNative = false}) {
  showLoadingAndRead(
      context,
      item[ReadingRecordConst.FILE_PATH],
      item[ReadingRecordConst.OWNER_GIT_URI],
      item[ReadingRecordConst.OWNER_GIT_BRANCH],
      item[ReadingRecordConst.OWNER_REPO_LOCAL_DIR],
      item[ReadingRecordConst.BIZ_FILE_TYPE],
      useNative: useNative);
}

///展示引导动画布局
Widget _showGuid(state, context) {
  println("_showGuid");
  return Container(
    width: double.infinity,
    child: Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Container(
          margin: EdgeInsets.all(20.px2Dp),
          width: double.infinity,
          height: 90.px2Dp,
          child: FlatButton(
            child: Text(
              StrsHome.closeGuid(),
              style: AppTvStyles.textStyle18Color66(true),
            ),
            onPressed: () {
              _confNewRepoPage(state, context);
            },
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            height: double.infinity,
            color: Colors.transparent,
            padding: EdgeInsets.only(
                left: 20.px2Dp, right: 20.px2Dp, bottom: 20.px2Dp),
            width: double.infinity,
            child: Image.asset(
              'assets/images/gif_clone_guid.gif',
              fit: BoxFit.contain,
            ),
          ),
        )
      ],
    ),
  );
}

///展示 loading 页面
Widget _showLoading(context) {
  var length = MediaQuery.of(context).size.width / 6;
  return Container(
    child: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: length,
            height: length,
            child: CircularProgressIndicator(
              value: null,
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          SizedBox(
            height: 20.px2Dp,
          ),
          Text(
            StrsHome.loadingHint(),
            style: AppTvStyles.textStyle14ColorWhite(),
          ),
        ],
      ),
    ),
  );
}

///构建 appBar
Widget _appBar(HomeState state, BuildContext context) {
  return EzAppBar.buildCenterTitleAppBar(StrsHome.title(), context,
      showBack: true,
      leading: SizedBox(
        height: 98.px2Dp,
        child: EzSelector(
          Padding(
            padding: EdgeInsets.only(left: 10.px2Dp, right: 10.px2Dp),
            child: Center(
              child: Image.asset(
                'assets/images/icon_more.png',
                width: 42.px2Dp,
                height: 42.px2Dp,
              ),
            ),
          ),
          () {
            _expandSections(state, context);
          },
          defaultColor: Colors.transparent,
          pressColor: AppColors.COLOR_TRANS_20,
        ),
      ),
      actions: _obtainActions(state, context));
}

///根据查询到的内容,显示文本
List<Widget> _obtainActions(HomeState state, BuildContext context) {
  List<Widget> list = List<Widget>();
  if (state.readingRecord.isNotEmpty) {
    list.add(SizedBox(
      height: 98.px2Dp,
      child: EzSelector(
        Padding(
          padding: EdgeInsets.only(left: 14.px2Dp, right: 14.px2Dp),
          child: Image.asset(
            'assets/images/icon_search.png',
            width: 36.px2Dp,
            height: 36.px2Dp,
          ),
        ),
        () {
          _search(state, context);
        },
        defaultColor: Colors.transparent,
        pressColor: AppColors.COLOR_TRANS_20,
      ),
    ));
  }
  list.add(SizedBox(
    height: 98.px2Dp,
    child: EzSelector(
      Padding(
        padding: EdgeInsets.only(left: 14.px2Dp, right: 14.px2Dp),
        child: Image.asset(
          'assets/images/icon_add_new.png',
          width: 36.px2Dp,
          height: 36.px2Dp,
        ),
      ),
      () {
        _confNewRepoPage(state, context);
      },
      defaultColor: Colors.transparent,
      pressColor: AppColors.COLOR_TRANS_20,
    ),
  ));
  if (state.repoList.isNotEmpty) {
    list.add(SizedBox(
      height: 98.px2Dp,
      child: EzSelector(
        Padding(
          padding: EdgeInsets.only(left: 14.px2Dp, right: 14.px2Dp),
          child: Image.asset(
            'assets/images/icon_repo_list.png',
            width: 36.px2Dp,
            height: 36.px2Dp,
          ),
        ),
        () {
          _toRepoListPage(state, context);
        },
        defaultColor: Colors.transparent,
        pressColor: AppColors.COLOR_TRANS_20,
      ),
    ));
  }
  return list;
}

///展开HomeDrawer
_expandSections(HomeState state, BuildContext context) {
  if (state.isInit) {
    FluroRouter.navigateTo(context, RouteNames.SETTING);
  }
}

///clone新的仓库
_confNewRepoPage(HomeState state, BuildContext context) {
  if (state.isInit) {
    FluroRouter.navigateTo(context, RouteNames.REPO_CONF);
  }
}

///去查看仓库列表
_search(HomeState state, BuildContext context) {
  if (state.isInit) {
    FluroRouter.navigateTo(context, RouteNames.SEARCH_READING_RECORD);
  }
}

///去查看仓库列表
_toRepoListPage(HomeState state, BuildContext context) {
  if (state.isInit) {
    if (state.repoList.isEmpty) {
      FluroRouter.navigateTo(context, RouteNames.REPO_CONF);
    } else {
      FluroRouter.navigateTo(context, RouteNames.REPO_LIST);
    }
  }
}
