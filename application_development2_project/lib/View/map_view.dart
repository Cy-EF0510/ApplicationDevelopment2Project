import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Position? _currentPosition;

  //create a controller that controls the satellite images
  late GoogleMapController mapController;
  static LatLng _center = LatLng(0, 0);
  final Set<Marker> _markers = {};
  late LatLng _currentMapLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentPosition();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nearby Gyms")),
      body: Stack(
        children: <Widget>[
          Positioned.fill(child:
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(target: _center, zoom: 10),
              markers: _markers,
              onCameraMove: _onCameraMove,
              circles: {
                Circle(
                  circleId: CircleId('1'),
                  center: _currentMapLocation,
                  radius: 5000,
                  strokeWidth: 2,
                  fillColor: Colors.lightGreenAccent.withValues(alpha: 0.5),
                )
              },
            )
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.topRight,
              child: FloatingActionButton(
                onPressed: _onAddMarkerButtonPressed,
                backgroundColor: Colors.purpleAccent,
                materialTapTargetSize: MaterialTapTargetSize.padded,
                child: Icon(Icons.map, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //Method to check and request the user's permission
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    //If Location Service is disabled, show snackbar and return false
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Location services are disabled. Please enable the service.',
          ),
        ),
      );
      return false;
    }
    //Call checkPermission() method to check it user already granted permission
    permission = await Geolocator.checkPermission();
    //If permission denied, call requestPermission() method
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permissions are denied')),
        );
        return false;
      }
    }
    //If permission is permanently denied, show the snackbar and return false
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Location permissions are permanently denied, we cannot request permissions',
          ),
        ),
      );
    }
    //Permissions are granted
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition()
        .then((Position position) {
          // setState(() => _currentPosition = position);
          setState(() {
            _currentPosition = position;
            _center = LatLng(position.latitude, position.longitude);
          });
        })
        .catchError((e) {
          debugPrint(e);
        });
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
          CameraPosition(target: _center, zoom: 10))
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
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
