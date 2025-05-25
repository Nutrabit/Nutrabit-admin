import 'package:flutter_test/flutter_test.dart';
import 'package:nutrabit_admin/core/models/file_type.dart';

void main() {
  group('FileTypeExtension', () {
    test('description returns correct string', () {
      expect(FileType.SHOPPING_LIST.description, "Lista de Compras");
      expect(FileType.EXERCISE_PLAN.description, "Plan de Ejercicio");
      expect(FileType.MEAL_PLAN.description, "Plan de Alimentación");
      expect(FileType.RECOMMENDATIONS.description, "Recomendaciones");
      expect(FileType.IN_BODY.description, "InBody");
    });

    test('values list contains all types', () {
      expect(FileType.values.length, 5);
      expect(FileType.values, contains(FileType.SHOPPING_LIST));
      expect(FileType.values, contains(FileType.IN_BODY));
    });
  });
}