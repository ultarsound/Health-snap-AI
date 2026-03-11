class HealthItem {
  final String id;
  final String title;
  final String description;
  final String category;
  final String imageUrl;
  final List<String> benefits;
  final String type; // 'food' or 'exercise'
  final String? mealDbId; // for fetching full recipe
  final List<String> ingredients;
  final List<String> measures;
  final String instructions;
  final String? area;
  final String? youtubeUrl;

  HealthItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.benefits,
    required this.type,
    this.mealDbId,
    this.ingredients = const [],
    this.measures = const [],
    this.instructions = '',
    this.area,
    this.youtubeUrl,
  });

  factory HealthItem.fromJson(Map<String, dynamic> json) {
    // Extract ingredients from MealDB format
    List<String> ingredients = [];
    List<String> measures = [];
    for (int i = 1; i <= 20; i++) {
      final ing = json['strIngredient$i'];
      final mea = json['strMeasure$i'];
      if (ing != null && ing.toString().trim().isNotEmpty) {
        ingredients.add(ing.toString().trim());
        measures.add(mea?.toString().trim() ?? '');
      }
    }

    return HealthItem(
      id: json['id']?.toString() ?? json['idMeal']?.toString() ?? '',
      title: json['title'] ?? json['strMeal'] ?? json['strExercise'] ?? '',
      description: json['description'] ?? json['strInstructions'] ?? '',
      category: json['category'] ?? json['strCategory'] ?? '',
      imageUrl: json['imageUrl'] ?? json['strMealThumb'] ?? '',
      benefits: List<String>.from(json['benefits'] ?? []),
      type: json['type'] ?? 'food',
      mealDbId: json['idMeal']?.toString() ?? json['mealDbId'],
      ingredients: ingredients,
      measures: measures,
      instructions: json['strInstructions'] ?? json['instructions'] ?? '',
      area: json['strArea'],
      youtubeUrl: json['strYoutube'],
    );
  }
}

class HealthNotification {
  final String id;
  final String title;
  final String body;
  final DateTime time;
  bool isRead;

  HealthNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    this.isRead = false,
  });
}
