import 'package:flutter/material.dart';
import 'package:intrst/models/interest.dart';
import 'package:provider/provider.dart';

class InterestListCards extends StatelessWidget {
  final List<Interest> userInterests;

  InterestListCards({
     required this.userInterests,
  });

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Container(
      alignment: Alignment.topCenter,
      width: deviceSize.width > 600 ? deviceSize.width * 0.3 : double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Container(),
            // child: AddInterest(),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: AddUserInterestsOrNewInterest(),
          // ),
          Expanded(
            child: ListView.builder(
              itemCount: userInterests.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(userInterests[index].interest),
                    trailing: IconButton(icon: Icon(Icons.delete),
                        onPressed: (){
                          // Provider.of<Auth>(context, listen: false)
                          //     .removeUserInterest(userInterests[index].id);
                        }),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}