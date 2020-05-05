import 'package:wreader_flutter_module/utils/common/json_util.dart';

import 'file_info.dart';

///repo的详情
class RepoDetailsBean {
  RepoDetailsBean();

  factory RepoDetailsBean.fromJson(Map<String, dynamic> json) {
    return RepoDetailsBean()
      ..id = JsonHelper.safeExtractValue(json['id'], int)
      ..fileInfo = json['fileInfo'] == null
          ? null
          : FileInfo.fromJson(json['fileInfo'] as Map<String, dynamic>)
      ..gitUri = JsonHelper.safeExtractValue(json['gitUri'])
      ..currentBranch = JsonHelper.safeExtractValue(json['currentBranch'])
      ..fullDir = JsonHelper.safeExtractValue(json['fullDir'])
      ..targetDir = JsonHelper.safeExtractValue(json['targetDir'])
      ..rootDir = JsonHelper.safeExtractValue(json['rootDir'])
      ..allBranch =
          JsonHelper.safeExtractValue(json['allBranch'], 'List<String>')
      ..allTag = JsonHelper.safeExtractValue(json['allTag'], 'List<String>')
      ..authenticationInfo =
          JsonHelper.safeExtractValue(json['authenticationInfo'])
      ..authenticationWay =
          JsonHelper.safeExtractValue(json['authenticationWay'], int);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': this.id,
        'fileInfo': this.fileInfo,
        'gitUri': this.gitUri,
        'currentBranch': this.currentBranch,
        'fullDir': this.fullDir,
        'targetDir': this.targetDir,
        'rootDir': this.rootDir,
        'allBranch': this.allBranch,
        'allTag': this.allTag,
        'authenticationInfo': this.authenticationInfo,
        'authenticationWay': this.authenticationWay,
      };

  int id;
  FileInfo fileInfo;
  String gitUri;
  String currentBranch;
  String fullDir;
  String targetDir;
  String rootDir;
  List<String> allBranch;
  List<String> allTag;
  String authenticationInfo;
  int authenticationWay;
}
