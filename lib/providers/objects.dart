import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'auth.dart';
import '../models/object.dart';

class Objects with ChangeNotifier {
  List<Object> _list = [];

  List<Object> get ordersList => [..._list];

  List sortGeofences(Map<String, dynamic> objectGeofences) {
    List currentGeofences = [];
    objectGeofences.forEach((k, v) => currentGeofences.add([k, v]));
    currentGeofences.sort((a, b) => b[1].compareTo(a[1]));
    return currentGeofences;
  }

  Future<void> fetchOrders(BuildContext context) async {
    Uri targetUrl = Uri.parse(
        '${Provider.of<Auth>(context, listen: false).backendUrl}/riot-api/objects?labels=Order&current_geofences=true');

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
        if (object['current_geofences'].isNotEmpty) {
          List currentGeofences = sortGeofences(object['current_geofences']);

          loadedObjects.add(Object(
            id: object['id'],
            name: object['name'],
            trackingId: object['properties']['tracking-id'] ?? '',
            location: currentGeofences[0][0],
            locationEnterTimestamp: DateTime.parse(currentGeofences[0][1]),
            materialA: object['properties'].containsKey('Material A'),
            materialB: object['properties'].containsKey('Material B'),
          ));
        } else {
          loadedObjects.add( Object(
            id: object['id'],
            name: object['name']!,
            trackingId: object['properties']['tracking-id'] ?? '',
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
        '${Provider.of<Auth>(context, listen: false).backendUrl}/riot-api/objects?id=$id&current_geofences=true');

    try {
      final response = await http.get(targetUrl,
          headers: Provider.of<Auth>(context, listen: false).authHeader);

      List<dynamic> extractedData = json.decode(response.body) as List<dynamic>;
      final Map<String, dynamic> fetchedObject = extractedData[0];

      if (fetchedObject['current_geofences'].isNotEmpty) {
        List currentGeofences = sortGeofences(fetchedObject['current_geofences']);

        return Object(
          id: fetchedObject['id'],
          name: fetchedObject['name'],
          trackingId: fetchedObject['properties']['tracking-id'] ?? '',
          location: currentGeofences[0][0],
          locationEnterTimestamp: DateTime.parse(currentGeofences[0][1]),
          materialA: fetchedObject['properties'].containsKey('Material A'),
          materialB: fetchedObject['properties'].containsKey('Material B'),
        );
      } else {
        return Object(
          id: fetchedObject['id'],
          name: fetchedObject['name']!,
          trackingId: fetchedObject['properties']['tracking-id'] ?? '',
          locationEnterTimestamp: DateTime.now(),
        );
      }
    } catch (error) {
      rethrow;
    }
  }
}
