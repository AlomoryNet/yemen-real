import '../core/constants/app_constants.dart';

class Commission {
  final String id;
  final String propertyId;
  final String liableParty; // seller, buyer, both
  final double sellerAmount;
  final double buyerAmount;
  final double totalAmount;
  final String currency; // YER, SAR, USD
  final String? reasonAndNotes;
  final String settlementStatus; // due, paid, cancelled
  final String? settlementMethod;
  final String? createdBy;
  final DateTime recordedAt;
  final DateTime? settledAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? propertyTitle;

  Commission({
    required this.id,
    required this.propertyId,
    required this.liableParty,
    this.sellerAmount = 0,
    this.buyerAmount = 0,
    required this.totalAmount,
    this.currency = AppConstants.currencyYer,
    this.reasonAndNotes,
    this.settlementStatus = AppConstants.commStatusDue,
    this.settlementMethod,
    this.createdBy,
    required this.recordedAt,
    this.settledAt,
    required this.createdAt,
    this.updatedAt,
    this.propertyTitle,
  });

  factory Commission.fromJson(Map<String, dynamic> json) {
    String? pTitle;
    if (json['properties'] != null) {
      final p = json['properties'] as Map<String, dynamic>;
      pTitle = p['title'] as String?;
    }

    return Commission(
      id: json['id'] as String,
      propertyId: json['property_id'] as String,
      liableParty: json['liable_party'] as String? ?? AppConstants.liableBoth,
      sellerAmount: json['seller_amount'] != null
          ? (json['seller_amount'] as num).toDouble()
          : 0,
      buyerAmount: json['buyer_amount'] != null
          ? (json['buyer_amount'] as num).toDouble()
          : 0,
      totalAmount: (json['total_amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? AppConstants.currencyYer,
      reasonAndNotes: json['reason_and_notes'] as String?,
      settlementStatus:
          json['settlement_status'] as String? ?? AppConstants.commStatusDue,
      settlementMethod: json['settlement_method'] as String?,
      createdBy: json['created_by'] as String?,
      recordedAt: json['recorded_at'] != null
          ? DateTime.parse(json['recorded_at'] as String)
          : DateTime.now(),
      settledAt: json['settled_at'] != null
          ? DateTime.parse(json['settled_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      propertyTitle: pTitle,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'liable_party': liableParty,
      'seller_amount': sellerAmount,
      'buyer_amount': buyerAmount,
      'total_amount': totalAmount,
      'currency': currency,
      'reason_and_notes': reasonAndNotes,
      'settlement_status': settlementStatus,
      'settlement_method': settlementMethod,
      'created_by': createdBy,
      'recorded_at': recordedAt.toIso8601String(),
      'settled_at': settledAt?.toIso8601String(),
    };
  }
}
