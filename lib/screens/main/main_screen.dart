import 'dart:async';

import 'package:UberFlutter/config/user_config/userConfig.dart';
import 'package:UberFlutter/data_handler/DataHandler/appData.dart';
import 'package:UberFlutter/model/directionDetails.dart';
import 'package:UberFlutter/request/assistantMethods.dart';
import 'package:UberFlutter/screens/search/search_screen.dart';
import 'package:UberFlutter/store/map/map_store.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_database/firebase_database.dart';
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
  double rideContainerRequestHeight = 0;
  DirectionDetails directionDetailsTrip;
  bool drawerOpen = true;
  DatabaseReference rideRequestRef;

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
  }

  Future<void> displayRideDetailsContainer() async {
    await getPlaceDirection();

    setState(() {
      searchContainerHeight = 0;
      rideDetailsContainerHeight = 280;
      rideContainerRequestHeight = 0;
      drawerOpen = false;
      bottomPaddingOfMap = 230;
    });
  }

  void displayRequestRideContainer() {
    setState(() {
      rideContainerRequestHeight = 280;
      rideDetailsContainerHeight = 0;
      drawerOpen = false;
      bottomPaddingOfMap = 230;
    });

    saveRideRequest();
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-19.9604937, -43.9955722),
    tilt: 59.440717697143555,
    zoom: 14.4746,
  );

  resetApp() {
    setState(() {
      searchContainerHeight = 350;
      rideDetailsContainerHeight = 0;

      drawerOpen = true;
      bottomPaddingOfMap = 230;
      rideContainerRequestHeight = 0;
      polyLineSet.clear();
      markersSet.clear();
      circlesSet.clear();
      pLineCoordinates.clear();
    });

    locatePosition();
  }

  @override
  void initState() {
    super.initState();
    AssistantMethods.getCurrentOnlineUserInfo();
  }

  void saveRideRequest() {
    rideRequestRef = FirebaseDatabase.instance.reference().child("RequestRide");
    final pickUp = Provider.of<AppData>(context, listen: false).pickUpLocation;
    final dropOff =
        Provider.of<AppData>(context, listen: false).dropOffLocation;

    Map pickUpMapInfo = {
      'latitude': pickUp.latitude.toString(),
      'longitude': pickUp.longitude.toString()
    };

    Map dropOffMapInfo = {
      'latitude': dropOff.latitude.toString(),
      'longitude': dropOff.longitude.toString()
    };

    Map rideMapInfo = {
      'driver_id': 'waiting',
      'payment_method': 'credit_card',
      'pickup': pickUpMapInfo,
      'dropoff': dropOffMapInfo,
      'createdAt': DateTime.now().toString(),
      'rider_name': userCurrent.name,
      'rider_phone': userCurrent.phone,
      'rider_email': userCurrent.email,
      'pickup_address': pickUp.placeName,
      'dropoff_address': dropOff.placeName
    };

    rideRequestRef.push().set(rideMapInfo);
  }

  void cancelRideRequest() {
    rideRequestRef.remove();
  }

  @override
  Widget build(BuildContext context) {
    final addressDataUser = Provider.of<AppData>(context).pickUpLocation;
    final addressDropOffDataUser =
        Provider.of<AppData>(context).dropOffLocation;
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
              InkWell(
                splashColor: Colors.red.shade400,
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
                child: ListTile(
                  leading: Icon(Icons.history),
                  title: Text('History', style: TextStyle(fontSize: 16)),
                ),
              ),

              Divider(indent: 8, endIndent: 8),

              InkWell(
                splashColor: Colors.green.shade400,
                onTap: () {},
                child: ListTile(
                  leading: Icon(FontAwesomeIcons.personBooth),
                  title: Text('Profile', style: TextStyle(fontSize: 16)),
                ),
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
              mapType: MapType.normal,
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

                mapStore.setBottomPadding(bottomPaddingOfMap);

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
                if (drawerOpen)
                  scaffoldKey.currentState.openDrawer();
                else
                  resetApp();
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
                  child: Icon((drawerOpen) ? Icons.menu : Icons.close,
                      color: Colors.black),
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
              duration: Duration(milliseconds: 500),
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
                      InkWell(
                        splashColor: Colors.red,
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
                        child: Row(
                          children: [
                            Icon(Icons.work, color: Colors.grey),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    addressDropOffDataUser != null
                                        ? addressDropOffDataUser
                                            .placeFormattedAddress
                                        : 'Add Office',
                                    softWrap: true,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Your Office address.',
                                    style: TextStyle(
                                        color: Colors.grey[400], fontSize: 12),
                                    softWrap: true,
                                    maxLines: 2,
                                    overflow: TextOverflow.clip,
                                  ),
                                ],
                              ),
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
              duration: Duration(milliseconds: 500),
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
                                    directionDetailsTrip != null
                                        ? directionDetailsTrip.distanceText
                                        : '10km',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Brand-Bold',
                                      color: Colors.black45,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Race cost',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Brand-Bold',
                                      color: Colors.black54,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    directionDetailsTrip != null
                                        ? '\$${AssistantMethods.calculateFares(directionDetailsTrip).toStringAsFixed(2)}'
                                        : '\$5,99',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Brand-Bold',
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ))
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
                            displayRequestRideContainer();
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

          Positioned(
            left: 0,
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16)),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    spreadRadius: 0.5,
                    blurRadius: 16,
                    color: Colors.black54,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              height: rideContainerRequestHeight,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ColorizeAnimatedTextKit(
                        onTap: () {},
                        text: [
                          "Requesting a Ride",
                          "Please wait ...",
                          "Finding a Driver",
                        ],
                        textStyle:
                            TextStyle(fontSize: 55.0, fontFamily: "Signatra"),
                        colors: [
                          Colors.green,
                          Colors.yellow,
                          Colors.orange,
                          Colors.red,
                          Colors.pink,
                          Colors.purple,
                        ],
                        textAlign: TextAlign.center,
                        alignment: AlignmentDirectional.topStart,
                      ),
                    ),
                    Divider(),
                    const SizedBox(height: 24),
                    InkWell(
                      splashColor: Colors.orange,
                      onTap: () {
                        cancelRideRequest();
                        resetApp();
                      },
                      child: Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(width: 2, color: Colors.grey[300]),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      child: Text(
                        'Cancel Ride',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                    )
                  ],
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

    //trip calculate
    directionDetailsTrip = details;

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
            InfoWindow(title: finalPos.placeName, snippet: 'Dropoff Location'));

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
  }
}
