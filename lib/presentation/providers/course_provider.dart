import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrabit_admin/core/models/course_model.dart';
import 'package:nutrabit_admin/core/services/course_service.dart';

final courseProvider = Provider<CourseProvider>((ref) {
  return CourseProvider();
});

class CourseProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> createCourseWithImage({
    required Course course,
    Uint8List? imageBytes,
  }) async {
    try {
      final docRef = _firestore.collection('courses').doc();
      final courseId = docRef.id;

      String imageUrl = '';

      if (imageBytes != null) {
        final storageRef = _storage.ref().child('course_image/$courseId.jpg');
        await storageRef.putData(imageBytes);
        imageUrl = await storageRef.getDownloadURL();
      }

      final newCourse = course.copyWith(id: courseId, picture: imageUrl);
      await docRef.set(newCourse.toMap());
    } catch (e) {
      throw Exception('Error al crear el curso: $e');
    }
  }

  Future<void> buildAndCreateCourse({
    required String title,
    required String webPage,
    required String inscriptionLink,
    required DateTime? startDate,
    required TimeOfDay? startTime,
    required TimeOfDay? endTime,
    required DateTime? inscriptionStart,
    required DateTime? inscriptionEnd,
    required DateTime? showFrom,
    required DateTime? showUntil,
    Uint8List? imageBytes,
  }) async {
    if (title.trim().isEmpty) {
      throw CourseValidationException('El título es requerido');
    }

    // Validar que si se pone alguna parte de la fecha del curso, estén las tres
    final bool anyCourseDatePartSet =
        startDate != null || startTime != null || endTime != null;
    final bool allCourseDatePartsSet =
        startDate != null && startTime != null && endTime != null;

    if (anyCourseDatePartSet && !allCourseDatePartsSet) {
      throw CourseValidationException(
        'Si se proporciona alguna información de fecha/hora del curso, se deben completar fecha, hora de inicio y hora de fin',
      );
    }

    DateTime? courseStart;
    DateTime? courseEnd;

    if (allCourseDatePartsSet) {
      courseStart = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
        startTime.hour,
        startTime.minute,
      );

      courseEnd = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
        endTime.hour,
        endTime.minute,
      );

      // Validar rangos lógicos para courseStart/courseEnd
      if (courseEnd.isBefore(courseStart)) {
        throw CourseValidationException(
          'La fecha de fin del curso no puede ser anterior a la fecha de inicio',
        );
      }
    }

    // Validar rangos lógicos para inscriptionStart/inscriptionEnd
    if (inscriptionStart != null && inscriptionEnd != null) {
      if (inscriptionEnd.isBefore(inscriptionStart)) {
        throw CourseValidationException(
          'La fecha de fin de inscripción no puede ser anterior a la de inicio',
        );
      }
    }

    // Validar rangos lógicos para showFrom/showUntil
    if (showFrom != null && showUntil != null) {
      if (showUntil.isBefore(showFrom)) {
        throw CourseValidationException(
          'La fecha de "mostrar desde" no puede ser posterior a la de "mostrar hasta"',
        );
      }
    }

    final course = Course(
      id: '',
      title: title,
      webPage: webPage,
      picture: '',
      courseStart: courseStart,
      courseEnd: courseEnd,
      inscriptionStart: inscriptionStart,
      inscriptionEnd: inscriptionEnd,
      showFrom: showFrom,
      showUntil: showUntil,
      showCourse: true,
      showInscription: true,
      inscriptionLink: inscriptionLink,
    );

    await createCourseWithImage(course: course, imageBytes: imageBytes);
  }

  Future<void> updateCourse(
    String id,
    Course updatedCourse, {
    Uint8List? imageBytes,
  }) async {
    try {
      // 1) Determinar la URL final de la imagen:
      //
      //    - Si vienen `imageBytes != null`, subimos esos bytes y obtenemos una URL nueva.
      //    - Si `imageBytes == null` Y `updatedCourse.picture == ''`, significa que
      //      el usuario pulsó X para borrar la imagen, así que debemos borrar el
      //      archivo en Storage (si existe).
      //    - En cualquier otro caso (`imageBytes == null` y `updatedCourse.picture != ''`),
      //      dejamos la URL antigua tal cual en Firestore.
      String finalPictureUrl = updatedCourse.picture;

      if (imageBytes != null) {
        // CASO A: Subir imagen nueva
        final storageRef = _storage.ref().child('course_image/$id.jpg');
        await storageRef.putData(imageBytes);
        finalPictureUrl = await storageRef.getDownloadURL();
      } else {
        // CASO B: No hay bytes nuevos
        if (updatedCourse.picture.isEmpty) {
          // El usuario mandó picture=='' → borrar imagen antigua de Storage
          try {
            final storageRef = _storage.ref().child('course_image/$id.jpg');
            await storageRef.delete();
          } catch (e) {
            // Puede que el archivo no existiera; podemos ignorar el error.
          }
          // finalPictureUrl queda en '' para que Firestore elimine ese campo
        }
        // Si updatedCourse.picture != '' (URL antigua), la dejamos intacta.
      }

      // 2) Ahora construimos un objeto Course que incluya la URL final (puede ser '' o la URL nueva o la antigua)
      final courseToSave = updatedCourse.copyWith(picture: finalPictureUrl);

      // 3) Preparamos el mapa de datos para Firestore.
      //    Usamos .set(merge: true) para que los campos nulos/'' eliminen valores anteriores.
      final data = <String, dynamic>{
        'title': courseToSave.title,
        'webPage': courseToSave.webPage,
        'inscriptionLink': courseToSave.inscriptionLink,
        'showCourse': courseToSave.showCourse,
        'showInscription': courseToSave.showInscription,
        'picture':
            courseToSave.picture, // '' si queremos borrarlo, o URL válida

        'courseStart':
            courseToSave.courseStart != null
                ? Timestamp.fromDate(courseToSave.courseStart!)
                : null,
        'courseEnd':
            courseToSave.courseEnd != null
                ? Timestamp.fromDate(courseToSave.courseEnd!)
                : null,
        'inscriptionStart':
            courseToSave.inscriptionStart != null
                ? Timestamp.fromDate(courseToSave.inscriptionStart!)
                : null,
        'inscriptionEnd':
            courseToSave.inscriptionEnd != null
                ? Timestamp.fromDate(courseToSave.inscriptionEnd!)
                : null,
        'showFrom':
            courseToSave.showFrom != null
                ? Timestamp.fromDate(courseToSave.showFrom!)
                : null,
        'showUntil':
            courseToSave.showUntil != null
                ? Timestamp.fromDate(courseToSave.showUntil!)
                : null,

        'modifiedAt': Timestamp.fromDate(courseToSave.modifiedAt),
        // Si tu modelo lleva createdAt/deletedAt, añádelos aquí igual:
        'createdAt': Timestamp.fromDate(courseToSave.createdAt),
      };

      // 4) Actualizamos en Firestore con merge: true para que los nulls/'' sobreescriban/eliminen
      await _firestore
          .collection('courses')
          .doc(id)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      throw CourseValidationException('Error al actualizar el curso: $e');
    }
  }

  Future<void> updateShowCourse(String id) async {
    final docRef = _firestore.collection('courses').doc(id);

    // Lee el valor actual
    final snapshot = await docRef.get();
    final data = snapshot.data();
    if (data == null) {
      throw CourseValidationException('Curso no encontrado');
    }
    final current = data['showCourse'] as bool? ?? true;

    // Actualiza con el valor contrario
    await docRef.update({'showCourse': !current});
  }

  Future<void> deleteCourse(String id, {String? imageUrl}) async {
    // Si hay imagen, se elimina de Storage
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final img = _storage.refFromURL(imageUrl);
        await img.delete();
      } catch (e) {
        debugPrint('Error borrando imagen de Storage: $e');
      }
    }
    // Se elimina el curso de Firestore
    try {
      await _firestore.collection('courses').doc(id).delete();
    } catch (e) {
      throw CourseValidationException('Error al eliminar el curso: $e');
    }
  }
}

class CourseValidationException implements Exception {
  final String message;
  CourseValidationException(this.message);

  @override
  String toString() => message;
}

final courseServiceProvider = Provider<CourseService>((ref) {
  return CourseService();
});

final courseListProvider = FutureProvider<List<Course>>((ref) async {
  final service = ref.watch(courseServiceProvider);
  return service.fetchAllCourses();

});
