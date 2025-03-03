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
    String result = text;
    for (final separator in _separators) {
      result = result.replaceAll(separator, '');
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

    // Проходим по маске, начиная после префикса
    for (var i = fixedPrefix.length; i < splitMask.length; i++) {
      if (index >= clearedValue.length) break;
      final maskChar = splitMask[i];
      if (maskChar == _anyCharMask || maskChar == _onlyDigitMask) {
        // Это позиция для ввода символа
        final curChar = clearedValue[index];
        if (maskChar == _onlyDigitMask && !RegExp(r'[0-9]').hasMatch(curChar)) {
          continue; // Пропускаем недопустимые символы
        }
        placeholder[i] = curChar;
        lastRealCharIndex = i + 1;
        index++;
      } else {
        // Это разделитель
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
    // Если текст полностью удалён или префикс отсутствует, восстанавливаем префикс
    if (newValue.text.length < fixedPrefix.length ||
        !newValue.text.startsWith(fixedPrefix)) {
      return TextEditingValue(
        text: fixedPrefix,
        selection: TextSelection.collapsed(offset: fixedPrefix.length),
      );
    }

    // Выделяем текст, который ввёл пользователь (без префикса)
    String inputText = newValue.text.substring(fixedPrefix.length);

    // Если текст пустой и равен префиксу, возвращаем текущее значение
    if (inputText.isEmpty && newValue.text == fixedPrefix) {
      return newValue;
    }

    // Применяем маску к введённому тексту
    final formattedValue = applyMask(fixedPrefix + inputText);
    _maskedValue = formattedValue._formattedValue;

    // Корректируем позицию курсора
    int selectionIndex = newValue.selection.baseOffset;

    // Если пользователь добавляет символ
    if (newValue.text.length > oldValue.text.length) {
      final newChar = newValue.text[newValue.selection.baseOffset - 1];

      // Если символ совпадает с символом из префикса, но находится за его пределами, разрешаем ввод
      if (fixedPrefix.contains(newChar) &&
          newValue.selection.baseOffset - 1 >= fixedPrefix.length) {
        // Ничего не делаем, символ будет добавлен в маску
      }
    }

    // Корректируем позицию курсора с учётом длины отформатированного текста
    final newTextLength = newValue.text.length;
    final formattedTextLength = _maskedValue.length;
    selectionIndex += formattedTextLength - newTextLength;

    // Ограничиваем позицию курсора в пределах текста
    selectionIndex =
        selectionIndex.clamp(fixedPrefix.length, formattedTextLength);

    // Пропускаем разделители при перемещении курсора
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
