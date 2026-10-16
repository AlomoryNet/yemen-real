class ReportItem {
  final String id;
  final String propertyId;
  final String? reporterId;
  final String reason;
  final String? details;
  final String status; // pending, investigating, resolved, dismissed
  final String? adminActionTaken;
  final String? resolvedBy;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? propertyTitle;

  ReportItem({
    required this.id,
    required this.propertyId,
    this.reporterId,
    required this.reason,
    this.details,
    this.status = 'pending',
    this.adminActionTaken,
    this.resolvedBy,
    required this.createdAt,
    this.resolvedAt,
    this.propertyTitle,
  });

  factory ReportItem.fromJson(Map<String, dynamic> json) {
    String? pTitle;
    if (json['properties'] != null) {
      final p = json['properties'] as Map<String, dynamic>;
      pTitle = p['title'] as String?;
    }

    return ReportItem(
      id: json['id'] as String,
      propertyId: json['property_id'] as String,
      reporterId: json['reporter_id'] as String?,
      reason: json['reason'] as String,
      details: json['details'] as String?,
      status: json['status'] as String? ?? 'pending',
      adminActionTaken: json['admin_action_taken'] as String?,
      resolvedBy: json['resolved_by'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
      propertyTitle: pTitle,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'reporter_id': reporterId,
      'reason': reason,
      'details': details,
      'status': status,
      'admin_action_taken': adminActionTaken,
      'resolved_by': resolvedBy,
    };
  }
}
