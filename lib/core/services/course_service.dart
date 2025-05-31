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

    return query.docs.map((doc) => Course.fromFirestore(doc)).toList();
  }
}