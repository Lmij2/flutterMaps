import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MapController mapController = MapController();
  List<Marker> markers = [];

  Future<http.Response> futureData;
  List<LatLng> latlngList = List<LatLng>();
  LatLng bongest = LatLng(35.7627916,10.8042714);
  LatLng topnet = LatLng(35.7695667,10.8203182);
  
  Future<void> myFun() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

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

    _locationData = await location.getLocation();
    mapController.move(LatLng(35.7633916,10.8033714), 15);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          onLongPress: addPin,
          onTap: makeMarkers(bongest),
          center: bongest,
          zoom: 17.0,
          minZoom: 10,
        ),
        layers: [
          new TileLayerOptions(
            urlTemplate:
                'https://api.mapbox.com/styles/v1/lmij/cklsc4udv1bun17t7a62vfa7o/tiles/256/{z}/{x}/{y}@2x?access_token={accessToken}',
            additionalOptions: {
              'accessToken':
                  'pk.eyJ1IjoibG1paiIsImEiOiJjanZwNzNudzIwN21yNDlvenh3aHN5dWRsIn0.C-XnqISq3XmGejHgv8wexw',
            },
          ),
          MarkerLayerOptions(
            markers: markers,
          ),
          PolylineLayerOptions(polylines: [
              Polyline(
                points: latlngList,
                // isDotted: true,
                color: Color(0xFF669DF6),
                strokeWidth: 3.0,
                borderColor: Color(0xFF1967D2),
                borderStrokeWidth: 0.1,
              )
          ])
        ],
        mapController: mapController,
        
      ),
    );
  }

  makeMarkers(LatLng latlng){

    setState(() {
      markers.add(Marker(
        width: 30.0,
        height: 30.0,
        point: latlng,
        builder: (ctx) => Container(
          child: Image.asset('assets/pin.png'),
        ),
      ));
    });
  }

  addPin(LatLng latLng) {
    fetchData();
/*
    myFun();*/
  }

Future<http.Response> fetchData() async {
  //var response = await http.get('https://api.mapbox.com/directions/v5/mapbox/driving/10.82617,35.77799;10.16579,36.81897?alternatives=true&geometries=geojson&steps=true&access_token=pk.eyJ1IjoibG1paiIsImEiOiJjanhmenpudXgwNnhqM3RsOThsengxdHRxIn0.porCqvlzirmaXQRvHnI3eA');
  var response = await http.get('https://api.openrouteservice.org/v2/directions/driving-car?api_key=5b3ce3597851110001cf62482a5676d4c7b44511aa5ee2e93c2f3b96' 
  + '&start=${bongest.longitude},${bongest.latitude}&end=${topnet.longitude},${topnet.latitude}');
  
  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');
 
  var respBody = jsonDecode(response.body)['features'][0]["geometry"]["coordinates"];
  print(respBody.length);
  int len = respBody.length;
  for(int i = 0; i < len; i++){
    var data = respBody[i];
    latlngList.add(LatLng(data[1], data[0]));
  }
  print(latlngList);
  print(respBody.toString());
  

  setState(() {
    
  });
  return null;

}
}
