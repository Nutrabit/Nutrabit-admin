import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  final String id;
  final String title;
  final String webPage;
  final String picture;
  final DateTime? courseStart;
  final DateTime? courseEnd;
  final DateTime? inscriptionStart;
  final DateTime? inscriptionEnd;
  final DateTime? showFrom;
  final DateTime? showUntil;
  final bool showCourse;
  final bool showInscription;
  final String inscriptionLink;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final DateTime? deletedAt;

  Course({
    required this.id,
    required this.title,
    required this.webPage,
    required this.picture,
    this.courseStart,
    this.courseEnd,
    this.inscriptionStart,
    this.inscriptionEnd,
    this.showFrom,
    this.showUntil,
    required this.showCourse,
    required this.showInscription,
    required this.inscriptionLink,
    DateTime? createdAtParam,
    DateTime? modifiedAtParam,
    DateTime? deletedAtParam,
  })  : createdAt = createdAtParam ?? DateTime.now(),
        modifiedAt = modifiedAtParam ?? DateTime.now(),
        deletedAt = deletedAtParam;

  factory Course.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Course(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      webPage: data['webPage'] ?? '',
      picture: data['picture'] ?? '',
      courseStart: data['courseStart'] != null
          ? (data['courseStart'] as Timestamp).toDate()
          : null,
      courseEnd: data['courseEnd'] != null
          ? (data['courseEnd'] as Timestamp).toDate()
          : null,
      inscriptionStart: data['inscriptionStart'] != null
          ? (data['inscriptionStart'] as Timestamp).toDate()
          : null,
      inscriptionEnd: data['inscriptionEnd'] != null
          ? (data['inscriptionEnd'] as Timestamp).toDate()
          : null,
      showFrom: data['showFrom'] != null
          ? (data['showFrom'] as Timestamp).toDate()
          : null,
      showUntil: data['showUntil'] != null
          ? (data['showUntil'] as Timestamp).toDate()
          : null,
      showCourse: data['showCourse'] ?? false,
      showInscription: data['showInscription'] ?? false,
      inscriptionLink: data['inscriptionLink'] ?? '',
      createdAtParam: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      modifiedAtParam: data['modifiedAt'] != null
          ? (data['modifiedAt'] as Timestamp).toDate()
          : DateTime.now(),
      deletedAtParam: data['deletedAt'] != null
          ? (data['deletedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'webPage': webPage,
      'picture': picture,
      'courseStart':
          courseStart != null ? Timestamp.fromDate(courseStart!) : null,
      'courseEnd': courseEnd != null ? Timestamp.fromDate(courseEnd!) : null,
      'inscriptionStart': inscriptionStart != null
          ? Timestamp.fromDate(inscriptionStart!)
          : null,
      'inscriptionEnd': inscriptionEnd != null
          ? Timestamp.fromDate(inscriptionEnd!)
          : null,
      'showFrom':
          showFrom != null ? Timestamp.fromDate(showFrom!) : null,
      'showUntil':
          showUntil != null ? Timestamp.fromDate(showUntil!) : null,
      'showCourse': showCourse,
      'showInscription': showInscription,
      'inscriptionLink': inscriptionLink,
      'createdAt': Timestamp.fromDate(createdAt),
      'modifiedAt': Timestamp.fromDate(modifiedAt),
      'deletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
    };
  }

  Course copyWith({
    String? id,
    String? title,
    String? webPage,
    String? picture,
    DateTime? courseStart,
    DateTime? courseEnd,
    DateTime? inscriptionStart,
    DateTime? inscriptionEnd,
    DateTime? showFrom,
    DateTime? showUntil,
    bool? showCourse,
    bool? showInscription,
    String? inscriptionLink,
    DateTime? createdAtParam,
    DateTime? modifiedAtParam,
    DateTime? deletedAtParam,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      webPage: webPage ?? this.webPage,
      picture: picture ?? this.picture,
      courseStart: courseStart ?? this.courseStart,
      courseEnd: courseEnd ?? this.courseEnd,
      inscriptionStart: inscriptionStart ?? this.inscriptionStart,
      inscriptionEnd: inscriptionEnd ?? this.inscriptionEnd,
      showFrom: showFrom ?? this.showFrom,
      showUntil: showUntil ?? this.showUntil,
      showCourse: showCourse ?? this.showCourse,
      showInscription: showInscription ?? this.showInscription,
      inscriptionLink: inscriptionLink ?? this.inscriptionLink,
      createdAtParam: createdAtParam ?? createdAt,
      modifiedAtParam: modifiedAtParam ?? modifiedAt,
      deletedAtParam: deletedAtParam ?? deletedAt,
    );
  }

}

extension CourseVisibility on Course {
  // True si está marcado para mostrarse *y*
  // la hora actual está dentro de [showFrom]–[showUntil] (cuando existen).
  bool get isVisibleNow {
    final now = DateTime.now();
    if (!showCourse) return false;
    if (showFrom != null && now.isBefore(showFrom!)) return false;
    if (showUntil != null && now.isAfter(showUntil!)) return false;
    return true;
  }
}