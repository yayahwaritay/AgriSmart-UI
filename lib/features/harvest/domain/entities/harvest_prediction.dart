import 'package:flutter/foundation.dart';

/// Bucketed width of the [HarvestWindow] — safe to render as a badge/color
/// directly (see README.mobile.md).
enum HarvestConfidence {
  high,
  medium,
  low;

  static HarvestConfidence fromJson(String value) {
    return switch (value) {
      'High' => HarvestConfidence.high,
      'Medium' => HarvestConfidence.medium,
      'Low' => HarvestConfidence.low,
      _ => HarvestConfidence.medium,
    };
  }
}

/// Where one [DailyTracePoint] came from. Matched case-insensitively per
/// README.mobile.md, since this is the one field the API serializes with a
/// capital first letter instead of the usual lowercase/camelCase.
enum TraceSource {
  observed,
  forecast,
  climatology;

  static TraceSource fromJson(String value) {
    return switch (value.toLowerCase()) {
      'observed' => TraceSource.observed,
      'forecast' => TraceSource.forecast,
      'climatology' => TraceSource.climatology,
      _ => TraceSource.observed,
    };
  }
}

@immutable
class GddProgress {
  const GddProgress({
    required this.accumulated,
    required this.required_,
    required this.remaining,
    required this.percentComplete,
    required this.baseTemperatureC,
    required this.upperTemperatureC,
    required this.daysObserved,
    required this.daysForecast,
  });

  final double accumulated;
  final double required_;
  final double remaining;

  /// `0..100` — the number to drive a progress bar with.
  final double percentComplete;
  final double baseTemperatureC;
  final double upperTemperatureC;
  final int daysObserved;
  final int daysForecast;

  factory GddProgress.fromJson(Map<String, dynamic> json) {
    return GddProgress(
      accumulated: (json['accumulated'] as num).toDouble(),
      required_: (json['required'] as num).toDouble(),
      remaining: (json['remaining'] as num).toDouble(),
      percentComplete: (json['percentComplete'] as num).toDouble(),
      baseTemperatureC: (json['baseTemperatureC'] as num).toDouble(),
      upperTemperatureC: (json['upperTemperatureC'] as num).toDouble(),
      daysObserved: json['daysObserved'] as int,
      daysForecast: json['daysForecast'] as int,
    );
  }
}

@immutable
class GrowthStageProgress {
  const GrowthStageProgress({required this.current, this.next, this.nextStageStarts});

  /// One of the crop's `stages[].name`, or `"Pre-planting"` if the planting
  /// date is in the future.
  final String current;

  /// `null` once the crop has reached its final stage — treat that as "no
  /// further stage", not a missing-data bug.
  final String? next;
  final DateTime? nextStageStarts;

  factory GrowthStageProgress.fromJson(Map<String, dynamic> json) {
    return GrowthStageProgress(
      current: json['current'] as String,
      next: json['next'] as String?,
      nextStageStarts:
          json['nextStageStarts'] != null ? DateTime.parse(json['nextStageStarts'] as String) : null,
    );
  }
}

@immutable
class HarvestWindow {
  const HarvestWindow({
    required this.earliest,
    required this.expected,
    required this.latest,
    required this.daysFromNow,
    required this.windowWidthDays,
    required this.confidence,
    required this.basis,
  });

  final DateTime earliest;

  /// The headline date — always show this as the primary answer, with
  /// [earliest]-[latest] as a range underneath.
  final DateTime expected;
  final DateTime latest;
  final int daysFromNow;
  final int windowWidthDays;
  final HarvestConfidence confidence;

  /// A one-line explanation of *why* the app is saying what it's saying —
  /// good for a "why?" info affordance rather than always-visible body text.
  final String basis;

  factory HarvestWindow.fromJson(Map<String, dynamic> json) {
    return HarvestWindow(
      earliest: DateTime.parse(json['earliest'] as String),
      expected: DateTime.parse(json['expected'] as String),
      latest: DateTime.parse(json['latest'] as String),
      daysFromNow: json['daysFromNow'] as int,
      windowWidthDays: json['windowWidthDays'] as int,
      confidence: HarvestConfidence.fromJson(json['confidence'] as String),
      basis: json['basis'] as String,
    );
  }
}

@immutable
class HarvestMethodology {
  const HarvestMethodology({
    required this.model,
    required this.weatherSource,
    required this.analogYears,
    required this.notes,
  });

  final String model;
  final String weatherSource;
  final int analogYears;

  /// Worth surfacing when non-empty and mentioning extrapolation — the
  /// backend being upfront that part of the answer is less certain.
  final String notes;

  factory HarvestMethodology.fromJson(Map<String, dynamic> json) {
    return HarvestMethodology(
      model: json['model'] as String,
      weatherSource: json['weatherSource'] as String,
      analogYears: json['analogYears'] as int,
      notes: json['notes'] as String,
    );
  }
}

@immutable
class DailyTracePoint {
  const DailyTracePoint({
    required this.date,
    required this.maxC,
    required this.minC,
    required this.gdd,
    required this.cumulative,
    required this.source,
  });

  final DateTime date;
  final double maxC;
  final double minC;
  final double gdd;
  final double cumulative;
  final TraceSource source;

  factory DailyTracePoint.fromJson(Map<String, dynamic> json) {
    return DailyTracePoint(
      date: DateTime.parse(json['date'] as String),
      maxC: (json['maxC'] as num).toDouble(),
      minC: (json['minC'] as num).toDouble(),
      gdd: (json['gdd'] as num).toDouble(),
      cumulative: (json['cumulative'] as num).toDouble(),
      source: TraceSource.fromJson(json['source'] as String),
    );
  }
}

/// `HarvestPredictionResponseDto` — see README.mobile.md's "Crops & Harvest
/// Prediction". Returned by `POST /harvest/predict` (fresh) and
/// `GET /harvest/history` (saved, `dailyTrace` always `null` there).
@immutable
class HarvestPrediction {
  const HarvestPrediction({
    required this.id,
    required this.cropId,
    required this.cropName,
    required this.latitude,
    required this.longitude,
    required this.plantingDate,
    required this.asOf,
    required this.alreadyMature,
    required this.gdd,
    required this.stage,
    required this.harvest,
    required this.methodology,
    required this.createdAt,
    this.dailyTrace,
  });

  /// Only meaningful/reusable (e.g. for a "view again" link) when the
  /// predict call was authenticated.
  final String id;
  final String cropId;
  final String cropName;
  final double latitude;
  final double longitude;
  final DateTime plantingDate;

  /// The date the backend computed this as of — pin countdown math to this
  /// rather than the device clock in case they differ.
  final DateTime asOf;
  final bool alreadyMature;
  final GddProgress gdd;
  final GrowthStageProgress stage;
  final HarvestWindow harvest;
  final HarvestMethodology methodology;
  final DateTime createdAt;

  /// Only populated when `includeDailyTrace: true` was sent to `POST
  /// /harvest/predict`; `null` from history.
  final List<DailyTracePoint>? dailyTrace;

  factory HarvestPrediction.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>;
    return HarvestPrediction(
      id: json['id'] as String,
      cropId: json['cropId'] as String,
      cropName: json['cropName'] as String,
      latitude: (location['latitude'] as num).toDouble(),
      longitude: (location['longitude'] as num).toDouble(),
      plantingDate: DateTime.parse(json['plantingDate'] as String),
      asOf: DateTime.parse(json['asOf'] as String),
      alreadyMature: json['alreadyMature'] as bool,
      gdd: GddProgress.fromJson(json['gdd'] as Map<String, dynamic>),
      stage: GrowthStageProgress.fromJson(json['stage'] as Map<String, dynamic>),
      harvest: HarvestWindow.fromJson(json['harvest'] as Map<String, dynamic>),
      methodology: HarvestMethodology.fromJson(json['methodology'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      dailyTrace: (json['dailyTrace'] as List<dynamic>?)
          ?.map((e) => DailyTracePoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
