import 'package:UberFlutter/data_handler/DataHandler/appData.dart';
import 'package:UberFlutter/model/address.dart';
import 'package:UberFlutter/request/requestAssistant.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class AssistantMethods {
  static Future<String> searchCoordinateAddress(
      Position position, context) async {
    String placeAddress = "";
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=AIzaSyAXhk1498g3ORPHcP6Wytkouh0Mn28obVo";
    var response = await RequestAssistant.getRequest(url);
    String st1;
    String st2;
    String st3;
    String st4;

    if (response != "Failed") {
      placeAddress = response['results'][0]['formatted_address'];
      st1 = response['results'][0]['address_components'][3]['long_name'];
      st2 = response['results'][0]['address_components'][4]['long_name'];
      st3 = response['results'][0]['address_components'][5]['long_name'];
      st4 = response['results'][0]['address_components'][6]['long_name'];
      // placeAddress = st1 + ", " + st2 + ", " + st3 + ", " + st4;

      Address userAddress = Address();
      userAddress.longitude = position.longitude;
      userAddress.latitude = position.latitude;
      userAddress.placeName = placeAddress;

      Provider.of<AppData>(context, listen: false)
          .updatePickUpLocationAddress(userAddress);
    }
    return placeAddress;
  }
}
