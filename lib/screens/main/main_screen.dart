import 'dart:async';

import 'package:UberFlutter/data_handler/DataHandler/appData.dart';
import 'package:UberFlutter/request/assistantMethods.dart';
import 'package:UberFlutter/screens/search/search_screen.dart';
import 'package:UberFlutter/store/map/map_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  static const String idScreen = "main";

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController googleMapController;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Position currentPosition;
  final geolocator = Geolocator();
  final mapStore = MapStore();
  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polyLineSet = {};
  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};
  double rideDetailsContainerHeight = 0;
  double searchContainerHeight = 350.0;
  double bottomPaddingOfMap = 0;

  //position
  Future<void> locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    LatLng latLngPosition = LatLng(position.latitude, position.longitude);
    final cameraPosition = CameraPosition(target: latLngPosition, zoom: 18);
    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String address =
        await AssistantMethods.searchCoordinateAddress(position, context);
    print("My address: $address");
  }

  Future<void> displayRideDetailsContainer() async {
    await getPlaceDirection();

    setState(() {
      searchContainerHeight = 0;
      rideDetailsContainerHeight = 280;
    });
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-19.9604937, -43.9955722),
    tilt: 59.440717697143555,
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    final addressDataUser = Provider.of<AppData>(context).pickUpLocation;
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
              polylines: polyLineSet,
              circles: circlesSet,
              markers: markersSet,
              zoomControlsEnabled: true,
              onMapCreated: (controller) {
                _controller.complete(controller);
                googleMapController = controller;

                mapStore.setBottomPadding(350);

                //get Current position
                locatePosition();
              },
              trafficEnabled: true,
              indoorViewEnabled: true,
              tiltGesturesEnabled: true,
              mapToolbarEnabled: true,
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
            child: AnimatedSize(
              vsync: this,
              curve: Curves.bounceIn,
              duration: Duration(milliseconds: 160),
              child: Container(
                height: searchContainerHeight,
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
                        style:
                            TextStyle(fontSize: 20, fontFamily: "Brand-Bold"),
                      ),
                      Divider(height: 24),
                      InkWell(
                        onTap: () async {
                          var response = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchScreen(),
                            ),
                          );

                          if (response == 'obtainDirection')
                            displayRideDetailsContainer();
                        },
                        splashColor: Colors.orange.withAlpha(200),
                        child: Container(
                          height: MediaQuery.of(context).size.height / 17,
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
                              Text('Search DropOff'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Icon(Icons.home, color: Colors.grey),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              children: [
                                Text(addressDataUser != null
                                    ? addressDataUser.placeName
                                    : 'Add Home'),
                                const SizedBox(height: 4),
                                Text(
                                  'Your living home address.',
                                  style: TextStyle(
                                      color: Colors.grey[400], fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Divider(
                        height: 16,
                        color: Colors.black38,
                        thickness: 0.5,
                      ),
                      Expanded(
                        child: Row(
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSize(
              vsync: this,
              curve: Curves.bounceIn,
              duration: Duration(milliseconds: 160),
              child: Container(
                clipBehavior: Clip.antiAlias,
                height: rideDetailsContainerHeight,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16)),
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
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: double.infinity,
                        color: Colors.deepOrangeAccent.withAlpha(150),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Image.asset('images/taxi.png',
                                  height: 70, width: 80),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Car',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontFamily: 'Brand-Bold',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '10 Km',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Brand-Bold',
                                      color: Colors.black45,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.moneyCheckAlt,
                              size: 18,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 16),
                            Text('Payment'),
                            const SizedBox(width: 6),
                            Icon(Icons.keyboard_arrow_down,
                                color: Colors.black54, size: 16),
                          ],
                        ),
                      ),
                      Divider(),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: RaisedButton.icon(
                          elevation: 5,
                          color: Colors.deepOrangeAccent,
                          shape: StadiumBorder(),
                          splashColor: Colors.amber,
                          onPressed: () {
                            print("Clicked");
                          },
                          icon: Icon(
                            FontAwesomeIcons.carAlt,
                            color: Colors.black87,
                          ),
                          label: Padding(
                            padding: const EdgeInsets.all(17.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Request',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'Brand-Bold',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getPlaceDirection() async {
    final initialPos =
        Provider.of<AppData>(context, listen: false).pickUpLocation;
    final finalPos =
        Provider.of<AppData>(context, listen: false).dropOffLocation;

    final pickUpLatLng = LatLng(initialPos.latitude, initialPos.longitude);
    final dropOffLatLng = LatLng(finalPos.latitude, finalPos.longitude);

    scaffoldKey.currentState.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Container(
          height: 170,
          child: Column(
            children: [
              Center(
                child: Icon(Icons.location_searching,
                    color: Colors.deepOrangeAccent, size: 56),
              ),
              Divider(
                height: 24,
                thickness: 2,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.redAccent),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Setting your Dropoff Location ... ',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    var details = await AssistantMethods.obtainPlaceDirectionDetails(
        pickUpLatLng, dropOffLatLng);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolylineResults =
        polylinePoints.decodePolyline(details.encodedPoints);

    pLineCoordinates.clear();

    if (decodedPolylineResults.isNotEmpty) {
      decodedPolylineResults.forEach((PointLatLng pointLatLng) {
        pLineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polyLineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.pink,
        polylineId: PolylineId('PolylineID'),
        jointType: JointType.round,
        points: pLineCoordinates,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polyLineSet.add(polyline);
    });

    LatLngBounds latLngBounds;
    if (pickUpLatLng.latitude > dropOffLatLng.latitude &&
        pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
    } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
          northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude));
    } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
          northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude));
    } else {
      latLngBounds =
          LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
    }

    googleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker pickUpLocMarker = Marker(
        position: pickUpLatLng,
        markerId: MarkerId('pickUpId'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        infoWindow:
            InfoWindow(title: initialPos.placeName, snippet: 'My Location'));

    Marker dropOffLocMarker = Marker(
        position: dropOffLatLng,
        markerId: MarkerId('dropOffId'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow:
            InfoWindow(title: finalPos.placeName, snippet: 'DropOff Location'));

    setState(() {
      markersSet.add(pickUpLocMarker);
      markersSet.add(dropOffLocMarker);
    });

    Circle pickUpCircle = Circle(
        fillColor: Colors.blue,
        center: pickUpLatLng,
        radius: 16,
        strokeWidth: 4,
        strokeColor: Colors.blueAccent,
        circleId: CircleId('pickUpId'));

    Circle dropOffCircle = Circle(
        fillColor: Colors.red,
        center: pickUpLatLng,
        radius: 16,
        strokeWidth: 4,
        strokeColor: Colors.redAccent,
        circleId: CircleId('dropOffId'));

    setState(() {
      circlesSet.add(pickUpCircle);
      circlesSet.add(dropOffCircle);
    });
    print("Encoded points \n${details.encodedPoints}");
  }
}
