import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ingredients/ingredient_model.dart';
import '../../services/remote_config_service.dart';
import 'recipe_model.dart';

class RecipeService {
  final String? _apiKey;
  late final GenerativeModel _jsonModel;
  
  // From your working sample: Prevents context window overflows or API errors
  static const int _maxCharacterLimit = 50000;

  RecipeService(RemoteConfigService config) : _apiKey = config.geminiApiKey {
    final key = _apiKey ?? '';
    
    _jsonModel = GenerativeModel(
      // FIXED: Changed to 1.5-flash or 2.0-flash to resolve 503 "High Demand" errors
      model: 'gemini-2.5-flash', 
      apiKey: key,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
    );
  }

  // --- SAFETY FUNCTION (Imported from your working sample) ---
  String _enforceTextLimit(String text) {
    if (text.length <= _maxCharacterLimit) return text;
    int safeCutOff = text.lastIndexOf(' ', _maxCharacterLimit);
    if (safeCutOff == -1) safeCutOff = _maxCharacterLimit;
    
    debugPrint('RecipeService: Truncating input from ${text.length} to $safeCutOff.');
    return '${text.substring(0, safeCutOff)}\n\n...[TRUNCATED]';
  }

  String _buildPrompt({
    required List<Ingredient> ingredients,
    required String dietaryType,
    required List<String> allergies,
  }) {
    final ingredientList = ingredients
        .map((i) =>
            '${i.name} x${i.quantity}${i.unit} (expires in ${i.daysUntilExpiry} days)')
        .join(', ');

    final allergyText = allergies.isEmpty ? 'none' : allergies.join(', ');

    return '''
You are a professional chef AI for the ChefMind app.
Your task is to suggest recipes based on available ingredients.

INSTRUCTIONS:
1. Prioritize ingredients expiring soonest.
2. Strictly exclude ingredients matching the allergy list.
3. Return exactly 3 recipes.
4. Output MUST be a JSON array of objects.

PARAMETERS:
- Dietary type: $dietaryType
- Allergies: $allergyText
- Ingredients: $ingredientList

REQUIRED JSON STRUCTURE:
[
  {
    "name": "Recipe Name",
    "cook_time_mins": 30,
    "difficulty": "Easy",
    "calories": 450,
    "ingredients_used": ["item1"],
    "ingredients_missing": ["item2"],
    "steps": ["Step 1..."]
  }
]
''';
  }

  Future<List<Recipe>> generateRecipes({
    required List<Ingredient> ingredients,
    required String dietaryType,
    required List<String> allergies,
  }) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('Gemini API key not configured');
    }

    final rawPrompt = _buildPrompt(
      ingredients: ingredients,
      dietaryType: dietaryType,
      allergies: allergies,
    );
    
    final safePrompt = _enforceTextLimit(rawPrompt);

    try {
      final response = await _jsonModel.generateContent([Content.text(safePrompt)]);
      print('Raw response text: ${response.text}, ${response}'); // Debug log for raw response 
      if (response.text == null) return [];

      // Cleaning the response text as done in your working sample
      String cleanJson = response.text!
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final List<dynamic> jsonList = jsonDecode(cleanJson);
      
      return jsonList
          .map((j) => Recipe.fromJson(j as Map<String, dynamic>))
          .toList();
          
    } catch (e) {
      debugPrint('Error generating recipes: $e');
      // Stability fallback: return empty list on failure
      return []; 
    }
  }
}

final recipeServiceProvider = Provider<RecipeService>((ref) {
  return RecipeService(ref.read(remoteConfigServiceProvider));
});