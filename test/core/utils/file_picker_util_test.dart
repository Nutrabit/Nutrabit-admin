import 'dart:typed_data';
import 'dart:io' as io;

import 'package:file_picker/file_picker.dart' as fp;
import 'package:flutter_test/flutter_test.dart';

import 'package:nutrabit_admin/core/models/file_type.dart';
import '../utils/pick_selected_file_test.dart';

void main() {
  test('pickSelectedFile devuelve archivo en modo Web', () async {
    // Archivo simulado con bytes (modo Web)
    final mockResult = fp.FilePickerResult([
      fp.PlatformFile(
        name: 'archivo.pdf',
        size: 3,
        bytes: Uint8List.fromList([1, 2, 3]),
      )
    ]);

    final result = await pickSelectedFile(
      FileType.MEAL_PLAN,
      'Plan de Alimentación',
      filePickerFn: (_) async => mockResult,
      isWeb: true, // Simula entorno web
    );

    expect(result, isNotNull);
    expect(result!.name, 'archivo.pdf');
    expect(result.title, 'Plan de Alimentación');
    expect(result.type, FileType.MEAL_PLAN);
    expect(result.bytes, isNotNull);
    expect(result.file, isNull);
  });

  test('pickSelectedFile devuelve archivo en modo Desktop/Mobile', () async {
    final mockResult = fp.FilePickerResult([
      fp.PlatformFile(
        name: 'archivo.jpg',
        size: 1024,
        path: '/mock/path/archivo.jpg',
      )
    ]);

    final result = await pickSelectedFile(
      FileType.RECOMMENDATIONS,
      'Recomendaciones',
      filePickerFn: (_) async => mockResult,
      isWeb: false, // Simula modo no web
    );

    expect(result, isNotNull);
    expect(result!.name, 'archivo.jpg');
    expect(result.title, 'Recomendaciones');
    expect(result.type, FileType.RECOMMENDATIONS);
    expect(result.file, isA<io.File>());
    expect(result.bytes, isNull);
  });

  test('pickSelectedFile retorna null si no hay archivo', () async {
    final result = await pickSelectedFile(
      FileType.IN_BODY,
      'InBody',
      filePickerFn: (_) async => null,
      isWeb: true,
    );

    expect(result, isNull);
  });
}