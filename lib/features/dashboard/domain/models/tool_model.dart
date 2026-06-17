import 'package:flutter/material.dart';

class ToolItem {
  final int id;
  final String title;
  final String description;
  final IconData icon;
  final String route;
  final Color color;
  final List<dynamic>? subtools;
  final List<dynamic>? media;

  ToolItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
    required this.color,
    this.subtools,
    this.media,
  });
}

class ToolModel {
  final int id;
  final String title;
  final String description;
  final String icon;
  final List<ToolMediaModel> media;
  final List<SubtoolModel> subtools;

  ToolModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.media,
    required this.subtools,
  });

  factory ToolModel.fromJson(Map<String, dynamic> json) {
    return ToolModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      media: json['media'] != null
          ? (json['media'] as List).map((m) => ToolMediaModel.fromJson(m)).toList()
          : [],
      subtools: json['subtools'] != null
          ? (json['subtools'] as List).map((s) => SubtoolModel.fromJson(s)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'media': media.map((m) => m.toJson()).toList(),
      'subtools': subtools.map((s) => s.toJson()).toList(),
    };
  }
}

class ToolMediaModel {
  final int id;
  final String title;
  final String filePath;
  final String fullUrl;
  final String mediaType;
  final String language;
  final String? thumbnailUrl;
  final String? pdf;
  final String? pdfUrl;
  final String? infoImage;
  final String? infoImageUrl;

  ToolMediaModel({
    required this.id,
    required this.title,
    required this.filePath,
    required this.fullUrl,
    required this.mediaType,
    required this.language,
    this.thumbnailUrl,
    this.pdf,
    this.pdfUrl,
    this.infoImage,
    this.infoImageUrl,
  });

  factory ToolMediaModel.fromJson(Map<String, dynamic> json) {
    return ToolMediaModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      filePath: json['file_path'] ?? '',
      fullUrl: json['full_url'] ?? '',
      mediaType: json['media_type'] ?? '',
      language: json['language'] ?? '',
      thumbnailUrl: json['thumbnail_url'],
      pdf: json['pdf'],
      pdfUrl: json['pdf_url'],
      infoImage: json['info_image'],
      infoImageUrl: json['info_image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'file_path': filePath,
      'full_url': fullUrl,
      'media_type': mediaType,
      'language': language,
      'thumbnail_url': thumbnailUrl,
      'pdf': pdf,
      'pdf_url': pdfUrl,
      'info_image': infoImage,
      'info_image_url': infoImageUrl,
    };
  }
}

class SubtoolModel {
  final int id;
  final int toolId;
  final String title;
  final String description;
  final List<ToolMediaModel> media;

  SubtoolModel({
    required this.id,
    required this.toolId,
    required this.title,
    required this.description,
    required this.media,
  });

  factory SubtoolModel.fromJson(Map<String, dynamic> json) {
    return SubtoolModel(
      id: json['id'] ?? 0,
      toolId: json['tool_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      media: json['media'] != null
          ? (json['media'] as List).map((m) => ToolMediaModel.fromJson(m)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tool_id': toolId,
      'title': title,
      'description': description,
      'media': media.map((m) => m.toJson()).toList(),
    };
  }
}
