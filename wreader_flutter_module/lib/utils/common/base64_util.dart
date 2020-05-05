import 'dart:convert' as convert;

///base64编解码工具类
class Base64Util {
  /// Base64编码
  static String encodeBase64(String data) {
    var content = convert.utf8.encode(data);
    var digest = convert.base64Encode(content);
    return digest;
  }

  ///Base64解码
  static String decodeBase64(String data) {
    return convert.utf8.decode(convert.base64Decode(data));
  }
}
