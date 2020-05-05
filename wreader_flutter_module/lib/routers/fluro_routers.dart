import 'package:fish_redux/fish_redux.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:wreader_flutter_module/page/about/about_me.dart';
import 'package:wreader_flutter_module/page/home/host/page.dart';
import 'package:wreader_flutter_module/page/home/search_reading/page.dart';
import 'package:wreader_flutter_module/page/log_list_page/log_list_page.dart';
import 'package:wreader_flutter_module/page/manage_repo/page.dart';
import 'package:wreader_flutter_module/page/repo_conf/page_repo_conf.dart';
import 'package:wreader_flutter_module/page/repo_details/page.dart';
import 'package:wreader_flutter_module/page/repo_details/search_file/page.dart';
import 'package:wreader_flutter_module/page/repo_list/repo_list.dart';
import 'package:wreader_flutter_module/page/setting/setting_page.dart';

///Flutter的Router管理参考文章
///- [flutter路由跳转fluro](https://blog.csdn.net/huchengzhiqiang/article/details/91415777)
///- [Flutter中管理路由栈的方法和应用](https://www.jianshu.com/p/5df089d360e4)
///- [Flutter入门之（fluro路由跳转框架)](https://www.jianshu.com/p/1987cc9b714a)

/// home 页面
var homeHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> parameters) {
  bool openDrawer = false;
  if (parameters['openDrawer'] != null && parameters['openDrawer'].isNotEmpty) {
    println(parameters['openDrawer']);
    try {
      openDrawer = '1' == "${parameters['openDrawer'].first}";
    } catch (e) {
      println(e);
    }
  }
  return HomePage().buildPage({'openDrawer': openDrawer ?? false});
});

///关于页面
var aboutHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> parameters) {
  return AboutMePage();
});

/// 搜索最近阅读记录
var searchReadingRecordHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> parameters) {
  return SearchReadingRecordPage().buildPage(null);
});

/// 搜索仓库文件
var searchRepoFileHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> parameters) {
  return SearchRepoFilePage().buildPage(null);
});

///管理仓库页面
var manageRepoHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> parameters) {
  return ManageGitRepoPage().buildPage(null);
});

///仓库配置页面
var repoConfHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> parameters) {
  return RepoConfPage();
});

///仓库列表页面
var repoListHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> parameters) {
  return RepoListPage();
});

///仓库列表页面
var settingPage = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> parameters) {
  return SettingPage();
});

///日志列表页面
var logListHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> parameters) {
  return LogListPage();
});

var repoDetailsHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> parameters) {
  return RepoDetailsPage().buildPage({
    'gitLocalDir': parameters['gitLocalDir'].first,
    'gitUri': parameters['gitUri'].first,
  });
});

///使用该类的[router]对象来跳转
class Application {
  static Router router;

  static configRouter() {
    router = Router();
    router.define(RouteNames.HOME, handler: homeHandler);
    router.define(RouteNames.REPO_CONF, handler: repoConfHandler);
    router.define(RouteNames.REPO_DETAILS, handler: repoDetailsHandler);
    router.define(RouteNames.REPO_LIST, handler: repoListHandler);
    router.define(RouteNames.MANAGE_REPO, handler: manageRepoHandler);
    router.define(RouteNames.ABOUT, handler: aboutHandler);
    router.define(RouteNames.LOG_LIST, handler: logListHandler);
    router.define(RouteNames.SEARCH_READING_RECORD,
        handler: searchReadingRecordHandler);
    router.define(RouteNames.SEARCH_REPO_FILE, handler: searchRepoFileHandler);
    router.define(RouteNames.SETTING, handler: settingPage);
  }
}

///使用Fluro作为跳转路由，替换一系列push操作，pop操作还是继续使用[Navigator]类
class FluroRouter {
  ///导航到指定path的页面，本module强制使用[RouteNames]的常量
  ///[replace]：为true时会置换掉当前页面，例如栈底是Home页面，栈顶是A页面，A打开B，
  ///此时replace为ture，那么A页面打开B页面之后，A页面会被置换掉。栈顶变成了B，栈底仍然是Home
  ///[clearStack]：为true时打开一个新页面，并且将之前栈底的页面全部清空
  ///[transition]页面切换动画，[TransitionType]类中提供了默认的几点
  ///[transitionDuration]页面切换动画耗时
  ///[transitionBuilder]自定义的切换动画
  static Future<dynamic> navigateTo(BuildContext context, String path,
      {bool replace = false,
      bool clearStack = false,
      TransitionType transition = TransitionType.fadeIn,
      Duration transitionDuration = const Duration(milliseconds: 150),
      RouteTransitionsBuilder transitionBuilder}) {
    return Application.router.navigateTo(context, path,
        replace: replace,
        clearStack: clearStack,
        transition: transition,
        transitionDuration: transitionDuration,
        transitionBuilder: transitionBuilder);
  }
}

///当前flutter module的所有page name的常量
class RouteNames {
  ///flutter module的首页
  static const HOME = '/home';

  ///仓库配置页面
  static const REPO_CONF = '/page/repoConf';

  ///仓库详情页面
  static const REPO_DETAILS = '/page/repoDetails';

  ///本地仓库列表页面
  static const REPO_LIST = '/page/repoList';

  ///管理仓库页面，目前功能就是删除
  static const MANAGE_REPO = '/page/manageRepo';

  ///鉴权信息页面
  static const AUTHEN_LIST = '';

  ///异常日志页面
  static const LOG_LIST = '/page/logList';

  ///关于页面
  static const ABOUT = '/page/about';

  ///搜索最近阅读记录
  static const SEARCH_READING_RECORD = '/page/searchReadingRecord';

  ///搜索仓库中的文件
  static const SEARCH_REPO_FILE = '/page/searchRepoFile';

  /// 设置页面
  static const SETTING = '/page/setting';
}
