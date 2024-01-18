import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intrst/screens/chat.dart';
import 'package:intrst/widgets/filter_or_add_interests.dart';
import 'package:intrst/widgets/human_interest_list.dart';
import 'package:intrst/widgets/interest_chips.dart';
import '../models/human.dart';
import '../models/interest.dart';
import '../models/position.dart';
import '../models/marker_information.dart';
import '../widgets/app_drawer.dart';
import '../providers/humans.dart';
//Authentication
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth.dart';
//Bare map function related
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:typed_data';
import 'package:maps_toolkit/maps_toolkit.dart'
    as mtk; //Maps calculate distance
import 'package:flutter/services.dart' show PlatformException, rootBundle;
import 'dart:ui' as ui;
//Location permissions and functions
import 'package:location/location.dart';

import 'my_interests_ordered.dart';
//Chat related functions
// import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
// import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:intrst/markers/name_display.dart' as nd;

class MapScreen extends StatefulWidget {
  const MapScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;
  Human? _currentHuman;
  List<Map<String, dynamic>> interests = [];
  List<Interest> interestList = [];
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  Location location = Location();
  late CameraPosition _newPosition;
  var _isLoading = true;
  //Marker related start
  Set<Marker> markers = {};
  List humans = [];
  List _filteredHumans = [];
  List<MarkerInformation> markerInformationList = [];
  MarkerInformation selectedMarker = MarkerInformation(
    email: '',
    name: '',
    interestList: [],
  );
  //end
  String _mapStyle = '';
  final Completer<GoogleMapController> _controller = Completer();

  @override
  initState() {
    rootBundle.loadString('assets/mapstyle.txt').then((string) {
      _mapStyle = string;
      if (humans.isNotEmpty) {
        // assuming humans data is also loaded by this time
        setState(() {
          _isLoading = false;
        });
      }
    });

    Provider.of<Humans>(context, listen: false).getHumansStream().then((_) {
      if (_mapStyle.isNotEmpty) {
        // check if map style is also loaded
        setState(() {
          _isLoading = false;
        });
      }
    });

    getCurrentUser();
    _getLocationServiceAndPermission();
    getInterestsStream();
    getCurrentHumanStream();
    super.initState();
    getHumansStream();
  }

  void _setHumanFilterList(List<Interest> filterInterests) {
    _filteredHumans.clear();
    var displayHumans = Provider.of<Humans>(context, listen: false).humans;
    setState(() {
      if (filterInterests.isNotEmpty) {
        for (var human in displayHumans) {
          human.interests.forEach((humanInterest) {
            for (var interest in filterInterests) {
              if (interest.id == humanInterest.id) {
                _filteredHumans.add(human);
              } else {
                // print('IDs are not the same mate!');
              }
            }
          });
        }
      } else {
        _filteredHumans = displayHumans;
      }
    });
    _setHumanMarkers(_filteredHumans, _currentHuman);
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (error) {
      // print(error);
    }
  }

  Future<void> getCurrentHumanStream() async {
    if (loggedInUser != null) {
      var humanSnapshot =
          await _firestore.collection('humans').doc(loggedInUser!.uid).get();
      if (humanSnapshot.exists) {
        Map<String, dynamic>? data = humanSnapshot.data();

        List<dynamic> interestsListData = [];
        interestsListData.addAll(data!['interests']);
        List<Interest> interestList = [];
        if (interestsListData.isNotEmpty) {
          interestsListData.forEach((e) {
            // This gets the Timestamp object from e['createdAt']
            Timestamp? timestamp = e['createdAt'] as Timestamp?;

            // Convert the Timestamp to DateTime, or use DateTime.now() if it's null
            DateTime? createdAt = timestamp?.toDate() ?? DateTime.now();

            interestList.add(Interest(
                interest: e['name'],
                id: e['id'],
                description: e['description'],
                website: e['website'] ?? '',
                createdAt: createdAt));
          });
        }

        setState(() {
          _currentHuman = Human(
              email: data['email'],
              name: data['name'],
              position: Position(
                latitude: data['position']['latitude'],
                longitude: data['position']['longitude'],
              ),
              interests: interestList);
        });
      }
    } else {
      return;
    }
  }

  Future<void> getInterestsStream() async {
    await for (var snapshot in _firestore.collection('interests').snapshots()) {
      for (var interest in snapshot.docs) {
        interests.add(interest.data());
      }
    }
  }

  Future<void> getHumansStream() async {
    await for (var snapshot in _firestore.collection('humans').snapshots()) {
      for (var human in snapshot.docs) {
        humans.add(human.data());
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _setHumanMarkers(humans, currentHuman) async {
    final Uint8List humanIcon =
        await getBytesFromAsset('assets/images/icons/poi.png', 100);
    final Uint8List userIcon =
        await getBytesFromAsset('assets/images/icons/2tws_45w.png', 100);
    final name_display = nd.NameDisplay();
    markers = {};
    for (var human in humans) {
      Marker nameMarker = await name_display.createMarker(
          human.position.latitude, human.position.longitude, human.name);
      setState(() {
        markers.add(nameMarker);
      });
    }
    for (var human in humans) {
      // print('PLACING HUMAN ON MARKER: ${human.name} & ${human.email} & ${human.position.latitude}');
      setState(() {
        markers.add(Marker(
          markerId: MarkerId(human.email),
          //infoWindow: InfoWindow(title: "Mark", snippet: "Mark"),
          position: LatLng(human.position.latitude, human.position.longitude),
          icon: (currentHuman != null && currentHuman!.email == human.email)
              ? BitmapDescriptor.fromBytes(userIcon)
              : BitmapDescriptor.fromBytes(humanIcon),
          draggable:
              (currentHuman != null && currentHuman!.email == human.email)
                  ? true
                  : false,
          onDragEnd:
              (currentHuman != null && currentHuman!.email == human.email)
                  ? (LatLng location) {
                      _savePositionAndGoThere(loggedInUser, location);
                    }
                  : null,
          onTap: () {
            List<Interest> selectedMarkerInterests = [];
            human.interests.forEach((interest) {
              selectedMarkerInterests.add(interest);
            });
            /*int distanceFromMe = 0;

            if (currentHuman != null) {
                distanceFromMe = (mtk.SphericalUtil.computeDistanceBetween(
                            mtk.LatLng(human.position.latitude,
                                human.position.longitude),
                            mtk.LatLng(currentHuman.position.latitude,
                                currentHuman.position.longitude)) /
                        1000.0)
                    .round();
              }*/
            if (currentHuman != null && currentHuman!.email == human.email) {
              Navigator.of(context)
                  .pushNamed(MyInterestsScreenOrdered.routeName);
            } else {
              selectedMarker = MarkerInformation(
                  email: human.email,
                  name: human.name,
                  interestList: selectedMarkerInterests);
              //           showCustomDialog(context, selectedMarker, distanceFromMe);
              showCustomDialog(context, selectedMarker);
            }
          },
        ));
      });
    }
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<void> _getLocationServiceAndPermission() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  Future<void> _gotoCurrentUserLocation() async {
    final GoogleMapController controller = await _controller.future;
    final locationData = await location.getLocation();
    _newPosition = CameraPosition(
        target: LatLng(locationData.latitude!, locationData.longitude!),
        zoom: 12);
    controller.animateCamera(CameraUpdate.newCameraPosition(_newPosition));
  }

  static final CameraPosition _initialPosition = CameraPosition(
    target: LatLng(47.77258384047156, -122.00515984935076),
    zoom: 6.4746,
  );

  Future<void> showCustomDialog(ctx, info) {
    //Future<void> showCustomDialog(ctx, info, distance) {
    return showDialog(
        context: ctx,
        builder: (ctx) {
          return StatefulBuilder(builder: (ctx, setState) {
            final deviceSize = MediaQuery.of(ctx).size;
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: deviceSize.width > 600
                    ? deviceSize.width * 0.6
                    : double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      (loggedInUser == null)
                          ? Container()
                          : Text(
                              // "${info.name}, $distance Km",
                              "${info.name}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                      const SizedBox(height: 12),
                      Container(
                          height: 36,
                          // child: InterestChips(selectedMarkerInfo: selectedMarker,)
                          child: InterestChips(
                            selectedMarkerInfo: info,
                          )),
                      const SizedBox(height: 6),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          loggedInUser == null
                              ? Container()
                              : TextButton.icon(
                                  onPressed: () {
                                    loggedInUser == null
                                        ? Navigator.of(context)
                                            .pushReplacementNamed(
                                            AuthScreen.routeName,
                                          )
                                        : Navigator.push(
                                            context,
                                            MaterialPageRoute<void>(
                                                builder: (BuildContext
                                                        context) =>
                                                    ChatScreen(
                                                      friendId:
                                                          selectedMarker.email,
                                                      friendName:
                                                          selectedMarker.name,
                                                      currentHumanId:
                                                          _currentHuman!.email,
                                                      currentHumanName:
                                                          _currentHuman!.name,
                                                    ),
                                                fullscreenDialog: true));
                                  },
                                  icon: const Icon(Icons.chat),
                                  label: const Text('Chat')),
                          TextButton.icon(
                              onPressed: () {
                                loggedInUser == null
                                    ? Navigator.of(context)
                                        .pushReplacementNamed(
                                        AuthScreen.routeName,
                                      )
                                    : Navigator.push(
                                        context,
                                        MaterialPageRoute<void>(
                                            builder: (BuildContext context) =>
                                                FullScreenDialog(
                                                  selectedMarkerInfo:
                                                      selectedMarker,
                                                ),
                                            fullscreenDialog: true));
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('List all interests'))
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  Future<void> _savePositionAndGoThere(loggedInUser, position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(
        position.latitude,
        position.longitude,
      ),
      zoom: 6,
    )));

    try {
      _firestore.collection('humans').doc(loggedInUser.uid).update({
        'position': {
          'longitude': position.longitude,
          'latitude': position.latitude,
        },
      });
    } on PlatformException catch (error) {
      //Handle exception of type SomeException
    } catch (error) {
      //Handle all other exceptions
    }
    getCurrentHumanStream();
  }

  @override
  Widget build(BuildContext context) {
    final providedHumans = Provider.of<Humans>(context).humans;

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: FilterOrAddInterests(
              filterHumans: _setHumanFilterList,
              user: loggedInUser,
              userInterests: _currentHuman?.interests),
        ),
      ),
      drawer: AppDrawer(
        loggedInUser: loggedInUser,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              markers: markers,
              mapType: MapType.normal,
              initialCameraPosition: (_currentHuman == null)
                  ? _initialPosition
                  : CameraPosition(
                      target: LatLng(_currentHuman!.position.latitude,
                          _currentHuman!.position.longitude),
                      zoom: 14.151926040649414),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                controller.setMapStyle(_mapStyle);
                // _setHumanMarkers(humans, _currentHuman);
                _setHumanMarkers(providedHumans, _currentHuman);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        // onPressed: getCurrentHumanStream,
        onPressed: () {
          if (_permissionGranted == PermissionStatus.granted) {
            _gotoCurrentUserLocation();
          } else {
            _getLocationServiceAndPermission();
          }
        },
        // backgroundColor: Colors.white,
        icon: const Icon(Icons.my_location),
        label: const Text('My location'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}

class FullScreenDialog extends StatelessWidget {
  final MarkerInformation selectedMarkerInfo;

  const FullScreenDialog({Key? key, required this.selectedMarkerInfo})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${selectedMarkerInfo.name}\'s Interests'),
      ),
      body: HumanInterestList(humanInfo: selectedMarkerInfo),
    );
  }
}
