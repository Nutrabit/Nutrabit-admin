import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String name;
  final String lastname;
  final String email;
  final DateTime? birthday;
  final String dni;
  // final int age;
  final int height;
  final int weight;
  final String gender;
  final bool isActive;
  final String profilePic;
  final String goal;

  final List<Map<String, Object?>> events;
  final List<Timestamp> appointments;

  final DateTime createdAt;
  final DateTime modifiedAt;  
  final DateTime? deletedAt;  

  AppUser({
    required this.id,
    required this.name,
    required this.lastname,
    required this.email,
    required this.birthday,
    required this.dni,
    // required this.age,
    required this.height,
    required this.weight,
    required this.gender,
    required this.isActive,
    required this.profilePic,
    required this.goal,
    required this.events,
    required this.appointments,
    DateTime? createdAtParam, 
    DateTime? modifiedAtParam,
    DateTime? deletedAtParam, 
  })  : createdAt = createdAtParam ?? DateTime.now(),
        modifiedAt = modifiedAtParam ?? DateTime.now(),
        deletedAt = deletedAtParam;  

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return AppUser(
      id: doc.id,
      name: data['name'] ?? '',
      lastname: data['lastname'] ?? '',
      email: data['email'] ?? '',
      birthday: data['birthday'] != null
          ? (data['birthday'] as Timestamp).toDate()
          : null,
      dni: data['dni']?.toString() ?? '',
      // age: data['age'] ?? 0,
      height: data['height'] ?? 0,
      weight: data['weight'] ?? 0,
      gender: data['gender'] ?? '',
      isActive: data['isActive'] ?? false,
      profilePic: data['profilePic'] ?? '',
      goal: data['goal'] ?? '',
      events: (data['events'] as List?)
              ?.map((e) => Map<String, Object?>.from(e as Map))
              .toList() ?? [],
      appointments: (data['appointments'] as List?)
              ?.map((e) => e as Timestamp)
              .toList() ?? [],
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
      'name': name,
      'lastname': lastname,
      'email': email,
      'birthday': birthday != null ? Timestamp.fromDate(birthday!) : null,
      'dni': dni,
      // 'age': age,
      'height': height,
      'weight': weight,
      'gender': gender,
      'isActive': isActive,
      'profilePic': profilePic,
      'goal': goal,
      'events': events,
      'appointments': appointments,
      'createdAt': Timestamp.fromDate(createdAt),
      'modifiedAt': Timestamp.fromDate(modifiedAt),
      'deletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null, 
    };
  }
}
