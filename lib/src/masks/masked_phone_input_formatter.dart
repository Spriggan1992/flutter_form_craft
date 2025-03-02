import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:collection/collection.dart';

class MaskedPhoneInputFormatter extends TextInputFormatter {
  final String mask; // Маска
  final String _anyCharMask = 'x';
  final String _onlyDigitMask = '0';
  final RegExp? allowedCharMatcher;
  final List<Separator> _separators = [];
  final String _fixedPrefix;

  String _maskedValue = '';

  MaskedPhoneInputFormatter(
    this.mask, {
    this.allowedCharMatcher,
    String initialValue = '',
    required String fixedPrefix,
  }) : _fixedPrefix = fixedPrefix {
    _prepareMask();
    if (initialValue.isNotEmpty) {
      if (!initialValue.startsWith(_fixedPrefix)) {
        initialValue = _fixedPrefix + initialValue;
      }
      _maskedValue = applyMask(initialValue).text;
    } else {
      _maskedValue = _fixedPrefix;
    }
  }

  bool get isFilled => _maskedValue.length == mask.length;

  String get maskedValue => _maskedValue;

  String get unmaskedValue {
    final stringBuffer = StringBuffer();
    for (var i = 0; i < _maskedValue.length; i++) {
      var char = _maskedValue[i];
      if (!_separators.any((s) => s.value == char)) {
        stringBuffer.write(char);
      }
    }
    return stringBuffer.toString();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final isDeleting = newValue.text.length < oldValue.text.length;

    if (!newValue.text.startsWith(_fixedPrefix)) {
      return oldValue;
    }

    final formattedValue = applyMask(newValue.text);
    _maskedValue = formattedValue.text;

    int cursorPosition = newValue.selection.end;

    if (isDeleting) {
      while (cursorPosition > 0 &&
          _separators.any((s) => s.value == _maskedValue[cursorPosition - 1])) {
        cursorPosition--;
      }
    } else {
      while (cursorPosition < _maskedValue.length &&
          _separators.any((s) => s.value == _maskedValue[cursorPosition])) {
        cursorPosition++;
      }
    }

    cursorPosition = cursorPosition.clamp(0, _maskedValue.length);

    log('Old text: ${oldValue.text}, New text: ${newValue.text}');
    log('Formatted text: $_maskedValue, Cursor: $cursorPosition');

    return TextEditingValue(
      text: _maskedValue,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }

  void _prepareMask() {
    if (_separators.isEmpty) {
      for (var i = 0; i < mask.length; i++) {
        final separatorChar = mask[i];
        if (separatorChar != _anyCharMask && separatorChar != _onlyDigitMask) {
          _separators.add(
            Separator(
              value: separatorChar,
              indexInMask: i,
            ),
          );
        }
      }
    }
  }

  String _removeSeparators(String text) {
    var stringBuffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      var char = text[i];
      if (!_separators.any((s) => s.value == char)) {
        stringBuffer.write(char);
      }
    }
    return stringBuffer.toString();
  }

  Separator? _getSeparatorForIndex(int index) {
    return _separators.firstWhereOrNull(
      (s) => s.indexInMask == index,
    );
  }

  FormattedValue applyMask(String text) {
    final clearedValue = _removeSeparators(text);
    final formattedValue = FormattedValue();
    final stringBuffer = StringBuffer();

    // Добавляем фиксированную часть маски
    stringBuffer.write(_fixedPrefix);

    var index = 0;
    for (var i = _fixedPrefix.length; i < mask.length; i++) {
      final separator = _getSeparatorForIndex(i);
      if (separator == null) {
        if (index < clearedValue.length) {
          final curChar = clearedValue[index];
          final isDigitMask = mask[i] == _onlyDigitMask;

          if (isDigitMask && !isDigit(curChar)) {
            break;
          }

          if (!isDigitMask &&
              allowedCharMatcher != null &&
              !allowedCharMatcher!.hasMatch(curChar)) {
            break;
          }

          stringBuffer.write(curChar);
          index++;
        } else {
          break;
        }
      } else {
        stringBuffer.write(separator.value);
      }
    }

    formattedValue._formattedValue = stringBuffer.toString();
    return formattedValue;
  }

  bool isDigit(String character) {
    if (character.isEmpty) return false;
    final codeUnit = character.codeUnitAt(0);
    return codeUnit >= 48 && codeUnit <= 57;
  }
}

class Separator {
  final String value;
  final int indexInMask;

  Separator({required this.value, required this.indexInMask});
}

class FormattedValue {
  String _formattedValue = '';

  String get text => _formattedValue;

  @override
  String toString() {
    return _formattedValue;
  }
}
