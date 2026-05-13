import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  Position? _currentPosition;
  GoogleMapController? mapController;
  LatLng _center = const LatLng(0, 0);
  final Set<Marker> _markers = {};
  late LatLng _currentMapLocation;

  @override
  void initState() {
    super.initState();
    _currentMapLocation = _center;
    _getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nearby Gyms")),
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(target: _center, zoom: 15),
              markers: _markers,
              onCameraMove: _onCameraMove,
              circles: {
                Circle(
                  circleId: const CircleId('1'),
                  center: _currentMapLocation,
                  radius: 5000,
                  strokeWidth: 2,
                  fillColor: Colors.lightGreenAccent.withValues(alpha: 0.5),
                )
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.topRight,
              child: FloatingActionButton(
                onPressed: _onAddMarkerButtonPressed,
                backgroundColor: Colors.purpleAccent,
                materialTapTargetSize: MaterialTapTargetSize.padded,
                child: const Icon(Icons.map, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled.')),
        );
      }
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied.')),
          );
        }
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are permanently denied.')),
        );
      }
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _center = LatLng(position.latitude, position.longitude);
          _currentMapLocation = _center;
        });
        _animateToCurrentPosition();
      }
    } catch (e) {
      debugPrint("Location error: $e");
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _animateToCurrentPosition();
  }

  void _animateToCurrentPosition() {
    if (mapController != null && _currentPosition != null) {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _center, zoom: 15),
        ),
      );
    }
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _currentMapLocation = position.target;
    });
  }

  void _onAddMarkerButtonPressed() {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(_currentMapLocation.toString()),
          position: _currentMapLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueViolet,
          ),
        ),
      );
    });
  }
}
