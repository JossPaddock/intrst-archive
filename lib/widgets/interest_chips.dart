import 'package:flutter/material.dart';
import 'package:intrst/models/marker_information.dart';
import 'package:url_launcher/url_launcher.dart';

class InterestChips extends StatelessWidget {
  final MarkerInformation selectedMarkerInfo;

  const InterestChips({
    Key? key,
    required this.selectedMarkerInfo
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemCount: (selectedMarkerInfo.interestList.length >= 5)
          ? 5
          : selectedMarkerInfo.interestList.length,
      itemBuilder: (context, index) {
        var website = selectedMarkerInfo.interestList[index].website;

        if (Uri.parse(website).isAbsolute) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () => launchUrl(Uri.parse(website)),
              child: Chip(
                backgroundColor: Colors.blueAccent,
                label: Row(
                  children: [
                    Icon(Icons.link),
                    Text(selectedMarkerInfo.interestList[index].interest),
                  ],
                ),
              ),
            ),
          );
        } else {
          print('NO WEBSITE TO SPEAK OF!');
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Chip(
              label: Text(selectedMarkerInfo.interestList[index].interest),
            ),
          );
        }
      },
    );
  }
}
