import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrabit_admin/core/utils/file_picker_util.dart';
import 'package:nutrabit_admin/presentation/providers/file_provider.dart'; // ajusta la ruta si es necesario
import 'dart:typed_data';
import 'package:nutrabit_admin/core/models/file_type.dart';

void main() {
  group('FileNotifier', () {
    late ProviderContainer container;

    final testFile = SelectedFile(
      name: 'test.pdf',
      title: 'Plan de Ejercicios',
      type: FileType.EXERCISE_PLAN,
      bytes: Uint8List.fromList([1, 2, 3]),
      file: null, // simulamos Web
    );

    setUp(() {
      container = ProviderContainer();
    });

    test('Estado inicial vacío', () {
      final files = container.read(fileProvider);
      expect(files.files, isEmpty);
    });

    test('addFile agrega un archivo correctamente', () {
      container.read(fileProvider.notifier).addFile(testFile);
      final files = container.read(fileProvider);
      expect(files.files.length, 1);
      expect(files.files.first.name, 'test.pdf');
    });

    test('removeFile elimina el archivo especificado', () {
      final notifier = container.read(fileProvider.notifier);
      notifier.addFile(testFile);
      notifier.removeFile(testFile);

      final files = container.read(fileProvider);
      expect(files.files, isEmpty);
    });

    test('clear limpia todos los archivos', () {
      final notifier = container.read(fileProvider.notifier);
      notifier.addFile(testFile);
      notifier.clear();

      final files = container.read(fileProvider);
      expect(files.files, isEmpty);
    });
  });
}