
///字符串处理工具类
class StringUtil {
  ///匹配是否是手机号的正则表达式
  static final _regPhone = RegExp('^1\\d{10}\$');
  static final _digitPhone = RegExp('^\\d+\$');
  static final _blankStr = RegExp('\s*?');

  ///字符串是null或者是1个空字符，返回true
  static bool isEmpty(String input) {
    return input == null || input.isEmpty;
  }

  ///字符串是null或者1个或多个空字符串,包含\n\r换行符等
  static bool isBlank(String input) {
    return isEmpty(input) && _blankStr.hasMatch(input);
  }

  ///获取男或者女的字符串，从输入的文本中获取
  static String getGenderFromInt(String input) {
    return isEmpty(input)
        ? '未知'
        : ('1' == input || '2' == input ? ('1' == input ? '男' : '女') : input);
  }

  ///避免空指针
  static String safeWrap(String input, [String replaceHolder = '——']) {
    return isEmpty(input)
        ? (isEmpty(replaceHolder) ? '——' : replaceHolder)
        : input;
  }

  static bool isPhone(String input) {
    if (input == null) {
      return false;
    }
    return _regPhone.hasMatch(input);
  }

  static bool isDigit(String input) {
    if (input == null) {
      return false;
    }
    return _digitPhone.hasMatch(input);
  }
}
