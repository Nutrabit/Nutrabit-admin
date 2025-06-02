import 'dart:io';
import 'dart:typed_data';
import 'dart:developer'; 
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;
import '../models/file_model.dart';
import '../utils/file_picker_util.dart';

class FileUploaderService {
  static Future<String> uploadLocalFile({
    required File file,
    required String userId,
    required String title,
  }) async {
    try {
      final fileName = _generateFileName(title, path.extension(file.path));
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('users_files/$userId/$fileName');

      final uploadTask = storageRef.putFile(file);
      final taskSnapshot = await uploadTask.whenComplete(() {});

      if (taskSnapshot.state == TaskState.success) {
        return await storageRef.getDownloadURL();
      } else {
        throw 'Error enviando archivo';
      }
    } catch (e) {
      log('Error enviando archivo: $e');
      rethrow;
    }
  }

  static Future<String> uploadWebFile({
    required Uint8List bytes,
    required String fileName,
    required String userId,
  }) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('users_files/$userId/$fileName');

    await ref.putData(bytes);
    return await ref.getDownloadURL();
  }

  static Future<bool> uploadFiles({
    required List<SelectedFile> files,
    required String patientId,
  }) async {
    try {
      for (final file in files) {
        String downloadUrl;
        final baseName = file.title.replaceAll(' ', '_').toLowerCase();
        final fileExtension = file.file != null
            ? path.extension(file.file!.path)
            : path.extension(file.name);
        final formattedName = _generateFileName(baseName, fileExtension);

        if (kIsWeb && file.bytes != null) {
           // 🌐 Si es archivo web (por ejemplo, en navegador)
          downloadUrl = await uploadWebFile(
            bytes: file.bytes!,
            fileName: formattedName,
            userId: patientId,
          );
        } else if (file.file != null) {
           // 📁 Si es archivo físico en dispositivo
          downloadUrl = await uploadLocalFile(
            file: file.file!,
            userId: patientId,
            title: file.title,
          );
        } else {
          continue;
        }

        final docRef = FirebaseFirestore.instance.collection('files').doc();

        final fileModel = FileModel(
          id: docRef.id,
          title: file.title,
          type: file.type,
          url: downloadUrl,
          date: DateTime.now(),
          userId: patientId,
        );

        await docRef.set(fileModel.toJson());
      }

      return true;
    } catch (e) {
      log('Error enviando archivos: $e');
      return false;
    }
  }

  static String _generateFileName(String baseName, String extension) {
    final now = DateTime.now();
    final date = '${now.year}${_twoDigits(now.month)}${_twoDigits(now.day)}'
        '${_twoDigits(now.hour)}${_twoDigits(now.minute)}${_twoDigits(now.second)}'
        '${_threeDigits(now.millisecond)}';
    final cleanedName = baseName.replaceAll(' ', '_').toLowerCase();
    return '$cleanedName$date$extension';
  }

  static String _twoDigits(int n) => n.toString().padLeft(2, '0');
  static String _threeDigits(int n) => n.toString().padLeft(3, '0');
}