import 'dart:async';
import 'dart:io';

import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart';
import 'package:wreader_flutter_module/consts/file_type.dart';
import 'package:wreader_flutter_module/db/sqlite_helper.dart';
import 'package:wreader_flutter_module/utils/channel/trans_bridge_channel.dart';
import 'package:wreader_flutter_module/utils/size/size_util.dart';
import 'package:wreader_flutter_module/values/app_colors.dart';
import 'package:wreader_flutter_module/values/app_strings.dart';
import 'package:wreader_flutter_module/widget/common_decoration.dart';

///插入阅读记录，并且打开文件
showLoadingAndRead(BuildContext context, String fileAbsolutePath, String gitUri,
    String currentBranch, String gitTargetDir, String bizFileType,
    {bool record = true, bool useNative = false}) async {
  showDialog(
      context: context,
      builder: (context) {
        return WillPopScope(
            child: Center(
              child: Container(
                margin: EdgeInsets.only(left: 30.px2Dp, right: 30.px2Dp),
                padding: EdgeInsets.all(30.px2Dp),
                decoration: CommonDecoration.commonRoundDecoration(),
                child: SizedBox(
                  width: 120.px2Dp,
                  height: 120.px2Dp,
                  child: CircularProgressIndicator(
                    value: null,
                    backgroundColor: AppColors.COLOR_MAIN,
                    valueColor: AlwaysStoppedAnimation(AppColors.COLOR_6E),
                  ),
                ),
              ),
            ),
            onWillPop: () {
              return Future.value(false);
            });
      });
  Timer(Duration(milliseconds: 100), () {
    Navigator.of(context).pop();
  });
  if (record) {
    await _updateReadingRecord(
        fileAbsolutePath, gitUri, currentBranch, gitTargetDir, bizFileType);
  }
  if (useNative) {
    String result =
        await TransBridgeChannel.openFileUseOtherApp(fileAbsolutePath);
    if ('success' != result) {
      TransBridgeChannel.showToast("${StrsToast.openFileFail()}：$result");
    }
    return;
  }
  switch (bizFileType) {
    case FileTypeConst.MD_FILE:
      await TransBridgeChannel.readMdFile(fileAbsolutePath);
      break;
    case FileTypeConst.IMAGE:
      await TransBridgeChannel.browseImage(fileAbsolutePath);
      break;
    case FileTypeConst.CODE:
      await TransBridgeChannel.readCodeFile(fileAbsolutePath);
      break;
    default:
      String result =
          await TransBridgeChannel.openFileUseOtherApp(fileAbsolutePath);
      if ('success' != result) {
        TransBridgeChannel.showToast("${StrsToast.openFileFail()}：$result");
      }
      break;
  }
}

_updateReadingRecord(String fileAbsolutePath, String gitUri,
    String currentBranch, String gitTargetDir, String bizFileType) async {
  var file = File(fileAbsolutePath);
  String cached;
  if (bizFileType == FileTypeConst.MD_FILE ||
      bizFileType == FileTypeConst.CODE ||
      bizFileType == FileTypeConst.OTHER_TEXT) {
    //如果是文本类型，使用文本作为缓存
    cached = (await file.readAsString());

    ///拿50个字符作为预览
    if (cached.length > 50) {
      cached.substring(0, 50);
    }
  }

  //将记录存放到最近阅读中
  bool result = await WReaderSqlHelper.insertOrUpdateReadingRecord(
      fileAbsolutePath,
      gitUri,
      gitTargetDir,
      currentBranch,
      cached,
      bizFileType);
  println("$fileAbsolutePath插入结果：$result");
}
