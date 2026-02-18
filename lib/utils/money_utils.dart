// FORMATTERS... (UzbekPhone va ThousandsSeparator o'sha-o'sha qoladi)
// --- FORMATTERS ---
import 'package:flutter/services.dart';

class UzbekPhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue newVal) {
    if (newVal.selection.baseOffset < old.selection.baseOffset) return newVal;
    String digits = newVal.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return newVal.copyWith(text: '');
    final buffer = StringBuffer();
    buffer.write('+');
    for (int i = 0; i < digits.length; i++) {
      if (i == 3) buffer.write(' (');
      if (i == 5) buffer.write(') ');
      if (i == 8 || i == 10) buffer.write('-');
      if (i < 12) buffer.write(digits[i]);
    }
    return TextEditingValue(text: buffer.toString(), selection: TextSelection.collapsed(offset: buffer.toString().length));
  }
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue newVal) {
    if (newVal.text.isEmpty) return newVal.copyWith(text: '');
    String clean = newVal.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < clean.length; i++) {
      if (i > 0 && (clean.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(clean[i]);
    }
    return newVal.copyWith(text: buffer.toString(), selection: TextSelection.collapsed(offset: buffer.toString().length));
  }
}