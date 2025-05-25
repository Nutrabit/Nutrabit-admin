import 'dart:typed_data';
import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart' as fp;
import 'package:nutrabit_admin/core/models/file_type.dart';

typedef FilePickerFunction = Future<fp.FilePickerResult?> Function(bool withData);

class SelectedFile {
  final Uint8List? bytes;
  final io.File? file;
  final String name;
  final String title;
  final FileType type;

  SelectedFile({
    this.bytes,
    this.file,
    required this.name,
    required this.title,
    required this.type,
  });
}

Future<SelectedFile?> pickSelectedFile(
  FileType type,
  String title, {
  FilePickerFunction filePickerFn = _defaultFilePickerFn,
  bool isWeb = kIsWeb,
}) async {
  final result = await filePickerFn(isWeb);

  if (result != null && result.files.isNotEmpty) {
    final file = result.files.single;

    if (!isWeb && file.path == null) return null;

    return SelectedFile(
      bytes: isWeb ? file.bytes : null,
      file: !isWeb && file.path != null ? io.File(file.path!) : null,
      name: file.name,
      title: title,
      type: type,
    );
  } else {
    return null;
  }
}

Future<fp.FilePickerResult?> _defaultFilePickerFn(bool withData) {
  return fp.FilePicker.platform.pickFiles(withData: withData);
}