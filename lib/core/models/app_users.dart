import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String name;
  final String lastname;
  final String email;
  final DateTime? birthday;
  final String dni;
  final int age;
  final int height;
  final int weight;
  final String gender;
  final bool isActive;
  final String profilePic;
  final String goal;

  final List<Map<String, Object?>> files;
  final List<Map<String, Object?>> events;
  final List<Timestamp> appointments;

  AppUser({
    required this.id,
    required this.name,
    required this.lastname,
    required this.email,
    required this.birthday,
    required this.dni,
    required this.age,
    required this.height,
    required this.weight,
    required this.gender,
    required this.isActive,
    required this.profilePic,
    required this.goal,
    required this.files,
    required this.events,
    required this.appointments,
  });

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
    age: data['age'] ?? 0,
    height: data['height'] ?? 0,
    weight: data['weight'] ?? 0,
    gender: data['gender'] ?? '',
    isActive: data['isActive'] ?? false,
    profilePic: data['profilePic'] ?? '',
    goal: data['goal'] ?? '',
    files: (data['files'] as List?)
            ?.map((e) => Map<String, Object?>.from(e as Map))
            .toList() ??
        [],
    events: (data['events'] as List?)
            ?.map((e) => Map<String, Object?>.from(e as Map))
            .toList() ??
        [],
    appointments: (data['appointments'] as List?)
            ?.map((e) => e as Timestamp)
            .toList() ??
        [],
  );
}

  Map<String, dynamic> toMap() {
  return {
    'name': name,
    'lastname': lastname,
    'email': email,
    'birthday': birthday != null ? Timestamp.fromDate(birthday!) : null,
    'dni': dni,
    'age': age,
    'height': height,
    'weight': weight,
    'gender': gender,
    'isActive': isActive,
    'profilePic': profilePic,
    'goal': goal,
    'files': files,
    'events': events,
    'appointments': appointments,
  };
}
}
