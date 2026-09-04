class CompleteSetupResponse {
  final bool status;
  final String message;
  final CompleteSetupData? data;

  CompleteSetupResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory CompleteSetupResponse.fromJson(Map<String, dynamic> json) {
    return CompleteSetupResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? CompleteSetupData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class CompleteSetupData {
  final String accessToken;
  final String tokenType;
  final UserSetupModel? user;

  CompleteSetupData({
    required this.accessToken,
    required this.tokenType,
    this.user,
  });

  factory CompleteSetupData.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? userData = json['user'] != null ? Map<String, dynamic>.from(json['user']) : null;
    if (userData != null) {
      if (json.containsKey('dealer')) userData['dealer'] = json['dealer'];
      if (json.containsKey('admin')) userData['admin'] = json['admin'];
    }
    
    return CompleteSetupData(
      accessToken: json['access_token'] ?? '',
      tokenType: json['token_type'] ?? '',
      user: userData != null ? UserSetupModel.fromJson(userData) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
      'user': user?.toJson(),
    };
  }
}

class UserSetupModel {
  final int id;
  final String name;
  final String? profilePhoto;
  final String? phoneNumber;
  final String? destination;
  final String? logo;
  final String email;
  final String? emailVerifiedAt;
  final String? approvalStatus;
  final String? subscriptionStartedAt;
  final String? subscriptionEndsAt;
  final String? whatsappNumber;
  final String? address;
  final Map<String, dynamic>? dealer;
  final Map<String, dynamic>? admin;

  UserSetupModel({
    required this.id,
    required this.name,
    this.profilePhoto,
    this.phoneNumber,
    this.destination,
    this.logo,
    required this.email,
    this.emailVerifiedAt,
    this.approvalStatus,
    this.subscriptionStartedAt,
    this.subscriptionEndsAt,
    this.whatsappNumber,
    this.address,
    this.dealer,
    this.admin,
  });

  factory UserSetupModel.fromJson(Map<String, dynamic> json) {
    return UserSetupModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      profilePhoto: json['profile_photo'],
      phoneNumber: json['phone_number'],
      destination: json['destination'],
      logo: json['logo'],
      email: json['email'] ?? '',
      emailVerifiedAt: json['email_verified_at'],
      approvalStatus: json['approval_status'],
      subscriptionStartedAt: json['subscription_started_at'],
      subscriptionEndsAt: json['subscription_ends_at'],
      whatsappNumber: json['whatsapp_number'],
      address: json['address'],
      dealer: json['dealer'],
      admin: json['admin'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profile_photo': profilePhoto,
      'phone_number': phoneNumber,
      'destination': destination,
      'logo': logo,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'approval_status': approvalStatus,
      'subscription_started_at': subscriptionStartedAt,
      'subscription_ends_at': subscriptionEndsAt,
      'whatsapp_number': whatsappNumber,
      'address': address,
      'dealer': dealer,
      'admin': admin,
    };
  }
}
