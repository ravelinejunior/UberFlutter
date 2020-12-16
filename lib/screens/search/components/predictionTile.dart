import 'package:UberFlutter/config/map_config/configMaps.dart';
import 'package:UberFlutter/data_handler/DataHandler/appData.dart';
import 'package:UberFlutter/model/address.dart';
import 'package:UberFlutter/model/placePredictions.dart';
import 'package:UberFlutter/request/requestAssistant.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PredictionTile extends StatelessWidget {
  final PlacePredictions placePrediction;

  PredictionTile({Key key, this.placePrediction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      padding: const EdgeInsets.all(0),
      onPressed: () =>
          getPlaceAddressDetails(placePrediction.place_id, context),
      child: Container(
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.add_location, color: Colors.red),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        placePrediction.main_text,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        placePrediction.secondary_text,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
          ],
        ),
      ),
    );
  }

  Future<void> getPlaceAddressDetails(
      String placeId, BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Container(
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.orangeAccent),
                ),
              ),
              Text('Loading the data ... '),
            ],
          ),
        ),
      ),
    );

    String placeDetailUrl =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey_2";

    Future.delayed(Duration(seconds: 2))
        .then((value) => Navigator.of(context).pop());

    final response = await RequestAssistant.getRequest(placeDetailUrl);
    if (response == "Failed") return;

    if (response['status'] == 'OK') {
      Address address = Address();
      address.placeName = response['result']['name'];
      address.placeId = placeId;
      address.latitude = response['result']['geometry']['location']['lat'];
      address.latitude = response['result']['geometry']['location']['lng'];

      Provider.of<AppData>(context, listen: false)
          .updateDropOffLocationAddress(address);

      print("Location drop ${address.placeName}");
    }
  }
}
