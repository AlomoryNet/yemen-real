import '../core/constants/app_constants.dart';

class RentalRequest {
  final String id;
  final String requestNumber;
  final String propertyId;
  final String userId;
  final String fullName;
  final String phone;
  final DateTime? requestedStartDate;
  final String? notes;
  final String status;
  final String? adminNotes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? propertyTitle;
  final double? propertyPrice;
  final String? propertyCurrency;

  RentalRequest({
    required this.id,
    required this.requestNumber,
    required this.propertyId,
    required this.userId,
    required this.fullName,
    required this.phone,
    this.requestedStartDate,
    this.notes,
    this.status = AppConstants.reqStatusNew,
    this.adminNotes,
    required this.createdAt,
    this.updatedAt,
    this.propertyTitle,
    this.propertyPrice,
    this.propertyCurrency,
  });

  factory RentalRequest.fromJson(Map<String, dynamic> json) {
    String? pTitle;
    double? pPrice;
    String? pCurr;

    if (json['properties'] != null) {
      final prop = json['properties'] as Map<String, dynamic>;
      pTitle = prop['title'] as String?;
      pPrice = prop['price'] != null ? (prop['price'] as num).toDouble() : null;
      pCurr = prop['currency'] as String?;
    }

    return RentalRequest(
      id: json['id'] as String,
      requestNumber: json['request_number'] as String,
      propertyId: json['property_id'] as String,
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String,
      requestedStartDate: json['requested_start_date'] != null
          ? DateTime.parse(json['requested_start_date'] as String)
          : null,
      notes: json['notes'] as String?,
      status: json['status'] as String? ?? AppConstants.reqStatusNew,
      adminNotes: json['admin_notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      propertyTitle: pTitle,
      propertyPrice: pPrice,
      propertyCurrency: pCurr,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'request_number': requestNumber,
      'property_id': propertyId,
      'user_id': userId,
      'full_name': fullName,
      'phone': phone,
      'requested_start_date': requestedStartDate
          ?.toIso8601String()
          .split('T')
          .first,
      'notes': notes,
      'status': status,
      'admin_notes': adminNotes,
    };
  }

  RentalRequest copyWith({String? status, String? adminNotes}) {
    return RentalRequest(
      id: id,
      requestNumber: requestNumber,
      propertyId: propertyId,
      userId: userId,
      fullName: fullName,
      phone: phone,
      requestedStartDate: requestedStartDate,
      notes: notes,
      status: status ?? this.status,
      adminNotes: adminNotes ?? this.adminNotes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      propertyTitle: propertyTitle,
      propertyPrice: propertyPrice,
      propertyCurrency: propertyCurrency,
    );
  }
}
