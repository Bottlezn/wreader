import 'package:flutter/material.dart';
import 'package:wreader_flutter_module/values/app_colors.dart';
import 'package:wreader_flutter_module/widget/common_styles.dart';

///文本选中状态枚举
enum TextSelecting { DEFAULT, PRESS }

///内部使用的状态值携带类
class _SelectedValue {
  bool enabled = true;
  bool isSelected = false;
  String text = '';

  _SelectedValue();
}

class SelectedController extends ValueNotifier<_SelectedValue> {
  SelectedController() : super(new _SelectedValue());

  String getText() {
    if (value == null) {
      return null;
    }
    return value.text;
  }

  void setText(String text) {
    _SelectedValue newValue;
    if (value == null) {
      newValue = new _SelectedValue();
      newValue.text = text;
      value = newValue;
      return;
    }
    if (text == value.text) {
      return;
    }
    newValue = new _SelectedValue();
    newValue.text = text;
    newValue.enabled = value.enabled;
    newValue.isSelected = value.isSelected;
    value = newValue;
  }

  void setSelected(bool isSelected) {
    _SelectedValue newValue;
    if (value == null) {
      newValue = new _SelectedValue();
      newValue.isSelected = isSelected;
      value = newValue;
      return;
    }
    if (isSelected == value.isSelected) {
      return;
    }
    newValue = new _SelectedValue();
    newValue.isSelected = isSelected;
    newValue.enabled = value.enabled;
    newValue.text = value.text;
    value = newValue;
  }

  void setEnabled(bool enabled) {
    _SelectedValue newValue;
    if (value == null) {
      newValue = new _SelectedValue();
      newValue.enabled = enabled;
      value = newValue;
      return;
    }
    if (enabled == value.enabled) {
      return;
    }
    newValue = new _SelectedValue();
    newValue.isSelected = value.enabled;
    newValue.enabled = enabled;
    newValue.text = value.text;
    value = newValue;
  }
}

///通用的文本选择按钮，可以设置默认、触摸、选中、不可用四种状态下的文本颜色、大小，容器颜色、border等配置
///如果不设置文本的话也可以用于普通按钮的点击效果上。
class TextSelector extends StatefulWidget {
  ///container的装饰器背景颜色
  final Color defaultColor;
  final Color pressingColor;
  final Color selectedColor;
  final Color disabledColor;
  final TextStyle defaultStyle;
  final TextStyle pressingStyle;
  final TextStyle selectedStyle;
  final TextStyle disabledStyle;
  final TextSelecting selecting;
  final double radiusAll;
  final double width;
  final double height;
  final EdgeInsets padding;
  final double radiusTopLeft;
  final double radiusTopRight;
  final double radiusBottomRight;
  final double radiusBottomLeft;
  final Function onPress;
  final Function onLongPress;
  final double borderWidth;
  final Color defaultBorderColor;
  final Color pressingBorderColor;
  final Color selectedBorderColor;
  final Color disableBorderColor;
  final SelectedController controller;
  final BoxConstraints boxConstraints;
  final Alignment alignment;

  TextSelector(
    this.controller, {
    Key key,
    this.defaultStyle,
    this.defaultColor,
    this.pressingColor,
    this.selectedColor,
    this.disabledColor,
    this.pressingStyle,
    this.selectedStyle,
    this.disabledStyle,
    this.selecting,
    this.radiusAll,
    this.width,
    this.height,
    this.padding,
    this.radiusTopLeft,
    this.radiusTopRight,
    this.radiusBottomRight,
    this.radiusBottomLeft,
    this.onPress,
    this.onLongPress,
    this.borderWidth,
    this.defaultBorderColor,
    this.pressingBorderColor,
    this.selectedBorderColor,
    this.disableBorderColor,
    this.boxConstraints,
    this.alignment,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TextSelectorState(
      controller,
      defaultColor,
      pressingColor,
      selectedColor,
      disabledColor,
      defaultStyle,
      pressingStyle,
      selectedStyle,
      disabledStyle,
      selecting,
      radiusAll,
      width,
      height,
      padding,
      radiusTopLeft,
      radiusTopRight,
      radiusBottomRight,
      radiusBottomLeft,
      onPress,
      onLongPress,
      borderWidth,
      defaultColor,
      pressingColor,
      selectedColor,
      disabledColor,
      boxConstraints,
      alignment);
}

class _TextSelectorState extends State<TextSelector> {
  Color defaultColor;
  Color pressingColor;
  Color selectedColor;
  Color disabledColor;
  TextStyle defaultStyle;
  TextStyle pressingStyle;
  TextStyle selectedStyle;
  TextStyle disabledStyle;
  TextSelecting selecting;
  double radiusAll;
  double width;
  double height;
  EdgeInsets padding;
  double radiusTopLeft;
  double radiusTopRight;
  double radiusBottomRight;
  double radiusBottomLeft;
  Function onPress;
  Function onLongPress;
  double borderWidth;
  Color defaultBorderColor;
  Color pressingBorderColor;
  Color selectedBorderColor;
  Color disableBorderColor;
  SelectedController _controller;
  BoxConstraints _boxConstraints;
  Alignment alignment;

  _TextSelectorState(
      this._controller,
      this.defaultColor,
      this.pressingColor,
      this.selectedColor,
      this.disabledColor,
      this.defaultStyle,
      this.pressingStyle,
      this.selectedStyle,
      this.disabledStyle,
      this.selecting,
      this.radiusAll,
      this.width,
      this.height,
      this.padding,
      this.radiusTopLeft,
      this.radiusTopRight,
      this.radiusBottomRight,
      this.radiusBottomLeft,
      this.onPress,
      this.onLongPress,
      this.borderWidth,
      this.defaultBorderColor,
      this.pressingBorderColor,
      this.selectedBorderColor,
      this.disableBorderColor,
      this._boxConstraints,
      this.alignment) {
    if (defaultStyle == null) {
      defaultStyle = AppTvStyles.textStyle16Color66();
    }
    if (pressingStyle == null) {
      pressingStyle = defaultStyle;
    }
    if (selectedStyle == null) {
      selectedStyle = defaultStyle;
    }
    if (disabledStyle == null) {
      disabledStyle = defaultStyle;
    }

    if (defaultColor == null) {
      defaultColor = AppColors.COLOR_BG;
    }
    if (pressingColor == null) {
      pressingColor = defaultColor;
    }
    if (selectedColor == null) {
      selectedColor = defaultColor;
    }
    if (disabledColor == null) {
      disabledColor = defaultColor;
    }

    if (defaultBorderColor == null) {
      defaultBorderColor = AppColors.COLOR_BG;
    }
    if (selectedBorderColor == null) {
      selectedBorderColor = defaultBorderColor;
    }
    if (pressingBorderColor == null) {
      pressingBorderColor = defaultBorderColor;
    }
    if (disableBorderColor == null) {
      disableBorderColor = defaultBorderColor;
    }
    if (borderWidth == null) {
      borderWidth = 0;
    }
  }

  @override
  void initState() {
    super.initState();
    if (_controller == null) {
      _controller = new SelectedController();
    }
    _controller.addListener(() {
      setState(() {});
    });
  }

  EdgeInsets _buildPadding() => padding ?? EdgeInsets.all(0);

  Color _whatColor() {
    if (!_controller.value.enabled) {
      return disabledColor;
    } else if (_controller.value.isSelected) {
      return selectedColor;
    }
    switch (selecting) {
      case TextSelecting.DEFAULT:
        return defaultColor;
      case TextSelecting.PRESS:
        return pressingColor;
    }
    return defaultColor;
  }

  BorderRadiusGeometry _buildBorderRadius() {
    if (radiusAll == null) {
      return BorderRadius.circular(0.toDouble());
    }
    return radiusAll > 0
        ? BorderRadius.circular(radiusAll)
        : BorderRadius.only(
            bottomLeft: Radius.circular(radiusBottomLeft),
            bottomRight: Radius.circular(radiusBottomRight),
            topLeft: Radius.circular(radiusTopLeft),
            topRight: Radius.circular(radiusTopRight));
  }

  Border _buildBorder() {
    if (borderWidth == null || borderWidth <= 0) {
      return null;
    }
    Color color = defaultBorderColor;
    if (!_controller.value.enabled) {
      color = disableBorderColor;
    } else if (_controller.value.isSelected) {
      color = selectedBorderColor;
    }
    switch (selecting) {
      case TextSelecting.DEFAULT:
        color = defaultBorderColor;
        break;
      case TextSelecting.PRESS:
        color = pressingBorderColor;
        break;
    }
    return Border.all(color: color, width: borderWidth);
  }

  TextStyle _whatStyle() {
    if (!_controller.value.enabled) {
      return disabledStyle;
    } else if (_controller.value.isSelected) {
      return selectedStyle;
    }
    switch (selecting) {
      case TextSelecting.DEFAULT:
        return defaultStyle;
      case TextSelecting.PRESS:
        return pressingStyle;
    }
    return defaultStyle;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        constraints: _boxConstraints,
        padding: _buildPadding(),
        width: width,
        height: height,
        decoration: BoxDecoration(
            color: _whatColor(),
            borderRadius: _buildBorderRadius(),
            border: _buildBorder()),
        child: Text(
          _controller.value.text,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          style: _whatStyle(),
        ),
        alignment: alignment ?? Alignment(0, 0),
      ),
      onTapDown: (TapDownDetails details) {
        if (!_controller.value.enabled) {
          return;
        }
        print('onTapDown');
        setState(() {
          selecting = TextSelecting.PRESS;
        });
      },
      onTapUp: (TapUpDetails details) {
        if (!_controller.value.enabled) {
          return;
        }
        print('onTapUp');
        setState(() {
          selecting = TextSelecting.DEFAULT;
        });
        if (onPress != null) {
          onPress();
        }
      },
      onLongPress: onLongPress,
      onTapCancel: () {
        if (!_controller.value.enabled) {
          return;
        }
        setState(() {
          selecting = TextSelecting.DEFAULT;
        });
        print('onTapCancel');
      },
    );
  }
}
