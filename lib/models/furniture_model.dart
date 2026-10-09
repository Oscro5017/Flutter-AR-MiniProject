class Furniture {
  final String name;
  final String subtitle;
  final List<String> categories;
  final String image;
  final String modelPath;
  final double price;
  final double rating;
  final int soldCount;
  final String description;
  final String dimensions;
  final String material;
  final String weight;

  const Furniture({
    required this.name,
    required this.subtitle,
    required this.categories,
    required this.price,
    required this.image,
    required this.modelPath,
    required this.rating,
    this.soldCount = 0,
    this.description = "",
    this.dimensions = "",
    this.material = "",
    this.weight = "",
  });

  /// Backward-compatible getter returning primary or joined categories
  String get category => categories.isNotEmpty ? categories.join(' • ') : 'Others';

  Furniture copyWith({
    String? name,
    String? subtitle,
    List<String>? categories,
    String? image,
    String? modelPath,
    double? price,
    double? rating,
    int? soldCount,
    String? description,
    String? dimensions,
    String? material,
    String? weight,
  }) {
    return Furniture(
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      categories: categories ?? this.categories,
      image: image ?? this.image,
      modelPath: modelPath ?? this.modelPath,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      soldCount: soldCount ?? this.soldCount,
      description: description ?? this.description,
      dimensions: dimensions ?? this.dimensions,
      material: material ?? this.material,
      weight: weight ?? this.weight,
    );
  }
}
