import 'package:flutter/material.dart';
import 'package:flutter_form_craft/form_craft.dart';
import 'package:flutter_form_craft/src/masks/mask_type.dart';

class PersistentMask {
  final String maskPattern;
  final TextStyle? maskTextStyle;
  final TextStyle? inputTextStyle;
  final FormCraftValidator? validator;
  final MaskType maskType;

  const PersistentMask._({
    required this.maskPattern,
    required this.maskType,
    this.maskTextStyle,
    this.inputTextStyle,
    this.validator,
  });

  factory PersistentMask.phone({
    required String maskPattern,
    TextStyle? maskTextStyle,
    TextStyle? inputTextStyle,
    final String message = 'Invalid value',
    MaskType maskType = MaskType.phone,
  }) =>
      PersistentMask._(
        maskPattern: maskPattern,
        maskType: maskType,
        maskTextStyle: maskTextStyle,
        inputTextStyle: inputTextStyle,
        validator: FormCraftValidator.custom(
          message: message,
          predicate: (input) {
            return input!.length == maskPattern.length;
          },
        ),
      );

  factory PersistentMask.defaultValidator({
    required String maskPattern,
    TextStyle? maskTextStyle,
    TextStyle? inputTextStyle,
    final String message = 'Invalid value',
    final bool validateEmpty = true,
  }) {
    return PersistentMask._(
      maskPattern: maskPattern,
      maskTextStyle: maskTextStyle,
      inputTextStyle: inputTextStyle,
      maskType: MaskType.custom,
      validator: FormCraftValidator.custom(
          message: message,
          predicate: (input) {
            if (validateEmpty) {
              return input!.length == maskPattern.length;
            } else {
              return input!.isEmpty ? true : input.length == maskPattern.length;
            }
          }),
    );
  }
}
