import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // created controller to display Google Maps
  final Completer<GoogleMapController> _googleMapController = Completer();

  //on below line we have set the camera position
  static const CameraPosition _initialLocation = CameraPosition(
    target: LatLng(23.913689376605852, 90.39846164980845),
    zoom: 15,
    bearing: 30,
    tilt: 10,
  );

  StreamSubscription? _streamSubscription;
  LocationData? locationData;
  //PolylinePoints polylinePoints = PolylinePoints();

  @override
  void initState() {
   // initialize();
    super.initState();

  }
  //
  // void initialize(){
  //   Location.instance.changeSettings(
  //     distanceFilter: 2,
  //     accuracy: LocationAccuracy.high,
  //     interval: 1000
  //   );
  // }

  void getMyLocation() async {
    await Location.instance.requestPermission().then((value) => {});
    Location.instance.hasPermission().then((value) => {});

    locationData = await Location.instance.getLocation();
    print(locationData);
    if (mounted) {
      setState(() {});
    }
  }

  void listenMyLocation() async {
    _streamSubscription =
        Location.instance.onLocationChanged.listen((location) {
      print(location);
      if (location != locationData) {
        locationData = location;
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  void stopMyLocation() {
    _streamSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Google Map"),
      ),
      body: SafeArea(
        child: GoogleMap(
          initialCameraPosition: _initialLocation,
          zoomControlsEnabled: true,
          zoomGesturesEnabled: true,
          compassEnabled: true,
          mapType: MapType.normal,
          onMapCreated: (GoogleMapController controller) {
            //method called when map is created
            _googleMapController.complete(controller);
            setState(() {});
          },
          markers:  <Marker>{
            Marker(
              markerId: const MarkerId("custom-marker"),
              position: LatLng(locationData?.latitude ?? 0,locationData?.longitude ?? 0),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              infoWindow:  InfoWindow(title: "My Current Location",
                snippet: "${locationData?.latitude ?? 0},${locationData?.longitude ?? 0}",
              ),
              draggable: true,
            )
          },
          polylines: <Polyline>{
              Polyline(
                visible: true,
                polylineId: const PolylineId("custom-polyline"),
                points:[
                  const LatLng(23.913689376605852, 90.39846164980845),
                  LatLng(locationData?.latitude ?? 0,locationData?.longitude ?? 0),
                ],

              )
          },
        ),
      ),
      floatingActionButton: Row(children: [
        FloatingActionButton.small(
          backgroundColor: Colors.deepOrange,
          onPressed: () {
            getMyLocation();
          },
          child: const Icon(Icons.my_location_rounded),
        ),
        FloatingActionButton.small(
          backgroundColor: Colors.deepOrange,
          onPressed: () {
            listenMyLocation();
          },
          child: const Icon(Icons.location_on),
        ),
        FloatingActionButton.small(
          backgroundColor: Colors.deepOrange,
          onPressed: () {
            stopMyLocation();
          },
          child: const Icon(Icons.location_off),
        ),
      ]),
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
    );

  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}
