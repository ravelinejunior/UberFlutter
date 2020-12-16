import 'package:UberFlutter/data_handler/DataHandler/appData.dart';
import 'package:UberFlutter/model/address.dart';
import 'package:UberFlutter/model/placePredictions.dart';
import 'package:UberFlutter/request/requestAssistant.dart';
import 'package:UberFlutter/screens/search/components/predictionTile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/map_config/configMaps.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final pickController = TextEditingController();

  final dropController = TextEditingController();

  List<PlacePredictions> predictionList = [];

  @override
  Widget build(BuildContext context) {
    String placeAddress =
        Provider.of<AppData>(context).pickUpLocation.placeName ?? "";
    pickController.text = placeAddress;

    return Scaffold(
      appBar: AppBar(
        title: Text('Search Address'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              color: Colors.white,
              child: Container(
                height: MediaQuery.of(context).size.height / 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Image.asset('images/pickicon.png',
                                height: 32, width: 32),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: TextField(
                                    controller: pickController,
                                    cursorColor: Colors.black,
                                    decoration: InputDecoration(
                                      hintText:
                                          placeAddress ?? "Pickup Location",
                                      filled: true,
                                      isDense: true,
                                      hintStyle:
                                          TextStyle(color: Colors.black38),
                                      border: OutlineInputBorder(
                                        gapPadding: 16,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(16),
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.all(16),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          height: 16,
                          thickness: 1,
                          color: Colors.black45,
                        ),
                        Row(
                          children: [
                            Image.asset('images/desticon.png',
                                height: 32, width: 32),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: TextField(
                                    onChanged: (value) =>
                                        findPlace(dropController.text),
                                    controller: dropController,
                                    decoration: InputDecoration(
                                      hintStyle:
                                          TextStyle(color: Colors.black38),
                                      hintText: "Where to",
                                      filled: true,
                                      isDense: true,
                                      border: OutlineInputBorder(
                                        gapPadding: 16,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(16),
                                        ),
                                        borderSide: BorderSide(
                                          color: Colors.orange,
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.all(16),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),
            //tile for predicitions
            predictionList.length > 0
                ? Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListView.separated(
                      itemBuilder: (context, index) => PredictionTile(
                          placePrediction: predictionList[index]),
                      separatorBuilder: (context, index) => Divider(),
                      itemCount: predictionList.length,
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Future<void> findPlace(String placeName) async {
    if (placeName.length > 1) {
      String autoComplete =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKey_2&sessiontoken=1234567890&components=country:BR";
      String autoCompleteWorld =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKey_2&sessiontoken=1234567890";
      var response = await RequestAssistant.getRequest(autoComplete);

      if (response == "Failed") return;

      if (response['status'] == "OK") {
        final predictions = response['predictions'];

        final placesList = (predictions as List)
            .map((e) => PlacePredictions.fromJson(e))
            .toList();

        setState(() {
          predictionList = placesList;
        });
      }
    }
  }
}
