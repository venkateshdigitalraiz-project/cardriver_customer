// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:http/http.dart' as http;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/place_address_utils.dart';
import '../../domain/entities/location_entity.dart';
import '../bloc/location_bloc.dart';
import '../bloc/location_event.dart';
import '../bloc/location_state.dart';

class SavedLocationsPage extends StatefulWidget {
  const SavedLocationsPage({super.key});

  @override
  State<SavedLocationsPage> createState() => _SavedLocationsPageState();
}

class _SavedLocationsPageState extends State<SavedLocationsPage> {
  final Completer<GoogleMapController> _mapController = Completer();
  Position? _currentPosition;
  bool _hasLocationPermission = false;
  bool _isMapLoading = true;

  @override
  void initState() {
    super.initState();
    context.read<LocationBloc>().add(LoadLocations());
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      if (mounted) setState(() => _hasLocationPermission = true);

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) setState(() => _currentPosition = position);

      final controller = await _mapController.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 14,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error fetching location: $e');
    }
  }

  void _openAddLocationScreen(BuildContext ctx) async {
    await Navigator.push(
      ctx,
      MaterialPageRoute(builder: (_) => AddLocationScreen(parentCtx: ctx)),
    );
  }

  Future<void> _saveCurrentLocation() async {
    if (_currentPosition == null) {
      await _fetchCurrentLocation();
    }
    if (_currentPosition == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not fetch current location')),
        );
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saving current location...')),
      );
    }

    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json'
        '?latlng=${_currentPosition!.latitude},${_currentPosition!.longitude}'
        '&key=AIzaSyCvBoWiQ4Eh2UQusV3fjjfVeqyf6HiAO2s',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && (data['results'] as List).isNotEmpty) {
          final result = data['results'][0];
          final formattedAddress =
              result['formatted_address']?.toString() ?? 'Current Location';

          final newLocation = LocationEntity(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: 'Current Location',
            address: formattedAddress,
            latitude: _currentPosition!.latitude,
            longitude: _currentPosition!.longitude,
            isCurrentLocation: true,
          );

          if (mounted) {
            context.read<LocationBloc>().add(AddLocation(newLocation));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Current location saved successfully!'),
              ),
            );
            Navigator.pop(context);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not find address for current location'),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving location: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Saved Locations',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocBuilder<LocationBloc, LocationState>(
        builder: (context, state) {
          // Compute markers only when loaded; empty set during loading
          final Set<Marker> markers = state is LocationLoaded
              ? state.locations.map((loc) {
                  return Marker(
                    markerId: MarkerId(loc.id),
                    position: LatLng(loc.latitude, loc.longitude),
                    infoWindow: InfoWindow(
                      title: loc.name,
                      snippet: loc.address,
                    ),
                  );
                }).toSet()
              : {};

          // Camera: prefer GPS â†’ first saved location â†’ India fallback
          final CameraPosition initialCamera = _currentPosition != null
              ? CameraPosition(
                  target: LatLng(
                    _currentPosition!.latitude,
                    _currentPosition!.longitude,
                  ),
                  zoom: 14,
                )
              : (state is LocationLoaded && state.locations.isNotEmpty)
              ? CameraPosition(
                  target: LatLng(
                    state.locations.first.latitude,
                    state.locations.first.longitude,
                  ),
                  zoom: 12,
                )
              : const CameraPosition(
                  target: LatLng(12.9716, 77.5946),
                  zoom: 11,
                );

          return Stack(
            children: [
              // â”€â”€ Google Map â€” always rendered immediately â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              GoogleMap(
                initialCameraPosition: initialCamera,
                markers: markers,
                onMapCreated: (GoogleMapController controller) {
                  if (!_mapController.isCompleted) {
                    _mapController.complete(controller);
                  }
                  if (mounted) setState(() => _isMapLoading = false);
                },
                myLocationEnabled: _hasLocationPermission,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false,
                padding: EdgeInsets.only(
                  bottom:
                      (state is LocationLoaded && state.locations.isNotEmpty)
                      ? 250
                      : 120,
                  top: 20,
                ),
              ),

              // â”€â”€ Spinner overlay while map tiles load â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              if (_isMapLoading)
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.25,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),

              // â”€â”€ Bottom locations list â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              if (state is LocationLoaded && state.locations.isNotEmpty)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(top: 12, bottom: 8),
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        Flexible(
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                            itemCount: state.locations.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final location = state.locations[index];
                              return _buildLocationCard(context, location);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (state is LocationLoaded)
                // Only show "no saved locations" once load is confirmed empty
                Positioned(
                  bottom: 100,
                  left: 24,
                  right: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_off_outlined,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'No saved locations yet',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'current_location',
            onPressed: _saveCurrentLocation,
            backgroundColor: Colors.white,
            tooltip: 'Save Current Location',
            child: const Icon(
              Icons.my_location,
              color: AppColors.primary,
              size: 40,
            ),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            heroTag: 'add_location',
            onPressed: () => _openAddLocationScreen(context),
            backgroundColor: AppColors.primary,
            tooltip: 'Add Location',
            child: const Icon(Icons.add, color: Colors.white, size: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context, LocationEntity location) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            location.isCurrentLocation ? Icons.my_location : Icons.location_on,
            color: AppColors.primaryDark,
          ),
        ),
        title: Text(
          location.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            location.address,
            style: TextStyle(color: Colors.grey.shade600, height: 1.3),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () {
            context.read<LocationBloc>().add(RemoveLocation(location.id));
          },
        ),
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// AddLocationScreen  â€” full-screen map + search + name field + save
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class AddLocationScreen extends StatefulWidget {
  /// The parent context that owns the LocationBloc.
  final BuildContext parentCtx;

  const AddLocationScreen({super.key, required this.parentCtx});

  @override
  State<AddLocationScreen> createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  static const String _apiKey = 'AIzaSyCvBoWiQ4Eh2UQusV3fjjfVeqyf6HiAO2s';

  // â”€â”€ Map â”€â”€
  GoogleMapController? _mapController;
  LatLng _pickedLocation = const LatLng(20.5937, 78.9629); // India fallback
  bool _mapLoading = true;
  bool _resolving = false;

  // â”€â”€ Address resolved from pin position â”€â”€
  PlaceAddressDetails? _resolvedDetails;

  // â”€â”€ UI controllers â”€â”€
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // â”€â”€ Initialise to GPS / fallback â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> _initLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled &&
          permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever) {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        _pickedLocation = LatLng(pos.latitude, pos.longitude);
      }
    } catch (e) {
      debugPrint('GPS error: $e');
    }

    await _reverseGeocode(_pickedLocation);
    if (mounted) setState(() => _mapLoading = false);
  }

  // â”€â”€ Reverse geocode â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> _reverseGeocode(LatLng pos) async {
    if (mounted) setState(() => _resolving = true);
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json'
        '?latlng=${pos.latitude},${pos.longitude}'
        '&key=$_apiKey',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && (data['results'] as List).isNotEmpty) {
          final result = data['results'][0];
          final List<dynamic> components = result['address_components'] ?? [];
          final formattedAddress =
              result['formatted_address']?.toString() ?? '';
          var shortAddress = buildShortAddress(components);
          if (shortAddress.isEmpty) shortAddress = formattedAddress;

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

          if (mounted) {
            setState(() {
              _resolvedDetails = PlaceAddressDetails(
                formattedAddress: formattedAddress,
                shortAddress: shortAddress,
                city: city,
                state: state,
                pincode: pincode,
                lat: pos.latitude,
                lng: pos.longitude,
                googleMapsUrl: PlaceAddressDetails.buildMapsUrl(
                  pos.latitude,
                  pos.longitude,
                ),
                cityCandidates: extractCityCandidates(components),
              );
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Reverse geocode error: $e');
    } finally {
      if (mounted) setState(() => _resolving = false);
    }
  }

  // â”€â”€ When user picks a search suggestion â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> _onSuggestionSelected(Prediction prediction) async {
    _searchFocus.unfocus();
    if (prediction.placeId == null) return;

    setState(() => _resolving = true);
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=${prediction.placeId!}'
        '&fields=geometry,address_components,formatted_address'
        '&key=$_apiKey',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['result'] != null) {
          final details = data['result'];
          final loc = details['geometry']?['location'];
          if (loc != null) {
            final lat = double.tryParse(loc['lat'].toString()) ?? 0.0;
            final lng = double.tryParse(loc['lng'].toString()) ?? 0.0;
            final target = LatLng(lat, lng);
            _pickedLocation = target;

            // Animate map to the selected place
            await _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(target, 16),
            );

            // Build address details from the place details response
            final List<dynamic> components =
                details['address_components'] ?? [];
            final formattedAddress =
                details['formatted_address']?.toString() ?? '';
            var shortAddress = buildShortAddress(components);
            if (shortAddress.isEmpty) shortAddress = formattedAddress;
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

            if (mounted) {
              setState(() {
                _resolvedDetails = PlaceAddressDetails(
                  formattedAddress: formattedAddress,
                  shortAddress: shortAddress,
                  city: city,
                  state: state,
                  pincode: pincode,
                  lat: lat,
                  lng: lng,
                  googleMapsUrl: PlaceAddressDetails.buildMapsUrl(lat, lng),
                  cityCandidates: extractCityCandidates(components),
                );
                // Pre-fill the search box with the short address
                _searchController.text = shortAddress;
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Place details error: $e');
    } finally {
      if (mounted) setState(() => _resolving = false);
    }
  }

  // â”€â”€ Camera events â€” user drags map â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _onCameraMove(CameraPosition position) {
    _pickedLocation = position.target;
  }

  void _onCameraIdle() {
    // Re-resolve address whenever the map stops moving
    _reverseGeocode(_pickedLocation);
  }

  // â”€â”€ Save â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _saveLocation() {
    if (_resolvedDetails == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait while the address loads.')),
      );
      return;
    }

    final newLocation = LocationEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _resolvedDetails!.shortAddress.isNotEmpty
          ? _resolvedDetails!.shortAddress
          : _resolvedDetails!.formattedAddress,
      address: _resolvedDetails!.shortAddress.isNotEmpty
          ? _resolvedDetails!.shortAddress
          : _resolvedDetails!.formattedAddress,
      latitude: _resolvedDetails!.lat,
      longitude: _resolvedDetails!.lng,
      isCurrentLocation: false,
    );

    // Persist via bloc (parent context owns the LocationBloc)
    widget.parentCtx.read<LocationBloc>().add(AddLocation(newLocation));

    // Pop AddLocationScreen, then SavedLocationsPage â†’ back to Profile
    final nav = Navigator.of(context);
    nav.pop(); // close AddLocationScreen
    if (nav.canPop()) {
      nav.pop(); // close SavedLocationsPage â†’ profile
    }
  }

  // â”€â”€ Helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

  // â”€â”€ Build â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Add Location',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _mapLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Stack(
              children: [
                // â”€â”€ Full-screen Google Map â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _pickedLocation,
                    zoom: 15,
                  ),
                  onMapCreated: (ctrl) => _mapController = ctrl,
                  onCameraMove: _onCameraMove,
                  onCameraIdle: _onCameraIdle,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                  // leave room for the search bar at top and card at bottom
                  padding: const EdgeInsets.only(top: 72, bottom: 220),
                ),

                // â”€â”€ Fixed centre pin â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                const IgnorePointer(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 44),
                      child: Icon(
                        Icons.location_on,
                        size: 48,
                        color: AppColors.primary,
                        shadows: [
                          Shadow(
                            color: Colors.black38,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // â”€â”€ Search bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: GooglePlaceAutoCompleteTextField(
                        textEditingController: _searchController,
                        focusNode: _searchFocus,
                        googleAPIKey: _apiKey,
                        debounceTime: 400,
                        countries: const ['in'],
                        isLatLngRequired: false,
                        showError: false,
                        boxDecoration: const BoxDecoration(),
                        inputDecoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Search for a locationâ€¦',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.primary,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: AppColors.textSecondary,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 14,
                          ),
                        ),
                        textStyle: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                        itemClick: (Prediction prediction) {
                          _searchController.text = prediction.description ?? '';
                          _onSuggestionSelected(prediction);
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
                              prediction.structuredFormatting?.secondaryText ??
                              '';
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            color: Colors.white,
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
                  ),
                ),

                // â”€â”€ Bottom card: resolved address + name + save â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 16,
                  child: Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // â”€â”€ Resolved address display â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.location_pin,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _resolving
                                    ? Row(
                                        children: [
                                          const SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Locatingâ€¦',
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Text(
                                        _resolvedDetails?.formattedAddress ??
                                            'Move the map to pick a location',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // â”€â”€ Save button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _resolving ? null : _saveLocation,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                disabledBackgroundColor: AppColors.primary
                                    .withValues(alpha: 0.4),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Save Location',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// PublishLocationField  (reusable â€” used in other parts of the app)
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
