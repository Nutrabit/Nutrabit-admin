import 'package:flutter/material.dart';
import 'dart:math';

import 'package:nutrabit_admin/core/utils/decorations.dart';

String normalize(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'[áàäâã]'), 'a')
      .replaceAll(RegExp(r'[éèëê]'), 'e')
      .replaceAll(RegExp(r'[íìïî]'), 'i')
      .replaceAll(RegExp(r'[óòöôõ]'), 'o')
      .replaceAll(RegExp(r'[úùüû]'), 'u')
      .replaceAll('ñ', 'n');
}

bool isValidEmail(String email) {
  final emailRegex = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@"
    r"[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?"
    r"(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*"
    r"\.(com|net|org|edu|gov|mil|info|io|co)$",
    caseSensitive: false,
  );
  return emailRegex.hasMatch(email);
}

String generateRandomPassword({int length = 6}) {
  const chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final rand = Random.secure();
  return List.generate(
    length,
    (index) => chars[rand.nextInt(chars.length)],
  ).join();
}


extension StringCasingExtension on String {
  
  String capitalize() {
    if (isEmpty) return "";
    return this[0].toUpperCase() + substring(1);
  }
}

Future<void> showCustomDialog({
  required BuildContext context,
  required String message,
  required String buttonText,
  required Color buttonColor,
  VoidCallback? onPressed,
}) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            const Divider(),
          ],
        ),
        actions: <Widget>[
          Center(
            child: ElevatedButton(
              onPressed: onPressed ?? () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(buttonText),
            ),
          ),
        ],
      );
    },
  );
}

int calculateAge(DateTime birthday) {
    final now = DateTime.now();
    int age = now.year - birthday.year;
    if (now.month < birthday.month ||
        (now.month == birthday.month && now.day < birthday.day)) {
      age--;
    }
    return age;
  }



  Future<void> showGenericPopupBack({
  required BuildContext context,
  required String message,
  required String id,
  required void Function(BuildContext context, String id) onNavigate,
}) async {
  final style = getDefaultPopupStyle();

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: style.decoration,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              style.icon,
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: style.messageTextStyle,
              ),
              const SizedBox(height: 16),
              const Divider(thickness: 1),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onNavigate(context, id);
                  },
                  style: style.buttonStyle,
                  child: Text(
                    'VOLVER',
                    style: style.buttonTextStyle,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}



Future<void> showGenericPopupBackStatic({
  required BuildContext context,
  required String message,
}) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: Colors.black, width: 2),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFEECDa),
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(22),
          ),
          padding: const EdgeInsets.all(20),
          width: 250,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Color(0xFF2F2F2F),
                ),
              ),
              const SizedBox(height: 10),
              const Divider(thickness: 1),
              const SizedBox(height: 6),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC607A),
                  side: const BorderSide(color: Colors.black),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'VOLVER',
                  style: TextStyle(fontSize: 14, color: Color(0xFFFDEEDB)),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}