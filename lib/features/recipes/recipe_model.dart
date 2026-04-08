class Recipe {
  final String name;
  final int cookTimeMins;
  final String difficulty;
  final int calories;
  final List<String> ingredientsUsed;
  final List<String> ingredientsMissing;
  final List<String> steps;

  Recipe({
    required this.name,
    required this.cookTimeMins,
    required this.difficulty,
    required this.calories,
    required this.ingredientsUsed,
    required this.ingredientsMissing,
    required this.steps,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      name: json['name'] as String,
      cookTimeMins: json['cook_time_mins'] as int,
      difficulty: json['difficulty'] as String,
      calories: json['calories'] as int,
      ingredientsUsed: List<String>.from(json['ingredients_used']),
      ingredientsMissing: List<String>.from(json['ingredients_missing']),
      steps: List<String>.from(json['steps']),
    );
  }
}