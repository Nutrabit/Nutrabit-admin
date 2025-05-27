import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrabit_admin/core/models/course_model.dart';

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
  final bool anyCourseDatePartSet = startDate != null || startTime != null || endTime != null;
  final bool allCourseDatePartsSet = startDate != null && startTime != null && endTime != null;

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
      throw CourseValidationException('La fecha de fin del curso no puede ser anterior a la fecha de inicio');
    }
  }

  // Validar rangos lógicos para inscriptionStart/inscriptionEnd
  if (inscriptionStart != null && inscriptionEnd != null) {
    if (inscriptionEnd.isBefore(inscriptionStart)) {
      throw CourseValidationException('La fecha de fin de inscripción no puede ser anterior a la de inicio');
    }
  }

  // Validar rangos lógicos para showFrom/showUntil
  if (showFrom != null && showUntil != null) {
    if (showUntil.isBefore(showFrom)) {
      throw CourseValidationException('La fecha de "mostrar desde" no puede ser posterior a la de "mostrar hasta"');
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
}

class CourseValidationException implements Exception {
  final String message;
  CourseValidationException(this.message);

  @override
  String toString() => message;
}

