import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../network/api_endpoints.dart';
import '../theme/app_colors.dart';
import '../utils/place_address_utils.dart';

class LocationPickerMapScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  final String? title;
  final bool? isPickup;
  final String? initialAddress;

  const LocationPickerMapScreen({
    super.key,
    this.initialLat,
    this.initialLng,
    this.title,
    this.isPickup,
    this.initialAddress,
  });

  @override
  State<LocationPickerMapScreen> createState() =>
      _LocationPickerMapScreenState();
}

class _PlaceSuggestion {
  final String placeId;
  final String mainText;
  final String secondaryText;
  final String description;

  const _PlaceSuggestion({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
    required this.description,
  });
}

class _LocationPickerMapScreenState extends State<LocationPickerMapScreen> {
  static const String _googleApiKey = ApiEndpoints.googleApiKey;
  static final Map<String, PlaceAddressDetails> _geocodeCache = {};

  GoogleMapController? _mapController;
  LatLng _pickedLocation = const LatLng(17.3850, 78.4867); // Hyderabad default
  bool _loading = false;
  bool _resolving = false;
  bool _isProgrammaticMove = false;
  bool _userHasMovedMap = false;
  bool _hasLocationPermission = false;
  PlaceAddressDetails? _resolvedDetails;
  Timer? _geocodeDebounce;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<_PlaceSuggestion> _suggestions = [];
  bool _isSearching = false;
  Timer? _searchDebounce;
  bool _isSelectingPlace = false;
  int _searchSessionId = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchQueryChanged);
    _initLocation();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _geocodeDebounce?.cancel();
    _searchController.removeListener(_onSearchQueryChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchQueryChanged() {
    if (_isSelectingPlace) {
      _isSelectingPlace = false;
      return;
    }
    if (!_searchFocusNode.hasFocus) {
      _searchDebounce?.cancel();
      if (_suggestions.isNotEmpty || _isSearching) {
        setState(() {
          _suggestions = [];
          _isSearching = false;
        });
      }
      return;
    }

    final query = _searchController.text.trim();
    if (query.length < 2) {
      if (_suggestions.isNotEmpty || _isSearching) {
        setState(() {
          _suggestions = [];
          _isSearching = false;
        });
      }
      return;
    }

    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      _fetchPlaceSuggestions(query);
    });
  }

  Future<void> _initLocation() async {
    // Check & request location permission
    await _checkAndRequestPermission();

    // 1. If coordinates are already provided from previous selection
    if (widget.initialLat != null && widget.initialLng != null) {
      _pickedLocation = LatLng(widget.initialLat!, widget.initialLng!);
      if (widget.initialAddress != null && widget.initialAddress!.isNotEmpty) {
        _resolvedDetails = PlaceAddressDetails(
          formattedAddress: widget.initialAddress!,
          shortAddress: widget.initialAddress!,
          city: '',
          state: '',
          pincode: '',
          lat: widget.initialLat!,
          lng: widget.initialLng!,
          googleMapsUrl: PlaceAddressDetails.buildMapsUrl(
            widget.initialLat!,
            widget.initialLng!,
          ),
          cityCandidates: const [],
        );
      }
      if (mounted) setState(() => _loading = false);
      _mapController?.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _pickedLocation, zoom: 16),
        ),
      );
      _reverseGeocode(_pickedLocation);
      return;
    }

    // 2. Instant last known position cached by OS (takes 0-10ms)
    try {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null && mounted) {
        final target = LatLng(lastKnown.latitude, lastKnown.longitude);
        _pickedLocation = target;
        _isProgrammaticMove = true;
        _mapController?.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: target, zoom: 16),
          ),
        );
        if (mounted) setState(() => _loading = false);
        _reverseGeocode(target);
      }
    } catch (_) {}

    // Ensure map is visible immediately
    if (_loading && mounted) {
      setState(() => _loading = false);
      _reverseGeocode(_pickedLocation);
    }

    // 3. Background fresh GPS acquisition
    _acquireFreshLocationInBackground();
  }

  Future<void> _checkAndRequestPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        if (mounted) {
          setState(() {
            _hasLocationPermission = true;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _acquireFreshLocationInBackground() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 5),
        ),
      );

      if (!mounted) return;
      final target = LatLng(position.latitude, position.longitude);

      // Center if user hasn't actively panned away
      if (!_userHasMovedMap) {
        _isProgrammaticMove = true;
        _pickedLocation = target;
        if (_mapController != null) {
          await _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: target, zoom: 16),
            ),
          );
        }
        _reverseGeocode(target);
      }
    } catch (e) {
      debugPrint('Background location fetch: $e');
    }
  }

  Future<void> _goToCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        if (mounted) setState(() => _hasLocationPermission = true);
      } else {
        return;
      }
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );
      final target = LatLng(pos.latitude, pos.longitude);
      _pickedLocation = target;
      _userHasMovedMap = true;
      _isProgrammaticMove = true;
      if (_mapController != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: target, zoom: 16),
          ),
        );
      }
      _reverseGeocode(target);
    } catch (e) {
      debugPrint('Error getting current location: $e');
    }
  }

  String _extractComponent(List<dynamic> components, List<String> types) {
    for (final type in types) {
      for (final comp in components) {
        if (comp is Map) {
          final List<dynamic> compTypes = comp['types'] ?? [];
          if (compTypes.contains(type)) {
            final val = comp['longText'] ?? comp['long_name'];
            if (val != null && val.toString().trim().isNotEmpty) {
              return val.toString().trim();
            }
          }
        }
      }
    }
    return '';
  }

  Future<void> _fetchPlaceSuggestions(String query) async {
    if (!mounted) return;
    final currentSession = ++_searchSessionId;
    setState(() => _isSearching = true);
    final List<_PlaceSuggestion> results = [];

    // 1. Try Places API (New) first: POST https://places.googleapis.com/v1/places:autocomplete
    try {
      final url = Uri.parse(
        'https://places.googleapis.com/v1/places:autocomplete',
      );
      final response = await http.post(
        url,
        headers: {
          'X-Goog-Api-Key': _googleApiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'input': query,
          'includedRegionCodes': ['in'],
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data['suggestions'] is List) {
          for (final item in data['suggestions']) {
            final pred = item['placePrediction'];
            if (pred != null) {
              final rawPlace = pred['place']?.toString() ?? '';
              final pId =
                  pred['placeId']?.toString() ??
                  (rawPlace.startsWith('places/')
                      ? rawPlace.substring(7)
                      : rawPlace);
              final desc = pred['text']?['text']?.toString() ?? '';
              final main =
                  pred['structuredFormat']?['mainText']?['text']?.toString() ??
                  desc;
              final sec =
                  pred['structuredFormat']?['secondaryText']?['text']
                      ?.toString() ??
                  '';

              if (pId.isNotEmpty) {
                results.add(
                  _PlaceSuggestion(
                    placeId: pId,
                    mainText: main,
                    secondaryText: sec,
                    description: desc.isNotEmpty ? desc : main,
                  ),
                );
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Places API (New) autocomplete error: $e');
    }

    // 2. If Places API (New) returned no results, fallback to legacy Places Autocomplete
    if (results.isEmpty) {
      try {
        final legacyUrl = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json'
          '?input=${Uri.encodeComponent(query)}'
          '&components=country:in'
          '&key=$_googleApiKey',
        );
        final legacyResp = await http.get(legacyUrl);
        if (legacyResp.statusCode == 200) {
          final data = json.decode(legacyResp.body);
          if (data['status'] == 'OK' && data['predictions'] is List) {
            for (final p in data['predictions']) {
              final pId = p['place_id']?.toString() ?? '';
              final desc = p['description']?.toString() ?? '';
              final main =
                  p['structured_formatting']?['main_text']?.toString() ?? desc;
              final sec =
                  p['structured_formatting']?['secondary_text']?.toString() ??
                  '';
              if (pId.isNotEmpty) {
                results.add(
                  _PlaceSuggestion(
                    placeId: pId,
                    mainText: main,
                    secondaryText: sec,
                    description: desc.isNotEmpty ? desc : main,
                  ),
                );
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Legacy places autocomplete error: $e');
      }
    }

    // 3. Fallback to OpenStreetMap (Nominatim) when Google Places quota is exhausted (429) or empty
    if (results.isEmpty) {
      try {
        final osmUrl = Uri.parse(
          'https://nominatim.openstreetmap.org/search'
          '?q=${Uri.encodeComponent(query)}'
          '&format=json'
          '&countrycodes=in'
          '&limit=8',
        );
        final osmResp = await http
            .get(osmUrl, headers: {'User-Agent': 'CarDriverApp/1.0'})
            .timeout(const Duration(seconds: 4));

        if (osmResp.statusCode == 200) {
          final List data = json.decode(osmResp.body);
          for (final item in data) {
            final latStr = item['lat']?.toString() ?? '';
            final lonStr = item['lon']?.toString() ?? '';
            final name = item['name']?.toString() ?? '';
            final displayName = item['display_name']?.toString() ?? '';

            String secText = '';
            if (displayName.contains(',')) {
              final parts = displayName
                  .split(',')
                  .map((e) => e.trim())
                  .toList();
              if (parts.length > 1) {
                secText = parts.sublist(1).take(3).join(', ');
              }
            }

            final placeId = 'osm:${latStr}_$lonStr';
            results.add(
              _PlaceSuggestion(
                placeId: placeId,
                mainText: name.isNotEmpty
                    ? name
                    : displayName.split(',').first.trim(),
                secondaryText: secText,
                description: displayName,
              ),
            );
          }
        }
      } catch (_) {}
    }

    if (!mounted ||
        currentSession != _searchSessionId ||
        !_searchFocusNode.hasFocus) {
      return;
    }

    setState(() {
      _suggestions = results;
      _isSearching = false;
    });
  }

  void _reverseGeocode(LatLng position) {
    final cacheKey =
        '${position.latitude.toStringAsFixed(4)},${position.longitude.toStringAsFixed(4)}';
    if (_geocodeCache.containsKey(cacheKey)) {
      if (mounted) {
        setState(() {
          _resolvedDetails = _geocodeCache[cacheKey];
          _resolving = false;
        });
      }
      return;
    }

    _geocodeDebounce?.cancel();
    _geocodeDebounce = Timer(const Duration(milliseconds: 200), () {
      _performReverseGeocode(position, cacheKey);
    });
  }

  Future<void> _performReverseGeocode(LatLng position, String cacheKey) async {
    if (mounted) setState(() => _resolving = true);
    PlaceAddressDetails? resolved;

    // 1. Try Google Geocoding API
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json'
        '?latlng=${position.latitude},${position.longitude}'
        '&key=$_googleApiKey',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' &&
            data['results'] != null &&
            (data['results'] as List).isNotEmpty) {
          final results = data['results'] as List<dynamic>;
          final result = results.firstWhere(
            (r) => !(r['types'] as List<dynamic>? ?? []).contains('plus_code'),
            orElse: () => results[0],
          );
          final List<dynamic> components = result['address_components'] ?? [];
          final rawFormatted = result['formatted_address']?.toString() ?? '';
          final formattedAddress = cleanAddressString(rawFormatted);
          final city = _extractComponent(components, [
            'locality',
            'administrative_area_level_2',
            'sublocality',
            'sublocality_level_1',
          ]);
          final state = _extractComponent(components, [
            'administrative_area_level_1',
          ]);
          final pincode = _extractComponent(components, ['postal_code']);
          var shortAddress = buildShortAddress(components);
          if (shortAddress.isEmpty) shortAddress = formattedAddress;

          resolved = PlaceAddressDetails(
            formattedAddress: formattedAddress,
            shortAddress: shortAddress,
            city: city,
            state: state,
            pincode: pincode,
            lat: position.latitude,
            lng: position.longitude,
            googleMapsUrl: PlaceAddressDetails.buildMapsUrl(
              position.latitude,
              position.longitude,
            ),
            cityCandidates: extractCityCandidates(components),
          );
        }
      }
    } catch (e) {
      debugPrint('Google reverse geocode error: $e');
    }

    // 2. Fallback: OpenStreetMap Nominatim reverse geocode
    if (resolved == null) {
      try {
        final osmRevUrl = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse'
          '?lat=${position.latitude}&lon=${position.longitude}'
          '&format=json'
          '&addressdetails=1',
        );
        final osmResp = await http
            .get(osmRevUrl, headers: {'User-Agent': 'CarDriverApp/1.0'})
            .timeout(const Duration(seconds: 4));
        if (osmResp.statusCode == 200) {
          final data = json.decode(osmResp.body);
          final addr = data['address'] as Map<String, dynamic>? ?? {};
          final disp = data['display_name']?.toString() ?? '';
          final sub =
              (addr['suburb'] ??
                      addr['neighbourhood'] ??
                      addr['residential'] ??
                      '')
                  .toString();
          final city = (addr['city'] ?? addr['town'] ?? addr['county'] ?? '')
              .toString();
          final state = (addr['state'] ?? '').toString();
          final postcode = (addr['postcode'] ?? '').toString();

          final shortAddr = sub.isNotEmpty
              ? sub
              : (city.isNotEmpty ? city : disp.split(',').first.trim());

          resolved = PlaceAddressDetails(
            formattedAddress: disp.isNotEmpty ? disp : 'Selected Location',
            shortAddress: shortAddr.isNotEmpty
                ? shortAddr
                : 'Selected Location',
            city: city,
            state: state,
            pincode: postcode,
            lat: position.latitude,
            lng: position.longitude,
            googleMapsUrl: PlaceAddressDetails.buildMapsUrl(
              position.latitude,
              position.longitude,
            ),
            cityCandidates: <String>[
              if (city.isNotEmpty) city,
              if (sub.isNotEmpty) sub,
            ].toSet().toList(),
          );
        }
      } catch (e) {
        debugPrint('OSM reverse geocode error: $e');
      }
    }

    // 4. Fallback C: Coordinates representation
    resolved ??= PlaceAddressDetails(
      formattedAddress:
          'Location (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})',
      shortAddress:
          'Selected Pin (${position.latitude.toStringAsFixed(3)}, ${position.longitude.toStringAsFixed(3)})',
      city: '',
      state: '',
      pincode: '',
      lat: position.latitude,
      lng: position.longitude,
      googleMapsUrl: PlaceAddressDetails.buildMapsUrl(
        position.latitude,
        position.longitude,
      ),
      cityCandidates: const [],
    );

    _geocodeCache[cacheKey] = resolved;
    if (mounted) {
      setState(() {
        _resolvedDetails = resolved;
        _resolving = false;
      });
    }
  }

  Future<void> _onSearchResultSelected(_PlaceSuggestion suggestion) async {
    _searchDebounce?.cancel();
    _searchSessionId++;
    _isSelectingPlace = true;
    _searchFocusNode.unfocus();
    _searchController.text = suggestion.description;
    setState(() {
      _suggestions = [];
      _isSearching = false;
      _resolving = true;
    });

    double? lat;
    double? lng;
    String formattedAddress = suggestion.description;
    String shortAddress = suggestion.mainText;
    String city = '';
    String state = '';
    String pincode = '';
    List<dynamic> components = [];

    // 0. If resolved via OpenStreetMap fallback, extract lat/lng immediately
    if (suggestion.placeId.startsWith('osm:')) {
      final parts = suggestion.placeId.substring(4).split('_');
      if (parts.length == 2) {
        lat = double.tryParse(parts[0]);
        lng = double.tryParse(parts[1]);
      }
    }

    // 1. Try Places API (New) Place Details first
    if (lat == null && !suggestion.placeId.startsWith('osm:')) {
      try {
        final cleanId = suggestion.placeId.startsWith('places/')
            ? suggestion.placeId.substring(7)
            : suggestion.placeId;
        final url = Uri.parse(
          'https://places.googleapis.com/v1/places/$cleanId',
        );
        final response = await http
            .get(
              url,
              headers: {
                'X-Goog-Api-Key': _googleApiKey,
                'X-Goog-FieldMask':
                    'id,displayName,formattedAddress,location,addressComponents',
              },
            )
            .timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data is Map) {
            if (data['location'] != null) {
              lat = double.tryParse(
                data['location']['latitude']?.toString() ?? '',
              );
              lng = double.tryParse(
                data['location']['longitude']?.toString() ?? '',
              );
            }
            if (data['formattedAddress'] != null) {
              formattedAddress = cleanAddressString(
                data['formattedAddress'].toString(),
              );
            }
            final dispName = data['displayName']?['text']?.toString();
            if (dispName != null && dispName.trim().isNotEmpty) {
              shortAddress = dispName.trim();
            }
            if (data['addressComponents'] is List) {
              components = data['addressComponents'];
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
            }
          }
        }
      } catch (e) {
        debugPrint('Places API (New) details error: $e');
      }
    }

    // 2. If lat/lng still null, try Legacy Place Details
    if (lat == null && !suggestion.placeId.startsWith('osm:')) {
      try {
        final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/details/json'
          '?place_id=${suggestion.placeId}'
          '&fields=geometry,address_components,formatted_address'
          '&key=$_googleApiKey',
        );
        final response = await http
            .get(url)
            .timeout(const Duration(seconds: 4));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'OK' && data['result'] != null) {
            final details = data['result'];
            final loc = details['geometry']?['location'];
            if (loc != null) {
              lat = double.tryParse(loc['lat']?.toString() ?? '');
              lng = double.tryParse(loc['lng']?.toString() ?? '');
              components = details['address_components'] ?? [];
              final rawFormatted =
                  details['formatted_address']?.toString() ?? '';
              formattedAddress = cleanAddressString(rawFormatted);
              final builtShort = buildShortAddress(components);
              if (builtShort.isNotEmpty) shortAddress = builtShort;

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
            }
          }
        }
      } catch (e) {
        debugPrint('Legacy place details error: $e');
      }
    }

    // 3. Fallback A: Geocode by address string using Google Geocoding API
    if (lat == null || lng == null) {
      try {
        final searchAddress = suggestion.description.isNotEmpty
            ? suggestion.description
            : suggestion.mainText;
        final geoUrl = Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json'
          '?address=${Uri.encodeComponent(searchAddress)}'
          '&key=$_googleApiKey',
        );
        final geoResp = await http
            .get(geoUrl)
            .timeout(const Duration(seconds: 4));
        if (geoResp.statusCode == 200) {
          final data = json.decode(geoResp.body);
          if (data['status'] == 'OK' &&
              data['results'] is List &&
              (data['results'] as List).isNotEmpty) {
            final first = data['results'][0];
            final loc = first['geometry']?['location'];
            if (loc != null) {
              lat = double.tryParse(loc['lat']?.toString() ?? '');
              lng = double.tryParse(loc['lng']?.toString() ?? '');
              components = first['address_components'] ?? [];
              formattedAddress = cleanAddressString(
                first['formatted_address']?.toString() ?? formattedAddress,
              );
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
            }
          }
        }
      } catch (e) {
        debugPrint('Google geocode fallback error: $e');
      }
    }

    // 4. Fallback B: OpenStreetMap Nominatim search
    if (lat == null || lng == null) {
      try {
        final searchAddress = suggestion.description.isNotEmpty
            ? suggestion.description
            : suggestion.mainText;
        final osmUrl = Uri.parse(
          'https://nominatim.openstreetmap.org/search'
          '?q=${Uri.encodeComponent(searchAddress)}'
          '&format=json'
          '&countrycodes=in'
          '&limit=1',
        );
        final osmResp = await http
            .get(osmUrl, headers: {'User-Agent': 'CarDriverApp/1.0'})
            .timeout(const Duration(seconds: 4));
        if (osmResp.statusCode == 200) {
          final list = json.decode(osmResp.body);
          if (list is List && list.isNotEmpty) {
            lat = double.tryParse(list[0]['lat']?.toString() ?? '');
            lng = double.tryParse(list[0]['lon']?.toString() ?? '');
            if (list[0]['display_name'] != null) {
              formattedAddress = list[0]['display_name'].toString();
            }
          }
        }
      } catch (e) {
        debugPrint('OSM search fallback error: $e');
      }
    }

    final effectiveLat = lat ?? _pickedLocation.latitude;
    final effectiveLng = lng ?? _pickedLocation.longitude;
    final target = LatLng(effectiveLat, effectiveLng);
    _pickedLocation = target;
    _userHasMovedMap = true;
    _isProgrammaticMove = true;

    final detailsObj = PlaceAddressDetails(
      formattedAddress: formattedAddress.isNotEmpty
          ? formattedAddress
          : suggestion.description,
      shortAddress: shortAddress.isNotEmpty
          ? shortAddress
          : suggestion.mainText,
      city: city,
      state: state,
      pincode: pincode,
      lat: effectiveLat,
      lng: effectiveLng,
      googleMapsUrl: PlaceAddressDetails.buildMapsUrl(
        effectiveLat,
        effectiveLng,
      ),
      cityCandidates: extractCityCandidates(components),
    );

    final cacheKey =
        '${effectiveLat.toStringAsFixed(4)},${effectiveLng.toStringAsFixed(4)}';
    _geocodeCache[cacheKey] = detailsObj;

    if (mounted) {
      setState(() {
        _resolvedDetails = detailsObj;
        _resolving = false;
      });

      // Animate map camera to the target coordinates
      if (_mapController != null) {
        _isProgrammaticMove = true;
        await _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: target, zoom: 16),
          ),
        );
      }
    }

    // If city or address details are still incomplete, trigger reverse geocode to fill bottom card
    if (city.isEmpty || formattedAddress.isEmpty) {
      _reverseGeocode(target);
    }
  }

  void _onCameraIdle() {
    if (_isProgrammaticMove) {
      _isProgrammaticMove = false;
      return;
    }
    _reverseGeocode(_pickedLocation);
  }

  void _onCameraMove(CameraPosition position) {
    if (!_isProgrammaticMove) {
      _userHasMovedMap = true;
    }
    _pickedLocation = position.target;
  }

  @override
  Widget build(BuildContext context) {
    final String screenTitle =
        widget.title ??
        (widget.isPickup == true ? 'Pickup Location' : 'Drop Location');

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(screenTitle, style: GoogleFonts.inter(fontSize: 16)),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _pickedLocation,
              zoom: 16,
            ),
            mapType: MapType.normal,
            compassEnabled: true,
            rotateGesturesEnabled: true,
            scrollGesturesEnabled: true,
            tiltGesturesEnabled: true,
            zoomGesturesEnabled: true,
            onMapCreated: (controller) {
              _mapController = controller;
              _mapController?.moveCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(target: _pickedLocation, zoom: 16),
                ),
              );
            },
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
            onTap: (_) {
              if (_suggestions.isNotEmpty || _searchFocusNode.hasFocus) {
                _searchDebounce?.cancel();
                _searchFocusNode.unfocus();
                setState(() {
                  _suggestions = [];
                  _isSearching = false;
                });
              }
            },
            myLocationEnabled: _hasLocationPermission,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            padding: const EdgeInsets.only(top: 72),
          ),
          const IgnorePointer(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Icon(
                  Icons.location_on,
                  size: 44,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.white,
                      hintText: widget.isPickup == true
                          ? 'Search for pickup location (e.g. Ameerpet)'
                          : widget.isPickup == false
                          ? 'Search for drop location (e.g. Hitec City)'
                          : 'Search for a location (e.g. Ameerpet)',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: AppColors.textSecondary,
                                size: 20,
                              ),
                              onPressed: () {
                                _searchDebounce?.cancel();
                                _searchSessionId++;
                                _searchController.clear();
                                setState(() {
                                  _suggestions = [];
                                  _isSearching = false;
                                });
                              },
                            )
                          : (_isSearching
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  )
                                : null),
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (_suggestions.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 240),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _suggestions.length,
                      separatorBuilder: (_, __) => const Divider(
                        color: AppColors.borderLight,
                        height: 1,
                        thickness: 1,
                      ),
                      itemBuilder: (context, index) {
                        final suggestion = _suggestions[index];
                        return InkWell(
                          onTap: () => _onSearchResultSelected(suggestion),
                          child: Padding(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        suggestion.mainText,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          color: AppColors.textPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (suggestion
                                          .secondaryText
                                          .isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          suggestion.secondaryText,
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
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 185,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _goToCurrentLocation,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.my_location,
                    size: 22,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 8),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _resolving
                        ? 'Locating...'
                        : (_resolvedDetails?.shortAddress.isNotEmpty == true
                              ? _resolvedDetails!.shortAddress
                              : (_resolvedDetails?.formattedAddress ??
                                    'Move the map to select a location')),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (!_resolving &&
                      _resolvedDetails != null &&
                      _resolvedDetails!.formattedAddress.isNotEmpty &&
                      _resolvedDetails!.formattedAddress !=
                          _resolvedDetails!.shortAddress) ...[
                    const SizedBox(height: 4),
                    Text(
                      _resolvedDetails!.formattedAddress,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _resolvedDetails == null
                          ? null
                          : () => context.pop(_resolvedDetails),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Confirm $screenTitle',
                        style: GoogleFonts.inter(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
