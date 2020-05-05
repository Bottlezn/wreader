import 'package:fish_redux/fish_redux.dart';

/// Created on 2020/5/4.
/// @author 悟笃笃
/// description:

abstract class GlobalBaseState {
  int get brightnessMode;

  String get languageCode;

  String get action;

  set brightnessMode(int brightnessMode);

  set languageCode(String languageCode);

  set action(String action);
}

class GlobalState implements GlobalBaseState, Cloneable<GlobalState> {
  @override
  String action;

  @override
  int brightnessMode;

  @override
  String languageCode;

  @override
  GlobalState clone() {
    return GlobalState()
      ..brightnessMode = this.brightnessMode
      ..action = this.action
      ..languageCode = this.languageCode;
  }
}