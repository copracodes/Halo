/// Lenient readers for TMDB's JSON.
///
/// Every field is treated as optional and wrongly-typed values are read as
/// absent rather than thrown. A single unexpected null in one field of one
/// result should cost that field, not the whole enrichment pass — and since
/// nothing here throws, decoding can't put an exception in front of the UI.
library;

String? asString(Object? value) {
  if (value is String && value.isNotEmpty) return value;
  return null;
}

int? asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double? asDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

/// TMDB dates are `yyyy-MM-dd`, and unknown ones come back as `""` (not null).
DateTime? asDate(Object? value) {
  final text = asString(value);
  if (text == null) return null;
  return DateTime.tryParse(text);
}

/// Runtime in minutes; TMDB uses 0 for "unknown", which is not a duration.
Duration? asMinutes(Object? value) {
  final minutes = asInt(value);
  if (minutes == null || minutes <= 0) return null;
  return Duration(minutes: minutes);
}

/// A JSON array of objects, with anything malformed dropped.
List<Map<String, dynamic>> asObjectList(Object? value) {
  if (value is! List) return const [];
  return value.whereType<Map<String, dynamic>>().toList();
}

/// A nested object, or null when the key is missing or the wrong shape.
Map<String, dynamic>? asObject(Object? value) =>
    value is Map<String, dynamic> ? value : null;

/// The `name` field of each object in a list — genres, networks, and so on.
List<String> asNames(Object? value) => asObjectList(value)
    .map((item) => asString(item['name']))
    .whereType<String>()
    .toList();
