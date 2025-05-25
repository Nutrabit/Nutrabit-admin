import 'package:flutter_test/flutter_test.dart';
import 'package:nutrabit_admin/core/utils/utils.dart';

void main() {
  group('normalize()', () {
    test('convierte tildes y diacríticos a letras simples', () {
      expect(normalize('áéíóú'), 'aeiou');
      expect(normalize('àèìòù'), 'aeiou');
      expect(normalize('äëïöü'), 'aeiou');
      expect(normalize('âêîôû'), 'aeiou');
      expect(normalize('ãõ'), 'ao');
      expect(normalize('Ñ'), 'n');
      expect(normalize('NiÑo'), 'nino');
    });

    test('convierte mayúsculas a minúsculas', () {
      expect(normalize('JOSÉ'), 'jose');
    });
  });

  group('isValidEmail()', () {
    test('valida emails correctos', () {
      expect(isValidEmail('test@example.com'), isTrue);
      expect(isValidEmail('usuario123@dominio.net'), isTrue);
      expect(isValidEmail('correo.email@dominio.co'), isTrue);
    });

    test('rechaza emails incorrectos', () {
      expect(isValidEmail('sin-arroba.com'), isFalse);
      expect(isValidEmail('nombre@dominio'), isFalse);
      expect(isValidEmail('nombre@dominio.xyz'), isFalse);
      expect(isValidEmail('@falso.com'), isFalse);
      expect(isValidEmail(''), isFalse);
    });
  });

  group('generateRandomPassword()', () {
    test('genera una contraseña de longitud predeterminada (6)', () {
      final pass = generateRandomPassword();
      expect(pass.length, 6);
    });

    test('genera una contraseña de longitud personalizada', () {
      final pass = generateRandomPassword(length: 12);
      expect(pass.length, 12);
    });

    test('solo contiene caracteres válidos', () {
      final validChars =
          'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
      final pass = generateRandomPassword(length: 100);
      expect(pass.split('').every((c) => validChars.contains(c)), isTrue);
    });
  });

  group('String.capitalize()', () {
    test('capitaliza una palabra normal', () {
      expect('hola'.capitalize(), 'Hola');
    });

    test('retorna vacío si el string está vacío', () {
      expect(''.capitalize(), '');
    });

    test('no modifica strings que ya están capitalizados', () {
      expect('Hola'.capitalize(), 'Hola');
    });
  });
}