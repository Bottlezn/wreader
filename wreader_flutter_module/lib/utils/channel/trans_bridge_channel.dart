import 'dart:collection';

import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/services.dart';
import 'package:wreader_flutter_module/consts/channel_about.dart';
import 'package:wreader_flutter_module/consts/file_type.dart';
import 'package:wreader_flutter_module/db/sqlite_helper.dart';
import 'package:wreader_flutter_module/page/main/state.dart';
import 'package:wreader_flutter_module/utils/common/json_util.dart';

///与原生交互的channel文件
class TransBridgeChannel {
  static const MethodChannel CHANNEL = MethodChannel(CHANNEL_TRANS_BRIDGE);

  ///直接clone，不需要鉴权
  static Future<String> cloneDirect(String gitUrl, String localPath,
      [String repoName]) async {
    return await CHANNEL.invokeMethod<String>(ChannelOutMethod.CLONE_DIRECT,
        JsonUtil.encode(_wrapCommonMap(gitUrl, localPath, repoName)));
  }

  ///{'isSuccess':false,'path':'','reason':''}
  static Future<Map<String, dynamic>> getExportExternalPath() async {
    return JsonUtil.decode(
        await CHANNEL.invokeMethod(ChannelOutMethod.GET_EXPORT_EXTERNAL_PATH));
  }

  ///获取所有 tag ,data class AllTagResult(val result: String, val allTagList: List<String>?)
  static Future<String> getTagList(String gitRepoLocalDir) async {
    return await CHANNEL.invokeMethod<String>(ChannelOutMethod.GET_TAG_LIST,
        JsonUtil.encode({'gitRepoLocalDir': gitRepoLocalDir}));
  }

  ///获取所有分支信息
  static Future<String> getAllBranch(String gitRepoLocalDir) async {
    return await CHANNEL.invokeMethod<String>(ChannelOutMethod.GET_ALL_BRANCH,
        JsonUtil.encode({'gitRepoLocalDir': gitRepoLocalDir}));
  }

  ///通过账号密码鉴权来clone项目
  ///String gitUrl, String localPath，String repoName,String account,String pwd
  static Future<String> cloneUseAccountAndPwd(
      String gitUrl, String localPath, String account, String pwd,
      {String repoName}) async {
    Map<String, dynamic> map = _wrapCommonMap(gitUrl, localPath, repoName);
    map['account'] = account;
    map['pwd'] = pwd;
    return await CHANNEL.invokeMethod<String>(
        ChannelOutMethod.CLONE_USE_ACCOUNT_AND_PWD, JsonUtil.encode(map));
  }

  ///通过RSA密钥对鉴权，clone项目
  ///String gitUrl, String localPath，String repoName,String priKey,String pubKey,String priKeyPass
  static Future<String> cloneUseKeyPair(
      String gitUrl, String localPath, String priKey, String pubKey,
      {String repoName, String priKeyPass}) async {
    Map<String, dynamic> map = _wrapCommonMap(gitUrl, localPath, repoName);
    map['priKey'] = priKey;
    map['pubKey'] = pubKey;
    map['priKeyPass'] = priKeyPass ?? '';
    return await CHANNEL.invokeMethod<String>(
        ChannelOutMethod.CLONE_USE_KEY_PAIR, JsonUtil.encode(map));
  }

  static Map<String, dynamic> _wrapCommonMap(String gitUri, String localPath,
      [String repoName]) {
    Map<String, dynamic> map = HashMap<String, dynamic>();
    map['gitUrl'] = gitUri;
    map['localPath'] = localPath;
    if (repoName == null || repoName.isEmpty) {
      repoName = gitUri.substring(
          gitUri.lastIndexOf('/') + 1, gitUri.lastIndexOf('.'));
    }
    map['repoName'] = repoName;
    return map;
  }

  ///检查git仓库是否存在
  static Future<String> checkGitExists(String gitUrl, String localPath,
      [String repoName]) async {
    return await CHANNEL.invokeMethod<String>(ChannelOutMethod.CHECK_GIT_EXISTS,
        JsonUtil.encode(_wrapCommonMap(gitUrl, localPath, repoName)));
  }

  static Future<String> showToast(String content, [int duration = 0]) async {
    Map<String, dynamic> map = HashMap<String, dynamic>();
    map['content'] = content;
    map['duration'] = duration;
    return await CHANNEL.invokeMethod<String>(
        ChannelOutMethod.SHOW_TOAST, JsonUtil.encode(map));
  }

  ///从Android设备上选择一个json内容的文件来解析git仓库配置
  static Future<String> getGitConfFile() async =>
      await CHANNEL.invokeMethod(ChannelOutMethod.GET_GIT_REPO_CONFIG_FILE);

  ///reset分支
  static Future<String> reset(
      String branchFullName, Map<String, dynamic> repoDetails) async {
    Map<String, dynamic> map = HashMap<String, dynamic>();
    map['repoDetails'] = repoDetails;
    return await CHANNEL.invokeMethod<String>(
        ChannelOutMethod.RESET, JsonUtil.encode(map));
  }

  ///pull代码
  static Future<String> pull(Map<String, dynamic> repoDetails) async {
    Map<String, dynamic> map = HashMap<String, dynamic>();
    map['repoDetails'] = repoDetails;
    return await CHANNEL.invokeMethod<String>(
        ChannelOutMethod.PULL, JsonUtil.encode(map));
  }

  ///pull代码
  static Future<String> fetch(Map<String, dynamic> repoDetails) async {
    Map<String, dynamic> map = HashMap<String, dynamic>();
    map['repoDetails'] = repoDetails;
    return await CHANNEL.invokeMethod<String>(
        ChannelOutMethod.FETCH, JsonUtil.encode(map));
  }

  ///切换分支，需要将用户选择的分支和当前仓库详情信息传递给native进行处理
  static Future<String> switchNewBranch(
      String branchFullName, Map<String, dynamic> repoDetails) async {
    Map<String, dynamic> map = HashMap<String, dynamic>();
    map['branchFullName'] = branchFullName;
    map['repoDetails'] = repoDetails;
    return await CHANNEL.invokeMethod<String>(
        ChannelOutMethod.SWITCH_NEW_BRANCH, JsonUtil.encode(map));
  }

  ///切换已有的
  static Future<String> switchExistedBranch(
      String branchFullName, Map<String, dynamic> repoDetails) async {
    Map<String, dynamic> map = HashMap<String, dynamic>();
    map['branchFullName'] = branchFullName;
    map['repoDetails'] = repoDetails;
    return await CHANNEL.invokeMethod<String>(
        ChannelOutMethod.SWITCH_EXISTED_BRANCH, JsonUtil.encode(map));
  }

  ///检出 tag
  static Future<String> checkoutTag(
      String fullTagName, Map<String, dynamic> repoDetails) async {
    Map<String, dynamic> map = HashMap<String, dynamic>();
    map['fullTagName'] = fullTagName;
    map['repoDetails'] = repoDetails;
    return await CHANNEL.invokeMethod<String>(
        ChannelOutMethod.CHECK_OUT_TAG, JsonUtil.encode(map));
  }

  ///使用 Native 浏览器打开 URL
  static openUrl(String url) {
    CHANNEL.invokeMethod<String>(ChannelOutMethod.OPEN_URL, url);
  }

  ///阅读md文件
  static Future<String> readMdFile(String mdFilePath) async {
    println("mdFilePath = $mdFilePath");
    Map<String, dynamic> map = {
      'filePath': mdFilePath,
      'fileType': FileTypeConst.MD_FILE,
      'brightnessMode': MainState.globalBrightnessMode == -1
          ? EnvironmentConst.MODE_LIGHT
          : MainState.globalBrightnessMode,
    };
    return await CHANNEL.invokeMethod(
        ChannelOutMethod.READ_MD_FILE, JsonUtil.encode(map));
  }

  ///浏览代码文件
  static Future<String> readCodeFile(String codeFile) async {
    println("codeFile = $codeFile");
    Map<String, dynamic> map = {
      'filePath': codeFile,
      'fileType': FileTypeConst.CODE,
      'brightnessMode': MainState.globalBrightnessMode == -1
          ? EnvironmentConst.MODE_LIGHT
          : MainState.globalBrightnessMode,
    };
    return await CHANNEL.invokeMethod(
        ChannelOutMethod.READ_CODE_FILE, JsonUtil.encode(map));
  }

  ///浏览图片
  static Future<String> browseImage(String imageFilePath) async {
    println("imageFilePath = $imageFilePath");
    Map<String, dynamic> map = {
      'filePath': imageFilePath,
      'fileType': FileTypeConst.IMAGE,
      'brightnessMode': MainState.globalBrightnessMode == -1
          ? EnvironmentConst.MODE_LIGHT
          : MainState.globalBrightnessMode,
    };
    return await CHANNEL.invokeMethod(
        ChannelOutMethod.BROWSE_IMAGE, JsonUtil.encode(map));
  }

  ///使用其他App打开文件
  static Future<String> openFileUseOtherApp(String imageFilePath) async {
    println("imageFilePath = $imageFilePath");
    Map<String, dynamic> map = {
      'filePath': imageFilePath,
      'fileType': FileTypeConst.IMAGE,
      'brightnessMode': MainState.globalBrightnessMode == -1
          ? EnvironmentConst.MODE_LIGHT
          : MainState.globalBrightnessMode,
    };
    return await CHANNEL.invokeMethod(
        ChannelOutMethod.OPEN_FILE_USE_OTHER_APP, JsonUtil.encode(map));
  }

  ///删除clone失败的仓库
  static Future<String> clearInvalidRepo() async {
    return await CHANNEL.invokeMethod(ChannelOutMethod.CLEAR_INVALID_REPO);
  }

  ///删除特定的仓库
  static Future<String> clearSpecifiedRepo(List<String> specifiedList) async {
    if (specifiedList == null || specifiedList.isEmpty) {
      return Future.value('Illegal arguments.');
    }
    return await CHANNEL.invokeMethod(ChannelOutMethod.CLEAR_SPECIFIED_REPO,
        JsonUtil.encode({'list': specifiedList}));
  }

  static Future<String> gotoHome() async {
    return await CHANNEL.invokeMethod(ChannelOutMethod.GOTO_HOME);
  }

  static Future<String> exitApp() async {
    return await CHANNEL.invokeMethod(ChannelOutMethod.EXIT_APP);
  }

  ///val versionName:String,val versionCode:Long
  ///["versionName":"1.1","versionCode":1]
  static Future<Map<String, dynamic>> getVersionInfo() async {
    return JsonUtil.decode(
        await CHANNEL.invokeMethod(ChannelOutMethod.GET_VERSION_INFO));
  }

  ///捕获异常。报告到Native端
  static Future<dynamic> reportErrorToNative(String error, String stack) async {
    return await CHANNEL.invokeMethod(
        ChannelOutMethod.REPORT_FLUTTER_ERROR,
        JsonUtil.encode({
          'error': error,
          'stack': stack,
        }));
  }

  ///切换语言环境
  static Future<dynamic> switchLanguage() async {
    return await CHANNEL.invokeMethod(
        ChannelOutMethod.SWITCH_LANGUAGE, MainState.globalLanguageCode);
  }

  ///获取日志存放目录，返回一个字符串数组，有可能是2个目录
  ///["",""]
  static Future<String> getLogDir() async {
    return await CHANNEL.invokeMethod(ChannelOutMethod.GET_LOG_DIR);
  }
}
