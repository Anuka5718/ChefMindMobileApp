import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ingredient_model.dart';

class IngredientRepository {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _collection => _db
      .collection('users')
      .doc(_auth.currentUser!.uid)
      .collection('ingredients');

  Stream<List<Ingredient>> watchIngredients() {
    return _collection
        .orderBy('expiryDate')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Ingredient.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<void> addIngredient(Ingredient ingredient) async {
    await _collection.add(ingredient.toFirestore());
  }

  Future<void> deleteIngredient(String id) async {
    await _collection.doc(id).delete();
  }

  Future<void> updateIngredient(Ingredient ingredient) async {
    await _collection.doc(ingredient.id).update(ingredient.toFirestore());
  }
}

final ingredientRepositoryProvider =
    Provider<IngredientRepository>((ref) => IngredientRepository());

final ingredientsProvider = StreamProvider<List<Ingredient>>((ref) {
  return ref.read(ingredientRepositoryProvider).watchIngredients();
});