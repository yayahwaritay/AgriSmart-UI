/// Lenient readers for the fertilizer API's JSON. The API promises no
/// nested nulls (unknowns are `""`, `0`, `[]`), but these also tolerate a
/// missing key so one odd field can't crash a whole result screen.
library;

double readDouble(Map<String, dynamic> json, String key) => (json[key] as num?)?.toDouble() ?? 0;

int readInt(Map<String, dynamic> json, String key) => (json[key] as num?)?.toInt() ?? 0;

String readString(Map<String, dynamic> json, String key) => json[key] as String? ?? '';

bool readBool(Map<String, dynamic> json, String key) => json[key] as bool? ?? false;

List<T> readList<T>(Map<String, dynamic> json, String key, T Function(Map<String, dynamic>) fromJson) {
  final raw = json[key] as List<dynamic>? ?? const [];
  return raw.map((e) => fromJson(e as Map<String, dynamic>)).toList();
}

List<String> readStrings(Map<String, dynamic> json, String key) {
  final raw = json[key] as List<dynamic>? ?? const [];
  return raw.whereType<String>().toList();
}

Map<String, dynamic> readMap(Map<String, dynamic> json, String key) => json[key] as Map<String, dynamic>? ?? const {};
