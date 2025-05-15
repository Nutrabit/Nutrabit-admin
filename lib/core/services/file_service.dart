import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import '../models/file_model.dart';
import '../utils/file_picker_util.dart'; 

class FileUploaderService {
  static Future<String> uploadSingleFile(File file, String userId) async {
    try {
      final fileId = const Uuid().v4();
      final fileExtension = path.extension(file.path);
      final fileName = '$fileId$fileExtension';

      final storageRef =
          FirebaseStorage.instance.ref().child('users_files/$userId/$fileName');

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

  static Future<void> uploadFiles({
    required List<SelectedFile> files,
    required String patientId,
    required BuildContext context,
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
          continue; // Invalid file
        }

        final fileId = const Uuid().v4();
        final fileModel = FileModel(
          id: fileId,
          title: file.title,
          type: file.type,
          url: downloadUrl,
          date: DateTime.now(),
          userId: patientId,
        );

        await FirebaseFirestore.instance
            .collection('files')
            .doc(fileId)
            .set(fileModel.toJson());
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Archivos enviados exitosamente')),
      );
    } catch (e) {
      print('Error enviando archivos');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error enviando files: $e')),
      );
    }
  }
}