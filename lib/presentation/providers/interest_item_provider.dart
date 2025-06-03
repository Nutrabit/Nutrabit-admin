import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutrabit_admin/core/models/interest_item_model.dart';

final interestItemsProvider =
    AsyncNotifierProvider<InterestItemsNotifier, List<InterestItem>>(
  InterestItemsNotifier.new,
);

class InterestItemsNotifier extends AsyncNotifier<List<InterestItem>> {
  static const int _limit = 4;

  late final CollectionReference _collection;
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _isFetching = false;

  @override
  Future<List<InterestItem>> build() async {
    _collection = FirebaseFirestore.instance.collection('interestItems');
    return await fetchInitialItems();
  }

  Future<List<InterestItem>> fetchInitialItems() async {
    _hasMore = true;
    _lastDocument = null;

    final query = _collection
        .orderBy('createdAt', descending: true)
        .limit(_limit);

    final snapshot = await query.get();
    final docs = snapshot.docs;

    if (docs.isNotEmpty) {
      _lastDocument = docs.last;
    }

    final items = docs
        .map((doc) =>
            InterestItem.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    state = AsyncValue.data(items);
    return items;
  }

  Future<void> fetchMoreItems() async {
    if (!_hasMore || _isFetching || _lastDocument == null) return;

    _isFetching = true;

    final query = _collection
        .orderBy('createdAt', descending: true)
        .startAfterDocument(_lastDocument!)
        .limit(_limit);

    final snapshot = await query.get();
    final docs = snapshot.docs;

    if (docs.isNotEmpty) {
      _lastDocument = docs.last;
    }

    if (docs.length < _limit) {
      _hasMore = false;
    }

    final newItems = docs
        .map((doc) =>
            InterestItem.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    state = AsyncValue.data([...state.value ?? [], ...newItems]);

    _isFetching = false;
  }

  Future<void> addInterestItem(String url, String title) async {
    final docRef = _collection.doc();
    final now = DateTime.now();

    final newItem = InterestItem(
      id: docRef.id,
      url: url,
      title: title,
      createdAt: now,
      modifiedAt: now,
    );

    await _collection.doc(newItem.id).set(newItem.toMap());

    state = AsyncValue.data([newItem, ...state.value ?? []]);
  }

  Future<void> deleteInterestItem(String id) async {
    await _collection.doc(id).delete();
    state = AsyncValue.data([...?state.value?.where((item) => item.id != id)]);
  }

  bool get hasMore => _hasMore;
  bool get isFetching => _isFetching;
}
