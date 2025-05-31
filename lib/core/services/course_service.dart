import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/course_model.dart';

class CourseService {
  final FirebaseFirestore _firestore;

  CourseService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<Course>> fetchAllCourses() async {
    final query = await _firestore
        .collection('courses')
        .get();

    final courses = query.docs.map((doc) => Course.fromFirestore(doc)).toList();
    // ordenar los cursos por fecha de inicio
    courses.sort((a, b) {
      if (a.courseStart == null && b.courseStart == null) return 0;
      if (a.courseStart == null) return 1;
      if (b.courseStart == null) return -1;
      return a.courseStart!.compareTo(b.courseStart!);
    });
    return courses;
  }
}