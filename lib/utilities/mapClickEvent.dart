import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mappls_gl/mappls_gl.dart';

class MapClickEvent extends StatefulWidget {
  const MapClickEvent({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MapClickEventState();
  }
}

class _MapClickEventState extends State {
  CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(28.551087, 77.257373),
    zoom: 14.0,
  );

  late MapplsMapController mapController;

  bool isMapLoded = false;
  List<ELocation> _elocation = [];
  bool showAutoSuggestWidget = false;
  TextEditingController textController = TextEditingController();

  void initState() {
    super.initState();
    MapplsAccountManager.setMapSDKKey("ff14368fe60f540ac50e358c315ba5c0");
    MapplsAccountManager.setRestAPIKey("ff14368fe60f540ac50e358c315ba5c0");
    MapplsAccountManager.setAtlasClientId(
        "96dHZVzsAutq0F-CusMHuxIhjT2JZmAWlH5nTXUwPTxwLwAdLNaDYsia3VxUaWUB8Ltzu4FwRxJ7Cx0hl6yzQA==");
    MapplsAccountManager.setAtlasClientSecret(
        "lrFxI-iSEg9KNmfYbtD7PoTzZDQm637UBhw-HeKvtkxng4E_pxsv8emtQqa4QK9XCnaFk4wd9fVkZrsvH_VuDwyhwwk1STHw");
    setState(() {});

    setPermission();
  }

  void setPermission() async {
    if (!kIsWeb) {
      final location = Location();
      final hasPermissions = await location.hasPermission();
      if (hasPermissions != PermissionStatus.granted) {
        await location.requestPermission();
      }
    }
  }

  void addMarker(ELocation eLocation) async {
    LatLng latLng = LatLng(eLocation.latitude!, eLocation.longitude!);
    await mapController.addSymbol(SymbolOptions(geometry: latLng));
    mapController.animateCamera(CameraUpdate.newLatLngZoom(latLng, 14));
  }

  void _onMapCreated(MapplsMapController controller) {
    mapController = controller;
    setState(() {
      isMapLoded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text('Map Click'),
      ),
      body: Stack(
        children: [
          MapplsMap(
            initialCameraPosition: _kInitialPosition,
            myLocationTrackingMode: MyLocationTrackingMode.Tracking,
            myLocationEnabled: true,
            onMapCreated: _onMapCreated,
            onMapClick: (point, latlng) => {
              print(">>>lat:${latlng.latitude},${latlng.longitude}"),
              Fluttertoast.showToast(msg: latlng.toString()),
              mapController.addSymbol(SymbolOptions(
                  geometry: LatLng(latlng.latitude, latlng.longitude))),
              mapController.animateCamera(CameraUpdate.newLatLngZoom(
                  LatLng(latlng.latitude, latlng.longitude), 14))
            },
            onUserLocationUpdated: (location) {
              _kInitialPosition = CameraPosition(
                target: LatLng(
                    location.position.latitude, location.position.longitude),
                zoom: 14.0,
              );

              mapController.animateCamera(CameraUpdate.newLatLngZoom(
                  LatLng(
                      location.position.latitude, location.position.longitude),
                  14));
            },
            onStyleLoadedCallback: () => {
              setState(() {
                showAutoSuggestWidget = true;
              })
            },
          ),
          showAutoSuggestWidget ? autosuggestWidget() : Container(),
        ],
      ),
    );
  }

  Widget autosuggestWidget() {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        Container(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: TextFormField(
                controller: textController,
                decoration: const InputDecoration(
                    hintText: "Search Here", fillColor: Colors.white),
                maxLines: 1,
                onChanged: (text) {
                  callAutoSuggest(text);
                })),
        const SizedBox(
          height: 20,
        ),
        _elocation.isNotEmpty
            ? Expanded(
                child: Container(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: ListView.builder(
                        itemCount: _elocation.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            focusColor: Colors.white,
                            title: Text(_elocation[index].placeName ?? ''),
                            subtitle: Text(
                              _elocation[index].placeAddress ?? '',
                              maxLines: 2,
                            ),
                            onTap: () {
                              addMarker(_elocation[index]);
                              setState(() {
                                _elocation = [];
                              });
                              textController.text = '';
                            },
                          );
                        })))
            : Container()
      ],
    );
  }

  void callAutoSuggest(String text) async {
    if (text.length > 2) {
      try {
        AutoSuggestResponse? response =
            await MapplsAutoSuggest(query: text).callAutoSuggest();
        if (response != null && response.suggestedLocations != null) {
          setState(() {
            _elocation = response.suggestedLocations!;
          });
        } else {
          setState(() {
            _elocation = [];
          });
        }
      } catch (e) {
        if (e is PlatformException) {
          Fluttertoast.showToast(msg: '${e.code} --- ${e.message}');
        }
      }
    } else {
      setState(() {
        _elocation = [];
      });
    }
  }
}
