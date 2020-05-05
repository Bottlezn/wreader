import 'dart:async';
import 'dart:collection';

import 'package:fish_redux/fish_redux.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wreader_flutter_module/bean/repo_preview_item.dart';
import 'package:wreader_flutter_module/consts/language_code_const.dart';
import 'package:wreader_flutter_module/utils/common/file_helper.dart';
import 'package:wreader_flutter_module/utils/common/string_utils.dart';

///收藏记录table常量
///暂时不用
class CollectingRecord {
  static const NAME = 'collecting_record';
  static const ID = '_id';
  static const COLLECTED_TIMESTAMP = 'collected_timestamp';
  static const OWNER_REPO_ID = 'owner_repo_id';
  static const OWNER_REPO_NAME = 'owner_repo_name';

  ///是否存在，因为没有uniqueKey，只能以绝对路径来对应文件，如果发生了重命名、删除甚至文件替换都无法保证
  /// ///特别是切换分支时，这种情况经常发生，所以弄一个字段来管理
  static const IS_EXISTS = 'is_exists';
}

///环境配置表，可以配置亮暗模式常量值、语言环境等
class EnvironmentConst {
  static const TABLE_NAME = 'environment';
  static const BRIGHTNESS_MODE = 'brightness_mode';
  static const LANGUAGE_CODE = 'language_code';
  static const SHOW_EXIT_HINT = 'show_exit_hint';

  /// 个性文本显示的文本，最多16个文字，最多显示2行，不许输入换行符哦
  static const MY_WORD = 'my_word';
  static const DEFAULT_MY_WORD = '空想无益，躬行笃履';
  static const MODE_LIGHT = 0;
  static const MODE_DARK = 1;
  static const SHOW_HINT = 0;
  static const NEVER_SHOW_HINT = 1;
}

///阅读记录table常量
///因为文章会变化，这里以文件路径[FILE_PATH]作为打开文章key
class ReadingRecordConst {
  static const TABLE_NAME = 'reading_record';
  static const ID = '_id';

  ///本文章的阅读次数
  static const READING_TIME = 'reading_time';

  ///在首页展示时的缓存数据
  static const READING_CACHED = 'reading_cached';

  ///文件的绝对路径
  static const FILE_PATH = 'file_path';

  ///文件名称，包括后缀
  static const FILE_NAME = 'file_name';

  ///文件的真实后缀名称
  static const REAL_FILE_TYPE = 'real_file_type';

  ///用与业务处理的后缀分类，是大类型的归类
  static const BIZ_FILE_TYPE = 'biz_file_type';

  ///所属仓库的name
  static const OWNER_REPO_LOCAL_DIR = 'owner_repo_local_dir';

  ///所属仓库的uri
  static const OWNER_GIT_URI = 'owner_git_uri';

  ///所属仓库的当前分支
  static const OWNER_GIT_BRANCH = 'owner_git_branch';

  ///文章首次阅读的时间戳
  static const CREATE_TIMESTAMP = 'create_timestamp';

  ///文章下次阅读的更新时间
  static const UPDATE_TIMESTAMP = 'update_timestamp';

  ///是否存在，因为没有uniqueKey，只能以绝对路径来对应文件，如果发生了重命名、删除甚至文件替换都无法保证
  ///特别是切换分支时，这种情况经常发生，所以弄一个字段来管理
  ///[VALUE_NOT_EXISTS]不存在，[VALUE_EXISTS]存在
  static const IS_EXISTS = 'is_exists';

  static const VALUE_EXISTS = 1;
  static const VALUE_NOT_EXISTS = 0;

  ///创建一个触发器，当阅读记录大于$[MAX_RECORD_COUNT]条时，删除[ReadingRecordConst.UPDATE_TIMESTAMP]最久远的那条记录
  static const DELETE_REDUNDANT_RECORD_TRI_NAME = 'delete_redundant_record';

  ///最大记录数
  static const MAX_RECORD_COUNT = 100;
}

///仓库配置table的常量
class RepoConfConst {
  static const TABLE_NAME = 'repo_conf';
  static const ID = '_id';
  static const GIT_URI = 'git_uri';
  static const ROOT_DIR = 'root_dir';
  static const TARGET_DIR = 'target_dir';
  static const AUTHENTICATION_WAY = 'authen_way';

  ///是否从 tag 检出,branchName : 是的话以 tag/ 开头,否的话以 branch/ 开头.并且从 tag 检出的不能pull
  static const CURRENT_BRANCH = 'current_branch';

  ///是否从 tag 检出,branchName : 是的话以 tag/ 开头,否的话以 branch/ 开头.并且从 tag 检出的不能pull
  static const CHECKOUT_FROM_TAG = 'chekcout_from_tag';
  static const CREATED_DATE_TIME = 'created_date_time';

  ///鉴权信息，存储json格式数据，懒得写太多项
  static const AUTHENTICATION_INFO = 'authen_info';
  static const FROM_TAG = 1;
  static const FROM_BRANCH = 0;
}

///WReader的sqlite 语句
class WRSqlStatement {
  ///创建git仓库配置语句
  static const CREATE_TABLE_REPO =
      "CREATE TABLE IF NOT EXISTS ${RepoConfConst.TABLE_NAME}("
      "${RepoConfConst.ID} INTEGER PRIMARY KEY AUTOINCREMENT, "
      "${RepoConfConst.GIT_URI} VARCHAR(2048) NOT NULL, "
      "${RepoConfConst.ROOT_DIR} VARCHAR(512) NOT NULL, "
      "${RepoConfConst.TARGET_DIR} VARCHAR(128) NOT NULL, "
      "${RepoConfConst.AUTHENTICATION_WAY} INT(1) NOT NULL, "
      "${RepoConfConst.CREATED_DATE_TIME} INT NOT NULL, "
      "${RepoConfConst.CURRENT_BRANCH} VARCHAR(256), "
      "${RepoConfConst.CHECKOUT_FROM_TAG} INT(1) NOT NULL, "
      "${RepoConfConst.AUTHENTICATION_INFO} TEXT NOT NULL"
      ")";

  ///创建软件环境表语句
  static const CREATE_TABLE_BRIGHTNESS =
      "CREATE TABLE IF NOT EXISTS ${EnvironmentConst.TABLE_NAME}("
      "${EnvironmentConst.BRIGHTNESS_MODE} INT(1),"
      "${EnvironmentConst.SHOW_EXIT_HINT} INT(1),"
      "${EnvironmentConst.MY_WORD} VARCHAR(64),"
      "${EnvironmentConst.LANGUAGE_CODE} VARCHAR(32)"
      ")";

  ///创建git仓库配置语句
  static const CREATE_TABLE_READING_RECORD =
      "CREATE TABLE IF NOT EXISTS ${ReadingRecordConst.TABLE_NAME}("
      "${ReadingRecordConst.ID} INTEGER PRIMARY KEY AUTOINCREMENT,"
      "${ReadingRecordConst.READING_TIME} INTEGER,"
      "${ReadingRecordConst.READING_CACHED} VARCHAR(50),"
      "${ReadingRecordConst.FILE_NAME} VARCHAR(1024),"
      "${ReadingRecordConst.FILE_PATH} VARCHAR(1024),"
      "${ReadingRecordConst.REAL_FILE_TYPE} VARCHAR(128),"
      "${ReadingRecordConst.BIZ_FILE_TYPE} VARCHAR(128),"
      "${ReadingRecordConst.OWNER_REPO_LOCAL_DIR} VARCHAR(128),"
      "${ReadingRecordConst.OWNER_GIT_URI} VARCHAR(2048),"
      "${ReadingRecordConst.OWNER_GIT_BRANCH} VARCHAR(128),"
      "${ReadingRecordConst.CREATE_TIMESTAMP} INTEGER,"
      "${ReadingRecordConst.UPDATE_TIMESTAMP} INTEGER,"
      "${ReadingRecordConst.IS_EXISTS} INT(1) DEFAULT ${ReadingRecordConst.VALUE_EXISTS}"
      ")";

  ///插入默认环境配置的语句
  static const INSERT_DEFAULT_BRIGHTNESS_MODE =
      "INSERT INTO ${EnvironmentConst.TABLE_NAME} ("
      "${EnvironmentConst.BRIGHTNESS_MODE},${EnvironmentConst.SHOW_EXIT_HINT},${EnvironmentConst.LANGUAGE_CODE}"
      ") VALUES (${EnvironmentConst.MODE_LIGHT},${EnvironmentConst.SHOW_HINT},'${LanguageCodeConsts.FOLLOW_SYSTEM}')";

  ///创建一个触发器，当阅读记录大于100条时，删除[ReadingRecordConst.UPDATE_TIMESTAMP]最久远的那条记录
  static const CREATE_TRIGGER_DELETE_REDUNDANT_RECORD =
      "CREATE TRIGGER ${ReadingRecordConst.DELETE_REDUNDANT_RECORD_TRI_NAME} AFTER INSERT  "
      "ON ${ReadingRecordConst.TABLE_NAME}  "
      "BEGIN  "
      "DELETE FROM ${ReadingRecordConst.TABLE_NAME} WHERE  "
      "(SELECT COUNT(*) FROM ${ReadingRecordConst.TABLE_NAME})>${ReadingRecordConst.MAX_RECORD_COUNT}  "
      "AND "
      "${ReadingRecordConst.UPDATE_TIMESTAMP} = "
      "(SELECT MIN(${ReadingRecordConst.UPDATE_TIMESTAMP}) FROM ${ReadingRecordConst.TABLE_NAME}); "
      "END";
}

///专门处理
class WReaderSqlHelper {
  static Database _db;

  static const DB_NAME = 'wreader_db.db';
  static const DB_VERSION = 1;
  static const _VERSION_INITIAL = 1;

  static FutureOr<void> initDb() async {
    if (_db == null) {
      _db = await openDatabase(DB_NAME,
          onCreate: onCreateFn, readOnly: false, version: DB_VERSION);
    }
  }

  ///关闭数据库。再次使用需要重新调用[initDb]
  static Future<void> closeDb() async {
    assert(_db != null);
    _db.close();
    _db = null;
  }

  ///更新[RepoConfConst.TABLE_NAME]的数据，条件是表的id
  static Future<bool> updateRepoConfTable(
      int id, Map<String, dynamic> values) async {
    assert(_db != null);
    var count = await _db.update(RepoConfConst.TABLE_NAME, values,
        where: "${RepoConfConst.ID} = ?", whereArgs: [id]);
    return Future.value(count > 0);
  }

  ///返回true，该uri存在，返回false该uri不存在
  static Future<bool> queryGitUriExists(String uri) async {
    assert(_db != null);
    var result = await _db.query(RepoConfConst.TABLE_NAME,
        where: "${RepoConfConst.GIT_URI} = ?", whereArgs: [uri]);
    return Future.value(result.isNotEmpty);
  }

  ///获取所有的仓库配置信息
  static Future<List<Map<String, dynamic>>> getAllRepoConf() async {
    assert(_db != null);
    return await _db.query(RepoConfConst.TABLE_NAME);
  }

  ///获取所有的阅读记录数据
  static Future<List<Map<String, dynamic>>> querySpecificReadingRecord(
      String key) async {
    assert(_db != null);
    if (StringUtil.isBlank(key)) {
      return Future.value([]);
    }
    //忽略大小写
    final String ignoreCas = ' --  PRAGMA case_sensitive_like =0 ';
    return await _db.query(ReadingRecordConst.TABLE_NAME,
        where:
            "${ReadingRecordConst.FILE_NAME} like '%$key%' $ignoreCas or ${ReadingRecordConst.OWNER_REPO_LOCAL_DIR} like '%$key%' $ignoreCas",
        orderBy: "${ReadingRecordConst.UPDATE_TIMESTAMP} DESC");
  }

  ///获取所有的阅读记录数据
  static Future<List<Map<String, dynamic>>> getAllReadingRecord() async {
    assert(_db != null);
    return await _db.query(ReadingRecordConst.TABLE_NAME,
        orderBy: "${ReadingRecordConst.UPDATE_TIMESTAMP} DESC");
  }

  static Future<Map<String, dynamic>> queryRepoInfo(String gitUri) async {
    assert(_db != null);
    var list = await _db.query(RepoConfConst.TABLE_NAME,
        where: "${RepoConfConst.GIT_URI} = ?", whereArgs: <String>[gitUri]);
    if (list?.isNotEmpty == true) {
      return Future.value(list[0]);
    } else {
      return Future.value(<String, dynamic>{});
    }
  }

  ///根据特定条件，删除指定阅读记录
  static Future<bool> deleteSpecificReadingRecord(
      [Map<String, dynamic> where]) async {
    assert(_db != null);
    String whereExp = "";
    List<dynamic> whereArgs = [];
    if (where != null && where.isNotEmpty) {
      where.forEach((key, value) {
        whereExp = " $key=? and";
        whereArgs.add(value);
      });
      whereExp = whereExp.substring(0, whereExp.length - 4);
      println(whereExp);
    }
    return Future.value((await _db.delete(ReadingRecordConst.TABLE_NAME,
            where: whereExp, whereArgs: whereArgs)) >
        0);
  }

  ///查出git仓库的预览信息
  static Future<List<RepoPreviewItem>> queryRepoPreItems() async {
    assert(_db != null);
    var list = List<RepoPreviewItem>();
    var result = await _db.query(RepoConfConst.TABLE_NAME);
    if (result.isNotEmpty) {
      for (var map in result) {
        var item = RepoPreviewItem();
        item.targetDir = map[RepoConfConst.TARGET_DIR];
        item.rootDir = map[RepoConfConst.ROOT_DIR];
        item.gitUri = map[RepoConfConst.GIT_URI];
        item.createdDateTime = DateTime.fromMillisecondsSinceEpoch(
            map[RepoConfConst.CREATED_DATE_TIME]);
        item.currentBranch = map[RepoConfConst.CURRENT_BRANCH];
        list.add(item);
      }
    }
    return Future.value(list);
  }

  ///修改环境配置参数
  static Future<bool> modifyEnvironmentConfig(
      {String languageCode, int targetMode, String myWord}) async {
    assert(_db != null);
    Map<String, dynamic> map = HashMap();
    if (targetMode != null) {
      map[EnvironmentConst.BRIGHTNESS_MODE] = targetMode;
    }
    if (languageCode != null) {
      map[EnvironmentConst.LANGUAGE_CODE] = languageCode;
    }
    if (myWord != null && myWord.isNotEmpty) {
      map[EnvironmentConst.MY_WORD] = myWord;
    }
    return Future.value(
        (await _db.update(EnvironmentConst.TABLE_NAME, map)) > 0);
  }

  ///获取环境配置参数
  static Future<Map<String, dynamic>> getEnvironmentConfig() async {
    assert(_db != null);
    var list = await _db.query(EnvironmentConst.TABLE_NAME);
    return Future.value(list.first);
  }

  ///插入或者更新阅读记录
  static Future<bool> insertOrUpdateReadingRecord(
      String filePath,
      String gitUri,
      String gitLocalDir,
      String gitCurrentBranch,
      String cached,
      String bizFileType) async {
    assert(_db != null);
    var result = await _db.query(ReadingRecordConst.TABLE_NAME,
        where: "${ReadingRecordConst.FILE_PATH} = ?", whereArgs: [filePath]);
    Map<String, dynamic> map = HashMap();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    if (result.isNotEmpty) {
      //记录已存在，filePath是唯一的，其他数据都跟着变咯
      //更新数据
      var resultMap = result.first;
      int id = resultMap[ReadingRecordConst.ID];
      int readTime = resultMap[ReadingRecordConst.READING_TIME] + 1;
      map[ReadingRecordConst.OWNER_GIT_BRANCH] = gitCurrentBranch;
      map[ReadingRecordConst.OWNER_REPO_LOCAL_DIR] = gitLocalDir;
      map[ReadingRecordConst.OWNER_GIT_URI] = gitUri;
      map[ReadingRecordConst.READING_CACHED] = cached;
      map[ReadingRecordConst.UPDATE_TIMESTAMP] = timestamp;
      map[ReadingRecordConst.READING_TIME] = readTime;
      map[ReadingRecordConst.IS_EXISTS] = 1;
      return Future.value((await _db.update(ReadingRecordConst.TABLE_NAME, map,
              where: "${ReadingRecordConst.ID} = ?", whereArgs: [id])) >
          0);
    }
    map[ReadingRecordConst.FILE_PATH] = filePath;
    map[ReadingRecordConst.REAL_FILE_TYPE] =
        FileHelper.extractFileFormat(filePath);
    map[ReadingRecordConst.BIZ_FILE_TYPE] = bizFileType;
    map[ReadingRecordConst.FILE_NAME] = FileHelper.extractFileName(filePath);
    map[ReadingRecordConst.OWNER_GIT_BRANCH] = gitCurrentBranch;
    map[ReadingRecordConst.OWNER_REPO_LOCAL_DIR] = gitLocalDir;
    map[ReadingRecordConst.OWNER_GIT_URI] = gitUri;
    map[ReadingRecordConst.READING_CACHED] = cached;

    map[ReadingRecordConst.CREATE_TIMESTAMP] = timestamp;
    map[ReadingRecordConst.UPDATE_TIMESTAMP] = timestamp;
    map[ReadingRecordConst.READING_TIME] = 1;
    return Future.value(
        (await _db.insert(ReadingRecordConst.TABLE_NAME, map)) > 0);
  }

  ///删除特定条件的仓库配置信息，同时会删除该仓库的最近阅读记录
  static Future<bool> deleteRepoConf(String uri) async {
    assert(_db != null);
    int count = await _db.delete(RepoConfConst.TABLE_NAME,
        where: "${RepoConfConst.GIT_URI}=?", whereArgs: [uri]);
    print("deleteRepoConf = $count");
    await _db.delete(ReadingRecordConst.TABLE_NAME,
        where: "${ReadingRecordConst.OWNER_GIT_URI}=?", whereArgs: [uri]);
    return Future.value(count == 1);
  }

  ///插入一条新的Git仓库配置信息，int等于1插入成功
  static Future<bool> insertRepoConf(
      String uri,
      String rootDir,
      String targetDir,
      int authenticationWay,
      String authenInfo,
      String currentBranch) async {
    assert(_db != null);
    Map<String, dynamic> map = HashMap();
    map[RepoConfConst.GIT_URI] = uri;
    map[RepoConfConst.ROOT_DIR] = rootDir;
    map[RepoConfConst.TARGET_DIR] = targetDir;
    map[RepoConfConst.AUTHENTICATION_WAY] = authenticationWay;
    map[RepoConfConst.AUTHENTICATION_INFO] = authenInfo;
    map[RepoConfConst.CREATED_DATE_TIME] =
        DateTime.now().millisecondsSinceEpoch;
    map[RepoConfConst.CURRENT_BRANCH] = currentBranch;
    map[RepoConfConst.CHECKOUT_FROM_TAG] = RepoConfConst.FROM_BRANCH;
    var insertCount = await _db.insert(RepoConfConst.TABLE_NAME, map);
    return Future.value(insertCount > 0);
  }
}

///创建数据库的函数
FutureOr<void> onCreateFn(Database db, int version) {
  if (version == WReaderSqlHelper._VERSION_INITIAL) {
    print(
        "当前数据库版本 = ${WReaderSqlHelper._VERSION_INITIAL}，执行建表语句：[${WRSqlStatement.CREATE_TABLE_REPO}]");
    //初始版本，创建数据库
    //创建git仓库配置表
    db.execute(WRSqlStatement.CREATE_TABLE_REPO);
    //创建环境配置表
    db.execute(WRSqlStatement.CREATE_TABLE_BRIGHTNESS);
    //创建阅读记录表
    db.execute(WRSqlStatement.CREATE_TABLE_READING_RECORD);
    //插入默认数据
    db.execute(WRSqlStatement.INSERT_DEFAULT_BRIGHTNESS_MODE);
    //创建一个触发器，当阅读记录大于100条时，删除[ReadingRecordConst.UPDATE_TIMESTAMP]最久远的那条记录
    db.execute(WRSqlStatement.CREATE_TRIGGER_DELETE_REDUNDANT_RECORD);
    print(WRSqlStatement.CREATE_TABLE_BRIGHTNESS);
    println(WRSqlStatement.CREATE_TRIGGER_DELETE_REDUNDANT_RECORD);
    println(WRSqlStatement.CREATE_TABLE_READING_RECORD);
  }
}
