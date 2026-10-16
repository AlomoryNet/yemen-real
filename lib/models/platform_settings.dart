class PlatformSettings {
  final String key;
  final Map<String, dynamic> value;
  final String? description;
  final DateTime? updatedAt;

  PlatformSettings({
    required this.key,
    required this.value,
    this.description,
    this.updatedAt,
  });

  factory PlatformSettings.fromJson(Map<String, dynamic> json) {
    return PlatformSettings(
      key: json['key'] as String,
      value: json['value'] as Map<String, dynamic>? ?? {},
      description: json['description'] as String?,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'key': key, 'value': value, 'description': description};
  }
}
