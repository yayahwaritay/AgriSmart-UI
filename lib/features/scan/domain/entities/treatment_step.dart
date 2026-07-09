import 'package:flutter/foundation.dart';

@immutable
class TreatmentStep {
  const TreatmentStep({
    required this.order,
    required this.title,
    required this.description,
  });

  final int order;
  final String title;
  final String description;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TreatmentStep &&
          order == other.order &&
          title == other.title &&
          description == other.description;

  @override
  int get hashCode => Object.hash(order, title, description);
}
