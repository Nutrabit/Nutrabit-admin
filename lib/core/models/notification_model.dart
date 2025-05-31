import 'package:cloud_firestore/cloud_firestore.dart';

class Notification {
  String id;
  String title;
  String description;
  DateTime scheduledTime;
  DateTime? endDate;
  int? repeatEvery;      
  String? urlIcon;
  bool cancel;
  
  Notification({
    this.id = '',
    required this.title,
    required this.description,
    required this.scheduledTime,
    this.endDate,
    this.repeatEvery,
    this.urlIcon,
    this.cancel = false,
  });
  
  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "description": description,
      "scheduledTime": scheduledTime,  
      "endDate": endDate,
      "repeatEvery": repeatEvery,
      "urlIcon": urlIcon,
      "sent": false,
      "cancel": cancel,
    };
  }

  factory Notification.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Notification(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      scheduledTime: (data['scheduledTime'] as Timestamp).toDate(),
      endDate: data['endDate'] != null ? (data['endDate'] as Timestamp).toDate() : null,
      repeatEvery: data['repeatEvery'],
      urlIcon: data['urlIcon'],
      cancel: data['cancel'] ?? false,
    );
  }
}
