import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';

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
    target: sourceLocation,
    zoom: 15,
    bearing: 30,
    tilt: 10,
  );

  static const LatLng sourceLocation = LatLng(23.9056, 90.3989);
  static const LatLng destinationLocation = LatLng(23.8746, 90.3967);

  StreamSubscription? _streamSubscription;
  LocationData? locationData;
  //PolylinePoints polylinePoints = PolylinePoints();

  @override
  void initState() {
    initialize();
    super.initState();

  }

  void initialize() {
    Permission.locationWhenInUse.request();
    Location.instance.changeSettings(
      distanceFilter: 10,
      accuracy: LocationAccuracy.high,
      interval: 10000
    );
  }

  void getMyLocation() async {
    await Location.instance.requestPermission().then((value) => {

    });
    Location.instance.hasPermission().then((value) => {});

    locationData = await Location.instance.getLocation();
    print(locationData);
    if (mounted) {
      setState(() {});
    }
  }

  void listenMyLocation() async {
    GoogleMapController googleMapController = await _googleMapController.future;

    _streamSubscription =
        Location.instance.onLocationChanged.listen((location) {
      print(location);

      if (location != locationData) {
        locationData = location;
        googleMapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(
            location.latitude!,location.longitude!
          ),
            zoom: 15,
            bearing: 30,
            tilt: 10,
          )
        ));
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
          initialCameraPosition: const CameraPosition(
            target: sourceLocation,
            zoom: 15,
            bearing: 30,
            tilt: 10,
          ),
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
              markerId: const MarkerId("custom-marker-1"),
              position: sourceLocation,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              draggable: true,
            ),
            Marker(
              markerId: const MarkerId("custom-marker-2"),
              position: LatLng(locationData?.latitude ?? 0,locationData?.longitude ?? 0),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              infoWindow:  InfoWindow(title: "My Current Location",
                snippet: "${locationData?.latitude ?? 0},${locationData?.longitude ?? 0}",
              ),
              draggable: true,
            ),
            Marker(
              markerId: const MarkerId("custom-marker-3"),
              position: destinationLocation,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              draggable: true,
            )
          },
          polylines: <Polyline>{
              Polyline(
                visible: true,
                polylineId: const PolylineId("custom-polyline"),
                points:[
                  sourceLocation,
                  LatLng(locationData?.latitude ?? 0,locationData?.longitude ?? 0),
                  destinationLocation
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
