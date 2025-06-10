import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrabit_admin/core/models/notification_model.dart';
import 'package:nutrabit_admin/core/models/topic.dart';

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
        .set(notification.toMap());
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

    if (notification.id.toString() == '') {
      await createNotification(notification);
    } else {
      await updateNotification(notification);
    }
  }

  Future<void> deleteNotification(String id) async {
    await _db.collection('notifications').doc(id).delete();
  }
}

final notificationsStreamProvider =
    StreamProvider.autoDispose<List<NotificationModel>>((ref) {
      final service = ref.watch(notificationServiceProvider);
      return service.getNotificationsStream();
    });
// Mantiene el estado del filtro de topics
final selectedTopicProvider = StateProvider<Topic?>((ref) => null);

// Maneja el controlador de notificaciones con estado asincrónico
// y maneja el paginado
final notificationsControllerProvider = StateNotifierProvider<
  NotificationsController,
  AsyncValue<List<NotificationModel>>
>((ref) => NotificationsController());

// Maneja la lógica de carga y estado de las notificaciones.
class NotificationsController
    extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  NotificationsController() : super(const AsyncLoading()) {
    loadMore();
  }
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  // Cantidad de notificaciones a cargar por tanda
  final int _limit = 10;
  // Lista interna donde se acumulan las notificaciones cargadas
  final List<NotificationModel> _notifications = [];
  // Guarda el último documento cargado, para usarlo como cursor en la siguiente página
  DocumentSnapshot? _lastDoc;
  // Indica si todavía hay más notificaciones para cargar
  bool _hasMore = true;
  // Indica si ya hay una carga en curso
  bool _isFetching = false;

  bool get hasMore => _hasMore;
  bool get isFetching => _isFetching;

  // Carga más notificaciones
  Future<void> loadMore() async {
    if (_isFetching || !_hasMore) return;
    _isFetching = true;
    try {
      Query query = _db
          .collection('notifications')
          .orderBy('scheduledTime', descending: false)
          .limit(_limit);

      final snapshot =
          _lastDoc != null
              ? await query.startAfterDocument(_lastDoc!).get()
              : await query.get();

      final newItems =
          snapshot.docs.map((doc) => NotificationModel.fromDoc(doc)).toList();

      if (snapshot.docs.isNotEmpty) {
        _lastDoc = snapshot.docs.last;
      }

      if (newItems.length < _limit) {
        _hasMore = false;
      }
      _notifications.addAll(newItems);
      state = AsyncData(List.from(_notifications));
    } catch (e, st) {
      state = AsyncError(e, st);
    }

    _isFetching = false;
  }

  // Reinicia la lista (ej: cuando cambia el filtro)
  void reset() {
    _lastDoc = null;
    _hasMore = true;
    _notifications.clear();
    state = const AsyncLoading();
    loadMore();
  }
}
