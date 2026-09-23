import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import '../utils/place_address_utils.dart';
import 'location_picker_map_screen.dart';

class PublishLocationField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final void Function(Prediction, double, double)? onPredictionSelected;
  final void Function(PlaceAddressDetails)? onAddressDetailsSelected;
  final bool showLabel;
  final bool showShadow;
  final Color? backgroundColor;

  const PublishLocationField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.onChanged,
    this.onPredictionSelected,
    this.onAddressDetailsSelected,
    this.showLabel = true,
    this.showShadow = true,
    this.backgroundColor,
  });

  @override
  State<PublishLocationField> createState() => _PublishLocationFieldState();
}

class _PublishLocationFieldState extends State<PublishLocationField> {
  static const String _googleApiKey = 'AIzaSyCvBoWiQ4Eh2UQusV3fjjfVeqyf6HiAO2s';
  final FocusNode _focusNode = FocusNode();

  double? _lastLat;
  double? _lastLng;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
      _openMapPicker();
    }
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.push<PlaceAddressDetails>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            LocationPickerMapScreen(initialLat: _lastLat, initialLng: _lastLng),
      ),
    );

    if (result != null) {
      _lastLat = result.lat;
      _lastLng = result.lng;
      widget.controller.text = result.shortAddress;
      widget.onChanged(result.shortAddress);
      widget.onAddressDetailsSelected?.call(result);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  String _extractComponent(List<dynamic> components, List<String> types) {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabel) ...[
          Text(
            widget.label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.transparent),
            boxShadow: widget.showShadow
                ? const [BoxShadow(color: Colors.black12, blurRadius: 4)]
                : null,
          ),
          child: GooglePlaceAutoCompleteTextField(
            textEditingController: widget.controller,
            focusNode: _focusNode,
            googleAPIKey: _googleApiKey,
            debounceTime: 400,
            countries: const ['in'],
            isLatLngRequired: false,
            showError: true,
            isCrossBtnShown: false,
            boxDecoration: const BoxDecoration(),
            inputDecoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.transparent,
              suffixIcon: ValueListenableBuilder<TextEditingValue>(
                valueListenable: widget.controller,
                builder: (context, value, child) {
                  if (value.text.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.textSecondary, size: 20),
                    onPressed: () {
                      widget.controller.clear();
                      widget.onChanged('');
                    },
                  );
                },
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
            textStyle: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
            itemClick: (Prediction prediction) async {
              widget.controller.text = prediction.description ?? '';
              widget.onChanged(widget.controller.text);

              double parsedLat = 0.0;
              double parsedLng = 0.0;
              String formattedAddress = prediction.description ?? '';
              String shortAddress = prediction.description ?? '';
              String city = '';
              String state = '';
              String pincode = '';
              List<dynamic> components = [];

              if (prediction.placeId != null) {
                try {
                  final url = Uri.parse(
                    'https://maps.googleapis.com/maps/api/place/details/json'
                    '?place_id=${prediction.placeId!}'
                    '&fields=geometry,address_components,formatted_address'
                    '&key=$_googleApiKey',
                  );
                  final response = await http.get(url);
                  if (response.statusCode == 200) {
                    final data = json.decode(response.body);
                    if (data['status'] == 'OK' && data['result'] != null) {
                      final details = data['result'];
                      if (details['geometry'] != null) {
                        final loc = details['geometry']['location'];
                        if (loc != null) {
                          parsedLat =
                              double.tryParse(loc['lat'].toString()) ?? 0.0;
                          parsedLng =
                              double.tryParse(loc['lng'].toString()) ?? 0.0;
                        }
                      }
                      if (details['formatted_address'] != null) {
                        formattedAddress = details['formatted_address']
                            .toString();
                      }
                      components = details['address_components'] ?? [];
                      city = _extractComponent(components, [
                        'locality',
                        'administrative_area_level_2',
                        'sublocality',
                        'sublocality_level_1',
                      ]);
                      state = _extractComponent(components, [
                        'administrative_area_level_1',
                      ]);
                      pincode = _extractComponent(components, ['postal_code']);
                      shortAddress = buildShortAddress(components);
                      if (shortAddress.isEmpty) shortAddress = formattedAddress;
                    } else {
                      debugPrint(
                        'Place Details API: ${data['status']} - ${data['error_message']}',
                      );
                    }
                  } else {
                    debugPrint(
                      'HTTP error fetching details: ${response.statusCode}',
                    );
                  }
                } catch (e) {
                  debugPrint('Error fetching place details: $e');
                }
              }

              widget.controller.text = shortAddress;
              widget.onChanged(shortAddress);

              widget.onPredictionSelected?.call(
                prediction,
                parsedLat,
                parsedLng,
              );
              widget.onAddressDetailsSelected?.call(
                PlaceAddressDetails(
                  formattedAddress: formattedAddress,
                  shortAddress: shortAddress,
                  city: city,
                  state: state,
                  pincode: pincode,
                  lat: parsedLat,
                  lng: parsedLng,
                  googleMapsUrl: PlaceAddressDetails.buildMapsUrl(
                    parsedLat,
                    parsedLng,
                  ),
                  cityCandidates: extractCityCandidates(components),
                ),
              );
            },
            seperatedBuilder: const Divider(
              color: AppColors.borderLight,
              height: 1,
              thickness: 1,
            ),
            itemBuilder: (context, index, Prediction prediction) {
              final String mainText =
                  prediction.structuredFormatting?.mainText ??
                  prediction.description ??
                  '';
              final String secondaryText =
                  prediction.structuredFormatting?.secondaryText ?? '';
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mainText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (secondaryText.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              secondaryText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
