import 'package:flutter/services.dart';

/// يحوّل الأرقام العربية (٠-٩ و۰-۹) إلى أرقام إنجليزية أثناء الكتابة،
/// لأن معالجة أرقام الهواتف تتجاهل الأرقام العربية.
class WesternDigitsFormatter extends TextInputFormatter {
  const WesternDigitsFormatter();

  static String convert(String input) {
    final buffer = StringBuffer();
    for (final unit in input.codeUnits) {
      if (unit >= 0x0660 && unit <= 0x0669) {
        buffer.writeCharCode(0x30 + (unit - 0x0660));
      } else if (unit >= 0x06F0 && unit <= 0x06F9) {
        buffer.writeCharCode(0x30 + (unit - 0x06F0));
      } else {
        buffer.writeCharCode(unit);
      }
    }
    return buffer.toString();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final converted = convert(newValue.text);
    if (converted == newValue.text) return newValue;
    return newValue.copyWith(text: converted);
  }
}
