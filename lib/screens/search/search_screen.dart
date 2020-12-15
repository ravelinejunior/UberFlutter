import 'package:UberFlutter/data_handler/DataHandler/appData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatelessWidget {
  final pickController = TextEditingController();
  final dropController = TextEditingController();
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
      body: Column(
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
                                    hintText: placeAddress ?? "Pickup Location",
                                    filled: true,
                                    isDense: true,
                                    hintStyle: TextStyle(color: Colors.black38),
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
                                  controller: dropController,
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(color: Colors.black38),
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
        ],
      ),
    );
  }
}
