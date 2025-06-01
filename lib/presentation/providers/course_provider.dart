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

  /// Crea un curso
  Future<void> createCourseWithImage({
    required Course course,
    Uint8List? imageBytes,
  }) async {
    final docRef = _firestore.collection('courses').doc();
    final courseId = docRef.id;
    // Se carga la imagen a Firebase Storage y se obtiene la URL
    final imageUrl = await _uploadImageIfNeeded(
      courseId: courseId,
      imageBytes: imageBytes,
    );
    final newCourse = course.copyWith(id: courseId, picture: imageUrl);
    await docRef.set(newCourse.toMap());
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
    DateTime? courseStart;
    DateTime? courseEnd;
    final anyCourseDatePartSet =
        startDate != null || startTime != null || endTime != null;
    final allCourseDatePartsSet =
        startDate != null && startTime != null && endTime != null;

    if (anyCourseDatePartSet && !allCourseDatePartsSet) {
      throw CourseValidationException(
        'Si se proporciona alguna información de fecha/hora del curso, se deben completar fecha, hora de inicio y hora de fin',
      );
    }
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
    _validateAllDateRanges(course);
    await createCourseWithImage(course: course, imageBytes: imageBytes);
  }

  /// Actualiza un curso existente. Aplicar las mismas validaciones que en creación.
  Future<void> updateCourse(
    String id,
    Course updatedCourse, {
    Uint8List? imageBytes,
  }) async {
    try {
      if (updatedCourse.title.trim().isEmpty) {
      throw CourseValidationException('El título es requerido');
    }
      // Se validan rangos de fechas
      _validateAllDateRanges(updatedCourse);
      // Se obtiene la imagen
      final finalPictureUrl = await _determineFinalImageUrl(
        courseId: id,
        updatedCourse: updatedCourse,
        imageBytes: imageBytes,
      );
      // Se genera el curso actualizado con la URL final de la imagen
      final courseToSave = updatedCourse.copyWith(picture: finalPictureUrl);
      final data = _courseToMap(courseToSave);
      await _firestore.collection('courses').doc(id).set(data);
    } catch (e) {
      throw CourseValidationException('Error al actualizar el curso: $e');
    }
  }

  /// Invierte el "showCourse"
  Future<void> updateShowCourse(String id) async {
    final docRef = _firestore.collection('courses').doc(id);
    final snapshot = await docRef.get();
    final data = snapshot.data();
    if (data == null) throw CourseValidationException('Curso no encontrado');
    final current = data['showCourse'] as bool? ?? true;
    await docRef.update({'showCourse': !current});
  }

  /// Elimina un curso y su imagen
  Future<void> deleteCourse(String id, {String? imageUrl}) async {
    // Si hay URL de imagen, se elimina de Storage
    if (imageUrl != null && imageUrl.isNotEmpty) {
      await _deleteImageByUrl(imageUrl);
    }
    // 2Se borra el curso de Firestore
    try {
      await _firestore.collection('courses').doc(id).delete();
    } catch (e) {
      throw CourseValidationException('Error al eliminar el curso: $e');
    }
  }

  void _validateAllDateRanges(Course course) {
    final DateTime? courseStart = course.courseStart;
    final DateTime? courseEnd = course.courseEnd;
    final DateTime? inscriptionStart = course.inscriptionStart;
    final DateTime? inscriptionEnd = course.inscriptionEnd;
    final DateTime? showFrom = course.showFrom;
    final DateTime? showUntil = course.showUntil;

    if ((courseStart == null) ^ (courseEnd == null)) {
      throw CourseValidationException(
        'Si define fecha/hora del curso, debe completar tanto “inicio” como “fin”.',
      );
    }
    if (courseStart != null && courseEnd != null) {
      if (courseEnd.isBefore(courseStart)) {
        throw CourseValidationException(
          'La fecha de fin del curso no puede ser anterior a la fecha de inicio.',
        );
      }
    }
    if ((inscriptionStart == null) ^ (inscriptionEnd == null)) {
      throw CourseValidationException(
        'Si define fecha de inscripción, debe completar tanto “Inscripción desde” como “Inscripción hasta”.',
      );
    }
    if (inscriptionStart != null && inscriptionEnd != null) {
      if (inscriptionEnd.isBefore(inscriptionStart)) {
        throw CourseValidationException(
          'La fecha de fin de inscripción no puede ser anterior a la de inicio.',
        );
      }
    }
    if ((showFrom == null) ^ (showUntil == null)) {
      throw CourseValidationException(
        'Si define fechas de visibilidad, debe completar tanto “Mostrar desde” como “Mostrar hasta”.',
      );
    }
    if (showFrom != null && showUntil != null) {
      if (showUntil.isBefore(showFrom)) {
        throw CourseValidationException(
          'La fecha de “Mostrar hasta” no puede ser anterior a la de “Mostrar desde”.',
        );
      }
    }
  }

  /// Sube una imagen a Firebase Storage y devuelve la URL.
  /// Si imageBytes es null, devuelve un String vacío.
  Future<String> _uploadImageIfNeeded({
    required String courseId,
    Uint8List? imageBytes,
  }) async {
    if (imageBytes == null) return '';
    try {
      final storageRef = _storage.ref().child('course_image/$courseId.jpg');
      await storageRef.putData(imageBytes);
      return await storageRef.getDownloadURL();
    } catch (e) {
      throw CourseValidationException('Error subiendo imagen: $e');
    }
  }

  // Determina la URL final de la imagen al actualizar:
  // Si vienen bytes nuevos, sube y devuelve URL nueva.
  // Si no viene bytes y updatedCourse.picture está vacío, borra la imagen antigua (si existía) y devuelve ''.
  // Si no viene bytes y updatedCourse.picture NO está vacío, devuelve la URL que ya estaba.
  Future<String> _determineFinalImageUrl({
    required String courseId,
    required Course updatedCourse,
    Uint8List? imageBytes,
  }) async {
    String finalUrl = updatedCourse.picture;
    if (imageBytes != null) {
      return await _uploadImageIfNeeded(
        courseId: courseId,
        imageBytes: imageBytes,
      );
    } else {
      if (finalUrl.isEmpty) {
        try {
          final storageRef = _storage.ref().child('course_image/$courseId.jpg');
          await storageRef.delete();
        } catch (e) {
          debugPrint('Error borrando imagen de Storage: $e');
        }
        return '';
      } else {
        return finalUrl;
      }
    }
  }

  /// Borra una imagen de Storage
  Future<void> _deleteImageByUrl(String imageUrl) async {
    try {
      final imgRef = _storage.refFromURL(imageUrl);
      await imgRef.delete();
    } catch (e) {
      debugPrint('Error borrando imagen de Storage: $e');
    }
  }

  Map<String, dynamic> _courseToMap(Course course) {
    return <String, dynamic>{
      'id': course.id,
      'title': course.title,
      'webPage': course.webPage,
      'inscriptionLink': course.inscriptionLink,
      'showCourse': course.showCourse,
      'showInscription': course.showInscription,
      'picture': course.picture,
      'courseStart':
          course.courseStart != null
              ? Timestamp.fromDate(course.courseStart!)
              : null,
      'courseEnd':
          course.courseEnd != null
              ? Timestamp.fromDate(course.courseEnd!)
              : null,
      'inscriptionStart':
          course.inscriptionStart != null
              ? Timestamp.fromDate(course.inscriptionStart!)
              : null,
      'inscriptionEnd':
          course.inscriptionEnd != null
              ? Timestamp.fromDate(course.inscriptionEnd!)
              : null,
      'showFrom':
          course.showFrom != null ? Timestamp.fromDate(course.showFrom!) : null,
      'showUntil':
          course.showUntil != null
              ? Timestamp.fromDate(course.showUntil!)
              : null,
      'createdAt': Timestamp.fromDate(course.createdAt),
      'modifiedAt': Timestamp.fromDate(course.modifiedAt),
    };
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
