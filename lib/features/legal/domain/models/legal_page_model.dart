class LegalPageModel {
  final int id;
  final String pageName;
  final String pageType;
  final String description;
  final int status;

  LegalPageModel({
    required this.id,
    required this.pageName,
    required this.pageType,
    required this.description,
    required this.status,
  });

  factory LegalPageModel.fromJson(Map<String, dynamic> json) {
    return LegalPageModel(
      id: json['id'] ?? 0,
      pageName: json['page_name'] ?? '',
      pageType: json['page_type'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'page_name': pageName,
      'page_type': pageType,
      'description': description,
      'status': status,
    };
  }
}
