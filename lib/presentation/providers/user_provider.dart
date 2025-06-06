import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/app_users.dart';
import '../../core/utils/utils.dart';

final paginatedUsersProvider =
    StateNotifierProvider<PaginatedUsersNotifier, AsyncValue<List<AppUser>>>(
  (ref) => PaginatedUsersNotifier(),
);

class PaginatedUsersNotifier extends StateNotifier<AsyncValue<List<AppUser>>> {
  PaginatedUsersNotifier() : super(const AsyncLoading()) {
    fetchInitialUsers();
  }

  static const int _limit = 10;
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _isFetching = false;

  final List<AppUser> _users = [];

  List<AppUser> get users => _users;

  Future<void> fetchInitialUsers() async {
    if (_isFetching) return;
    _isFetching = true;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('name')
          .limit(_limit)
          .get();

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
        _users.clear();
        _users.addAll(snapshot.docs.map((doc) => AppUser.fromFirestore(doc)));
        _sortUsers();
        state = AsyncData(List.from(_users));
      } else {
        state = const AsyncData([]);
        _hasMore = false;
      }
    } catch (e, st) {
      state = AsyncError(e, st);
    }

    _isFetching = false;
  }

  Future<void> fetchMoreUsers() async {
  if (_isFetching || !_hasMore) return;
  _isFetching = true;

  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .orderBy('name')
        .startAfterDocument(_lastDocument!)
        .limit(_limit)
        .get();

    if (snapshot.docs.isNotEmpty) {
      _lastDocument = snapshot.docs.last;
      _users.addAll(snapshot.docs.map((doc) => AppUser.fromFirestore(doc)));
      _sortUsers();
      state = AsyncData(List.from(_users));
    } else {
      _hasMore = false;
      state = AsyncData(List.from(_users));
    }
  } catch (e, st) {
    state = AsyncError(e, st);
  }

  _isFetching = false;
}

  void _sortUsers() {
    _users.sort((a, b) => normalize(a.name).compareTo(normalize(b.name)));
  }

  bool get hasMore => _hasMore;
  bool get isFetching => _isFetching;
}

Future<void> addUser(AppUser user) async {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  try {
    final String password = generateRandomPassword();
    UserCredential userCredential = await auth.createUserWithEmailAndPassword(
      email: user.email,
      password: password,
    );
    final uid = userCredential.user!.uid;
    final newUser = user.copyWith(id: uid);
    await firestore.collection('users').doc(uid).set(newUser.toMap());
    await auth.sendPasswordResetEmail(email: user.email);
  } on FirebaseAuthException catch (e) {
    throw Exception('Error de autenticación: ${e.message}');
  } catch (e) {
    throw Exception('Error al agregar el usuario: $e');
  }
}

final userProvider = StateNotifierProvider<UserNotifier, AsyncValue<void>>(
  (ref) => UserNotifier(),
);

class UserNotifier extends StateNotifier<AsyncValue<void>> {
  UserNotifier() : super(const AsyncData(null));

  Future<void> updateUserState(String id, bool newState) async {
    state = const AsyncLoading();
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .update({'isActive': newState});
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updatePatient({
    required String id,
    required String name,
    required String lastname,
    required String email,
    required int height,
    required int weight,
    required String gender,
    Timestamp? birthday,
    required String activity,
  }) async {
    state = const AsyncLoading();
    try {
      await FirebaseFirestore.instance.collection('users').doc(id).update({
        'name': name,
        'lastname': lastname,
        'email': email,
        'height': height,
        'weight': weight,
        'gender': gender,
        'birthday': birthday,
        'activity': activity,
        'modifiedAt': FieldValue.serverTimestamp(),
        'deletedAt': null,
      });
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final userStreamProvider = StreamProvider.family<DocumentSnapshot, String>((ref, id) {
  return FirebaseFirestore.instance.collection('users').doc(id).snapshots();
});

final searchUsersProvider = FutureProvider.family<List<AppUser>, String>(
  (ref, query) async {
    if (query.isEmpty) return [];

    final firestore = FirebaseFirestore.instance;
    final usersCollection = firestore.collection('users');

    final usersByName = await usersCollection
        .orderBy('name')
        .startAt([query])
        .endAt([query + '\uf8ff'])
        .get();
    final usersByLastName = await usersCollection
        .orderBy('lastname')
        .startAt([query])
        .endAt([query + '\uf8ff'])
        .get();
    final usersByEmail = await usersCollection
        .orderBy('email')
        .startAt([query])
        .endAt([query + '\uf8ff'])
        .get();

    final Map<String, QueryDocumentSnapshot> usersMap = {};
    for (var doc in usersByName.docs) {
      usersMap[doc.id] = doc;
    }
    for (var doc in usersByLastName.docs) {
      usersMap[doc.id] = doc;
    }
    for (var doc in usersByEmail.docs) {
      usersMap[doc.id] = doc;
    }

    final users = usersMap.values.map((doc) => AppUser.fromFirestore(doc)).toList();
    users.sort((a, b) => normalize(a.name).compareTo(normalize(b.name)));
    return users;
  },
);