import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ingredients/ingredient_model.dart';
import '../../services/remote_config_service.dart';
import 'recipe_model.dart';

class HuggingFaceRecipeService {
  final RemoteConfigService _config;
  HuggingFaceRecipeService(this._config);

  // Hugging Face Inference API endpoint
  static const _model = 'mistralai/Mistral-7B-Instruct-v0.2';
  static const _url = 'https://api-inference.huggingface.co/models/$_model';

  String _buildPrompt({
    required List<Ingredient> ingredients,
    required String dietaryType,
    required List<String> allergies,
  }) {
    final ingredientList = ingredients
        .map((i) => '${i.name} x${i.quantity}${i.unit} '
            '(expires in ${i.daysUntilExpiry} days)')
        .join(', ');

    final allergyText = allergies.isEmpty ? 'none' : allergies.join(', ');

    // Mistral uses [INST] instruction format
    return '''<s>[INST]
You are a professional chef AI.
Return ONLY a valid JSON array. No markdown, no explanation.

Dietary type: $dietaryType
Allergies to avoid: $allergyText
Available ingredients: $ingredientList

Prioritise ingredients expiring soonest.
Return exactly 3 recipes.

Each recipe must have this exact structure:
{
  "name": "string",
  "cook_time_mins": number,
  "difficulty": "Easy" or "Medium" or "Hard",
  "calories": number,
  "ingredients_used": ["string"],
  "ingredients_missing": ["string"],
  "steps": ["string"]
}

Return only the JSON array, nothing else.
[/INST]''';
  }

  Future<List<Recipe>> generateRecipes({
    required List<Ingredient> ingredients,
    required String dietaryType,
    required List<String> allergies,
  }) async {
    final apiKey = _config.huggingFaceApiKey;
    if (apiKey.isEmpty) {
      throw Exception('Hugging Face API key not found in Remote Config');
    }

    final prompt = _buildPrompt(
      ingredients: ingredients,
      dietaryType: dietaryType,
      allergies: allergies,
    );

    final response = await http.post(
      Uri.parse(_url),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'inputs': prompt,
        'parameters': {
          'max_new_tokens': 1024,
          'temperature': 0.7,
          'return_full_text': false, // only return generated text
          'stop': ['</s>'],
        },
      }),
    );

    if (response.statusCode == 503) {
      // Model is loading — wait and retry once
      await Future.delayed(const Duration(seconds: 20));
      return generateRecipes(
        ingredients: ingredients,
        dietaryType: dietaryType,
        allergies: allergies,
      );
    }

    if (response.statusCode != 200) {
      throw Exception('Hugging Face API error ${response.statusCode}: '
          '${response.body}');
    }

    final decoded = jsonDecode(response.body);
    // HF returns a list with one object containing generated_text
    final rawText = decoded[0]['generated_text'] as String;

    debugPrint('=== HF RAW RESPONSE ===\n$rawText\n====================');

    // Extract JSON array from response
    final start = rawText.indexOf('[');
    final end = rawText.lastIndexOf(']');

    if (start == -1 || end == -1) {
      throw Exception('No JSON array found in response');
    }

    final jsonStr = rawText.substring(start, end + 1).trim();
    final List<dynamic> jsonList = jsonDecode(jsonStr);

    return jsonList
        .map((j) => Recipe.fromJson(j as Map<String, dynamic>))
        .toList();
  }
}

final huggingFaceRecipeServiceProvider =
    Provider<HuggingFaceRecipeService>((ref) {
  return HuggingFaceRecipeService(ref.read(remoteConfigServiceProvider));
});
