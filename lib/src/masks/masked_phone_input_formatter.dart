import 'package:flutter/services.dart';
import 'package:flutter_form_craft/src/masks/mask_formatter.dart';

class MaskedPhoneInputFormatter extends TextInputFormatter {
  final String mask;
  final String fixedPrefix;
  final RegExp? allowedCharMatcher;

  late String _maskedValue;
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
    _maskedValue = initialValue?.isNotEmpty == true
        ? applyMask(initialValue!)._formattedValue
        : fixedPrefix;
    _separators = _prepareMask();
  }

  /// Подготовка списка разделителей из маски
  List<String> _prepareMask() {
    return mask
        .split('')
        .where((ch) => ch != _anyCharMask && ch != _onlyDigitMask)
        .toList();
  }

  /// Удаление разделителей из текста
  String _removeSeparators(String text) {
    String result = text;
    for (final separator in _separators) {
      result = result.replaceAll(separator, '');
    }
    return result;
  }

  /// Получение разделителя для заданного индекса в маске
  Separator? _getSeparatorForIndex(int index) {
    final maskChar = mask[index];
    if (maskChar != _anyCharMask && maskChar != _onlyDigitMask) {
      return Separator(value: maskChar, indexInMask: index);
    }
    return null;
  }

  /// Применение маски к тексту
  FormattedValue applyMask(String text) {
    // Удаляем разделители и оставляем только цифры
    String clearedValue =
        _removeSeparators(text).replaceAll(RegExp(r'[^0-9]'), '');
    final isErasing = _maskedValue.length > text.length;
    FormattedValue formattedValue = FormattedValue();
    StringBuffer stringBuffer = StringBuffer();

    // Добавляем фиксированный префикс
    stringBuffer.write(fixedPrefix);

    var index = 0;
    final splitMask = mask.split('');
    final placeholder = List.filled(splitMask.length, '', growable: false);
    var lastRealCharIndex = fixedPrefix.length;

    // Размещаем цифры в переменных позициях маски
    for (var i = fixedPrefix.length; i < splitMask.length; i++) {
      if (index >= clearedValue.length) break;
      final separator = _getSeparatorForIndex(i);
      if (separator == null) {
        final curChar = clearedValue[index];
        // Проверяем, соответствует ли символ allowedCharMatcher
        if (allowedCharMatcher == null ||
            allowedCharMatcher!.hasMatch(curChar)) {
          placeholder[i] = curChar;
          lastRealCharIndex = i + 1;
          index++;
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

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Если новый текст не начинается с фиксированного префикса, добавляем его
    if (!newValue.text.startsWith(fixedPrefix)) {
      return TextEditingValue(
        text: fixedPrefix + newValue.text,
        selection: TextSelection.collapsed(offset: fixedPrefix.length),
      );
    }

    final isErasing = oldValue.text.length > newValue.text.length;
    final formattedValue = applyMask(newValue.text);
    _maskedValue = formattedValue._formattedValue;

    // Корректировка позиции курсора
    int selectionIndex = newValue.selection.baseOffset;
    if (selectionIndex > _maskedValue.length) {
      selectionIndex = _maskedValue.length;
    } else if (selectionIndex < fixedPrefix.length) {
      selectionIndex = fixedPrefix.length;
    }

    if (!isErasing) {
      // При вставке перемещаем курсор за разделители
      while (selectionIndex < _maskedValue.length &&
          _separators.contains(_maskedValue[selectionIndex])) {
        selectionIndex++;
      }
    } else {
      // При удалении перемещаем курсор перед разделители
      while (selectionIndex > fixedPrefix.length &&
          _separators.contains(_maskedValue[selectionIndex - 1])) {
        selectionIndex--;
      }
    }

    return TextEditingValue(
      text: _maskedValue,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

/// Вспомогательный класс для хранения форматированного значения
class FormattedValue {
  late String _formattedValue;
  late bool _isErasing;

  String get formattedValue => _formattedValue;
  bool get isErasing => _isErasing;
}
