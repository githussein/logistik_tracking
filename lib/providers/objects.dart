import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'auth.dart';
import '../models/object.dart';

class Objects with ChangeNotifier {
  List<Object> _list = [];
  final String propertiesKey = 'properties';
  final String currentGeofencesKey = 'current_geofences';
  final String trackingIdKey = 'tracking-id';
  final String idKey = 'id';
  final String nameKey = 'name';
  final String materialA = 'Material A';
  final String materialB = 'Material B';
  final String readyForShipment = 'Ready for Shipment';


  List<Object> get ordersList => [..._list];

  List sortGeofences(Map<String, dynamic> objectGeofences) {
    List currentGeofences = [];
    objectGeofences.forEach((k, v) => currentGeofences.add([k, v]));
    currentGeofences.sort((a, b) => b[1].compareTo(a[1]));
    return currentGeofences;
  }

  Future<void> fetchOrders(BuildContext context) async {
    Uri targetUrl = Uri.parse(
        '${Provider.of<Auth>(context, listen: false).backendUrl}/api/packages?location=entry&active=true');

    try {
      final response = await http.get(targetUrl,
          headers: Provider.of<Auth>(context, listen: false).authHeader);

      List<dynamic> extractedData = json.decode(response.body) as List<dynamic>;
      final List<Object> loadedObjects = [];

      for (var object in extractedData) {
        /// current geofence is an object where the keys represent current
        /// locations and the values are the times the object entered these geofences.
        /// Example: "current_geofences": {
        ///             "Outbound": "2022-03-16T16:13:40.441Z",
        ///             "Assembly": "2022-03-16T16:13:36.277Z"
        ///         }
        if (object[currentGeofencesKey].isNotEmpty) {
          List currentGeofences = sortGeofences(object[currentGeofencesKey]);

          loadedObjects.add(Object(
            id: object[idKey],
            name: object[nameKey],
            trackingId: object[propertiesKey][trackingIdKey] ?? '',
            location: currentGeofences[0][0],
            locationEnterTimestamp: DateTime.parse(currentGeofences[0][1]),
            materialA: object[propertiesKey][materialA] ?? 'missing',
            materialB: object[propertiesKey][materialB] ?? 'missing',
            readyForShipment: object[propertiesKey][readyForShipment] ?? 'no',
          ));
        } else {
          loadedObjects.add( Object(
            id: object[idKey],
            name: object[nameKey],
            trackingId: object[propertiesKey][trackingIdKey] ?? '',
            locationEnterTimestamp: DateTime.now(),
          ));
        }
      }

      _list = loadedObjects;
    } catch (error) {
      rethrow;
    }
  }

  Future<Object> fetchObjectById(BuildContext context, int id) async {
    var targetUrl = Uri.parse(
        '${Provider.of<Auth>(context, listen: false).backendUrl}/api/packages?id=$id&active=true');

    try {
      final response = await http.get(targetUrl,
          headers: Provider.of<Auth>(context, listen: false).authHeader);

      List<dynamic> extractedData = json.decode(response.body) as List<dynamic>;
      final Map<String, dynamic> fetchedObject = extractedData[0];

      if (fetchedObject[currentGeofencesKey].isNotEmpty) {
        List currentGeofences = sortGeofences(fetchedObject[currentGeofencesKey]);

        return Object(
          id: fetchedObject[idKey],
          name: fetchedObject[nameKey],
          trackingId: fetchedObject[propertiesKey][trackingIdKey] ?? '',
          location: currentGeofences[0][0],
          locationEnterTimestamp: DateTime.parse(currentGeofences[0][1]),
          materialA: fetchedObject[propertiesKey][materialA] ?? 'missing',
          materialB: fetchedObject[propertiesKey][materialB] ?? 'missing' ,
          readyForShipment: fetchedObject[propertiesKey][readyForShipment] ?? 'no',
        );
      } else {
        return Object(
          id: fetchedObject[idKey],
          name: fetchedObject[nameKey],
          trackingId: fetchedObject[propertiesKey][trackingIdKey] ?? '',
          locationEnterTimestamp: DateTime.now(),
        );
      }
    } catch (error) {
      rethrow;
    }
  }
}
