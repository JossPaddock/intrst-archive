import 'package:flutter/material.dart';
import 'package:intrst/models/marker_information.dart';
import '../models/interest.dart';
import '../helpers/randomize.dart';
import '../models/expansion_panel_item.dart';


class HumanInterestList extends StatelessWidget {
  final MarkerInformation humanInfo;

  const HumanInterestList({
    Key? key,
    required this.humanInfo
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Item> items = [];
    for (var interest in humanInfo.interestList) {
      items.add(Item(
          header: interest.interest,
          body: interest.description),
      );
    }
    return SingleChildScrollView(
      child: ExpansionPanelList.radio(
        children: items.map((item) => ExpansionPanelRadio(
          value: generateRandomNumber(),
          headerBuilder: (_, isExpanded) => ListTile(
            title: Text(
              item.header,
              style: const TextStyle(
                  fontWeight: FontWeight.bold
              ),
            ),
          ),
          body: ListTile(
            title: Text(item.body,),
          ),
        )).toList(),
      ),
    );
  }
}