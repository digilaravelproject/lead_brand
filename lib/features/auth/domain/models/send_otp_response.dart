class SendOtpResponse {
  final bool status;
  final String message;
  final SendOtpData? data;

  SendOtpResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    return SendOtpResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? SendOtpData.fromJson(json['data']) : null,
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

class SendOtpData {
  final String email;
  final String expiresAt;
  final int isNew;

  SendOtpData({
    required this.email,
    required this.expiresAt,
    required this.isNew,
  });

  factory SendOtpData.fromJson(Map<String, dynamic> json) {
    return SendOtpData(
      email: json['email'] ?? '',
      expiresAt: json['expires_at'] ?? '',
      isNew: json['is_new'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'expires_at': expiresAt,
      'is_new': isNew,
    };
  }
}
