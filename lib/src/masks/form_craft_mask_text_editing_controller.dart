part of '../form_craft.dart';

class MaskedTextController extends TextEditingController {
  final RegExp _digitRegExp = RegExp(r'[0-9]');
  PersistentMask _mask;

  MaskedTextController({
    required PersistentMask initialMask,
  }) : _mask = initialMask {
    updateText(text);
  }

  // Метод для обновления маски
  void updateMask(PersistentMask newMask) {
    _mask = newMask;
    updateText(text);
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    bool withComposing = false,
  }) {
    var children = <TextSpan>[];

    if (text.isEmpty) {
      // Если текст пустой, отображаем маску
      children = _mask.maskPattern.split(',').map((e) {
        return TextSpan(
          text: e,
          style: _mask.maskTextStyle ??
              Theme.of(context).inputDecorationTheme.hintStyle,
        );
      }).toList();
    } else {
      // Если текст введен, отображаем его с учетом маски
      for (var i = 0; i < _mask.maskPattern.length; i++) {
        if (i <= text.length - 1) {
          // Введенные данные
          children.add(
            TextSpan(
              text: text[i],
              style: _mask.inputTextStyle,
            ),
          );
        } else {
          // Оставшаяся часть маски
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

  // Метод для применения маски к введенному тексту
  String applyPhoneMask(String input) {
    final buffer = StringBuffer();
    var inputIndex = 0;

    for (var i = 0; i < _mask.maskPattern.length; i++) {
      if (inputIndex >= input.length) break;

      final maskChar = _mask.maskPattern[i];
      if (maskChar == '#') {
        // Заменяем '#' на введенную цифру
        if (inputIndex < input.length &&
            _digitRegExp.hasMatch(input[inputIndex])) {
          buffer.write(input[inputIndex]);
          inputIndex++;
        }
      } else {
        // Добавляем разделитель из маски
        buffer.write(maskChar);
      }
    }

    return buffer.toString();
  }

  // Метод для обновления текста с учетом маски
  void updateText(String input) {
    String maskedText;

    if (_mask.maskType == MaskType.phone) {
      // Если маска для номера телефона, применяем соответствующую логику
      maskedText = applyPhoneMask(input);
    } else {
      // Иначе используем текущую логику (пользовательская маска)
      maskedText = input;
    }

    value = value.copyWith(
      text: maskedText,
      selection: TextSelection.collapsed(offset: maskedText.length),
    );
  }
}
