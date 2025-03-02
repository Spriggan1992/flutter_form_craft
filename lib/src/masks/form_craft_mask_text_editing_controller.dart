part of '../form_craft.dart';

class MaskedTextController extends TextEditingController {
  final PersistentMask _mask;

  MaskedTextController(
    this._mask,
  );

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    bool withComposing = false,
  }) {
    var children = <TextSpan>[];

    if (text.isEmpty) {
      children = _mask.maskPattern.split(',').map((e) {
        return TextSpan(
          text: e,
          style: _mask.maskTextStyle ??
              Theme.of(context).inputDecorationTheme.hintStyle,
        );
      }).toList();
    } else {
      for (var i = 0; i < _mask.maskPattern.length; i++) {
        if (i <= text.length - 1) {
          children.add(
            TextSpan(
              text: text[i],
              style: _mask.inputTextStyle,
            ),
          );
        } else {
          children.add(TextSpan(
            text: _mask.maskPattern[i],
            style: _mask.maskTextStyle ??
                Theme.of(context).inputDecorationTheme.hintStyle,
          ));
        }
      }
    }

    return TextSpan(
      children: children,
    );
  }
}
