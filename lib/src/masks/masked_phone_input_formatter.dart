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
        ? applyMask(initialValue!)._formattedValue
        : fixedPrefix;
  }

  List<String> _prepareMask() {
    return mask
        .split('')
        .where((ch) => ch != _anyCharMask && ch != _onlyDigitMask)
        .toList();
  }

  String _removeSeparators(String text) {
    String result = text; // Обрабатываем всю строку, включая префикс
    for (final separator in _separators) {
      if (!fixedPrefix.contains(separator)) {
        result = result.replaceAll(separator, '');
      }
    }
    return result;
  }

  FormattedValue applyMask(String text) {
    String clearedValue =
        _removeSeparators(text).replaceAll(RegExp(r'[^0-9]'), '');
    final isErasing = _maskedValue.length > text.length;
    FormattedValue formattedValue = FormattedValue();
    StringBuffer stringBuffer = StringBuffer();

    stringBuffer.write(fixedPrefix);

    var index = 0;
    final splitMask = mask.split('');
    final placeholder = List.filled(splitMask.length, '', growable: false);
    var lastRealCharIndex = fixedPrefix.length;

    for (var i = fixedPrefix.length; i < splitMask.length; i++) {
      if (index >= clearedValue.length) break;
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
    if (newValue.text.length < fixedPrefix.length ||
        !newValue.text.startsWith(fixedPrefix)) {
      return TextEditingValue(
        text: fixedPrefix,
        selection: TextSelection.collapsed(offset: fixedPrefix.length),
      );
    }

    String inputText = newValue.text.substring(fixedPrefix.length);

    if (inputText.isEmpty && newValue.text == fixedPrefix) {
      return newValue;
    }

    final formattedValue = applyMask(fixedPrefix + inputText);
    _maskedValue = formattedValue._formattedValue;

    int selectionIndex = newValue.selection.baseOffset;

    if (newValue.text.length > oldValue.text.length) {
      final newChar = newValue.text[newValue.selection.baseOffset - 1];

      if (fixedPrefix.contains(newChar) &&
          newValue.selection.baseOffset - 1 >= fixedPrefix.length) {}
    }

    final newTextLength = newValue.text.length;
    final formattedTextLength = _maskedValue.length;
    selectionIndex += formattedTextLength - newTextLength;

    selectionIndex =
        selectionIndex.clamp(fixedPrefix.length, formattedTextLength);

    while (selectionIndex < _maskedValue.length &&
        _separators.contains(_maskedValue[selectionIndex])) {
      selectionIndex++;
    }

    while (selectionIndex > fixedPrefix.length &&
        _separators.contains(_maskedValue[selectionIndex - 1])) {
      selectionIndex--;
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
