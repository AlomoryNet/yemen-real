import 'package:flutter/foundation.dart';

import 'map_query.dart';

/// A user-owned search whose filters are reused for results and new-listing alerts.
@immutable
class SavedSearch {
  const SavedSearch({
    required this.id,
    required this.userId,
    required this.name,
    required this.query,
    this.notify = true,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String name;
  final MapQuery query;
  final bool notify;
  final DateTime createdAt;
  final DateTime updatedAt;

  SavedSearch copyWith({
    String? name,
    MapQuery? query,
    bool? notify,
  }) {
    return SavedSearch(
      id: id,
      userId: userId,
      name: name ?? this.name,
      query: query ?? this.query,
      notify: notify ?? this.notify,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Restores a row from `saved_searches`, tolerating older JSON shapes.
  factory SavedSearch.fromJson(Map<String, dynamic> json) {
    final rawQuery = json['query'];
    final query = rawQuery is Map<String, dynamic>
        ? MapQuery.fromSavedJson(rawQuery)
        : rawQuery is Map
            ? MapQuery.fromSavedJson(
                Map<String, dynamic>.from(rawQuery),
              )
            : const MapQuery();

    return SavedSearch(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String? ?? '',
      query: query,
      notify: json['notify'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  /// Converts this search into a Supabase row payload.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'user_id': userId,
        'name': name,
        'query': query.toSavedJson(),
        'notify': notify,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
