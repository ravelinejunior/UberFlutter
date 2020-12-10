import 'dart:async';

import 'package:UberFlutter/request/assistantMethods.dart';
import 'package:UberFlutter/store/map/map_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MainScreen extends StatefulWidget {
  static const String idScreen = "main";

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController googleMapController;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Position currentPosition;
  final geolocator = Geolocator();
  final mapStore = MapStore();

  //position
  Future<void> locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    LatLng latLngPosition = LatLng(position.latitude, position.longitude);
    final cameraPosition = CameraPosition(target: latLngPosition, zoom: 18);
    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String address = await AssistantMethods.searchCoordinateAddress(position);
    print("My address: $address");
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-19.9604937, -43.9955722),
    tilt: 59.440717697143555,
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
    bearing: 192.8334901395799,
    target: LatLng(37.43296265331129, -122.08832357078792),
    tilt: 59.440717697143555,
    zoom: 19.151926040649414,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Main Screen'),
        centerTitle: true,
      ),
      drawer: Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width / 1.5,
        child: Drawer(
          child: ListView(
            children: [
              //Drawer header
              Container(
                height: MediaQuery.of(context).size.height / 5,
                decoration: BoxDecoration(color: Colors.white),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Image.asset("images/user_icon.png",
                          height: 65, width: 65),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Profile Name',
                          style:
                              TextStyle(fontSize: 16, fontFamily: "Brand-Bold"),
                        ),
                        const SizedBox(width: 8),
                        Text('Visit Profile'),
                      ],
                    ),
                  ],
                ),
              ),

              //buttons of drawer
              const SizedBox(height: 8),
              //Drawer Body Controllers
              ListTile(
                leading: Icon(Icons.history),
                title: Text('History', style: TextStyle(fontSize: 16)),
              ),
              Divider(indent: 8, endIndent: 8),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Profile', style: TextStyle(fontSize: 16)),
              ),
              Divider(indent: 8, endIndent: 8),
              ListTile(
                leading: Icon(Icons.monetization_on),
                title: Text('Discounts', style: TextStyle(fontSize: 16)),
              ),
              Divider(indent: 8, endIndent: 8),
              ListTile(
                leading: Icon(Icons.info),
                title: Text('About', style: TextStyle(fontSize: 16)),
              ),
              Divider(indent: 8, endIndent: 8),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Observer(builder: (_) {
            return GoogleMap(
              padding: EdgeInsets.only(bottom: mapStore.paddingBottom),
              initialCameraPosition: _kGooglePlex,
              mapType: MapType.satellite,
              buildingsEnabled: true,
              compassEnabled: true,
              zoomGesturesEnabled: true,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              zoomControlsEnabled: true,
              onMapCreated: (controller) {
                _controller.complete(controller);
                googleMapController = controller;

                mapStore.setBottomPadding(400);

                //get Current position
                locatePosition();
              },
              trafficEnabled: true,
              rotateGesturesEnabled: true,
              scrollGesturesEnabled: true,
            );
          }),

          //hamburguerButton for Drawer
          Positioned(
            child: InkWell(
              splashColor: Colors.orange,
              onTap: () {
                scaffoldKey.currentState.openDrawer();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 6,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    )
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.menu),
                  radius: 20,
                ),
              ),
            ),
            top: 45,
            left: 22,
          ),

          Positioned(
            child: Container(
              margin: const EdgeInsets.all(16),
              height: MediaQuery.of(context).size.height / 2.5,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 16,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      'Hi there, ',
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      'Where to',
                      style: TextStyle(fontSize: 20, fontFamily: "Brand-Bold"),
                    ),
                    Divider(height: 24),
                    Container(
                      height: MediaQuery.of(context).size.height / 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 6,
                            spreadRadius: 0.5,
                            offset: Offset(0.7, 0.7),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 4),
                          Icon(Icons.search, color: Colors.blueAccent),
                          const SizedBox(height: 8, width: 8),
                          Text('Search Drop off'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Icon(Icons.home, color: Colors.grey),
                        const SizedBox(width: 12),
                        Column(
                          children: [
                            Text('Add Home'),
                            const SizedBox(height: 4),
                            Text(
                              'Your living home address.',
                              style: TextStyle(
                                  color: Colors.grey[400], fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(height: 24),
                    Row(
                      children: [
                        Icon(Icons.work, color: Colors.grey),
                        const SizedBox(width: 12),
                        Column(
                          children: [
                            Text('Add Work'),
                            const SizedBox(height: 4),
                            Text(
                              'Your Office address.',
                              style: TextStyle(
                                  color: Colors.grey[400], fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
          )
        ],
      ),
    );
  }
}
