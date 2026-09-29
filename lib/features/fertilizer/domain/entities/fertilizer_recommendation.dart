import 'package:flutter/foundation.dart';

import 'fertilizer_request.dart';
import 'fertilizer_result.dart';
import 'json_read.dart';

DateTime _readDate(Map<String, dynamic> json, String key) {
  return DateTime.tryParse(readString(json, key))?.toLocal() ?? DateTime.fromMillisecondsSinceEpoch(0);
}

/// One row of `GET /fertilizer/recommendations`.
@immutable
class RecommendationSummary {
  const RecommendationSummary({
    required this.id,
    required this.cropId,
    required this.cropName,
    required this.plotLabel,
    required this.areaHectares,
    required this.totalEstimatedCost,
    required this.currency,
    required this.createdAt,
  });

  final String id;
  final String cropId;
  final String cropName;

  /// `""` when the farmer didn't name the plot.
  final String plotLabel;
  final double areaHectares;
  final double totalEstimatedCost;
  final String currency;
  final DateTime createdAt;

  factory RecommendationSummary.fromJson(Map<String, dynamic> json) {
    return RecommendationSummary(
      id: readString(json, 'id'),
      cropId: readString(json, 'cropId'),
      cropName: readString(json, 'cropName'),
      plotLabel: readString(json, 'plotLabel'),
      areaHectares: readDouble(json, 'areaHectares'),
      totalEstimatedCost: readDouble(json, 'totalEstimatedCost'),
      currency: readString(json, 'currency'),
      createdAt: _readDate(json, 'createdAt'),
    );
  }
}

/// A saved recommendation — `GET /fertilizer/recommendations/{id}` and the
/// `201` from saving. [result] is exactly what was calculated then.
@immutable
class FertilizerRecommendation {
  const FertilizerRecommendation({
    required this.id,
    required this.cropId,
    required this.cropName,
    required this.plotLabel,
    required this.areaHectares,
    required this.createdAt,
    required this.inputs,
    required this.result,
  });

  final String id;
  final String cropId;
  final String cropName;
  final String plotLabel;
  final double areaHectares;
  final DateTime createdAt;
  final FertilizerRequest inputs;
  final FertilizerResult result;

  factory FertilizerRecommendation.fromJson(Map<String, dynamic> json) {
    return FertilizerRecommendation(
      id: readString(json, 'id'),
      cropId: readString(json, 'cropId'),
      cropName: readString(json, 'cropName'),
      plotLabel: readString(json, 'plotLabel'),
      areaHectares: readDouble(json, 'areaHectares'),
      createdAt: _readDate(json, 'createdAt'),
      inputs: FertilizerRequest.fromJson(readMap(json, 'inputs')),
      result: FertilizerResult.fromJson(readMap(json, 'result')),
    );
  }
}

/// `{ items, page, pageSize, totalCount, totalPages }`.
@immutable
class PagedResult<T> {
  const PagedResult({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
  });

  final List<T> items;
  final int page;
  final int pageSize;
  final int totalCount;
  final int totalPages;

  bool get hasMore => page < totalPages;

  factory PagedResult.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) itemFromJson) {
    return PagedResult(
      items: readList(json, 'items', itemFromJson),
      page: readInt(json, 'page'),
      pageSize: readInt(json, 'pageSize'),
      totalCount: readInt(json, 'totalCount'),
      totalPages: readInt(json, 'totalPages'),
    );
  }
}
