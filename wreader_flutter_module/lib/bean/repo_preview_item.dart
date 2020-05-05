import 'package:wreader_flutter_module/utils/common/json_util.dart';

///git仓库列表预览信息
class RepoPreviewItem {
  factory RepoPreviewItem.fromJson(Map<String, dynamic> json) {
    return RepoPreviewItem()
      ..targetDir = JsonHelper.safeExtractValue(json['targetDir'])
      ..rootDir = JsonHelper.safeExtractValue(json['rootDir'])
      ..gitUri = JsonHelper.safeExtractValue(json['gitUri'])
      ..currentBranch = JsonHelper.safeExtractValue(json['currentBranch'])
      ..createdDateTime = json['createdDateTime'] == null
          ? null
          : DateTime.parse(json['createdDateTime'] as String);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'targetDir': this.targetDir,
        'rootDir': this.rootDir,
        'gitUri': this.gitUri,
        'currentBranch': this.currentBranch,
        'createdDateTime': this.createdDateTime?.toIso8601String(),
      };

  RepoPreviewItem();

  String targetDir;
  String rootDir;
  String gitUri;
  String currentBranch;
  DateTime createdDateTime;
}
