import 'package:flutter/services.dart';

class DecimalTextInputFormatter extends TextInputFormatter {
  const DecimalTextInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    final reg = RegExp(r'^(0|[1-9]\d*)(\.\d{0,2})?$');
    if (reg.hasMatch(text)) return newValue;

    return oldValue;
  }
}
