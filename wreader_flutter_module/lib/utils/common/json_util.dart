import 'dart:convert';


class JsonUtil {
  static const _JSON = JsonCodec();

  ///将一个obj的json字符串转换成实体json map信息，然后调用obj.fromJson(Map)转换成具体obj对象
  static dynamic decode(String source, {reviver(Object key, Object value)}) =>
      _JSON.decode(source, reviver: reviver);

  ///将一个obj的json map信息转换成json字符串，
  static String encode(Object value, {toEncodable(object)}) =>
      _JSON.encode(value, toEncodable: toEncodable);
}

///json转换的帮助类
class JsonHelper {
  ///将服务器响应的值，根据对应的type进行转换，避免转换错误。
  ///如果type有实际传入值，会根据传入的type转换。默认值是String
  ///type没有实际传入值，会获取value的runtimeType进行转换
  ///目前只支持String,int,double,bool,List<String>和List<int>
  static dynamic safeExtractValue(dynamic value, [dynamic type = String]) {
    if (value == null) {
      return null;
    }
    return _wrapType(type ?? value.runtimeType, value);
  }

  static dynamic _wrapType(Type type, dynamic value) {
    if (!(value is String)) {
      String typeStr = type.toString();
      switch (typeStr) {
        case 'String':
          return _extractString(value);
        case 'int':
          return _extractInt(value);
        case 'double':
          return _extractDouble(value);
        case 'bool':
          return _extractBool(value);
        default:
          return value.toString();
      }
    } else {
      switch (value) {
        case 'List<String>':
          return _extractStringList(value);
        case 'List<int>':
          return _extractIntList(value);
        case 'List<double>':
          return _extractDoubleList(value);
        case 'List<bool>':
          return _extractBoolList(value);
        default:
          return value.toString();
      }
    }
  }

  ///将value转换成String值
  static String _extractString(value) {
    if (value == null) {
      return null;
    } else if (value is String) {
      return value;
    } else {
      return value.toString();
    }
  }

  ///提取bool值，失败会返回null
  static bool _extractBool(value) {
    try {
      if (value == null) {
        return null;
      } else if (value is bool) {
        return value;
      } else {
        if (true == value) {
          return true;
        } else if (false == value) {
          return false;
        } else {
          String valueStr = value.toString();
          if ('false' == valueStr) {
            return false;
          } else if ('true' == valueStr) {
            return true;
          }
          return null;
        }
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  ///提取List<int>值，失败会返回null
  static List<bool> _extractBoolList(value) {
    try {
      if (value == null) {
        return null;
      } else if (value is List<bool>) {
        return value;
      } else {
        return (value as List)?.map((e) => e as bool)?.toList();
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  ///提取List<int>值，失败会返回null
  static List<double> _extractDoubleList(value) {
    try {
      if (value == null) {
        return null;
      } else if (value is List<double>) {
        return value;
      } else {
        return (value as List)?.map((e) => (e as num)?.toDouble())?.toList();
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  ///提取List<int>值，失败会返回null
  static List<int> _extractIntList(value) {
    try {
      if (value == null) {
        return null;
      } else if (value is List<int>) {
        return value;
      } else {
        return (value as List)?.map((e) => e as int)?.toList();
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  ///提取List<String>值，失败会返回null
  static List<String> _extractStringList(value) {
    try {
      if (value == null) {
        return null;
      } else if (value is List<String>) {
        return value;
      } else {
        return (value as List)?.map((e) => e as String)?.toList();
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  ///提取double值，失败会返回null
  static double _extractDouble(value) {
    try {
      if (value == null) {
        return null;
      } else if (value is double) {
        return value;
      } else {
        return (value as num)?.toDouble();
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  ///提取int值，失败会返回null
  static int _extractInt(value) {
    try {
      if (value == null) {
        return null;
      } else if (value is int) {
        return value;
      } else {
        return (value as num)?.toInt();
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
