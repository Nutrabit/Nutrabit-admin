import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrabit_admin/core/models/calendar_event.dart';

final eventsStreamProvider = StreamProvider.family<List<Event>, String>((
  ref,
  userId,
) {
  return FirebaseFirestore.instance
      .collection('events')
      .where('userid', isEqualTo: userId)
      .snapshots()
      .map((querySnap) {
        // Mapea directamente cada documento a un Event:
        return querySnap.docs
          .map((doc) => Event.fromMap(doc.id, doc.data()))
          .toList();
      });
});

/// Agrupa los eventos por día
final eventsByDateProvider = Provider. family<AsyncValue<Map<DateTime, List<Event>>>, String>((
  ref, userId
) {
  final asyncEvents = ref.watch(eventsStreamProvider(userId));

  return asyncEvents.whenData((events) {
    final map = <DateTime, List<Event>>{};
    for (var event in events) {
      final day = DateTime(event.date.year, event.date.month, event.date.day);
      map.putIfAbsent(day, () => []).add(event);
    }
    return map;
  });
});
