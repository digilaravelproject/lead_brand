class TrainingCategoryModel {
  final int id;
  final String categoryName;
  final String? description;

  TrainingCategoryModel({
    required this.id,
    required this.categoryName,
    this.description,
  });

  factory TrainingCategoryModel.fromJson(Map<String, dynamic> json) {
    return TrainingCategoryModel(
      id: json['id'] ?? 0,
      categoryName: json['category_name'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_name': categoryName,
      'description': description,
    };
  }
}
