// import 'dart:convert';
// import 'package:app_settings/app_settings.dart';
// import 'package:flutter/gestures.dart';
// import 'package:geocoding/geocoding.dart' as Geocoding;
// import 'package:SellShip/screens/addsubcategory.dart';
// import 'package:alphabet_list_scroll_view/alphabet_list_scroll_view.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_feather_icons/flutter_feather_icons.dart';
//
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:location/location.dart' as Location;
// import 'package:flutter/material.dart';
// import 'package:shimmer/shimmer.dart';
//
// class AddLocation extends StatefulWidget {
//   _AddLocationState createState() => _AddLocationState();
// }
//
// class _AddLocationState extends State<AddLocation> {
//   @override
//   void initState() {
//     super.initState();
//     getlocation();
//   }
//
//   getlocation() async {
//     Location.Location _location = new Location.Location();
//
//     bool _serviceEnabled;
//     Location.PermissionStatus _permissionGranted;
//
//     _serviceEnabled = await _location.serviceEnabled();
//     if (!_serviceEnabled) {
//       _serviceEnabled = await _location.requestService();
//       if (!_serviceEnabled) {
//         return;
//       }
//     }
//
//     _permissionGranted = await _location.hasPermission();
//     if (_permissionGranted == Location.PermissionStatus.denied) {
//       setState(() {
//         position = LatLng(25.2048, 55.2708);
//         loading = false;
//       });
//       showDialog(
//           context: context,
//           useRootNavigator: false,
//           barrierDismissible: false,
//           builder: (_) => AssetGiffyDialog(
//                 image: Image.asset(
//                   'assets/oops.gif',
//                   fit: BoxFit.cover,
//                 ),
//                 title: Text(
//                   'Turn on Location Services!',
//                   style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600),
//                 ),
//                 description: Text(
//                   'You need to provide access to your location in order to Add an Item within your community',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(),
//                 ),
//                 onlyOkButton: true,
//                 entryAnimation: EntryAnimation.DEFAULT,
//                 onOkButtonPressed: () async {
//                   Navigator.pop(context);
//                   Navigator.pop(context);
//                   AppSettings.openLocationSettings();
//                 },
//               ));
//     } else if (_permissionGranted == Location.PermissionStatus.granted) {
//       var location = await _location.getLocation();
//       var positio =
//           LatLng(location.latitude.toDouble(), location.longitude.toDouble());
//
//       setState(() {
//         position = positio;
//         loading = false;
//       });
//     }
//   }
//
//   LatLng position;
//
//   GoogleMapController controller;
//   LatLng _lastMapPosition;
//
//   Set<Marker> _markers = Set();
//   TextEditingController searchcontroller = TextEditingController();
//
//   void mapCreated(GoogleMapController controlle) {
//     setState(() {
//       controller = controlle;
//     });
//   }
//
//   void _onCameraMove(CameraPosition position) {
//     setState(() {
//       _lastMapPosition = position.target;
//     });
//   }
//
//   String city;
//   String country;
//
//   _handleTap(LatLng point) async {
//     if (_markers.isNotEmpty) {
//       _markers.remove(_markers.last);
//       setState(() {
//         _markers.add(Marker(
//           markerId: MarkerId(point.toString()),
//           position: point,
//           infoWindow: InfoWindow(
//             title: 'Location of Item',
//           ),
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//         ));
//
//         _lastMapPosition = point;
//       });
//
//       List<Geocoding.Placemark> placemarks =
//           await Geocoding.placemarkFromCoordinates(
//               position.latitude, position.longitude,
//               localeIdentifier: 'en');
//
//       Geocoding.Placemark place = placemarks[0];
//       print(place);
//       var cit = place.administrativeArea;
//       var countr = place.country;
//       setState(() {
//         city = cit;
//         country = countr;
//       });
//       Navigator.of(context).pop({
//         'city': city,
//         'country': country,
//         'lastmapposition': _lastMapPosition,
//       });
//     } else {
//       setState(() {
//         _markers.add(Marker(
//           markerId: MarkerId(point.toString()),
//           position: point,
//           infoWindow: InfoWindow(
//             title: 'Location of Item',
//           ),
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//         ));
//
//         _lastMapPosition = point;
//         print(_lastMapPosition);
//       });
//       List<Geocoding.Placemark> placemarks =
//           await Geocoding.placemarkFromCoordinates(
//               position.latitude, position.longitude,
//               localeIdentifier: 'en');
//
//       Geocoding.Placemark place = placemarks[0];
//       print(place);
//       var cit = place.administrativeArea;
//       var countr = place.country;
//       setState(() {
//         city = cit;
//         country = countr;
//       });
//       Navigator.of(context).pop({
//         'city': city,
//         'country': country,
//         'lastmapposition': _lastMapPosition,
//       });
//     }
//   }
//
//   bool loading = true;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           automaticallyImplyLeading: false,
//           backgroundColor: Colors.white,
//           iconTheme: IconThemeData(color: Colors.black),
//           title: Text(
//             'Location',
//             style: TextStyle(
//                 fontFamily: 'Helvetica', fontSize: 16, color: Colors.black),
//           ),
//           elevation: 0,
//         ),
//         body: loading == false
//             ? ListView(
//                 children: <Widget>[
//                   Padding(
//                     padding:
//                         EdgeInsets.only(left: 5, bottom: 5, top: 10, right: 5),
//                     child: Container(
//                       padding: EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.all(Radius.circular(15)),
//                       ),
//                       child: SearchMap.SearchMapPlaceWidget(
//                         apiKey: 'AIzaSyAL0gczX37-cNVHC_4aV6lWE3RSNqeamf4',
//                         language: 'en',
//                         location: position,
//                         hasClearButton: true,
//                         radius: 10000,
//                         onSelected: (SearchMap.Place places) async {
//                           final geolocations = await places.geolocation;
//
//                           controller.animateCamera(
//                               CameraUpdate.newLatLng(geolocations.coordinates));
//                           controller.animateCamera(CameraUpdate.newLatLngBounds(
//                               geolocations.bounds, 0));
//
//                           setState(() {
//                             position = geolocations.coordinates;
//                           });
//
//                           List<Geocoding.Placemark> placemarks =
//                               await Geocoding.placemarkFromCoordinates(
//                                   position.latitude, position.longitude,
//                                   localeIdentifier: 'en');
//
//                           Geocoding.Placemark place = placemarks[0];
//                           var cit = place.administrativeArea;
//                           var countr = place.country;
//                           setState(() {
//                             city = cit;
//                             country = countr;
//                           });
//                         },
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding:
//                         EdgeInsets.only(left: 5, bottom: 5, top: 4, right: 5),
//                     child: Container(
//                       padding: EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.all(Radius.circular(15)),
//                       ),
//                       child: Column(
//                         children: <Widget>[
//                           position != null
//                               ? Container(
//                                   height:
//                                       MediaQuery.of(context).size.height - 250,
//                                   width: MediaQuery.of(context).size.width,
//                                   child: GoogleMap(
//                                     initialCameraPosition: CameraPosition(
//                                         target: position,
//                                         zoom: 18.0,
//                                         bearing: 70),
//                                     onMapCreated: mapCreated,
//                                     onCameraMove: _onCameraMove,
//                                     onTap: _handleTap,
//                                     markers: _markers,
//                                     zoomGesturesEnabled: true,
//                                     myLocationEnabled: true,
//                                     myLocationButtonEnabled: true,
//                                     compassEnabled: true,
//                                     gestureRecognizers: Set()
//                                       ..add(Factory<EagerGestureRecognizer>(
//                                           () => EagerGestureRecognizer())),
//                                   ),
//                                 )
//                               : Text(
//                                   'Oops! Something went wrong. \n Please try again',
//                                   style: TextStyle(
//                                     fontFamily: 'Helvetica',
//                                     fontSize: 16,
//                                   ),
//                                 ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               )
//             : Container(
//                 width: MediaQuery.of(context).size.width,
//                 height: MediaQuery.of(context).size.height,
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 16.0, vertical: 16.0),
//                 child: Shimmer.fromColors(
//                   baseColor: Colors.grey[300],
//                   highlightColor: Colors.grey[100],
//                   child: ListView(
//                     children: [0, 1, 2, 3, 4, 5, 6]
//                         .map((_) => Padding(
//                               padding: const EdgeInsets.only(bottom: 8.0),
//                               child: Row(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Container(
//                                     decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                     width:
//                                         MediaQuery.of(context).size.width / 2 -
//                                             30,
//                                     height: 150.0,
//                                   ),
//                                   Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 8.0),
//                                   ),
//                                   Container(
//                                     width:
//                                         MediaQuery.of(context).size.width / 2 -
//                                             30,
//                                     height: 150.0,
//                                     decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ))
//                         .toList(),
//                   ),
//                 ),
//               ));
//   }
// }
