import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── PlaceAddressDetails ─────────────────────────────────────────────────────

class PlaceAddressDetails {
  final String formattedAddress;
  final String shortAddress;
  final String city;
  final String state;
  final String pincode;
  final double lat;
  final double lng;
  final String googleMapsUrl;
  final List<String> cityCandidates;

  const PlaceAddressDetails({
    required this.formattedAddress,
    required this.shortAddress,
    required this.city,
    required this.state,
    required this.pincode,
    required this.lat,
    required this.lng,
    required this.googleMapsUrl,
    this.cityCandidates = const [],
  });

  static String buildMapsUrl(double lat, double lng) =>
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
}

// ─── Address helpers ──────────────────────────────────────────────────────────

/// Extracts a concise human-readable address from Google address_components.
String buildShortAddress(List<dynamic> components) {
  String premise = _component(components, ['premise']);
  String streetNumber = _component(components, ['street_number']);
  String route = _component(components, ['route']);
  String sublocality = _component(
    components,
    ['sublocality_level_1', 'sublocality', 'neighborhood'],
  );
  String locality = _component(components, ['locality']);
  String admin2 = _component(components, ['administrative_area_level_2']);

  final parts = <String>[
    if (premise.isNotEmpty) premise,
    if (streetNumber.isNotEmpty && route.isNotEmpty) '\$streetNumber \$route'
    else if (route.isNotEmpty) route,
    if (sublocality.isNotEmpty) sublocality,
    if (locality.isNotEmpty) locality else if (admin2.isNotEmpty) admin2,
  ];

  return parts.join(', ');
}

/// Returns every plausible city name from address components.
List<String> extractCityCandidates(List<dynamic> components) {
  const cityTypes = [
    'locality',
    'administrative_area_level_2',
    'sublocality',
    'sublocality_level_1',
  ];
  final seen = <String>{};
  final result = <String>[];
  for (final type in cityTypes) {
    final val = _component(components, [type]);
    if (val.isNotEmpty && seen.add(val)) result.add(val);
  }
  return result;
}

String _component(List<dynamic> components, List<String> types) {
  for (final type in types) {
    for (final comp in components) {
      final List<dynamic> compTypes = comp['types'] ?? [];
      if (compTypes.contains(type)) {
        return comp['long_name']?.toString() ?? '';
      }
    }
  }
  return '';
}

// ─── UI helpers ──────────────────────────────────────────────────────────────

/// Builds a label text with a red asterisk suffix.
Widget buildAsteriskText(String text, {TextStyle? style}) {
  return RichText(
    text: TextSpan(
      text: text,
      style: style ??
          GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
      children: const [
        TextSpan(
          text: ' *',
          style: TextStyle(color: Colors.red),
        ),
      ],
    ),
  );
}
