import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrabit_admin/core/models/notification_model.dart';

final notificationServiceProvider = Provider((ref) => NotificationService());

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createNotification(Notification notification) async {
    // Convertir a mapa y guardar en Firestore
    await _db.collection('notifications').add(notification.toMap());
  }

  Future<void> updateNotification(Notification notification) async {
    await _db.collection('notifications').doc(notification.id).update(notification.toMap());
  }

  Future<void> cancelNotification(String id) async {
    // Marcar cancel en true
    await _db.collection('notifications').doc(id).update({"cancel": true});
  }

  Stream<List<Notification>> getNotificationsStream() {
    // Opcional: para listar notificaciones programadas en la UI admin
    return _db.collection('notifications').snapshots().map((query) {
      return query.docs.map((doc) => Notification.fromDoc(doc)).toList();
    });
  }
}
