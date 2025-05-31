import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;
import '../models/file_model.dart';
import '../utils/file_picker_util.dart';

class FileUploaderService {
  static Future<String> uploadSingleFile(File file, String userId) async {
    try {
      final fileExtension = path.extension(file.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}$fileExtension';

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
      print('Error enviando archivo');
      rethrow;
    }
  }

  /// Retorna `true` si se subieron todos los archivos correctamente, `false` si hubo un error
  static Future<bool> uploadFiles({
    required List<SelectedFile> files,
    required String patientId,
  }) async {
    try {
      for (final file in files) {
        String downloadUrl;

        if (kIsWeb && file.bytes != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('users_files/$patientId/${file.name}');
          await ref.putData(file.bytes!);
          downloadUrl = await ref.getDownloadURL();
        } else if (file.file != null) {
          downloadUrl = await uploadSingleFile(file.file!, patientId);
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
      print('Error enviando archivos: $e');
      return false;
    }
  }
}