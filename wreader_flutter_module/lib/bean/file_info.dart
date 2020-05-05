import 'package:wreader_flutter_module/utils/common/json_util.dart';

class FileInfo {
  factory FileInfo.fromJson(Map<String, dynamic> json) {
    return FileInfo()
      ..isDir = JsonHelper.safeExtractValue(json['isDir'], bool)
      ..fileName = JsonHelper.safeExtractValue(json['fileName'])
      ..absoultPath = JsonHelper.safeExtractValue(json['absoultPath'])
      ..fileType = JsonHelper.safeExtractValue(json['fileType'])
      ..modifiedDateTime = json['modifiedDateTime'] == null
          ? null
          : DateTime.parse(json['modifiedDateTime'] as String)
      ..fileSize = JsonHelper.safeExtractValue(json['fileSize'], int)
      ..childList = (json['childList'] as List)
          ?.map((e) =>
              e == null ? null : FileInfo.fromJson(e as Map<String, dynamic>))
          ?.toList()
      ..parentDir = JsonHelper.safeExtractValue(json['parentDir'])
      ..preList = (json['preList'] as List)
          ?.map((e) =>
              e == null ? null : FileInfo.fromJson(e as Map<String, dynamic>))
          ?.toList()
      ..itemConut = JsonHelper.safeExtractValue(json['itemConut'], int);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'isDir': this.isDir,
        'fileName': this.fileName,
        'absoultPath': this.absoultPath,
        'fileType': this.fileType,
        'modifiedDateTime': this.modifiedDateTime?.toIso8601String(),
        'fileSize': this.fileSize,
        'childList': this.childList,
        'parentDir': this.parentDir,
        'preList': this.preList,
        'itemConut': this.itemConut,
      };

  FileInfo();

  ///true是文件夹，false是文件
  bool isDir;

  ///文件夹或文件名字，包含格式
  String fileName;

  ///绝对路径
  String absoultPath;

  ///如果是文件类型，并且有后缀的话
  String fileType;

  ///文件修改时间
  DateTime modifiedDateTime;

  ///如果是文件类型会有该值
  int fileSize;

  ///如果是文件夹的话，该对象会有子列表集合
  List<FileInfo> childList;

  ///父级文件夹名称，不是绝对路径
  String parentDir;

  ///上一级的文件列表信息
  List<FileInfo> preList;

  ///元素个数，结果会根据是否忽略隐藏项目而变化
  int itemConut;

  @override
  String toString() {
    return '\nFileInfo{isDir: $isDir, fileName: $fileName, absoultPath: $absoultPath, fileType: $fileType, modifiedDateTime: $modifiedDateTime, fileSize: $fileSize,\n childList: ${childList?.length ?? 0},\n parentDir: $parentDir,\n preList: ${preList?.length ?? 0},\n itemConut: $itemConut}\n';
  }
}
