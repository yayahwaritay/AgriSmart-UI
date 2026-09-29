import 'dart:convert';

/// Example JSON from README.fertilizer.mobile.md, verbatim where the README
/// gives it (the saved record's `inputs` placeholder is the calculate
/// request from the same README).
const calculateRequestJson = '''
{
  "cropId": "maize",
  "area": 0.5,
  "areaUnit": "hectare",
  "soil": { "mode": "simple", "fertility": "medium", "soilType": "loamy", "ph": 5.2 },
  "targetYieldTPerHa": 4.0,
  "fertilizerProductIds": ["npk-15-15-15", "urea"],
  "customPrices": [
    { "productId": "npk-15-15-15", "pricePerBag": 950 },
    { "productId": "urea", "pricePerBag": 900 }
  ]
}
''';

const calculateResponseJson = '''
{
  "cropId": "maize",
  "crop": "Maize",
  "areaHectares": 0.5,
  "targetYieldTPerHa": 4,
  "targetYieldCapped": false,
  "yieldBasis": "dry grain",
  "soilAdjustment": {
    "mode": "simple", "nitrogenClass": "medium", "phosphorusClass": "medium", "potassiumClass": "medium",
    "nitrogenFactor": 1, "phosphateFactor": 1, "potashFactor": 1
  },
  "nutrientRequirementPerHaKg": { "n": 102.9, "p2o5": 51.4, "k2o": 51.4 },
  "nutrientRequirementKg": { "n": 51.4, "p2o5": 25.7, "k2o": 25.7 },
  "selectionMode": "farmerSelected",
  "products": [
    {
      "productId": "npk-15-15-15", "name": "NPK 15-15-15", "type": "compound",
      "quantityKg": 171.4, "bagSizeKg": 50, "bags": 3.5, "bags50Kg": 3.5,
      "pricePerBag": 950, "hasPrice": true, "estimatedCost": 3325.0,
      "nutrientsSupplied": { "n": 25.7, "p2o5": 25.7, "k2o": 25.7 }
    },
    {
      "productId": "urea", "name": "Urea (46-0-0)", "type": "straight",
      "quantityKg": 55.9, "bagSizeKg": 50, "bags": 1.5, "bags50Kg": 1.5,
      "pricePerBag": 900, "hasPrice": true, "estimatedCost": 1350.0,
      "nutrientsSupplied": { "n": 25.7, "p2o5": 0, "k2o": 0 }
    }
  ],
  "nutrientsSupplied": { "n": 51.4, "p2o5": 25.7, "k2o": 25.7 },
  "nutrientBalanceKg": { "n": 0, "p2o5": 0, "k2o": 0 },
  "schedule": [
    {
      "stage": "Basal (at planting)", "daysAfterPlanting": 0,
      "timing": "At planting or within 1 week, in a band beside the row",
      "nutrients": { "n": 25.7, "p2o5": 25.7, "k2o": 25.7 },
      "products": [
        { "productId": "npk-15-15-15", "name": "NPK 15-15-15", "quantityKg": 171.4, "gramsPerPlant": 6.4,
          "perPlantHint": "about 1.5 level bottle caps per plant (1 cap ≈ 5 g)" }
      ]
    },
    {
      "stage": "Top-dressing", "daysAfterPlanting": 35,
      "timing": "4-6 weeks after planting, before tasselling",
      "nutrients": { "n": 25.7, "p2o5": 0, "k2o": 0 },
      "products": [
        { "productId": "urea", "name": "Urea (46-0-0)", "quantityKg": 55.9, "gramsPerPlant": 2.1,
          "perPlantHint": "about 0.5 level bottle cap per plant (1 cap ≈ 5 g)" }
      ]
    }
  ],
  "plantCount": 26666,
  "totalEstimatedCost": 4675.0,
  "costComplete": true,
  "currency": "SLE",
  "warnings": [],
  "notes": [
    "Soil pH 5.2 is acidic (below 5.5). Apply agricultural lime or dolomite — typically 1–2 t/ha, ...",
    "Cover Urea / Ammonium Sulphate with soil after applying, ...",
    "Place fertilizer 5–10 cm away from seeds and stems ...",
    "These rates are general guidelines based on regional averages and must be validated locally. ..."
  ]
}
''';

const historyPageJson = '''
{
  "items": [
    { "id": "3f2b8c1e-4d5a-4b7e-9c61-2a8e7d4f1b90", "cropId": "maize", "cropName": "Maize",
      "plotLabel": "Back field by the stream", "areaHectares": 0.5,
      "totalEstimatedCost": 4675.0, "currency": "SLE", "createdAt": "2026-09-29T10:30:00+00:00" }
  ],
  "page": 1, "pageSize": 20, "totalCount": 1, "totalPages": 1
}
''';

String savedRecordJson() => '''
{
  "id": "3f2b8c1e-4d5a-4b7e-9c61-2a8e7d4f1b90", "userId": "9a1c6e52-0000-0000-0000-000000000000",
  "cropId": "maize", "cropName": "Maize",
  "plotLabel": "Back field by the stream", "areaHectares": 0.5, "createdAt": "2026-09-29T10:30:00+00:00",
  "inputs": $calculateRequestJson,
  "result": $calculateResponseJson
}
''';

const cropJson = '''
{
  "id": "maize",
  "name": "Maize",
  "localName": "Kon",
  "nutrientRequirementKgPerHa": { "n": 90, "p2o5": 45, "k2o": 45 },
  "referenceYieldTPerHa": 3.5,
  "maxRealisticYieldTPerHa": 7,
  "yieldBasis": "dry grain",
  "plantsPerHectare": 53333,
  "isPerennial": false,
  "notes": "",
  "schedule": [
    { "stage": "Basal (at planting)", "daysAfterPlanting": 0, "timing": "At planting or within 1 week, in a band beside the row", "nitrogenPercent": 40, "phosphatePercent": 100, "potashPercent": 100 },
    { "stage": "Top-dressing", "daysAfterPlanting": 35, "timing": "4-6 weeks after planting, before tasselling", "nitrogenPercent": 60, "phosphatePercent": 0, "potashPercent": 0 }
  ]
}
''';

const productJson = '''
{
  "id": "npk-15-15-15", "name": "NPK 15-15-15", "type": "compound",
  "nitrogenPercent": 15, "phosphatePercent": 15, "potashPercent": 15,
  "sulphurPercent": 0, "zincPercent": 0, "bagSizeKg": 50,
  "pricePerBag": 0, "hasPrice": false, "currency": "SLE",
  "notes": "Balanced compound — the most widely available fertilizer in Sierra Leone."
}
''';

Map<String, dynamic> decode(String json) => jsonDecode(json) as Map<String, dynamic>;
