import 'category_model.dart';

class TrainingModel {
  final int id;
  final int trainingCategoryId;
  final String type;
  final String title;
  final String description;
  final String filePath;
  final int status;
  final String fileUrl;
  final TrainingCategoryModel? category;

  TrainingModel({
    required this.id,
    required this.trainingCategoryId,
    required this.type,
    required this.title,
    required this.description,
    required this.filePath,
    required this.status,
    required this.fileUrl,
    this.category,
  });

  factory TrainingModel.fromJson(Map<String, dynamic> json) {
    return TrainingModel(
      id: json['id'] ?? 0,
      trainingCategoryId: json['training_category_id'] ?? 0,
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      filePath: json['file_path'] ?? '',
      status: json['status'] ?? 0,
      fileUrl: json['file_url'] ?? '',
      category: json['category'] != null
          ? TrainingCategoryModel.fromJson(json['category'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'training_category_id': trainingCategoryId,
      'type': type,
      'title': title,
      'description': description,
      'file_path': filePath,
      'status': status,
      'file_url': fileUrl,
      'category': category?.toJson(),
    };
  }
}
