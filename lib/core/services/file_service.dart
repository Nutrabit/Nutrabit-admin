import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;
import '../models/file_model.dart';
import '../utils/file_picker_util.dart';

class FileUploaderService {
  static Future<String> uploadSingleFile(File file, String userId, {String? fileName}) async {
    try {
      final fileExtension = path.extension(file.path);
      final resolvedFileName = fileName ?? '${DateTime.now().millisecondsSinceEpoch}$fileExtension';

      final storageRef =
          FirebaseStorage.instance.ref().child('users_files/$userId/$resolvedFileName');

      final uploadTask = storageRef.putFile(file);
      final taskSnapshot = await uploadTask.whenComplete(() {});

      if (taskSnapshot.state == TaskState.success) {
        return await storageRef.getDownloadURL();
      } else {
        throw 'Error enviando archivo';
      }
    } catch (e, stackTrace) {
      log('Error enviando archivo', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  static Future<bool> uploadFiles({
    required List<SelectedFile> files,
    required String patientId,
  }) async {
    try {
      for (final file in files) {
        String downloadUrl;

        final docRef = FirebaseFirestore.instance.collection('files').doc();
        final fileId = docRef.id;
        final fileName = '$fileId${path.extension(file.name)}';

        if (kIsWeb && file.bytes != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('users_files/$patientId/$fileName');
          await ref.putData(file.bytes!);
          downloadUrl = await ref.getDownloadURL();
        } else if (file.file != null) {
          downloadUrl = await uploadSingleFile(file.file!, patientId, fileName: fileName);
        } else {
          continue;
        }

        final fileModel = FileModel(
          id: fileId,
          title: file.title,
          type: file.type,
          url: downloadUrl,
          userId: patientId,
          createdAt: null,
        );

        await docRef.set({
          ...fileModel.toJson(),
          'id': fileId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return true;
    } catch (e, stackTrace) {
      log('Error enviando archivos', error: e, stackTrace: stackTrace);
      return false;
    }
  }
}