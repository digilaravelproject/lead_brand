class LeadModel {
  final int id;
  final int? userId;
  final String fullName;
  final String phoneNumber;
  final String status; // 'hot_lead', 'appointment', 'follow_up', 'done'
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;

  LeadModel({
    required this.id,
    this.userId,
    required this.fullName,
    required this.phoneNumber,
    required this.status,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    return LeadModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id'].toString()),
      fullName: json['full_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      status: json['status'] ?? 'hot_lead',
      isActive: json['is_active'] is bool ? json['is_active'] : (json['is_active'].toString() == '1'),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'status': status,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Get UI-friendly status string
  String get uiStatus {
    switch (status) {
      case 'hot_lead':
        return 'Hot Lead';
      case 'appointment':
        return 'Appointment';
      case 'follow_up':
      case 'followup':
        return 'Follow Up';
      case 'done':
        return 'Done';
      default:
        // Try mapping direct UI values just in case
        if (status == 'Hot Lead' || status == 'Appointment' || status == 'Follow Up' || status == 'Done') {
          return status;
        }
        return 'Hot Lead';
    }
  }

  // Map UI-friendly status back to API status value
  static String mapUIToApiStatus(String uiStatus) {
    switch (uiStatus) {
      case 'Hot Lead':
        return 'hot_lead';
      case 'Appointment':
        return 'appointment';
      case 'Follow Up':
        return 'followup';
      case 'Done':
        return 'done';
      default:
        return 'hot_lead';
    }
  }
}
