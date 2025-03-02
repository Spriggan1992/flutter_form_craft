import 'package:flutter/services.dart';
import 'package:flutter_form_craft/src/masks/mask_formatter.dart';
import 'package:collection/collection.dart';

class MaskedPhoneInputFormatter extends TextInputFormatter {
  final String mask; // Маска (теперь может изменяться)
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

  bool isDigit(String character, {bool positiveOnly = true}) {
    if (character.isEmpty) return false;
    final codeUnit = character.codeUnitAt(0);
    if (positiveOnly) {
      return codeUnit >= 48 && codeUnit <= 57;
    }
    return (codeUnit >= 48 && codeUnit <= 57) || character == '-';
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Убедимся, что фиксированная часть маски всегда присутствует
    if (!newValue.text.startsWith(_fixedPrefix)) {
      return oldValue;
    }

    final FormattedValue oldFormattedValue = applyMask(oldValue.text);
    final FormattedValue newFormattedValue = applyMask(newValue.text);

    var numSeparatorsInNew = 0;
    var numSeparatorsInOld = 0;

    var addOffset = newFormattedValue._numLeadingSymbols;
    numSeparatorsInOld = _countSeparators(oldFormattedValue.text);
    numSeparatorsInNew = _countSeparators(newFormattedValue.text);

    var separatorsDiff = (numSeparatorsInNew - numSeparatorsInOld);
    if (newFormattedValue._isErasing) {
      separatorsDiff = 0;
    }
    var selectionOffset = newValue.selection.end + separatorsDiff;
    _maskedValue = newFormattedValue.text;

    if (selectionOffset > _maskedValue.length) {
      selectionOffset = _maskedValue.length;
    }

    return TextEditingValue(
      text: _maskedValue,
      selection: TextSelection.collapsed(
        offset: selectionOffset + addOffset,
        affinity: TextAffinity.upstream,
      ),
    );
  }

  bool _isMatchingRestrictor(String character) {
    if (allowedCharMatcher == null) {
      return true;
    }
    return allowedCharMatcher!.stringMatch(character) != null;
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

  int _countSeparators(String text) {
    var numSeparators = 0;
    for (var i = 0; i < text.length; i++) {
      final char = text[i];

      if (_separators.any((s) => s.value == char)) {
        numSeparators++;
      }
    }
    return numSeparators;
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
    String clearedValueAfter = _removeSeparators(text);
    final isErasing = _maskedValue.length > text.length;
    FormattedValue formattedValue = FormattedValue();
    StringBuffer stringBuffer = StringBuffer();

    // Добавляем фиксированную часть маски
    stringBuffer.write(_fixedPrefix);

    var index = 0;
    final splitMask = mask.split('');
    final placeholder = List.filled(splitMask.length, '', growable: false);
    var lastRealCharIndex = 0;

    // Начинаем ввод с места после фиксированной части маски
    for (var i = _fixedPrefix.length; i < splitMask.length; i++) {
      final separator = _getSeparatorForIndex(i);
      if (separator == null) {
        if (clearedValueAfter.length > index) {
          final maskOnDigitMatcher = splitMask[i] == _onlyDigitMask;
          var curChar = clearedValueAfter[index];
          if (maskOnDigitMatcher) {
            if (!isDigit(curChar, positiveOnly: true)) {
              break;
            }
          } else {
            if (!_isMatchingRestrictor(curChar)) {
              break;
            }
          }
          placeholder[i] = curChar;
          lastRealCharIndex = i + 1;
          index++;
        } else {
          break;
        }
      } else {
        placeholder[i] = separator.value;
      }
    }

    for (var i = 0; i < lastRealCharIndex; i++) {
      stringBuffer.write(placeholder[i]);
    }
    formattedValue._isErasing = isErasing;
    formattedValue._formattedValue = stringBuffer.toString();

    return formattedValue;
  }
}

class FormattedValue {
  String _formattedValue = '';
  bool _isErasing = false;
  int _numLeadingSymbols = 0;

  String get text {
    return _formattedValue;
  }

  void increaseNumberOfLeadingSymbols() {
    _numLeadingSymbols++;
  }

  @override
  String toString() {
    return _formattedValue;
  }
}
