import 'package:flutter/material.dart';

InputDecoration textFieldDecoration(String label) {
  return InputDecoration(
    labelText: label,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  );
}

  ButtonStyle mainButtonDecoration() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFDC607A),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  InputDecoration inputDecoration(String label, {String? suffix}) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(fontSize: 14, color: Colors.grey),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xFFDC607A), width: 2.0),
      borderRadius: BorderRadius.circular(8),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xFFDC607A), width: 1.5),
      borderRadius: BorderRadius.circular(8),
    ),
    suffixText: suffix, // Aquí se añade el sufijo opcional
  );
}