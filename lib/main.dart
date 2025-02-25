import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HealthcareMap(),
    );
  }
}

class HealthcareMap extends StatefulWidget {
  @override
  _HealthcareMapState createState() => _HealthcareMapState();
}

class _HealthcareMapState extends State<HealthcareMap> {
  late GoogleMapController _mapController;
  LatLng _currentLocation = LatLng(20.5937, 78.9629); // Default to India
  List<Marker> _markers = [];
  final String _apiKey =
      "AIzaSyDhJ8Zu3Lm4RMMsrrTMHNrkLnUHJi_v5jU"; // Replace with your API Key

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      _fetchNearbyHospitals();
    }
  }

  Future<void> _fetchNearbyHospitals() async {
    final places = GoogleMapsPlaces(apiKey: _apiKey);
    PlacesSearchResponse response = await places.searchNearbyWithRadius(
      Location(lat: _currentLocation.latitude, lng: _currentLocation.longitude),
      5000, // 5km radius
      type: "hospital",
    );

    if (response.status == "OK") {
      setState(() {
        _markers =
            response.results
                .map(
                  (place) => Marker(
                    markerId: MarkerId(place.placeId),
                    position: LatLng(
                      place.geometry!.location.lat,
                      place.geometry!.location.lng,
                    ),
                    infoWindow: InfoWindow(title: place.name),
                  ),
                )
                .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Healthcare Map")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentLocation,
          zoom: 10,
        ),
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        markers: Set<Marker>.of(_markers),
        myLocationEnabled: true,
      ),
    );
  }
}
