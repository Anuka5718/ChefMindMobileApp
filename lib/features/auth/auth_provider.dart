import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final userProfileProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value(null);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) => doc.data());
});

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Future<void> signUp(
    String email,
    String password, {
    required String username,
    String dietaryType = 'omnivore',
    List<String> allergies = const [],
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user!.updateDisplayName(username);
    await _db.collection('users').doc(credential.user!.uid).set({
      'email': email,
      'username': username,
      'dietaryType': dietaryType,
      'allergies': allergies,
      'calorieTarget': 2000,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> updatePhotoUrl(String url) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.updatePhotoURL(url);
    await _db.collection('users').doc(user.uid).update(
      {'photoUrl': url},
    );
  }

  Future<void> updateUsername(String username) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.updateDisplayName(username);
    await _db.collection('users').doc(user.uid).update(
      {'username': username},
    );
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());