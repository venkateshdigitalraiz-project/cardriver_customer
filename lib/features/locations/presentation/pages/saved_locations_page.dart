import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../../core/theme/app_colors.dart';
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
  @override
  void initState() {
    super.initState();
    context.read<LocationBloc>().add(LoadLocations());
  }

  void _showAddLocationBottomSheet(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    bool isCurrentLocation = false;
    double? currentLat;
    double? currentLng;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (BuildContext statefulContext, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(statefulContext).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Add New Location',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Current Location Toggle
                    Material(
                      color: isCurrentLocation
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.grey.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isCurrentLocation
                              ? AppColors.primary
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: SwitchListTile(
                        title: Text(
                          'Use Current Location',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isCurrentLocation
                                ? AppColors.primaryDark
                                : Colors.black87,
                          ),
                        ),
                        subtitle: const Text(
                          'Automatically fetch GPS location',
                        ),
                        value: isCurrentLocation,
                        activeColor: AppColors.primary,
                        onChanged: (value) async {
                          setModalState(() {
                            isCurrentLocation = value;
                            if (value) {
                              addressController.text =
                                  "Fetching current GPS address...";
                            } else {
                              addressController.clear();
                              currentLat = null;
                              currentLng = null;
                            }
                          });

                          if (value) {
                            try {
                              bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
                              if (!serviceEnabled) {
                                throw Exception('Location services are disabled.');
                              }

                              LocationPermission permission = await Geolocator.checkPermission();
                              if (permission == LocationPermission.denied) {
                                permission = await Geolocator.requestPermission();
                                if (permission == LocationPermission.denied) {
                                  throw Exception('Location permissions are denied');
                                }
                              }
                              
                              if (permission == LocationPermission.deniedForever) {
                                throw Exception('Location permissions are permanently denied');
                              }

                              Position position = await Geolocator.getCurrentPosition(
                                desiredAccuracy: LocationAccuracy.high
                              );
                              
                              currentLat = position.latitude;
                              currentLng = position.longitude;

                              List<Placemark> placemarks = await Geocoding().placemarkFromCoordinates(
                                position.latitude,
                                position.longitude,
                              );

                              if (placemarks.isNotEmpty) {
                                Placemark place = placemarks[0];
                                String address = '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
                                // Clean up any empty parts
                                address = address.replaceAll(RegExp(r'^, |, $'), '').replaceAll(', ,', ',');
                                setModalState(() {
                                  addressController.text = address;
                                });
                              }
                            } catch (e) {
                              setModalState(() {
                                addressController.text = "Error getting location: ${e.toString()}";
                                isCurrentLocation = false;
                              });
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Location Name
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Location Name (e.g. Home, Office)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Address Field
                    TextField(
                      controller: addressController,
                      maxLines: 2,
                      enabled:
                          !isCurrentLocation, // Disable if using current location
                      decoration: InputDecoration(
                        labelText: 'Full Address',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: () {
                        String finalName = nameController.text.trim();
                        if (finalName.isEmpty) {
                          finalName = "My Location";
                        }

                        String finalAddress = addressController.text.trim();
                        if (finalAddress.isEmpty || finalAddress.startsWith("Fetching") || finalAddress.startsWith("Error")) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a valid address or wait for GPS')),
                          );
                          return;
                        }

                        final newLocation = LocationEntity(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: finalName,
                          address: finalAddress,
                          latitude: currentLat ?? 12.9716, // Use real if available, else mock
                          longitude: currentLng ?? 77.5946,
                          isCurrentLocation: isCurrentLocation,
                        );

                        // Use the original context to add event
                        context.read<LocationBloc>().add(
                          AddLocation(newLocation),
                        );
                        
                        // Close bottom sheet and SavedLocationsPage to return to Profile
                        Navigator.of(context)
                          ..pop()
                          ..pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
          if (state is LocationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LocationLoaded) {
            if (state.locations.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_off_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No saved locations yet',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.locations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final location = state.locations[index];
                return _buildLocationCard(context, location);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddLocationBottomSheet(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_location_alt, color: Colors.white),
        label: const Text(
          'Add Location',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
            color: Colors.blue.withOpacity(0.04),
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
            color: AppColors.primary.withOpacity(0.1),
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
