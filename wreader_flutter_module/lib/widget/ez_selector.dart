import 'package:flutter/material.dart';
import 'package:wreader_flutter_module/values/app_colors.dart';

///简单易用的选择器，
///可以控制默认颜色和触摸颜色
///传入的child请不要设置颜色，否则不起效
class EzSelector extends StatefulWidget {
  final Color defaultColor;
  final Color pressColor;
  final Widget _child;
  final GestureTapCallback _pressCallback;
  final GestureTapCallback onLongCallback;

  EzSelector(this._child, this._pressCallback,
      {this.defaultColor = Colors.transparent,
      this.onLongCallback,
      this.pressColor = AppColors.COLOR_BG,
      Key key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _EzSelectState(this.defaultColor,
      this.pressColor, this._child, this._pressCallback, this.onLongCallback);
}

class _EzSelectState extends State<EzSelector> {
  final Color _defaultColor;
  final Color _pressColor;
  final Widget _child;
  final GestureTapCallback _callback;
  final GestureTapCallback _onLongCallback;
  Color _color;

  _EzSelectState(this._defaultColor, this._pressColor, this._child,
      this._callback, this._onLongCallback);

  void initState() {
    _color = _defaultColor;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapCancel: () {
        setState(() {
          _color = _defaultColor;
        });
      },
      onTapUp: (_) {
        setState(() {
          _color = _defaultColor;
        });
      },
      onTap: _callback,
      onLongPress: _onLongCallback,
      onTapDown: (_) {
        setState(() {
          _color = _pressColor;
        });
      },
      child: Container(
        child: _child,
        color: _color,
      ),
    );
  }
}
