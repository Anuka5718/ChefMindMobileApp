class Ingredient {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final String category;
  final DateTime expiryDate;

  Ingredient({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.category,
    required this.expiryDate,
  });

  int get daysUntilExpiry =>
      expiryDate.difference(DateTime.now()).inDays;

  String get expiryStatus {
    if (daysUntilExpiry <= 1) return 'red';
    if (daysUntilExpiry <= 3) return 'amber';
    return 'green';
  }

  factory Ingredient.fromFirestore(Map<String, dynamic> data, String id) {
    return Ingredient(
      id: id,
      name: data['name'] as String,
      quantity: (data['quantity'] as num).toDouble(),
      unit: data['unit'] as String,
      category: data['category'] as String,
      expiryDate: DateTime.parse(data['expiryDate'] as String),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'quantity': quantity,
    'unit': unit,
    'category': category,
    'expiryDate': expiryDate.toIso8601String(),
  };
}