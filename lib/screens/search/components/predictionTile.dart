import 'package:UberFlutter/model/placePredictions.dart';
import 'package:flutter/material.dart';

class PredictionTile extends StatelessWidget {
  final PlacePredictions placePrediction;

  PredictionTile({Key key, this.placePrediction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        Row(
          children: [
            Icon(Icons.add_location_alt, color: Colors.red),
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
    ));
  }
}
