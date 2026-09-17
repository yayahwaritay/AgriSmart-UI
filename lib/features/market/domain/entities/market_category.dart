import 'package:flutter/foundation.dart';

@immutable
class MarketCategory {
  const MarketCategory({required this.id, required this.name, this.description});

  final String id;
  final String name;
  final String? description;

  factory MarketCategory.fromJson(Map<String, dynamic> json) {
    return MarketCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is MarketCategory && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
