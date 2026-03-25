part of 'mask_formatter.dart';

final RegExp _digitRegExp = RegExp(r'[-0-9]+');
final RegExp _positiveDigitRegExp = RegExp(r'[0-9]+');
final RegExp _digitWithPeriodRegExp = RegExp(r'[-0-9]+(\.[0-9]+)?');
final RegExp _oneDashRegExp = RegExp(r'[-]{2,}');
final RegExp _startPlusRegExp = RegExp(r'^\+{1}[)(\d]+');
final RegExp _maskContentsRegExp = RegExp(r'^[-0-9)( +]{3,}$');
final RegExp _isMaskSymbolRegExp = RegExp(r'^[-\+ )(]+$');
// final RegExp _repeatingDotsRegExp = RegExp(r'\.{2,}');
final _spaceRegex = RegExp(r'[\s]+');

/// [errorText] if you don't want this method to throw any
/// errors, pass null here
/// [allowAllZeroes] might be useful e.g. for phone masks
String toNumericString(
  String? inputString, {
  bool allowPeriod = false,
  bool allowHyphen = true,
  String mantissaSeparator = '.',
  String? errorText,
  bool allowAllZeroes = false,
  int? mantissaLength,
}) {
  if (inputString == null) {
    return '';
  } else if (inputString == '+') {
    return inputString;
  }
  // if (mantissaLength != null) {
  //   if (mantissaLength < 1) {
  //     /// a small hack to fix this https://github.com/caseyryan/flutter_multi_formatter/issues/136
  //     // inputString = inputString.replaceAll('.', '');
  //   }
  // }
  if (mantissaSeparator == '.') {
    inputString = inputString.replaceAll(',', '');
  } else if (mantissaSeparator == ',') {
    final fractionSep = _detectFractionSeparator(inputString);
    if (fractionSep != null) {
      inputString = inputString.replaceAll(fractionSep, '%FRAC%');
    }
    inputString = inputString.replaceAll('.', '').replaceAll('%FRAC%', '.');
  }
  var startsWithPeriod = numericStringStartsWithOrphanPeriod(
    inputString,
  );

  var regexWithoutPeriod = allowHyphen ? _digitRegExp : _positiveDigitRegExp;
  var regExp = allowPeriod ? _digitWithPeriodRegExp : regexWithoutPeriod;
  var result = inputString.splitMapJoin(
    regExp,
    onMatch: (m) => m.group(0)!,
    onNonMatch: (nm) => '',
  );
  if (startsWithPeriod && allowPeriod) {
    result = '0.$result';
  }
  if (result.isEmpty) {
    return result;
  }
  try {
    result = _toDoubleString(
      result,
      allowPeriod: allowPeriod,
      errorText: errorText,
      allowAllZeroes: allowAllZeroes,
    );
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
  }
  return result;
}

String toNumericStringByRegex(
  String? inputString, {
  bool allowPeriod = false,
  bool allowHyphen = true,
}) {
  if (inputString == null) return '';
  var regexWithoutPeriod = allowHyphen ? _digitRegExp : _positiveDigitRegExp;
  var regExp = allowPeriod ? _digitWithPeriodRegExp : regexWithoutPeriod;
  return inputString.splitMapJoin(
    regExp,
    onMatch: (m) => m.group(0)!,
    onNonMatch: (nm) => '',
  );
}

/// This hack is necessary because double.parse
/// fails at some point
/// while parsing too large numbers starting to convert
/// them into a scientific notation with e+/- power
/// This function doesnt' really care for numbers, it works
/// with strings from the very beginning
/// [input] a value to be converted to a string containing only numbers
/// [allowPeriod] if you need int pass false here
/// [errorText] if you don't want this method to throw an
/// error if a number cannot be formatted
/// pass null
/// [allowAllZeroes] might be useful e.g. for phone masks
String _toDoubleString(
  String input, {
  bool allowPeriod = true,
  String? errorText = 'Invalid number',
  bool allowAllZeroes = false,
}) {
  const period = '.';
  const zero = '0';
  const dash = '-';
  // final allowedSymbols = ['-', period];
  final temp = <String>[];
  if (input.startsWith(period)) {
    if (allowPeriod) {
      temp.add(zero);
    } else {
      return zero;
    }
  }
  bool periodUsed = false;

  for (var i = 0; i < input.length; i++) {
    final char = input[i];
    if (!isDigit(char, positiveOnly: true)) {
      if (char == dash) {
        if (i > 0) {
          if (errorText != null) {
            throw errorText;
          } else {
            continue;
          }
        }
      } else if (char == period) {
        if (!allowPeriod) {
          break;
        } else if (periodUsed) {
          continue;
        }
        periodUsed = true;
      }
    }
    temp.add(char);
  }
  if (temp.contains(period)) {
    while (temp.isNotEmpty && temp[0] == zero) {
      temp.removeAt(0);
    }
    if (temp.isEmpty) {
      return zero;
    } else if (temp[0] == period) {
      temp.insert(0, zero);
    }
  } else {
    if (!allowAllZeroes) {
      while (temp.length > 1) {
        if (temp.first == zero) {
          temp.removeAt(0);
        } else {
          break;
        }
      }
    }
  }
  return temp.join();
}

bool numericStringStartsWithOrphanPeriod(String string) {
  var result = false;
  for (var i = 0; i < string.length; i++) {
    var char = string[i];
    if (isDigit(char)) {
      break;
    }
    if (char == '.' || char == ',') {
      result = true;
      break;
    }
  }
  return result;
}

void checkMask(String mask) {
  if (_oneDashRegExp.hasMatch(mask)) {
    throw ('A mask cannot contain more than one dash (-) symbols in a row');
  }
  if (!_startPlusRegExp.hasMatch(mask)) {
    throw ('A mask must start with a + sign followed by a digit of a rounded brace');
  }
  if (!_maskContentsRegExp.hasMatch(mask)) {
    throw ('A mask can only contain digits, a plus sign, spaces and dashes');
  }
}

String _getThousandSeparator(
  ThousandSeparator thousandSeparator,
) {
  if (thousandSeparator == ThousandSeparator.Comma) {
    return ',';
  }
  if (thousandSeparator == ThousandSeparator.SpaceAndCommaMantissa ||
      thousandSeparator == ThousandSeparator.SpaceAndPeriodMantissa ||
      thousandSeparator == ThousandSeparator.Space) {
    return ' ';
  }
  if (thousandSeparator == ThousandSeparator.Period) {
    return '.';
  }
  return '';
}

String _getMantissaSeparator(
  ThousandSeparator thousandSeparator,
  int mantissaLength,
) {
  if (mantissaLength < 1) {
    return '';
  }
  if (thousandSeparator == ThousandSeparator.Comma) {
    return '.';
  }
  if (thousandSeparator == ThousandSeparator.Period ||
      thousandSeparator == ThousandSeparator.SpaceAndCommaMantissa) {
    return ',';
  }
  return '.';
}

final RegExp _possibleFractionRegExp = RegExp(r'[,.]');
String? _detectFractionSeparator(String value) {
  final index = value.lastIndexOf(_possibleFractionRegExp);
  if (index < 0) {
    return null;
  }
  final separator = value[index];
  int numOccurrences = 0;
  for (var i = 0; i < value.length; i++) {
    final char = value[i];
    if (char == separator) {
      numOccurrences++;
    }
  }
  if (numOccurrences == 1) {
    return separator;
  }
  return null;
}

ShorteningPolicy _detectShorteningPolicyByStrLength(String evenPart) {
  if (evenPart.length > 3 && evenPart.length < 7) {
    return ShorteningPolicy.RoundToThousands;
  }
  if (evenPart.length > 6 && evenPart.length < 10) {
    return ShorteningPolicy.RoundToMillions;
  }
  if (evenPart.length > 9 && evenPart.length < 13) {
    return ShorteningPolicy.RoundToBillions;
  }
  if (evenPart.length > 12) {
    return ShorteningPolicy.RoundToTrillions;
  }

  return ShorteningPolicy.NoShortening;
}

/// [isRawValue] pass true if you
String toCurrencyString(
  String value, {
  int mantissaLength = 2,
  ThousandSeparator thousandSeparator = ThousandSeparator.Comma,
  ShorteningPolicy shorteningPolicy = ShorteningPolicy.NoShortening,
  String leadingSymbol = '',
  String trailingSymbol = '',
  bool useSymbolPadding = false,
  bool isRawValue = false,
}) {
  bool isNegative = false;
  if (value.startsWith('-')) {
    value = value.replaceAll(RegExp(r'^[-+]+'), '');
    isNegative = true;
  }
  value = value.replaceAll(_spaceRegex, '');
  if (value.isEmpty) {
    value = '0';
  }
  String mSeparator = _getMantissaSeparator(
    thousandSeparator,
    mantissaLength,
  );
  String tSeparator = _getThousandSeparator(
    thousandSeparator,
  );

  /// нужно только для того, чтобы не допустить числа начинающиеся с нуля
  /// 04.00 и т.д
  value = toNumericString(
    value,
    allowAllZeroes: false,
    allowHyphen: true,
    allowPeriod: true,
    mantissaSeparator: mSeparator,
    mantissaLength: mantissaLength,
  );
  bool hasFraction = mantissaLength > 0;
  String? fractionalSeparator;
  if (hasFraction) {
    fractionalSeparator = _detectFractionSeparator(value);
  } else {
    value = value.replaceAll(tSeparator, '');
  }

  var sb = StringBuffer();

  bool addedMantissaSeparator = false;
  for (var i = 0; i < value.length; i++) {
    final char = value[i];
    if (char == '-') {
      if (i > 0) {
        continue;
      }
      sb.write(char);
    }
    if (isDigit(char, positiveOnly: true)) {
      sb.write(char);
    }
    if (char == fractionalSeparator) {
      if (!addedMantissaSeparator) {
        sb.write('.');
        addedMantissaSeparator = true;
      } else {
        continue;
      }
    } else {
      if (!hasFraction) {
        if (char == '.' && char != tSeparator) {
          break;
        }
      }
    }
  }

  final str = sb.toString();
  final evenPart =
      addedMantissaSeparator ? str.substring(0, str.indexOf('.')) : str;

  int skipEvenNumbers = 0;
  String shorteningName = '';
  if (shorteningPolicy != ShorteningPolicy.NoShortening) {
    switch (shorteningPolicy) {
      case ShorteningPolicy.NoShortening:
        break;
      case ShorteningPolicy.RoundToThousands:
        skipEvenNumbers = 3;
        shorteningName = 'K';
        break;
      case ShorteningPolicy.RoundToMillions:
        skipEvenNumbers = 6;
        shorteningName = 'M';
        break;
      case ShorteningPolicy.RoundToBillions:
        skipEvenNumbers = 9;
        shorteningName = 'B';
        break;
      case ShorteningPolicy.RoundToTrillions:
        skipEvenNumbers = 12;
        shorteningName = 'T';
        break;
      case ShorteningPolicy.Automatic:
        // find out what shortening to use base on the length of the string
        final policy = _detectShorteningPolicyByStrLength(evenPart);
        return toCurrencyString(
          value,
          leadingSymbol: leadingSymbol,
          mantissaLength: mantissaLength,
          shorteningPolicy: policy,
          thousandSeparator: thousandSeparator,
          trailingSymbol: trailingSymbol,
          useSymbolPadding: useSymbolPadding,
        );
    }
  }
  bool ignoreMantissa = skipEvenNumbers > 0;

  final fractionalPart =
      addedMantissaSeparator ? str.substring(str.indexOf('.') + 1) : '';
  final reversed = evenPart.split('').reversed.toList();
  List<String> temp = [];
  bool skippedLast = false;
  for (var i = 0; i < reversed.length; i++) {
    final char = reversed[i];
    if (skipEvenNumbers > 0) {
      skipEvenNumbers--;
      skippedLast = true;
      continue;
    }
    if (i > 0) {
      if (i % 3 == 0) {
        if (!skippedLast) {
          temp.add(tSeparator);
        }
      }
    }
    skippedLast = false;
    temp.add(char);
  }
  value = temp.reversed.join('');
  sb = StringBuffer();
  for (var i = 0; i < mantissaLength; i++) {
    if (i < fractionalPart.length) {
      sb.write(fractionalPart[i]);
    } else {
      sb.write('0');
    }
  }

  final fraction = sb.toString();
  if (value.isEmpty) {
    value = '0';
  }
  if (ignoreMantissa) {
    value = '$value$shorteningName';
  } else {
    value = '$value$mSeparator$fraction';
  }

  // print(value);

  /// add leading and trailing
  sb = StringBuffer();
  for (var i = 0; i < value.length; i++) {
    if (i == 0) {
      if (leadingSymbol.isNotEmpty) {
        sb.write(leadingSymbol);
        if (useSymbolPadding) {
          sb.write(' ');
        }
      }
    }
    sb.write(value[i]);
    if (i == value.length - 1) {
      if (trailingSymbol.isNotEmpty) {
        if (useSymbolPadding) {
          sb.write(' ');
        }
        sb.write(trailingSymbol);
      }
    }
  }
  value = sb.toString();
  if (isNegative) {
    return '-$value';
  }
  return value;
}

bool isUnmaskableSymbol(String? symbol) {
  if (symbol == null || symbol.length > 1) {
    return false;
  }
  return _isMaskSymbolRegExp.hasMatch(symbol);
}

/// Checks if currency is fiat
bool isFiatCurrency(String currencyId) {
  if (currencyId.length != 3) {
    return false;
  }
  return allFiatCurrencies.contains(
    currencyId.toUpperCase(),
  );
}

/// Basically it doesn't really check if the currencyId is
/// a crypto currency. It just checks if it's not fiat.
/// I decided not to collect all possible crypto currecies as
/// there's an endless amount of them
bool isCryptoCurrency(String currencyId) {
  if (currencyId.length < 3 || currencyId.length > 4) {
    return false;
  }
  return !isFiatCurrency(currencyId);
}

/// [character] a character to check if it's a digit against
/// [positiveOnly] if true it will not allow a minus (dash) character
/// to be accepted as a part of a digit
bool isDigit(
  String? character, {
  bool positiveOnly = false,
}) {
  if (character == null || character.isEmpty || character.length > 1) {
    return false;
  }
  if (positiveOnly) {
    return _positiveDigitRegExp.stringMatch(character) != null;
  }
  return _digitRegExp.stringMatch(character) != null;
}

enum ShorteningPolicy {
  /// displays a value of 1234456789.34 as 1,234,456,789.34
  NoShortening,

  /// displays a value of 1234456789.34 as 1,234,456K
  RoundToThousands,

  /// displays a value of 1234456789.34 as 1,234M
  RoundToMillions,

  /// displays a value of 1234456789.34 as 1B
  RoundToBillions,
  RoundToTrillions,

  /// uses K, M, B, or T depending on how big the numeric value is
  Automatic
}

/// [Comma] means this format 1,000,000.00
/// [Period] means thousands and mantissa will look like this
/// 1.000.000,00
/// [None] no separator will be applied at all
/// [SpaceAndPeriodMantissa] 1 000 000.00
/// [SpaceAndCommaMantissa] 1 000 000,00
enum ThousandSeparator {
  Comma,
  Space,
  Period,
  None,
  SpaceAndPeriodMantissa,
  SpaceAndCommaMantissa,
}

const allFiatCurrencies = <String>[
  'CNY',
  'USD',
  'EUR',
  'JPY',
  'GBP',
  'KRW',
  'INR',
  'CAD',
  'HKD',
  'BRL',
  'AUD',
  'TWD',
  'RUB',
  'CHF',
  'MXN',
  'SAR',
  'THB',
  'AED',
  'SGD',
  'VND',
  'IDR',
  'ILS',
  'MYR',
  'SEK',
  'PLN',
  'TRY',
  'CLP',
  'NOK',
  'PHP',
  'ZAR',
  'EGP',
  'DKK',
  'CZK',
  'NZD',
  'QAR',
  'COP',
  'MAD',
  'PKR',
  'LBP',
  'KWD',
  'RON',
  'NGN',
  'ARS',
  'IQD',
  'HUF',
  'MOP',
  'PEN',
  'BGN',
  'KZT',
  'UAH',
  'JOD',
  'OMR',
  'GTQ',
  'BHD',
  'DOP',
  'XOF',
  'KES',
  'BOB',
  'RSD',
  'LKR',
  'HRK',
  'AZN',
  'AOA',
  'HNL',
  'BYN',
  'CRC',
  'LYD',
  'MUR',
  'ISK',
  'PYG',
  'TZS',
  'TTD',
  'ALL',
  'CDF',
  'GEL',
  'BND',
  'UYU',
  'MZN',
  'BSD',
  'UGX',
  'MNT',
  'LAK',
  'SDG',
  'BWP',
  'NAD',
  'BAM',
  'MKD',
  'AMD',
  'MDL',
  'XPF',
  'JMD',
  'NIO',
  'GNF',
  'MGA',
  'KGS',
  'MVR',
  'RWF',
  'GYD',
  'BTN',
  'CVE',
  'SCR',
  'XAF',
  'BIF',
  'SZL',
  'GMD',
  'LRD',
  'SLL',
  'LSL',
  'KMF',
  'BDT',
  'TND',
  'ZMK',
  'TJS',
  'MWK',
  'STD',
];
