import 'dart:io';

import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:intl/intl.dart';
import 'package:wreader_flutter_module/bean/file_info.dart';
import 'package:wreader_flutter_module/bean/repo_details_bean.dart';
import 'package:wreader_flutter_module/page/main/state.dart';
import 'package:wreader_flutter_module/utils/channel/trans_bridge_channel.dart';
import 'package:wreader_flutter_module/utils/common/file_helper.dart';
import 'package:wreader_flutter_module/utils/common/file_type_helper.dart';
import 'package:wreader_flutter_module/utils/reading/reading.dart';
import 'package:wreader_flutter_module/utils/size/size_util.dart';
import 'package:wreader_flutter_module/values/app_colors.dart';
import 'package:wreader_flutter_module/values/app_strings.dart';
import 'package:wreader_flutter_module/widget/common_decoration.dart';
import 'package:wreader_flutter_module/widget/common_styles.dart';
import 'package:wreader_flutter_module/widget/ez_selector.dart';

/// Created on 2020/5/4.
/// @author 悟笃笃
/// description:

typedef OnFilePress = Function(
    FileInfo info,
    RepoDetailsBean repoDetailsBean,
    Dispatch dispatch,
    ViewService viewService,
    BuildContext context,
    int index);

/// 封装 repo 页面 查询与现实统一 UI 构建函数
class RepoFileHelper {
  static buildInfoItem(
      FileInfo info,
      RepoDetailsBean repoDetailsBean,
      Dispatch dispatch,
      ViewService viewService,
      BuildContext context,
      int index,
      OnFilePress onFilePress,
      {OnFilePress onFileLongPress}) {
    return EzSelector(
      Container(
        width: SizeUtil.deviceWidth,
        padding: EdgeInsets.all(10.px2Dp),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 6.px2Dp),
              child: _buildIcon(info),
            ),
            SizedBox(
              width: 4.px2Dp,
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    info.isDir ? _buildDirType(info) : _buildFileType(info),
              ),
            )
          ],
        ),
      ),
      () {
        onFilePress(
            info, repoDetailsBean, dispatch, viewService, context, index);
      },
      defaultColor: AppColors.commonIdleColor(context),
      pressColor: AppColors.commonPressColor(context),
      onLongCallback: () {
        _onLongPress(
            info, repoDetailsBean, dispatch, viewService, context, index);
      },
      key: Key("${info.absoultPath}${MainState.globalBrightnessMode}"),
    );
  }

  static _onLongPress(FileInfo info, RepoDetailsBean repo, Dispatch dispatch,
      ViewService viewService, BuildContext context, int index) {
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
                      "${StrsHome.moreOperate()}\n",
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
                          onPressed: () {
                            Navigator.pop(context, false);
                            _openAndRead(info, repo, context);
                          },
                          child: Text(StrsHome.openWithNative()),
                        ),
                      ),
                      SizedBox(
                        width: 30.px2Dp,
                      ),
                      Expanded(
                        flex: 1,
                        child: RaisedButton(
                          onPressed: () async {
                            if (Platform.isAndroid) {
                              //{'isSuccess':false,'path':'','reason':''}
                              Map<String, dynamic> map =
                                  await TransBridgeChannel
                                      .getExportExternalPath();
                              if (map['isSuccess'] ?? false == true) {
                                String rootDir = map['path'];
                                Map<String, dynamic> result =
                                    await FileHelper.exportFile(
                                        info.absoultPath, rootDir);
                                println(rootDir);
                                println(result);
                                if (result['exported'] ?? false == true) {
                                  Navigator.pop(context);
                                  _exportSuccess(
                                      context, result['exportAbsolutePath']);
                                } else {
                                  TransBridgeChannel.showToast(
                                      result['reason'] ??
                                          'Export fail,unknown err!');
                                  Navigator.pop(context);
                                }
                              } else {
                                TransBridgeChannel.showToast(map['reason'] ??
                                    'Export fail,unknown err!');
                                Navigator.pop(context);
                              }
                            } else {
                              Navigator.pop(context);
                              TransBridgeChannel.showToast(
                                  StrsHome.notSupport());
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
  static _exportSuccess(BuildContext context, String newFilePath) {
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

  ///打开最近阅读记录的文件
  static _openAndRead(
    FileInfo info,
    RepoDetailsBean repoDetailsBean,
    BuildContext context,
  ) {
    showLoadingAndRead(
        context,
        info.absoultPath,
        repoDetailsBean.gitUri,
        repoDetailsBean.currentBranch,
        repoDetailsBean.targetDir,
        FileTypeHelper.getBizType(info.absoultPath),
        useNative: true);
  }

  static _buildDirType(FileInfo info) {
    return <Widget>[
      Text(
        info.fileName ?? '--',
        style: AppTvStyles.textStyle16Color63(),
      ),
      SizedBox(height: 6.px2Dp),
      Text(
        "itemCount：${info.itemConut ?? 0}",
        style: AppTvStyles.textStyle12Color66(),
      ),
      SizedBox(height: 4.px2Dp),
      Text(
        "${_formatTime(info.modifiedDateTime)}",
        style: AppTvStyles.textStyle12Color66(),
      ),
    ];
  }

  static var _format = DateFormat('MM-dd HH:mm:ss');

  static String _formatTime(DateTime time) {
    return _format.format(time ?? DateTime.now());
  }

  static String _fileSizeStr(int size) {
    if (size == 0) {
      return '0bytes';
    }
    double sizeValue;
    if (size < 1024) {
      return "${size}bytes";
    } else if ((sizeValue = size / 1024 / 1024) > 1) {
      return "${_formatNum(sizeValue, 2)}MB";
    } else if ((sizeValue = size / 1024) > 1) {
      return "${_formatNum(sizeValue, 2)}KB";
    } else {
      return "${size}bytes";
    }
  }

  static _buildFileType(FileInfo info) {
    return <Widget>[
      Text(
        info.fileName ?? '--',
        style: AppTvStyles.textStyle16Color63(),
      ),
      SizedBox(height: 6.px2Dp),
      Text(
        "fileSize：${_fileSizeStr(info.fileSize) ?? 0}",
        style: AppTvStyles.textStyle12Color66(),
      ),
      SizedBox(height: 4.px2Dp),
      Text(
        "${_formatTime(info.modifiedDateTime)}",
        style: AppTvStyles.textStyle12Color66(),
      ),
    ];
  }

  ///copy自[Dart 取两位小数 不要四舍五入的方法](https://blog.csdn.net/u013095264/article/details/103056322)
  static _formatNum(double num, int position) {
    if ((num.toString().length - num.toString().lastIndexOf(".") - 1) <
        position) {
      //小数点后有几位小数
      return num.toStringAsFixed(position)
          .substring(0, num.toString().lastIndexOf(".") + position + 1)
          .toString();
    } else {
      return num.toString()
          .substring(0, num.toString().lastIndexOf(".") + position + 1)
          .toString();
    }
  }

  ///感谢 https://www.iconfont.cn/
  static _buildIcon(FileInfo info) {
    String imageSrc;
    if (info.isDir) {
      imageSrc = 'assets/images/icon_folder.png';
    } else if (FileTypeHelper.isMarkdown(info.fileType)) {
      imageSrc = 'assets/images/icon_md_file.png';
    } else if (FileTypeHelper.isImage(info.fileType)) {
      imageSrc = 'assets/images/icon_image_file.png';
    } else if (FileTypeHelper.isCode(info.fileType)) {
      imageSrc = 'assets/images/icon_code_file.png';
    } else {
      imageSrc = 'assets/images/icon_unknown_file.png';
    }
    return Image.asset(
      imageSrc,
      width: 64.px2Dp,
      height: 64.px2Dp,
    );
  }
}
