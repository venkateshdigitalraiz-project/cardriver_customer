import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/flow/booking_flow_bloc.dart';
import '../bloc/flow/booking_flow_state.dart';

class BookingMapPreview extends StatefulWidget {
  const BookingMapPreview({super.key});

  @override
  State<BookingMapPreview> createState() => _BookingMapPreviewState();
}

class _BookingMapPreviewState extends State<BookingMapPreview> {
  GoogleMapController? _mapController;

  void _updateMapBounds(BookingFlowState state) {
    if (_mapController == null) return;
    
    final req = state.request;
    if (req.pickupLat != null &&
        req.pickupLng != null &&
        req.dropLat != null &&
        req.dropLng != null) {
      final lat1 = req.pickupLat!;
      final lon1 = req.pickupLng!;
      final lat2 = req.dropLat!;
      final lon2 = req.dropLng!;

      final bounds = LatLngBounds(
        southwest: LatLng(
          lat1 < lat2 ? lat1 : lat2,
          lon1 < lon2 ? lon1 : lon2,
        ),
        northeast: LatLng(
          lat1 > lat2 ? lat1 : lat2,
          lon1 > lon2 ? lon1 : lon2,
        ),
      );

      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 60.0),
      );
    } else if (req.pickupLat != null && req.pickupLng != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(LatLng(req.pickupLat!, req.pickupLng!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingFlowBloc, BookingFlowState>(
      listenWhen: (previous, current) {
        return previous.request.pickupLat != current.request.pickupLat ||
               previous.request.dropLat != current.request.dropLat ||
               previous.request.pickupLng != current.request.pickupLng ||
               previous.request.dropLng != current.request.dropLng;
      },
      listener: (context, state) {
        _updateMapBounds(state);
      },
      builder: (context, state) {
        final req = state.request;

        return GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(req.pickupLat ?? 17.4156, req.pickupLng ?? 78.4347),
            zoom: 12,
          ),
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          scrollGesturesEnabled: false,
          markers: {
            if (req.pickupLat != null && req.pickupLng != null)
              Marker(
                markerId: const MarkerId('pickup'),
                position: LatLng(req.pickupLat!, req.pickupLng!),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
              ),
            if (req.dropLat != null && req.dropLng != null)
              Marker(
                markerId: const MarkerId('drop'),
                position: LatLng(req.dropLat!, req.dropLng!),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              ),
          },
          polylines: {
            if (req.pickupLat != null && req.pickupLng != null && req.dropLat != null && req.dropLng != null)
              Polyline(
                polylineId: const PolylineId('route'),
                points: [
                  LatLng(req.pickupLat!, req.pickupLng!),
                  LatLng(req.dropLat!, req.dropLng!),
                ],
                color: AppColors.primary,
                width: 4,
                patterns: [PatternItem.dash(20), PatternItem.gap(10)],
              ),
          },
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                _updateMapBounds(state);
              }
            });
          },
        );
      },
    );
  }
}
