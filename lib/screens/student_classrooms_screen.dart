import 'dart:async';
import 'dart:math';

import 'package:attend/providers/attendance_provider.dart';
import 'package:attend/utils/constants/api.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import 'package:provider/provider.dart';

import '../providers/student_classrooms.dart';

import '../models/student_classroom.dart';

import '../components/general_app_drawer.dart';

import './join_classroom_screen.dart';
import './student_classroom_details/student_classroom_details_screen.dart';

class StudentClassroomsScreen extends StatefulWidget {
  @override
  _StudentClassroomsScreenState createState() =>
      _StudentClassroomsScreenState();
}

class _StudentClassroomsScreenState extends State<StudentClassroomsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<AttendanceProvider>(context, listen: false);
      await provider.getCurrentLatLng();
      await Provider.of<StudentClassrooms>(context, listen: false)
          .getUserIdAndNameAndEmailAndClassroomsReferences();
      Provider.of<StudentClassrooms>(context, listen: false).fetchClassrooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double sh = screenSize.height;
    double sw = screenSize.width;
    final attendanceProvider = Provider.of<AttendanceProvider>(context);

    return Scaffold(
      drawer: GeneralAppDrawer(
        userType: "student",
      ),
      appBar: AppBar(
        elevation: 1.5,
        title: Text(
          'Attend KWASU',
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.add,
            ),
            onPressed: () {
              if (attendanceProvider.checkDistance()) {
                Navigator.of(context).pushNamed(JoinClassroomScreen.routeName);
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "You can't take attendance at the moment, because you are not in the school premises",
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Selector<StudentClassrooms, bool>(
        selector: (_, instructor) => instructor.classroomsLoading,
        shouldRebuild: (_, __) => true,
        builder: (_, classroomsLoading, __) {
          print(Provider.of<StudentClassrooms>(context, listen: false)
              .classrooms);
          if (classroomsLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            List<Stream<StudentClassroom>> _classrooms =
                Provider.of<StudentClassrooms>(context, listen: false)
                    .classrooms;
            if (_classrooms == null || _classrooms.isEmpty) {
              return Center(
                child: Text('No classrooms yet...'),
              );
            }
            return ListView.separated(
              padding: EdgeInsets.all(0.04 * sw),
              itemCount: _classrooms.length,
              itemBuilder: (_, index) {
                return StreamBuilder<StudentClassroom>(
                  stream: _classrooms[index],
                  builder: (_, snapshot) {
                    if (snapshot.hasData) {
                      StudentClassroom classroom = snapshot.data;
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            StudentClassroomDetailsScreen.routName,
                            arguments: [
                              _classrooms[index],
                              classroom,
                            ],
                          );
                        },
                        child: AspectRatio(
                          aspectRatio: 2.5 / 1.0,
                          child: Container(
                            width: double.maxFinite,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(9.0),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: AssetImage(
                                    'assets/images/classroom_cover.jpg'),
                              ),
                            ),
                            child: Stack(
                              children: <Widget>[
                                Positioned(
                                  top: 18.0,
                                  left: 14.0,
                                  child: Text(
                                    classroom.name,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                Positioned(
                                  bottom: 12.0,
                                  left: 14.0,
                                  child: Text(
                                    '${classroom.instructorName}',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 12.0,
                                  right: 14.0,
                                  width: 200,
                                  child: SelectableText(
                                    '${classroom.instructorEmail}',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                );
              },
              separatorBuilder: (_, index) {
                return const SizedBox(height: 10.0);
              },
            );
          }
        },
      ),
    );
  }
}

// class MapPage extends StatefulWidget {
//   @override
//   _MapPageState createState() => _MapPageState();
// }

// class _MapPageState extends State<MapPage> {
//   CameraPosition _initialLocation = CameraPosition(target: LatLng(0.0, 0.0));
//   GoogleMapController mapController;

//   final Geolocator _geolocator = Geolocator();

//   Position _currentPosition;
//   Position _desPosition;
//   String _currentAddress;

//   final startAddressController = TextEditingController();
//   final destinationAddressController = TextEditingController();

//   String _startAddress = '';
//   String _destinationAddress = '';
//   String _placeDistance;

//   Set<Marker> markers = {};

//   PolylinePoints polylinePoints;
//   Map<PolylineId, Polyline> polylines = {};
//   List<LatLng> polylineCoordinates = [];

//   final _scaffoldKey = GlobalKey<ScaffoldState>();

//   Widget _textField({
//     TextEditingController controller,
//     String label,
//     String hint,
//     String initialValue,
//     double width,
//     Icon prefixIcon,
//     Widget suffixIcon,
//     Function(String) locationCallback,
//   }) {
//     return Container(
//       width: width * 0.8,
//       child: TextField(
//         onChanged: (value) {
//           locationCallback(value);
//         },
//         controller: controller,
//         // initialValue: initialValue,
//         decoration: new InputDecoration(
//           prefixIcon: prefixIcon,
//           suffixIcon: suffixIcon,
//           labelText: label,
//           filled: true,
//           fillColor: Colors.white,
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.all(
//               Radius.circular(10.0),
//             ),
//             borderSide: BorderSide(
//               color: Colors.grey[400],
//               width: 2,
//             ),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.all(
//               Radius.circular(10.0),
//             ),
//             borderSide: BorderSide(
//               color: Colors.blue[300],
//               width: 2,
//             ),
//           ),
//           contentPadding: EdgeInsets.all(15),
//           hintText: hint,
//         ),
//       ),
//     );
//   }

//   // _getCurrentLocation() async {
//   //   await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
//   //       .then((Position position) async {
//   //     setState(() {
//   //       // Store the position in the variable
//   //       _currentPosition = position;

//   //       print('CURRENT POS: $_currentPosition');

//   //       // For moving the camera to current location
//   //       mapController.animateCamera(
//   //         CameraUpdate.newCameraPosition(
//   //           CameraPosition(
//   //             target: LatLng(position.latitude, position.longitude),
//   //             zoom: 18.0,
//   //           ),
//   //         ),
//   //       );
//   //     });
//   //   }).catchError((e) {
//   //     print(e);
//   //   });
//   // }

//   _getAddress() async {
//     try {
//       List<Placemark> p = await placemarkFromCoordinates(
//           _currentPosition.latitude, _currentPosition.longitude);

//       Placemark place = p[0];

//       setState(() {
//         _currentAddress =
//             "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
//         startAddressController.text = _currentAddress;
//         _startAddress = _currentAddress;
//       });
//     } catch (e) {
//       print(e);
//     }
//   }

//   Future<bool> _calculateDistance() async {
//     try {
//       // Retrieving placemarks from addresses
//       // List<Location> startPlacemark = await locationFromAddress(_startAddress);
//       // List<Location> destinationPlacemark =
//       //     await locationFromAddress(_destinationAddress);

//       // double startLatitude = _startAddress == _currentAddress
//       //     ? _currentPosition.latitude
//       //     : startPlacemark[0].latitude;

//       // double startLongitude = _startAddress == _currentAddress
//       //     ? _currentPosition.longitude
//       //     : startPlacemark[0].longitude;

//       // double destinationLatitude = destinationPlacemark[0].latitude;
//       // double destinationLongitude = destinationPlacemark[0].longitude;

//       // String startCoordinatesString = '($startLatitude, $startLongitude)';
//       // String destinationCoordinatesString =
//       //     '($destinationLatitude, $destinationLongitude)';

//       // // Start Location Marker
//       // Marker startMarker = Marker(
//       //   markerId: MarkerId(startCoordinatesString),
//       //   position: LatLng(startLatitude, startLongitude),
//       //   infoWindow: InfoWindow(
//       //     title: 'Start $startCoordinatesString',
//       //     snippet: _startAddress,
//       //   ),
//       //   icon: BitmapDescriptor.defaultMarker,
//       // );

//       // // Destination Location Marker
//       // Marker destinationMarker = Marker(
//       //   markerId: MarkerId(destinationCoordinatesString),
//       //   position: LatLng(8.508, 4.585),
//       //   infoWindow: InfoWindow(
//       //     title: 'Destination $destinationCoordinatesString',
//       //     snippet: _destinationAddress,
//       //   ),
//       //   icon: BitmapDescriptor.defaultMarker,
//       // );

//       // Adding the markers to the list
//       // markers.add(startMarker);
//       // markers.add(destinationMarker);

//       // print(
//       //   'START COORDINATES: ($startLatitude, $startLongitude)',
//       // );
//       // print(
//       //   'DESTINATION COORDINATES: ($destinationLatitude, $destinationLongitude)',
//       // );

//       // // Calculating to check that the position relative
//       // // to the frame, and pan & zoom the camera accordingly.
//       // double miny = (startLatitude <= destinationLatitude)
//       //     ? startLatitude
//       //     : destinationLatitude;
//       // double minx = (startLongitude <= destinationLongitude)
//       //     ? startLongitude
//       //     : destinationLongitude;
//       // double maxy = (startLatitude <= destinationLatitude)
//       //     ? destinationLatitude
//       //     : startLatitude;
//       // double maxx = (startLongitude <= destinationLongitude)
//       //     ? destinationLongitude
//       //     : startLongitude;

//       // double southWestLatitude = miny;
//       // double southWestLongitude = minx;

//       // double northEastLatitude = maxy;
//       // double northEastLongitude = maxx;

//       // // Accommodate the two locations within the
//       // // camera view of the map
//       // mapController.animateCamera(
//       //   CameraUpdate.newLatLngBounds(
//       //     LatLngBounds(
//       //       northeast: LatLng(northEastLatitude, northEastLongitude),
//       //       southwest: LatLng(southWestLatitude, southWestLongitude),
//       //     ),
//       //     100.0,
//       //   ),
//       // );

//       // // Calculating the distance between the start and the end positions
//       // // with a straight path, without considering any route
//       // // double distanceInMeters = await Geolocator.bearingBetween(
//       // //   startLatitude,
//       // //   startLongitude,
//       // //   destinationLatitude,
//       // //   destinationLongitude,
//       // // );

//       // await _createPolylines(startLatitude, startLongitude, destinationLatitude,
//       //     destinationLongitude);

//       double totalDistance = 0.0;

//       // Calculating the total distance by adding the distance
//       // between small segments
//       for (int i = 0; i < polylineCoordinates.length - 1; i++) {
//         totalDistance += _coordinateDistance(
//           polylineCoordinates[i].latitude,
//           polylineCoordinates[i].longitude,
//           polylineCoordinates[i + 1].latitude,
//           polylineCoordinates[i + 1].longitude,
//         );
//       }

//       setState(() {
//         _placeDistance = totalDistance.toStringAsFixed(2);
//         print('DISTANCE: $_placeDistance km');
//       });

//       return true;
//     } catch (e) {
//       print(e);
//     }
//     return false;
//   }

//   double _coordinateDistance(lat1, lon1, lat2, lon2) {
//     var p = 0.017453292519943295;
//     var c = cos;
//     var a = 0.5 -
//         c((lat2 - lat1) * p) / 2 +
//         c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
//     return 12742 * asin(sqrt(a));
//   }

//   // Create the polylines for showing the route between two places
//   _createPolylines(
//     double startLatitude,
//     double startLongitude,
//     double destinationLatitude,
//     double destinationLongitude,
//   ) async {
//     polylinePoints = PolylinePoints();
//     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//       Secrets.API_KEY, // Google Maps API Key
//       PointLatLng(startLatitude, startLongitude),
//       PointLatLng(8.508, 4.585),
//       travelMode: TravelMode.transit,
//     );

//     if (result.points.isNotEmpty) {
//       result.points.forEach((PointLatLng point) {
//         polylineCoordinates.add(LatLng(point.latitude, point.longitude));
//       });
//     }

//     PolylineId id = PolylineId('poly');
//     Polyline polyline = Polyline(
//       polylineId: id,
//       color: Colors.red,
//       points: polylineCoordinates,
//       width: 3,
//     );
//     polylines[id] = polyline;
//   }

//   @override
//   void initState() {
//     super.initState();

//     // setState(() {
//     //   _getCurrentLocation();
//     //   _calculateDistance();
//     // });
//   }

//   @override
//   Widget build(BuildContext context) {
//     var height = MediaQuery.of(context).size.height;
//     var width = MediaQuery.of(context).size.width;
//     final attendanceProvider = Provider.of<AttendanceProvider>(context);
//     return Container(
//       height: height,
//       width: width,
//       child: Scaffold(
//         key: _scaffoldKey,
//         body: Stack(
//           children: <Widget>[
//             // Map View
//             GoogleMap(
//               markers: markers != null ? Set<Marker>.from(markers) : null,
//               initialCameraPosition: _initialLocation,
//               myLocationEnabled: true,
//               myLocationButtonEnabled: false,
//               mapType: MapType.normal,
//               zoomGesturesEnabled: true,
//               zoomControlsEnabled: false,
//               polylines: Set<Polyline>.of(polylines.values),
//               onMapCreated: (GoogleMapController controller) {
//                 mapController = controller;
//               },
//             ),
//             // Show zoom buttons
//             SafeArea(
//               child: Padding(
//                 padding: const EdgeInsets.only(left: 10.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: <Widget>[
//                     ClipOval(
//                       child: Material(
//                         color: Colors.blue[100], // button color
//                         child: InkWell(
//                           splashColor: Colors.blue, // inkwell color
//                           child: SizedBox(
//                             width: 50,
//                             height: 50,
//                             child: Icon(Icons.add),
//                           ),
//                           onTap: () {
//                             mapController.animateCamera(
//                               CameraUpdate.zoomIn(),
//                             );
//                             _calculateDistance();
//                           },
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 20),
//                     ClipOval(
//                       child: Material(
//                         color: Colors.blue[100], // button color
//                         child: InkWell(
//                           splashColor: Colors.blue, // inkwell color
//                           child: SizedBox(
//                             width: 50,
//                             height: 50,
//                             child: Icon(Icons.remove),
//                           ),
//                           onTap: () {
//                             mapController.animateCamera(
//                               CameraUpdate.zoomOut(),
//                             );
//                           },
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//             // Show the place input fields & button for
//             // showing the route
//             // SafeArea(
//             //   child: Align(
//             //     alignment: Alignment.topCenter,
//             //     child: Padding(
//             //       padding: const EdgeInsets.only(top: 10.0),
//             //       child: Container(
//             //         decoration: BoxDecoration(
//             //           color: Colors.white70,
//             //           borderRadius: BorderRadius.all(
//             //             Radius.circular(20.0),
//             //           ),
//             //         ),
//             //         width: width * 0.9,
//             //         child: Padding(
//             //           padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
//             //           child: Column(
//             //             mainAxisSize: MainAxisSize.min,
//             //             children: <Widget>[
//             //               Text(
//             //                 'Places',
//             //                 style: TextStyle(fontSize: 20.0),
//             //               ),
//             //               SizedBox(height: 10),
//             //               _textField(
//             //                   label: 'Start',
//             //                   hint: 'Choose starting point',
//             //                   initialValue: _currentAddress,
//             //                   prefixIcon: Icon(Icons.looks_one),
//             //                   suffixIcon: IconButton(
//             //                     icon: Icon(Icons.my_location),
//             //                     onPressed: () {
//             //                       startAddressController.text = _currentAddress;
//             //                       _startAddress = _currentAddress;
//             //                     },
//             //                   ),
//             //                   controller: startAddressController,
//             //                   width: width,
//             //                   locationCallback: (String value) {
//             //                     setState(() {
//             //                       _startAddress = value;
//             //                     });
//             //                   }),
//             //               SizedBox(height: 10),
//             //               _textField(
//             //                   label: 'Destination',
//             //                   hint: 'Choose destination',
//             //                   initialValue: '',
//             //                   prefixIcon: Icon(Icons.looks_two),
//             //                   controller: destinationAddressController,
//             //                   width: width,
//             //                   locationCallback: (String value) {
//             //                     setState(() {
//             //                       _destinationAddress = value;
//             //                     });
//             //                   }),
//             //               SizedBox(height: 10),
//             // Visibility(
//             //   visible: _placeDistance == null ? false : true,
//             //   child: Text(
//             //     'DISTANCE: $_placeDistance km',
//             //     style: TextStyle(
//             //       fontSize: 16,
//             //       fontWeight: FontWeight.bold,
//             //     ),
//             //   ),
//             // ),
//             //               SizedBox(height: 5),
//             //               RaisedButton(
//             //                 onPressed: (_startAddress != '' &&
//             //                         _destinationAddress != '')
//             //                     ? () async {
//             //                         setState(() {
//             //                           if (markers.isNotEmpty) markers.clear();
//             //                           if (polylines.isNotEmpty)
//             //                             polylines.clear();
//             //                           if (polylineCoordinates.isNotEmpty)
//             //                             polylineCoordinates.clear();
//             //                           _placeDistance = null;
//             //                         });

//             //                         _calculateDistance().then((isCalculated) {
//             //                           if (isCalculated) {
//             //                             _scaffoldKey.currentState.showSnackBar(
//             //                               SnackBar(
//             //                                 content: Text(
//             //                                     'Distance Calculated Sucessfully'),
//             //                               ),
//             //                             );
//             //                           } else {
//             //                             _scaffoldKey.currentState.showSnackBar(
//             //                               SnackBar(
//             //                                 content: Text(
//             //                                     'Error Calculating Distance'),
//             //                               ),
//             //                             );
//             //                           }
//             //                         });
//             //                       }
//             //                     : null,
//             //                 color: Colors.red,
//             //                 shape: RoundedRectangleBorder(
//             //                   borderRadius: BorderRadius.circular(20.0),
//             //                 ),
//             //                 child: Padding(
//             //                   padding: const EdgeInsets.all(8.0),
//             //                   child: Text(
//             //                     'Show Route'.toUpperCase(),
//             //                     style: TextStyle(
//             //                       color: Colors.white,
//             //                       fontSize: 20.0,
//             //                     ),
//             //                   ),
//             //                 ),
//             //               ),
//             //             ],
//             //           ),
//             //         ),
//             //       ),
//             //     ),
//             //   ),
//             // ),
//             // Show current location button
//             SafeArea(
//               child: Align(
//                 alignment: Alignment.bottomRight,
//                 child: Padding(
//                   padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
//                   child: ClipOval(
//                     child: Material(
//                       color: Colors.orange[100], // button color
//                       child: InkWell(
//                         splashColor: Colors.orange, // inkwell color
//                         child: SizedBox(
//                           width: 56,
//                           height: 56,
//                           child: Icon(Icons.my_location),
//                         ),
//                         onTap: () {
//                           mapController.animateCamera(
//                             CameraUpdate.newCameraPosition(
//                               CameraPosition(
//                                 target: LatLng(
//                                   _currentPosition.latitude,
//                                   _currentPosition.longitude,
//                                 ),
//                                 zoom: 18.0,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
