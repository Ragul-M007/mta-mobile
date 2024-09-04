import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:mta/models/AddMeetingReq.dart';
import 'package:mta/network/ApiService.dart';
import 'package:mta/screens/meetings/meetings_home.dart';
import 'package:mta/utilities/AppBarWidget.dart';
import 'package:mta/utilities/apputilities.dart';
import 'package:mta/utilities/strings.dart';
import 'package:mta/utilities/theme_button.dart';
import 'package:provider/provider.dart';

class LocationSelection extends StatefulWidget {
  final AddMeetingReq addMeetingData;
  const LocationSelection({super.key, required this.addMeetingData});

  @override
  State<LocationSelection> createState() => _LocationSelectionState();
}

class _LocationSelectionState extends State<LocationSelection> {
  BuildContext? ctx;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  CameraPosition initialLocation = CameraPosition(target: LatLng(28.0, 77.0));

  double? height;

  double? width;

  var searchField;

  TextEditingController _searchFieldController = TextEditingController();

  LatLng? _markedLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    // Check location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      // Get current position
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {});
      if (_markedLocation == null) {
        // Move the camera to the user's location
        final GoogleMapController controller = await _controller.future;
        await controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 18.0,
          ),
        ));
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Provider<ApiService>(
      create: (context) => ApiService.create(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Builder(
          builder: (BuildContext newContext) {
            return LcoationSelectionWidget(newContext);
          },
        ),
      ),
    );
  }

  Widget LcoationSelectionWidget(BuildContext newContext) {
    ctx = newContext;
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: AppBarWidget(
              backButtonfunction: () {
                Navigator.pop(context);
              },
              title: "Add Location",
              actionWidget: []),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 20, left: 30, right: 30),
          child:
              ThemeButton(title: "CREATE MEETING", buttonfunction: submitData),
        ),
        body: Column(
          children: [
            Padding(
              padding:
                  EdgeInsets.only(left: 20, right: 20, top: height! * 0.06),
              child: Container(
                // height: 35,
                child: GooglePlaceAutoCompleteTextField(
                  googleAPIKey: Strings.googleAPIKey,
                  itemClick: (prediction) async {
                    _searchFieldController.text = prediction.description!;
                    _searchFieldController.selection =
                        TextSelection.fromPosition(TextPosition(
                            offset: prediction.description!.length));
                    // Update the map to display the new marker
                    setState(() {});
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  getPlaceDetailWithLatLng: (postalCodeResponse) async {
                    _markedLocation = LatLng(
                        double.tryParse(postalCodeResponse.lat!)!,
                        double.tryParse(postalCodeResponse.lng!)!);
                    final GoogleMapController controller =
                        await _controller.future;
                    await controller
                        .animateCamera(CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: _markedLocation!,
                        zoom: 18.0,
                      ),
                    ));
                    setState(() {});
                    FocusManager.instance.primaryFocus?.unfocus();
                    // Add a marker to the selected place
                  },
                  inputDecoration: InputDecoration(
                    border: InputBorder.none, // Remove underline
                    hintText: 'Search places',
                    contentPadding: EdgeInsets.only(left: 10.0),
                    // hintStyle: TextStyle(color: Colors.grey),
                  ),
                  textEditingController: _searchFieldController,
                  boxDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: const Color(0xFFeceeef),
                  ),
                ),
              ),
            ),
            Container(
              height: height! * 0.6,
              padding: EdgeInsets.only(left: 20, right: 20, top: 30),
              child: GoogleMap(
                initialCameraPosition: initialLocation,
                myLocationEnabled: true,
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                onTap: (LatLng point) {
                  _markedLocation = point;
                  setState(() {});
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                markers: _markedLocation != null
                    ? {
                        Marker(
                          markerId: MarkerId('marked_location'),
                          position: _markedLocation!,
                          infoWindow: InfoWindow(
                            title: 'Marked Location',
                          ),
                        ),
                      }
                    : {},
              ),
            ),
          ],
        ));
  }

  submitData() {
    if (_markedLocation != null) {
      widget.addMeetingData.location =
          'https://www.google.com/maps?q=${_markedLocation!.latitude},${_markedLocation!.longitude}';
      final api = Provider.of<ApiService>(context, listen: false);

      print(">AddMeeting:${jsonEncode(widget.addMeetingData)}");
      api.createMeeting(widget.addMeetingData).then((response) {
        if (response.status!) {
          AppUtils.showToastSuccess("Meeting created successfully!");

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => Meetings(),
            ),
            (route) => false,
          );
        } else {
          AppUtils.showErrorSnackBar(context, response.message!);
        }
      }).catchError((onError) {
        AppUtils.showToastError("Something went wrong!");
      });
    } else {
      AppUtils.showToastError("Please mark meeting location!");
    }
  }
}
