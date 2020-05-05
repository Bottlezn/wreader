import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:wreader_flutter_module/main.dart';

String i18nTranslate(String key,
    [final Map<String, String> translationParams]) {
  return FlutterI18n.translate(
      NavigatorService.getInstance().navigatorState.currentContext,
      key,
      translationParams);
}

String i18nPlural(String key, int index) {
  return FlutterI18n.plural(
      NavigatorService.getInstance().navigatorState.currentContext, key, index);
}
