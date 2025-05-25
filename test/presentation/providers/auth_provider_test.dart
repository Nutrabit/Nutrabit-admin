import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider_auxiliary_test.dart'; // Asegúrate de que esté bien

// Mock classes
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}

void main() {
  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockFirestore;
  late AuthNotifier notifier;

  setUpAll(() {
  registerFallbackValue(MockDocumentSnapshot());
  registerFallbackValue(MockUser());
  });


  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    notifier = AuthNotifier(
      authInstance: mockAuth,
      firestoreInstance: mockFirestore,
    );

  });

  group('AuthNotifier', () {
    test('login returns true if user is admin', () async {
      final mockCredential = MockUserCredential();
      final mockUser = MockUser();
      final mockCollection = MockCollectionReference();
      final mockDoc = MockDocumentReference();
      final mockSnapshot = MockDocumentSnapshot();

      when(() => mockUser.uid).thenReturn('admin123');
      when(() => mockCredential.user).thenReturn(mockUser);
      when(() => mockAuth.signInWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => mockCredential);
      when(() => mockFirestore.collection('admin')).thenReturn(mockCollection);
      when(() => mockCollection.doc('admin123')).thenReturn(mockDoc);
      when(() => mockDoc.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.exists).thenReturn(true);

      final result = await notifier.login('test@example.com', '123456');
      expect(result, isTrue);
    });

    test('login returns null on FirebaseAuthException', () async {
      when(() => mockAuth.signInWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenThrow(FirebaseAuthException(code: 'user-not-found', message: 'User not found'));

      final result = await notifier.login('invalid@example.com', 'wrong');
      expect(result, isNull);
    });

    test('isAdmin returns true if document exists', () async {
      final mockCollection = MockCollectionReference();
      final mockDoc = MockDocumentReference();
      final mockSnapshot = MockDocumentSnapshot();

      when(() => mockFirestore.collection('admin')).thenReturn(mockCollection);
      when(() => mockCollection.doc('admin456')).thenReturn(mockDoc);
      when(() => mockDoc.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.exists).thenReturn(true);

      final result = await notifier.isAdmin('admin456');
      expect(result, isTrue);
    });

    test('isAdmin returns false on error', () async {
      when(() => mockFirestore.collection('admin')).thenThrow(Exception('Firestore error'));
      final result = await notifier.isAdmin('admin456');
      expect(result, isFalse);
    });

    test('logout returns true when successful', () async {
      when(() => mockAuth.signOut()).thenAnswer((_) async {});
      notifier = AuthNotifier(authInstance: mockAuth, firestoreInstance: mockFirestore);
      final result = await notifier.logout();
      expect(result, isTrue);
    });

    test('logout returns false on error', () async {
      when(() => mockAuth.signOut()).thenThrow(Exception('Logout failed'));
      notifier = AuthNotifier(authInstance: mockAuth, firestoreInstance: mockFirestore);
      final result = await notifier.logout();
      expect(result, isFalse);
    });
  });
}