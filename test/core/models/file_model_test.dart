import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutrabit_admin/core/models/file_model.dart';
import 'package:nutrabit_admin/core/models/file_type.dart';

void main() {
  group('FileModel', () {
    final now = DateTime.now();

    final file = FileModel(
      id: 'file123',
      title: 'Plan de Ejercicios',
      type: FileType.EXERCISE_PLAN,
      url: 'https://example.com/file.pdf',
      date: now,
      userId: 'user456',
    );

    test('toJson serializes correctly', () {
      final json = file.toJson();

      expect(json['title'], 'Plan de Ejercicios');
      expect(json['type'], FileType.EXERCISE_PLAN.name);
      expect(json['url'], 'https://example.com/file.pdf');
      expect(json['date'], Timestamp.fromDate(now));
      expect(json['userId'], 'user456');
      expect(json.containsKey('id'), isFalse); // el ID no está en el JSON
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'title': 'Plan de Ejercicios',
        'type': 'EXERCISE_PLAN',
        'url': 'https://example.com/file.pdf',
        'date': Timestamp.fromDate(now),
        'userId': 'user456',
      };

      final parsed = FileModel.fromJson(json, id: 'file123');

      expect(parsed.id, 'file123');
      expect(parsed.title, 'Plan de Ejercicios');
      expect(parsed.type, FileType.EXERCISE_PLAN);
      expect(parsed.url, 'https://example.com/file.pdf');
      expect(parsed.date, now);
      expect(parsed.userId, 'user456');
    });

    test('fromJson throws if type is unknown', () {
      final invalidJson = {
        'title': 'Archivo extraño',
        'type': 'UNKNOWN_TYPE',
        'url': 'https://example.com/file.pdf',
        'date': Timestamp.fromDate(now),
        'userId': 'user456',
      };

      expect(() => FileModel.fromJson(invalidJson),
          throwsA(isA<StateError>())); // porque falla el `firstWhere`
    });
  });
}