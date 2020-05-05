import 'dart:io';

import 'package:intl/intl.dart';
import 'package:wreader_flutter_module/bean/file_info.dart';

///文件是否是隐藏项目，返回true忽略，false不忽略
typedef IsHideItem = bool Function(String fileName, String absolutPath);

///默认的“.xxx”格式认为是隐藏项
bool defaultIsHideItemFun(String fileName, String absolutPath) {
  return fileName?.isNotEmpty == true && fileName.startsWith('.');
}

class FileHelper {
  ///将文件夹作为根目录，加载出该目录下的所有子文件
  ///[ignoreHideItem]是否忽略隐藏项目，这里的隐藏项目是以 '.xxx'这种格式的文件或者文件夹
  static Future<FileInfo> loadFileInfos(String dirAbsoultPath,
      [bool ignoreHideItem = true,
      IsHideItem isHideItemFun = defaultIsHideItemFun]) async {
    var rootDir = Directory(dirAbsoultPath);
    //判断文件是否存在
    bool rooExists = await rootDir.exists();
    assert(rooExists);
    //判断存入的路径是否是文件夹
    var rootState = await rootDir.stat();
    assert(rootState.type == FileSystemEntityType.directory);
    //获取文件夹的子信息
    var list = rootDir.listSync();
    FileInfo rootInfo = FileInfo()
      ..isDir = true
      ..absoultPath = dirAbsoultPath
      ..fileSize = rootState.size
      ..fileName = dirAbsoultPath.substring(
          dirAbsoultPath.lastIndexOf("/") + 1, dirAbsoultPath.length)
      ..modifiedDateTime = rootState.modified;
    if (list?.isNotEmpty == true) {
      rootInfo.childList = await _loadChildList(
          rootInfo, rootState, list, null, ignoreHideItem, isHideItemFun);
      rootInfo.itemConut = rootInfo.childList?.length ?? 0;
    } else {
      //子元素为空
      return Future.value(rootInfo);
    }
    return Future.value(rootInfo);
  }

  ///递归查找处所有文件信息来
  static Future<List<FileInfo>> _loadChildList(
      FileInfo parent,
      FileStat parentStat,
      List<FileSystemEntity> children,
      List<FileInfo> preList,
      [bool ignoreHideItem = true,
      IsHideItem isHideItem = defaultIsHideItemFun]) async {
    //当前传递的文件夹的子项目信息
    var list = <FileInfo>[];
    for (var entity in children) {
      var fileState = await entity.stat();

      if (fileState.type == FileSystemEntityType.file) {
        if (!ignoreHideItem ||
            (ignoreHideItem &&
                !isHideItem(extractFileName(entity.path), entity.path))) {
          //不忽略项目，或者忽略文件项目为ture，但是不符合忽略项目条件
          FileInfo info = FileInfo()
            ..absoultPath = entity.path
            ..fileName = extractFileName(entity.path)
            ..isDir = false
            ..fileSize = fileState.size
            ..fileType = extractFileFormat(entity.path)
            ..modifiedDateTime = fileState.modified
            ..preList = preList
            ..parentDir = parent.fileName;
          list.add(info);
        }
      } else if (fileState.type == FileSystemEntityType.directory) {
        if (!ignoreHideItem ||
            (ignoreHideItem &&
                !isHideItem(extractFileName(entity.path), entity.path))) {
          //不忽略项目，或者忽略文件项目为ture，但是不符合忽略项目条件
          FileInfo info = FileInfo()
            ..absoultPath = entity.path
            ..fileName = extractFileName(entity.path)
            ..isDir = true
            ..fileSize = fileState.size
            ..modifiedDateTime = fileState.modified
            ..preList = preList
            ..parentDir = parent.fileName;
          var dir = Directory(entity.path);
          var dirChildren = dir.listSync();
          if (dirChildren?.isNotEmpty == true) {
            info.childList =
                await _loadChildList(info, fileState, dirChildren, list);
          }
          info.itemConut = info.childList?.length ?? 0;
          list.add(info);
        }
      }
    }
    return list;
  }

  ///提取文件类型
  static String extractFileFormat(String absolutePath) {
    //先提取文件名字，再根据是否有后缀是否截断文件类型
    var nameWithFormat = absolutePath.substring(
        absolutePath.lastIndexOf("/") + 1, absolutePath.length);
    if (nameWithFormat.contains('.')) {
      return nameWithFormat.substring(
          nameWithFormat.lastIndexOf('.') + 1, nameWithFormat.length);
    } else {
      return null;
    }
  }

  ///提取文件或者文件夹名字，[splitFileFormat]为ture时，会忽略文件格式，只提取文件名字。为false时，带格式取出来
  static String extractFileName(String absolutePath,
      {bool splitFileFormat = false}) {
    //先提取文件名字，再根据是否有后缀是截断文件类型
    var nameWithFormat = absolutePath.substring(
        absolutePath.lastIndexOf("/") + 1, absolutePath.length);
    if (splitFileFormat && nameWithFormat.contains('.')) {
      return nameWithFormat.substring(0, nameWithFormat.lastIndexOf('.'));
    } else {
      return nameWithFormat;
    }
  }

  ///导出文件,如果 应用不给予外置 SD 卡读写权限,或者没有 公共存储区域,会导出失败
  ///返回 格式 {'exported':true,'exportAbsolutePath':'','reason':'reason'} exported 为 true 导出成功,false 导出失败
  static Future<Map<String, dynamic>> exportFile(
      String absolutePath, String rootDir) async {
    File file = File(absolutePath);
    bool exist = await file.exists();
    Map<String, dynamic> result = {'exported': false};
    FileStat state = await file.stat();
    if (exist) {
      if (state.type == FileSystemEntityType.file) {
        try {
          File newFile = await file.copy(
              "$rootDir/${extractFileName(absolutePath, splitFileFormat: true)}_${_formatTime()}.${extractFileFormat(absolutePath)}");
          result['exported'] = true;
          result['exportAbsolutePath'] = newFile.path;
          return result;
        } catch (e) {
          print(e);
          result['reason'] = '${e.toString()}';
          return result;
        }
      } else {
        result['reason'] = '$absolutePath was not file type!';
      }
    } else {
      result['reason'] = '$absolutePath was not existed!';
    }
    return Future.value(result);
  }

  static var _format = DateFormat('MMddHHmmss');

  static String _formatTime([DateTime time]) {
    return _format.format(time ?? DateTime.now());
  }
}
