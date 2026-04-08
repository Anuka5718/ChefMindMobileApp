import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ingredients/ingredient_model.dart';
import '../../services/remote_config_service.dart';
import 'recipe_model.dart';

class RecipeService {
  final RemoteConfigService _config;
  RecipeService(this._config);

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
Return ONLY a valid JSON array. No markdown, no explanation, no extra text.

Dietary type: $dietaryType
Allergies to strictly avoid: $allergyText
Available ingredients: $ingredientList

Rules:
- Prioritise ingredients expiring soonest
- Strictly exclude ingredients matching the allergy list
- Return exactly 3 recipes
- Make recipes practical and delicious

Each recipe must follow this exact JSON structure:
[
  {
    "name": "Recipe Name",
    "cook_time_mins": 30,
    "difficulty": "Easy",
    "calories": 450,
    "ingredients_used": ["ingredient1", "ingredient2"],
    "ingredients_missing": ["ingredient3"],
    "steps": ["Step 1: Do this", "Step 2: Do that"]
  }
]

Return only the JSON array, nothing else.
''';
  }

  Future<List<Recipe>> generateRecipes({
    required List<Ingredient> ingredients,
    required String dietaryType,
    required List<String> allergies,
  }) async {
    final apiKey = _config.geminiApiKey;
    if (apiKey.isEmpty) throw Exception('Gemini API key not configured');

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey',
    );

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {
              "text": _buildPrompt(
                ingredients: ingredients,
                dietaryType: dietaryType,
                allergies: allergies,
              )
            }
          ]
        }
      ]
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      debugPrint('Gemini error: ${response.body}');
      throw Exception('Gemini API error: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    final text = decoded['candidates'][0]['content']['parts'][0]['text'] as String;

    debugPrint('Gemini response: $text');

    final cleaned = text
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    final List<dynamic> jsonList = jsonDecode(cleaned);
    return jsonList
        .map((j) => Recipe.fromJson(j as Map<String, dynamic>))
        .toList();
  }
}

final recipeServiceProvider = Provider<RecipeService>((ref) {
  return RecipeService(ref.read(remoteConfigServiceProvider));
});