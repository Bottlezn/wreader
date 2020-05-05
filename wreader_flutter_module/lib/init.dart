import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart';
import 'package:wreader_flutter_module/db/sqlite_helper.dart';

Future<bool> initModule(BuildContext context) async {
  println('before WReaderSqlHelper.initDb()');
  //初始化数据库
  await WReaderSqlHelper.initDb();
  println('after WReaderSqlHelper.initDb()');
  return Future.value(true);
}
