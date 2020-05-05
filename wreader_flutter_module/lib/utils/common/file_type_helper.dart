import 'package:wreader_flutter_module/consts/file_type.dart';

///文件类型帮助处理类
class FileTypeHelper {
  ///目前只认为md，mmd，txt与text是markdown格式，其余认为是未知
  static bool isMarkdown(String type) {
    if (type?.isNotEmpty == true) {
      return 'md' == type || 'mmd' == type || 'txt' == type || 'text' == type;
    } else {
      return false;
    }
  }

  ///是否是图片文件
  static bool isImage(String type) {
    if (type?.isNotEmpty == true) {
      return 'png' == type || 'jpg' == type || 'jpeg' == type;
    } else {
      return false;
    }
  }

  static String getBizType(String absolutePath) {
    String fileType = FileTypeConst.UNKNOWN;
    if (FileTypeHelper.isMarkdownBasePath(absolutePath)) {
      fileType = FileTypeConst.MD_FILE;
    } else if (FileTypeHelper.isImageBasePath(absolutePath)) {
      fileType = FileTypeConst.IMAGE;
    } else if (FileTypeHelper.isCode(absolutePath.substring(
        absolutePath.lastIndexOf('.') + 1, absolutePath.length))) {
      fileType = FileTypeConst.CODE;
    }
    return fileType;
  }

  ///是否是代码文件
  static bool isCode(String type) {
    if (type?.isNotEmpty == true) {
      return 'java' == type ||
          'c' == type ||
          'h' == type ||
          'cpp' == type ||
          'kt' == type ||
          'js' == type ||
          'dart' == type ||
          'html' == type ||
          'css' == type ||
          'xml' == type ||
          'htm' == type ||
          'gradle' == type ||
          'yaml' == type ||
          'php' == type ||
          'jsp' == type ||
          'aspx' == type ||
          'json' == type ||
          'asp' == type ||
          'cs' == type;
    } else {
      return false;
    }
  }

  static bool isMarkdownBasePath(String fileAbsolutePath) {
    return fileAbsolutePath?.isNotEmpty == true &&
        (fileAbsolutePath.endsWith('.md') ||
            fileAbsolutePath.endsWith('.mmd') ||
            fileAbsolutePath.endsWith('.txt') ||
            fileAbsolutePath.endsWith('.text'));
  }

  static bool isImageBasePath(String fileAbsolutePath) {
    return fileAbsolutePath?.isNotEmpty == true &&
        (fileAbsolutePath.endsWith('.png') ||
            fileAbsolutePath.endsWith('.jpeg') ||
            fileAbsolutePath.endsWith('.jpg') ||
            fileAbsolutePath.endsWith('.gif'));
  }
}
