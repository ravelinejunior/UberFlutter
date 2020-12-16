import 'package:UberFlutter/model/address.dart';
import 'package:flutter/material.dart';

class AppData extends ChangeNotifier {
  Address pickUpLocation;
  Address dropOffLocation;

  void updatePickUpLocationAddress(Address pickUpAddress) {
    pickUpLocation = pickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Address dropAddress) {
    dropOffLocation = dropAddress;
    notifyListeners();
  }
}
