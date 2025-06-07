import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrabit_admin/core/models/notification_model.dart';

final notificationServiceProvider = Provider((ref) => NotificationService());

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createNotification(NotificationModel notification) async {
    final docRef = _db.collection('notifications').doc();
    final notificationId = docRef.id;
    final newNotification = notification.copyWith(id: notificationId);
    await docRef.set(newNotification.toMap());
  }

  Future<void> updateNotification(NotificationModel notification) async {
    await _db
        .collection('notifications')
        .doc(notification.id)
        .update(notification.toMap());
  }

  Future<void> cancelNotification(String id) async {
    await _db.collection('notifications').doc(id).update({"cancel": true});
  }

  Stream<List<NotificationModel>> getNotificationsStream() {
    return _db.collection('notifications').snapshots().map((query) {
      return query.docs.map((doc) => NotificationModel.fromDoc(doc)).toList();
    });
  }

  
  Future<void> submitNotification(NotificationModel notification) async {
    
    if (notification.title.trim().isEmpty ||
        notification.description.trim().isEmpty ||
        // ignore: unnecessary_null_comparison
        notification.scheduledTime == null) {
      throw Exception("Título, descripción y fecha son obligatorios");
    }

    if (notification.id.isEmpty) {
      await createNotification(notification);
    } else {
      await updateNotification(notification);
    }
  }
}
