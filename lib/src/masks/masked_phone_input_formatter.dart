import 'package:flutter/services.dart';

class MaskedPhoneInputFormatter extends TextInputFormatter {
  final String mask;
  final String fixedPrefix;
  final RegExp? allowedCharMatcher;

  String _maskedValue = '';
  late final List<String> _separators;

  static const String _anyCharMask = 'x';
  static const String _onlyDigitMask = '0';

  String get maskedValue => _maskedValue;

  MaskedPhoneInputFormatter(
    this.mask, {
    required this.fixedPrefix,
    this.allowedCharMatcher,
    String? initialValue,
  }) {
    _separators = _prepareMask();
    _maskedValue = initialValue?.isNotEmpty == true
        ? fixedPrefix + applyMask(initialValue!).formattedValue
        : fixedPrefix;
  }

  List<String> _prepareMask() {
    return mask
        .split('')
        .where((ch) => ch != _anyCharMask && ch != _onlyDigitMask)
        .toList();
  }

  String _removeSeparators(String text) {
    String result = text;
    for (final separator in _separators) {
      result = result.replaceAll(separator, '');
    }
    return result;
  }

  FormattedValue applyMask(String text) {
    String clearedValue =
        _removeSeparators(text).replaceAll(RegExp(r'[^0-9]'), '');
    final isErasing = _maskedValue.length > (fixedPrefix.length + text.length);
    FormattedValue formattedValue = FormattedValue();
    StringBuffer stringBuffer = StringBuffer();

    var index = 0;
    final splitMask = mask.split('');
    final placeholder = List.filled(splitMask.length, '', growable: false);
    var lastRealCharIndex = 0;

    for (var i = 0; i < splitMask.length && index < clearedValue.length; i++) {
      final maskChar = splitMask[i];
      if (maskChar == _anyCharMask || maskChar == _onlyDigitMask) {
        final curChar = clearedValue[index];
        if (maskChar == _onlyDigitMask && !RegExp(r'[0-9]').hasMatch(curChar)) {
          continue;
        }
        placeholder[i] = curChar;
        lastRealCharIndex = i + 1;
        index++;
      } else {
        placeholder[i] = maskChar;
      }
    }

    for (var i = 0; i < lastRealCharIndex; i++) {
      stringBuffer.write(placeholder[i]);
    }

    formattedValue._isErasing = isErasing;
    formattedValue._formattedValue = stringBuffer.toString();
    return formattedValue;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length < fixedPrefix.length) {
      return TextEditingValue(
        text: fixedPrefix,
        selection: TextSelection.collapsed(offset: fixedPrefix.length),
      );
    }

    if (!newValue.text.startsWith(fixedPrefix)) {
      return TextEditingValue(
        text: fixedPrefix,
        selection: TextSelection.collapsed(offset: fixedPrefix.length),
      );
    }

    String userInput = newValue.text.substring(fixedPrefix.length);

    final formattedValue = applyMask(userInput);
    _maskedValue = fixedPrefix + formattedValue.formattedValue;

    int selectionIndex = newValue.selection.baseOffset;
    if (selectionIndex < fixedPrefix.length) {
      selectionIndex = fixedPrefix.length;
    }

    int offset = selectionIndex - fixedPrefix.length;
    int newOffset = offset;

    if (!formattedValue.isErasing) {
      while (newOffset < formattedValue.formattedValue.length &&
          _separators.contains(formattedValue.formattedValue[newOffset])) {
        newOffset++;
      }
    } else {
      while (newOffset > 0 &&
          _separators.contains(formattedValue.formattedValue[newOffset - 1])) {
        newOffset--;
      }
    }

    selectionIndex = fixedPrefix.length + newOffset;
    if (selectionIndex > _maskedValue.length) {
      selectionIndex = _maskedValue.length;
    }

    return TextEditingValue(
      text: _maskedValue,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

class FormattedValue {
  late String _formattedValue;
  late bool _isErasing;

  String get formattedValue => _formattedValue;
  bool get isErasing => _isErasing;
}
