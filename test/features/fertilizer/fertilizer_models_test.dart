import 'package:agrismart/features/fertilizer/application/fertilizer_providers.dart';
import 'package:agrismart/features/fertilizer/domain/entities/fertilizer_crop.dart';
import 'package:agrismart/features/fertilizer/domain/entities/fertilizer_enums.dart';
import 'package:agrismart/features/fertilizer/domain/entities/fertilizer_product.dart';
import 'package:agrismart/features/fertilizer/domain/entities/fertilizer_recommendation.dart';
import 'package:agrismart/features/fertilizer/domain/entities/fertilizer_request.dart';
import 'package:agrismart/features/fertilizer/domain/entities/fertilizer_result.dart';
import 'package:agrismart/features/fertilizer/presentation/fertilizer_format.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fertilizer_fixtures.dart';

void main() {
  group('parsing README examples', () {
    test('calculate result', () {
      final r = FertilizerResult.fromJson(decode(calculateResponseJson));
      expect(r.crop, 'Maize');
      expect(r.areaHectares, 0.5);
      expect(r.targetYieldCapped, isFalse);
      expect(r.soilAdjustment.mode, SoilMode.simple);
      expect(r.soilAdjustment.nitrogenClass, NutrientClass.medium);
      expect(r.nutrientRequirementKg.p2o5, 25.7);
      expect(r.selectionMode, SelectionMode.farmerSelected);
      expect(r.products, hasLength(2));
      final npk = r.products.first;
      expect(npk.type, ProductType.compound);
      expect(npk.bags50Kg, 3.5);
      expect(npk.hasPrice, isTrue);
      expect(npk.estimatedCost, 3325);
      expect(npk.hasNonStandardBag, isFalse);
      expect(r.schedule[1].daysAfterPlanting, 35);
      expect(r.schedule[0].products.single.perPlantHint, startsWith('about 1.5 level bottle caps'));
      expect(r.plantCount, 26666);
      expect(r.totalEstimatedCost, 4675);
      expect(r.costComplete, isTrue);
      expect(r.warnings, isEmpty);
      expect(r.notes, hasLength(4));
    });

    test('history page', () {
      final page = PagedResult.fromJson(decode(historyPageJson), RecommendationSummary.fromJson);
      expect(page.totalCount, 1);
      expect(page.hasMore, isFalse);
      final item = page.items.single;
      expect(item.cropName, 'Maize');
      expect(item.plotLabel, 'Back field by the stream');
      expect(item.totalEstimatedCost, 4675);
      expect(item.createdAt.toUtc(), DateTime.utc(2026, 9, 29, 10, 30));
    });

    test('saved record with inputs and result', () {
      final saved = FertilizerRecommendation.fromJson(decode(savedRecordJson()));
      expect(saved.plotLabel, 'Back field by the stream');
      expect(saved.inputs.cropId, 'maize');
      expect(saved.inputs.areaUnit, AreaUnit.hectare);
      expect(saved.inputs.soil.fertility, SoilFertility.medium);
      expect(saved.inputs.soil.soilType, SoilType.loamy);
      expect(saved.inputs.customPrices.map((p) => p.pricePerBag), [950, 900]);
      expect(saved.result.products, hasLength(2));
    });

    test('crop and product', () {
      final crop = FertilizerCrop.fromJson(decode(cropJson));
      expect(crop.localName, 'Kon');
      expect(crop.maxRealisticYieldTPerHa, 7);
      expect(crop.schedule.first.phosphatePercent, 100);
      final product = FertilizerProduct.fromJson(decode(productJson));
      expect(product.type, ProductType.compound);
      expect(product.hasPrice, isFalse);
      expect(product.bagSizeKg, 50);
    });

    test('missing keys fall back to empty values instead of throwing', () {
      final r = FertilizerResult.fromJson(const {});
      expect(r.products, isEmpty);
      expect(r.crop, '');
      expect(r.costComplete, isFalse);
    });
  });

  group('enum string mapping', () {
    test('round-trips every value', () {
      for (final v in AreaUnit.values) {
        expect(AreaUnit.fromJson(v.toJson()), v);
      }
      for (final v in SoilMode.values) {
        expect(SoilMode.fromJson(v.toJson()), v);
      }
      for (final v in SoilFertility.values) {
        expect(SoilFertility.fromJson(v.toJson()), v);
      }
      for (final v in SoilType.values) {
        expect(SoilType.fromJson(v.toJson()), v);
      }
      for (final v in ProductType.values) {
        expect(ProductType.fromJson(v.toJson()), v);
      }
      for (final v in SelectionMode.values) {
        expect(SelectionMode.fromJson(v.toJson()), v);
      }
      for (final v in NutrientClass.values) {
        expect(NutrientClass.fromJson(v.toJson()), v);
      }
    });

    test('uses the API camelCase strings', () {
      expect(AreaUnit.squareMeter.toJson(), 'squareMeter');
      expect(AreaUnit.plotDimensions.toJson(), 'plotDimensions');
      expect(SoilMode.soilTest.toJson(), 'soilTest');
      expect(SelectionMode.farmerSelected.toJson(), 'farmerSelected');
    });

    test('unknown or empty values fall back safely', () {
      expect(AreaUnit.fromJson('furlong'), AreaUnit.hectare);
      expect(ProductType.fromJson(null), ProductType.compound);
      expect(SoilFertility.fromJson(''), isNull);
      expect(SoilType.fromJson(null), isNull);
    });
  });

  group('request toJson', () {
    test('simple soil', () {
      const request = FertilizerRequest(
        cropId: 'maize',
        areaUnit: AreaUnit.acre,
        area: 2,
        soil: SoilInput(fertility: SoilFertility.low, soilType: SoilType.sandy),
      );
      expect(request.toJson(), {
        'cropId': 'maize',
        'areaUnit': 'acre',
        'area': 2.0,
        'soil': {'mode': 'simple', 'fertility': 'low', 'soilType': 'sandy'},
      });
    });

    test('soil test sends the lab values and not fertility', () {
      const request = FertilizerRequest(
        cropId: 'tomato',
        areaUnit: AreaUnit.hectare,
        area: 0.25,
        soil: SoilInput(
          mode: SoilMode.soilTest,
          fertility: SoilFertility.high,
          ph: 6.1,
          nitrogenTotalPercent: 0.12,
          phosphorusBray1MgPerKg: 8,
          potassiumCmolPerKg: 0.3,
        ),
        targetYieldTPerHa: 20,
      );
      expect(request.toJson(), {
        'cropId': 'tomato',
        'areaUnit': 'hectare',
        'area': 0.25,
        'soil': {
          'mode': 'soilTest',
          'ph': 6.1,
          'nitrogenTotalPercent': 0.12,
          'phosphorusBray1MgPerKg': 8.0,
          'potassiumCmolPerKg': 0.3,
        },
        'targetYieldTPerHa': 20.0,
      });
    });

    test('plot dimensions send length and width, not area', () {
      const request = FertilizerRequest(
        cropId: 'pepper-chili',
        areaUnit: AreaUnit.plotDimensions,
        area: 99,
        lengthM: 20,
        widthM: 15,
        soil: SoilInput(fertility: SoilFertility.medium),
      );
      final json = request.toJson();
      expect(json['areaUnit'], 'plotDimensions');
      expect(json.containsKey('area'), isFalse);
      expect(json['lengthM'], 20);
      expect(json['widthM'], 15);
    });

    test('products, custom prices and plot label', () {
      const request = FertilizerRequest(
        cropId: 'maize',
        areaUnit: AreaUnit.hectare,
        area: 0.5,
        soil: SoilInput(fertility: SoilFertility.medium),
        fertilizerProductIds: ['npk-15-15-15', 'urea'],
        customPrices: [
          CustomPrice(productId: 'npk-15-15-15', pricePerBag: 950),
          CustomPrice(productId: 'urea', pricePerBag: 900),
        ],
      );
      final json = request.withPlotLabel('  Back field  ').toJson();
      expect(json['fertilizerProductIds'], ['npk-15-15-15', 'urea']);
      expect(json['customPrices'], [
        {'productId': 'npk-15-15-15', 'pricePerBag': 950.0},
        {'productId': 'urea', 'pricePerBag': 900.0},
      ]);
      expect(json['plotLabel'], 'Back field');
    });

    test('"Choose for me" omits product ids; blank plot label is omitted', () {
      const request = FertilizerRequest(
        cropId: 'maize',
        areaUnit: AreaUnit.hectare,
        area: 1,
        soil: SoilInput(fertility: SoilFertility.medium),
        plotLabel: '   ',
      );
      final json = request.toJson();
      expect(json.containsKey('fertilizerProductIds'), isFalse);
      expect(json.containsKey('customPrices'), isFalse);
      expect(json.containsKey('plotLabel'), isFalse);
    });

    test('round-trips through fromJson (saved inputs)', () {
      final request = FertilizerRequest.fromJson(decode(calculateRequestJson));
      expect(request.toJson(), decode(calculateRequestJson));
    });

    test('soil mode is inferred from lab values when omitted', () {
      final soil = SoilInput.fromJson(const {'phosphorusBray1MgPerKg': 12});
      expect(soil.mode, SoilMode.soilTest);
    });
  });

  group('mapFertilizerApiErrors', () {
    const request = FertilizerRequest(
      cropId: 'maize',
      areaUnit: AreaUnit.acre,
      area: 1,
      soil: SoilInput(),
      customPrices: [
        CustomPrice(productId: 'npk-15-15-15', pricePerBag: 950),
        CustomPrice(productId: 'urea', pricePerBag: -1),
      ],
    );

    test('maps request field paths to form fields', () {
      final mapped = mapFertilizerApiErrors({
        'area': ['area must be greater than 0.'],
        'soil.fertility': ['fertility is required.'],
        'customPrices[1].pricePerBag': ['must be 0 or more.'],
        'fertilizerProductIds[0]': ['Unknown product.'],
        r'$.areaUnit': ['bad enum'],
      }, request);
      expect(mapped, {
        FertilizerField.area: 'area must be greater than 0.',
        FertilizerField.fertility: 'fertility is required.',
        FertilizerField.price('urea'): 'must be 0 or more.',
        FertilizerField.products: 'Unknown product.',
      });
    });
  });

  group('formatting', () {
    test('bags render halves as ½', () {
      expect(formatBags(3.5), '3½');
      expect(formatBags(0.5), '½');
      expect(formatBags(4), '4');
    });

    test('money and numbers', () {
      expect(formatMoney(4675), '4,675');
      expect(formatMoney(1234567.5), '1,234,567.50');
      expect(formatNumber(171.4), '171.4');
      expect(formatNumber(56), '56');
      expect(formatBalance(-50), '−50 kg');
      expect(parseNumber('2,5'), 2.5);
      expect(parseNumber(''), isNull);
    });
  });
}
