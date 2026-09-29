import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../data/repositories/http_fertilizer_repository.dart';
import '../domain/entities/fertilizer_crop.dart';
import '../domain/entities/fertilizer_enums.dart';
import '../domain/entities/fertilizer_product.dart';
import '../domain/entities/fertilizer_recommendation.dart';
import '../domain/entities/fertilizer_request.dart';
import '../domain/entities/fertilizer_result.dart';
import '../domain/repositories/fertilizer_repository.dart';

final fertilizerRepositoryProvider = Provider<FertilizerRepository>((ref) {
  return HttpFertilizerRepository(ref.watch(apiClientProvider));
});

/// The calculator's crop picker — cached for the app session (the list
/// rarely changes). Don't hardcode it, see README.fertilizer.mobile.md.
final fertilizerCropsProvider = FutureProvider<List<FertilizerCrop>>((ref) {
  return ref.watch(fertilizerRepositoryProvider).fetchCrops();
});

/// Fertilizers the farmer can tick — cached like [fertilizerCropsProvider].
final fertilizerProductsProvider = FutureProvider<List<FertilizerProduct>>((ref) {
  return ref.watch(fertilizerRepositoryProvider).fetchProducts();
});

/// Keys for [FertilizerFormState.fieldErrors] — the API's own `errors`
/// field paths, so server and client validation land in the same place.
/// Custom price errors are keyed per product via [price].
abstract final class FertilizerField {
  static const crop = 'cropId';
  static const area = 'area';
  static const lengthM = 'lengthM';
  static const widthM = 'widthM';
  static const soil = 'soil';
  static const fertility = 'soil.fertility';
  static const ph = 'soil.ph';
  static const nitrogen = 'soil.nitrogenTotalPercent';
  static const phosphorus = 'soil.phosphorusBray1MgPerKg';
  static const potassium = 'soil.potassiumCmolPerKg';
  static const targetYield = 'targetYieldTPerHa';
  static const products = 'fertilizerProductIds';
  static const plotLabel = 'plotLabel';

  static String price(String productId) => 'price:$productId';

  static const _known = {
    crop, area, lengthM, widthM, soil, fertility, ph, nitrogen, phosphorus, potassium, targetYield, plotLabel,
  };
}

/// Maps an [ApiException.errors] map to [FertilizerField] keys, keeping the
/// first message per field. `customPrices[i]...` resolves to the product at
/// index `i` of [request]'s prices; `fertilizerProductIds[i]` to
/// [FertilizerField.products]. ASP.NET's `$.field` keys (unknown enum or bad
/// JSON) are dropped — the caller shows the exception's message instead.
Map<String, String> mapFertilizerApiErrors(Map<String, List<String>> errors, FertilizerRequest? request) {
  final mapped = <String, String>{};
  final pricePattern = RegExp(r'^customprices\[(\d+)\]');
  for (final entry in errors.entries) {
    if (entry.value.isEmpty) continue;
    final key = entry.key.toLowerCase();
    if (key.startsWith(r'$')) continue;

    String? field;
    final priceMatch = pricePattern.firstMatch(key);
    if (priceMatch != null) {
      final index = int.parse(priceMatch.group(1)!);
      final prices = request?.customPrices ?? const <CustomPrice>[];
      if (index < prices.length) field = FertilizerField.price(prices[index].productId);
    } else if (key.startsWith('fertilizerproductids')) {
      field = FertilizerField.products;
    } else {
      for (final known in FertilizerField._known) {
        if (known.toLowerCase() == key) field = known;
      }
    }
    if (field != null) mapped.putIfAbsent(field, () => entry.value.first);
  }
  return mapped;
}

enum CalculationStatus { idle, calculating, success, error }

const _unset = Object();

@immutable
class FertilizerFormState {
  const FertilizerFormState({
    this.crop,
    this.areaUnit = AreaUnit.acre,
    this.area,
    this.lengthM,
    this.widthM,
    this.soilMode = SoilMode.simple,
    this.fertility,
    this.soilType,
    this.ph,
    this.nitrogenTotalPercent,
    this.phosphorusBray1MgPerKg,
    this.potassiumCmolPerKg,
    this.targetYieldTPerHa,
    this.selectedProductIds = const [],
    this.prices = const {},
    this.status = CalculationStatus.idle,
    this.result,
    this.lastRequest,
    this.fieldErrors = const {},
    this.errorMessage,
    this.formVersion = 0,
  });

  final FertilizerCrop? crop;
  final AreaUnit areaUnit;
  final double? area;
  final double? lengthM;
  final double? widthM;
  final SoilMode soilMode;
  final SoilFertility? fertility;
  final SoilType? soilType;
  final double? ph;
  final double? nitrogenTotalPercent;
  final double? phosphorusBray1MgPerKg;
  final double? potassiumCmolPerKg;

  /// `null` = the crop's reference yield (the API's default).
  final double? targetYieldTPerHa;

  /// Empty = "Choose for me".
  final List<String> selectedProductIds;

  /// SLE per bag, by product id — sent as `customPrices`.
  final Map<String, double> prices;

  final CalculationStatus status;
  final FertilizerResult? result;

  /// The request that produced [result] — what "Save" sends.
  final FertilizerRequest? lastRequest;

  /// Inline errors by [FertilizerField] key.
  final Map<String, String> fieldErrors;
  final String? errorMessage;

  /// Bumped when the whole form is replaced (prefill from history), so text
  /// fields rebuild with the new initial values.
  final int formVersion;

  bool get chooseForMe => selectedProductIds.isEmpty;

  FertilizerFormState copyWith({
    Object? crop = _unset,
    AreaUnit? areaUnit,
    Object? area = _unset,
    Object? lengthM = _unset,
    Object? widthM = _unset,
    SoilMode? soilMode,
    Object? fertility = _unset,
    Object? soilType = _unset,
    Object? ph = _unset,
    Object? nitrogenTotalPercent = _unset,
    Object? phosphorusBray1MgPerKg = _unset,
    Object? potassiumCmolPerKg = _unset,
    Object? targetYieldTPerHa = _unset,
    List<String>? selectedProductIds,
    Map<String, double>? prices,
    CalculationStatus? status,
    Object? result = _unset,
    Object? lastRequest = _unset,
    Map<String, String>? fieldErrors,
    String? errorMessage,
    int? formVersion,
  }) {
    return FertilizerFormState(
      crop: crop == _unset ? this.crop : crop as FertilizerCrop?,
      areaUnit: areaUnit ?? this.areaUnit,
      area: area == _unset ? this.area : area as double?,
      lengthM: lengthM == _unset ? this.lengthM : lengthM as double?,
      widthM: widthM == _unset ? this.widthM : widthM as double?,
      soilMode: soilMode ?? this.soilMode,
      fertility: fertility == _unset ? this.fertility : fertility as SoilFertility?,
      soilType: soilType == _unset ? this.soilType : soilType as SoilType?,
      ph: ph == _unset ? this.ph : ph as double?,
      nitrogenTotalPercent:
          nitrogenTotalPercent == _unset ? this.nitrogenTotalPercent : nitrogenTotalPercent as double?,
      phosphorusBray1MgPerKg:
          phosphorusBray1MgPerKg == _unset ? this.phosphorusBray1MgPerKg : phosphorusBray1MgPerKg as double?,
      potassiumCmolPerKg: potassiumCmolPerKg == _unset ? this.potassiumCmolPerKg : potassiumCmolPerKg as double?,
      targetYieldTPerHa: targetYieldTPerHa == _unset ? this.targetYieldTPerHa : targetYieldTPerHa as double?,
      selectedProductIds: selectedProductIds ?? this.selectedProductIds,
      prices: prices ?? this.prices,
      status: status ?? this.status,
      result: result == _unset ? this.result : result as FertilizerResult?,
      lastRequest: lastRequest == _unset ? this.lastRequest : lastRequest as FertilizerRequest?,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      errorMessage: errorMessage,
      formVersion: formVersion ?? this.formVersion,
    );
  }

  /// The request body for the current inputs. Assumes [crop] is set.
  FertilizerRequest toRequest() {
    return FertilizerRequest(
      cropId: crop!.id,
      areaUnit: areaUnit,
      area: area,
      lengthM: lengthM,
      widthM: widthM,
      soil: SoilInput(
        mode: soilMode,
        fertility: fertility,
        soilType: soilType,
        ph: ph,
        nitrogenTotalPercent: nitrogenTotalPercent,
        phosphorusBray1MgPerKg: phosphorusBray1MgPerKg,
        potassiumCmolPerKg: potassiumCmolPerKg,
      ),
      targetYieldTPerHa: targetYieldTPerHa,
      fertilizerProductIds: selectedProductIds,
      customPrices: [
        for (final entry in prices.entries) CustomPrice(productId: entry.key, pricePerBag: entry.value),
      ],
    );
  }
}

/// Drives the `/fertilizer` calculator: form inputs plus the in-flight
/// `POST /fertilizer/calculate` call. Calculation is public, so it never
/// needs a token; saving goes through [save].
class FertilizerCalculatorController extends Notifier<FertilizerFormState> {
  @override
  FertilizerFormState build() => const FertilizerFormState();

  /// Updates the form and clears [field]'s inline error, if any.
  void _edit(FertilizerFormState next, [List<String> fields = const []]) {
    if (fields.any(next.fieldErrors.containsKey)) {
      next = next.copyWith(fieldErrors: {...next.fieldErrors}..removeWhere((k, _) => fields.contains(k)));
    }
    state = next;
  }

  void selectCrop(FertilizerCrop crop) {
    if (state.crop?.id == crop.id) return;
    // A target yield only makes sense for the crop it was set for.
    _edit(state.copyWith(crop: crop, targetYieldTPerHa: null), [FertilizerField.crop, FertilizerField.targetYield]);
  }

  void setAreaUnit(AreaUnit unit) => _edit(
        state.copyWith(areaUnit: unit),
        [FertilizerField.area, FertilizerField.lengthM, FertilizerField.widthM],
      );

  void setArea(double? value) => _edit(state.copyWith(area: value), [FertilizerField.area]);

  void setLength(double? value) => _edit(state.copyWith(lengthM: value), [FertilizerField.lengthM]);

  void setWidth(double? value) => _edit(state.copyWith(widthM: value), [FertilizerField.widthM]);

  void setSoilMode(SoilMode mode) => _edit(state.copyWith(soilMode: mode), [FertilizerField.soil]);

  void setFertility(SoilFertility value) =>
      _edit(state.copyWith(fertility: value), [FertilizerField.fertility, FertilizerField.soil]);

  /// Tapping the selected soil type again clears it (it's optional).
  void toggleSoilType(SoilType value) => _edit(state.copyWith(soilType: state.soilType == value ? null : value));

  void setPh(double? value) => _edit(state.copyWith(ph: value), [FertilizerField.ph]);

  void setNitrogen(double? value) =>
      _edit(state.copyWith(nitrogenTotalPercent: value), [FertilizerField.nitrogen, FertilizerField.soil]);

  void setPhosphorus(double? value) =>
      _edit(state.copyWith(phosphorusBray1MgPerKg: value), [FertilizerField.phosphorus, FertilizerField.soil]);

  void setPotassium(double? value) =>
      _edit(state.copyWith(potassiumCmolPerKg: value), [FertilizerField.potassium, FertilizerField.soil]);

  void setTargetYield(double? value) =>
      _edit(state.copyWith(targetYieldTPerHa: value), [FertilizerField.targetYield]);

  void chooseForMe() => _edit(state.copyWith(selectedProductIds: const []), [FertilizerField.products]);

  /// Ticks/unticks [product]. Ticking prefills its price from the catalog
  /// when it has one and the farmer hasn't typed their own.
  void toggleProduct(FertilizerProduct product) {
    final selected = [...state.selectedProductIds];
    final prices = {...state.prices};
    if (selected.remove(product.id)) {
      prices.remove(product.id);
    } else {
      selected.add(product.id);
      if (product.hasPrice) prices.putIfAbsent(product.id, () => product.pricePerBag);
    }
    _edit(
      state.copyWith(selectedProductIds: selected, prices: prices),
      [FertilizerField.products, FertilizerField.price(product.id)],
    );
  }

  /// `null` removes the price (the product then shows "Add price").
  void setPrice(String productId, double? pricePerBag) {
    final prices = {...state.prices};
    if (pricePerBag == null) {
      prices.remove(productId);
    } else {
      prices[productId] = pricePerBag;
    }
    _edit(state.copyWith(prices: prices), [FertilizerField.price(productId)]);
  }

  /// Mirrors the server's basic checks (README.fertilizer.mobile.md
  /// "Errors"), keyed like the API's `errors`.
  Map<String, String> _validate() {
    final s = state;
    final errors = <String, String>{};
    if (s.crop == null) errors[FertilizerField.crop] = 'Choose a crop.';

    if (s.areaUnit == AreaUnit.plotDimensions) {
      if ((s.lengthM ?? 0) <= 0) errors[FertilizerField.lengthM] = 'Enter the plot length in metres.';
      if ((s.widthM ?? 0) <= 0) errors[FertilizerField.widthM] = 'Enter the plot width in metres.';
    } else if ((s.area ?? 0) <= 0) {
      errors[FertilizerField.area] = 'Enter a farm size bigger than 0.';
    }

    if (s.soilMode == SoilMode.simple) {
      if (s.fertility == null) errors[FertilizerField.fertility] = 'Choose how good your soil is.';
    } else {
      const missing = 'Enter a value of 0 or more.';
      if ((s.nitrogenTotalPercent ?? -1) < 0) errors[FertilizerField.nitrogen] = missing;
      if ((s.phosphorusBray1MgPerKg ?? -1) < 0) errors[FertilizerField.phosphorus] = missing;
      if ((s.potassiumCmolPerKg ?? -1) < 0) errors[FertilizerField.potassium] = missing;
    }

    final ph = s.ph;
    if (ph != null && (ph < 3 || ph > 10)) errors[FertilizerField.ph] = 'pH must be between 3 and 10.';

    final yield_ = s.targetYieldTPerHa;
    if (yield_ != null && yield_ <= 0) errors[FertilizerField.targetYield] = 'Target yield must be more than 0.';

    for (final entry in s.prices.entries) {
      if (entry.value < 0) errors[FertilizerField.price(entry.key)] = 'Price can\'t be negative.';
    }
    return errors;
  }

  /// Runs `POST /fertilizer/calculate`. Returns true on success; on failure
  /// [FertilizerFormState.fieldErrors] and/or `errorMessage` explain why.
  Future<bool> calculate() async {
    final errors = _validate();
    if (errors.isNotEmpty) {
      state = state.copyWith(
        status: CalculationStatus.error,
        fieldErrors: errors,
        errorMessage: errors.length == 1 ? errors.values.first : 'Please fix the fields marked below.',
      );
      return false;
    }

    final request = state.toRequest();
    state = state.copyWith(status: CalculationStatus.calculating, fieldErrors: const {});
    try {
      final result = await ref.read(fertilizerRepositoryProvider).calculate(request);
      state = state.copyWith(status: CalculationStatus.success, result: result, lastRequest: request);
      return true;
    } on ApiException catch (e) {
      final fieldErrors = mapFertilizerApiErrors(e.errors, request);
      state = state.copyWith(status: CalculationStatus.error, fieldErrors: fieldErrors, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(status: CalculationStatus.error, errorMessage: '$e');
      return false;
    }
  }

  /// `POST /fertilizer/recommendations` with the request behind the current
  /// result. Throws [ApiException] on failure (a `plotLabel` error comes back
  /// in its `errors`).
  Future<FertilizerRecommendation> save({String? plotLabel}) async {
    final request = state.lastRequest;
    if (request == null) throw StateError('Calculate before saving.');
    final saved = await ref.read(fertilizerRepositoryProvider).save(request.withPlotLabel(plotLabel));
    ref.invalidate(fertilizerHistoryProvider);
    return saved;
  }

  /// Replaces the form with a saved record's [inputs] ("Recalculate").
  Future<void> prefillFrom(FertilizerRequest inputs) async {
    final crops = await ref.read(fertilizerCropsProvider.future);
    FertilizerCrop? crop;
    for (final c in crops) {
      if (c.id == inputs.cropId) crop = c;
    }
    final soil = inputs.soil;
    state = FertilizerFormState(
      crop: crop,
      areaUnit: inputs.areaUnit,
      area: inputs.area,
      lengthM: inputs.lengthM,
      widthM: inputs.widthM,
      soilMode: soil.mode,
      fertility: soil.fertility,
      soilType: soil.soilType,
      ph: soil.ph,
      nitrogenTotalPercent: soil.nitrogenTotalPercent,
      phosphorusBray1MgPerKg: soil.phosphorusBray1MgPerKg,
      potassiumCmolPerKg: soil.potassiumCmolPerKg,
      targetYieldTPerHa: inputs.targetYieldTPerHa,
      selectedProductIds: inputs.fertilizerProductIds,
      prices: {for (final p in inputs.customPrices) p.productId: p.pricePerBag},
      formVersion: state.formVersion + 1,
    );
  }
}

final fertilizerCalculatorControllerProvider =
    NotifierProvider<FertilizerCalculatorController, FertilizerFormState>(FertilizerCalculatorController.new);

/// History list filters — `cropId` and exact `plotLabel`.
@immutable
class FertilizerHistoryFilter {
  const FertilizerHistoryFilter({this.cropId, this.plotLabel});

  final String? cropId;
  final String? plotLabel;

  bool get isActive => cropId != null || plotLabel != null;
}

class FertilizerHistoryFilterController extends Notifier<FertilizerHistoryFilter> {
  @override
  FertilizerHistoryFilter build() => const FertilizerHistoryFilter();

  void setCrop(String? cropId) => state = FertilizerHistoryFilter(cropId: cropId, plotLabel: state.plotLabel);

  void setPlotLabel(String? plotLabel) {
    final trimmed = plotLabel?.trim();
    state = FertilizerHistoryFilter(
      cropId: state.cropId,
      plotLabel: trimmed == null || trimmed.isEmpty ? null : trimmed,
    );
  }

  void clear() => state = const FertilizerHistoryFilter();
}

final fertilizerHistoryFilterProvider =
    NotifierProvider<FertilizerHistoryFilterController, FertilizerHistoryFilter>(FertilizerHistoryFilterController.new);

@immutable
class FertilizerHistoryState {
  const FertilizerHistoryState({
    required this.items,
    required this.page,
    required this.totalCount,
    required this.hasMore,
    this.loadingMore = false,
    this.loadMoreFailed = false,
  });

  final List<RecommendationSummary> items;
  final int page;
  final int totalCount;
  final bool hasMore;
  final bool loadingMore;
  final bool loadMoreFailed;

  FertilizerHistoryState copyWith({
    List<RecommendationSummary>? items,
    int? page,
    int? totalCount,
    bool? hasMore,
    bool? loadingMore,
    bool? loadMoreFailed,
  }) {
    return FertilizerHistoryState(
      items: items ?? this.items,
      page: page ?? this.page,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
      loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
    );
  }
}

/// The caller's saved recommendations — `GET /fertilizer/recommendations`,
/// one page at a time, re-fetched from page 1 whenever the filter changes.
class FertilizerHistoryList extends AsyncNotifier<FertilizerHistoryState> {
  static const pageSize = 20;

  @override
  Future<FertilizerHistoryState> build() async {
    final filter = ref.watch(fertilizerHistoryFilterProvider);
    final page = await ref.watch(fertilizerRepositoryProvider).fetchHistory(
          pageSize: pageSize,
          cropId: filter.cropId,
          plotLabel: filter.plotLabel,
        );
    return FertilizerHistoryState(
      items: page.items,
      page: page.page,
      totalCount: page.totalCount,
      hasMore: page.hasMore,
    );
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.loadingMore) return;

    state = AsyncData(current.copyWith(loadingMore: true, loadMoreFailed: false));
    final filter = ref.read(fertilizerHistoryFilterProvider);
    try {
      final next = await ref.read(fertilizerRepositoryProvider).fetchHistory(
            page: current.page + 1,
            pageSize: pageSize,
            cropId: filter.cropId,
            plotLabel: filter.plotLabel,
          );
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...next.items],
          page: next.page,
          totalCount: next.totalCount,
          hasMore: next.hasMore,
          loadingMore: false,
        ),
      );
    } catch (_) {
      state = AsyncData(current.copyWith(loadingMore: false, loadMoreFailed: true));
    }
  }

  /// Deletes on the server, then drops the row locally (no full reload).
  Future<void> delete(String id) async {
    await ref.read(fertilizerRepositoryProvider).deleteRecommendation(id);
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        items: current.items.where((e) => e.id != id).toList(),
        totalCount: current.totalCount - 1,
      ),
    );
  }
}

final fertilizerHistoryProvider = AsyncNotifierProvider<FertilizerHistoryList, FertilizerHistoryState>(
  FertilizerHistoryList.new,
);

/// One saved recommendation with its full `inputs` and `result`.
final fertilizerRecommendationProvider =
    FutureProvider.autoDispose.family<FertilizerRecommendation, String>((ref, id) {
  return ref.watch(fertilizerRepositoryProvider).fetchRecommendation(id);
});
