import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:mta/blocs/meetings/meeting_create_bloc.dart';
import 'package:mta/models/AddMeetingReq.dart';
import 'package:mta/network/ApiService.dart';
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

  bool _isLoading = false;

  FocusNode searchFocus = FocusNode();
  late final MeetingCreateBloc _bloc;
  late final StreamSubscription<MeetingCreateState> _blocSub;

  @override
  void initState() {
    super.initState();
    _bloc = MeetingCreateBloc(ApiService.create());
    _blocSub = _bloc.stream.listen(_onBlocState);
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _blocSub.cancel();
    _bloc.close();
    super.dispose();
  }

  /// Performs the UI side effects for [MeetingCreateBloc] states — the loading
  /// flag/spinner, toasts, error snackbar and the triple pop submitData() did.
  void _onBlocState(MeetingCreateState state) {
    if (state is MeetingCreateLoading) {
      setState(() => _isLoading = true);
      EasyLoading.show();
    } else if (state is MeetingCreated) {
      setState(() => _isLoading = false);
      EasyLoading.dismiss();
      AppUtils.showToastSuccess("Meeting created successfully!");
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
    } else if (state is MeetingCreateFailed) {
      setState(() => _isLoading = false);
      EasyLoading.dismiss();
      AppUtils.showErrorSnackBar(context, state.message);
    } else if (state is MeetingCreateError) {
      setState(() => _isLoading = false);
      EasyLoading.dismiss();
      AppUtils.showToastError("Something went wrong!");
    }
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
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Builder(
            builder: (BuildContext newContext) {
              return LcoationSelectionWidget(newContext);
            },
          ),
        ),
      ),
    );
  }

  Widget LcoationSelectionWidget(BuildContext newContext) {
    ctx = newContext;
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        searchFocus.unfocus();
      },
      child: Scaffold(
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
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 20, left: 30, right: 30),
            child: ThemeButton(
                title: "CREATE MEETING", buttonfunction: _isLoading ? null : submitData),
          ),
          body: Column(
            children: [
              Padding(
                padding:
                    EdgeInsets.only(left: 20, right: 20, top: height! * 0.06),
                child: GooglePlaceAutoCompleteTextField(
                  focusNode: searchFocus,
                  googleAPIKey: Strings.googleAPIKey,
                  itemClick: (prediction) async {
                    _searchFieldController.text = prediction.description!;
                    _searchFieldController.selection =
                        TextSelection.fromPosition(TextPosition(
                            offset: prediction.description!.length));
                    searchFocus.unfocus();
                    setState(() {});
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
                    searchFocus.unfocus();
                    setState(() {});
                  },
                  inputDecoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search places',
                    contentPadding: EdgeInsets.only(left: 10.0),
                  ),
                  textEditingController: _searchFieldController,
                  boxDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: const Color(0xFFeceeef),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 20, right: 20, top: 30, bottom: 90),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: initialLocation,
                      myLocationEnabled: true,
                      zoomControlsEnabled: false,
                      myLocationButtonEnabled: false,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                      onTap: (LatLng point) {
                        _markedLocation = point;
                        searchFocus.unfocus();
                        setState(() {});
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
                ),
              ),
            ],
          )),
    );
  }

  submitData() {
    if (_markedLocation != null) {
      widget.addMeetingData.location =
          'https://www.google.com/maps?q=${_markedLocation!.latitude},${_markedLocation!.longitude}';
    } else {
      widget.addMeetingData.location = 'Location Not Mentioned!';
    }
    _bloc.add(MeetingSubmitted(widget.addMeetingData));
  }
}
