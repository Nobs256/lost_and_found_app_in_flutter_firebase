import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'dart:async';

// Define a constant for the current location marker ID
const String currentLocMarkerId = 'currentLocationMarker';

// Define a default location (Mbarara City)
final LatLng defaultLocation = LatLng(-0.6049, 30.6485); // Mbarara coordinates

// Simple class to hold marker data
class MapMarker {
  final String id;
  LatLng position; // Make position mutable for the current location marker

  MapMarker(this.id, this.position);

  // Override equality operator and hashCode for proper comparison and Set usage
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapMarker && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // Use late initialization for the MapController as it's assigned in build
  // Or initialize directly if preferred and manage its lifecycle
  final MapController _mapController = MapController();
  final Location _location = Location();

  // Use a Set for markers to easily manage the current location marker
  final Set<MapMarker> _markers = {};
  // List for points tapped by the user, forming the polyline
  final List<LatLng> _polylinePoints = [];

  StreamSubscription<LocationData>? _locationSubscription;
  LatLng? _lastKnownLocation; // Store the last known location

  @override
  void initState() {
    super.initState();
    // Initialize location services and start listening
    _initializeLocationService();
  }

  @override
  void dispose() {
    // Cancel the location subscription when the widget is disposed
    _locationSubscription?.cancel();
    // Dispose the map controller if necessary (depends on how it's managed)
    // _mapController.dispose(); // Add if needed
    super.dispose();
  }

  // --- Location Handling ---

  Future<void> _initializeLocationService() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        print("Location service denied.");
        _setMapToDefaultLocation();
        return;
      }
    }

    PermissionStatus permission = await _location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await _location.requestPermission();
      if (permission != PermissionStatus.granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location permission denied. Please enable it in settings.")),
        );
        _setMapToDefaultLocation();
        return;
      }
    }

    // Get initial location once
    try {
      LocationData initialLocation = await _location.getLocation();
      if (initialLocation.latitude != null && initialLocation.longitude != null) {
        _updateCurrentLocation(LatLng(initialLocation.latitude!, initialLocation.longitude!), moveCamera: true);
      } else {
        _setMapToDefaultLocation(); // Set to default if initial location is null
      }
    } catch (e) {
      print("Error getting initial location: $e");
      _setMapToDefaultLocation(); // Fallback to default on error
    }

    // Listen for location changes
    _locationSubscription = _location.onLocationChanged.listen((locationData) {
      if (locationData.latitude != null && locationData.longitude != null) {
        final currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
        _updateCurrentLocation(currentLocation);
      }
    }, onError: (error) {
      print("Error listening to location changes: $error");
    });
  }

  // Helper to set map center to default location
  void _setMapToDefaultLocation() {
     if (mounted) { // Check if the widget is still in the tree
        setState(() {
          _lastKnownLocation = defaultLocation;
        });
        // Use controller methods if available after build, or handle initial state
        // Note: Calling move here might fail if build hasn't run yet
        // Consider setting initialCenter in MapOptions instead for first load
     }
  }


  // Updates the current location marker or adds it if it doesn't exist
  void _updateCurrentLocation(LatLng location, {bool moveCamera = false}) {
     if (!mounted) return; // Don't update state if widget is disposed

    setState(() {
      _lastKnownLocation = location;
      MapMarker currentMarkerData = MapMarker(currentLocMarkerId, location);
      // Remove existing current marker first, then add the updated one
      // This handles the case where the marker object identity might change
      _markers.removeWhere((m) => m.id == currentLocMarkerId);
      _markers.add(currentMarkerData);
    });

    // Optionally move the map camera to the new location
    // Ensure mapController is ready before calling move
    if (moveCamera) {
       // Use try-catch as a safety measure
      try {
          // Ensure the controller is accessed safely, potentially after build
          // Using addPostFrameCallback ensures it runs after the current frame
           WidgetsBinding.instance.addPostFrameCallback((_) {
             if(mounted) { // Check mounted again inside callback
                _mapController.move(location, 15.0);
             }
           });
      } catch (e) {
          print("Error moving map controller in _updateCurrentLocation: $e");
          // Handle cases where controller might not be initialized yet
      }
    }
  }


  // --- Marker and Polyline Handling ---

  // Adds a marker where the user taps on the map
  void _addMarker(LatLng position) {
    if (!mounted) return;
    String markerId = DateTime.now().millisecondsSinceEpoch.toString();
    setState(() {
      _markers.add(MapMarker(markerId, position));
      _polylinePoints.add(position);
    });
  }

  // Removes a specific marker and its corresponding point from the polyline
  void _removeMarker(MapMarker markerToRemove) {
    if (!mounted) return;
    if (markerToRemove.id == currentLocMarkerId) return; // Don't remove current location

    setState(() {
      bool removed = _markers.remove(markerToRemove);
      if (removed) {
        _polylinePoints.remove(markerToRemove.position);
      }
    });
  }

  // Clears all user-added markers and the polyline
  void _clearUserMarkersAndPolyline() {
     if (!mounted) return;
    setState(() {
      _markers.removeWhere((marker) => marker.id != currentLocMarkerId);
      _polylinePoints.clear();
    });
  }

  // --- UI and Dialogs ---

  // Shows an info dialog when a marker is tapped
  void _showMarkerInfo(MapMarker marker) {
     if (marker.id == currentLocMarkerId) {
        print("Tapped on current location marker.");
        // Optionally show info like coordinates if needed
        // showDialog(...);
        return;
     }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Marker Info"),
          content: Text(
              "ID: ${marker.id}\nLocation: ${marker.position.latitude.toStringAsFixed(5)}, ${marker.position.longitude.toStringAsFixed(5)}"),
          actions: [
            TextButton(
              child: Text("Remove"),
              onPressed: () {
                _removeMarker(marker);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // --- Build Method ---

  @override
  Widget build(BuildContext context) {
    // Determine the initial center for the map options
    // Use last known location if available, otherwise use the default
    LatLng initialMapCenter = _lastKnownLocation ?? defaultLocation;

    return Scaffold(
      body: FlutterMap(
        mapController: _mapController, // Assign controller
        options: MapOptions(
          initialCenter: initialMapCenter, // Use initialCenter
          initialZoom: 15.0, // Use initialZoom
          minZoom: 3.0,
          maxZoom: 18.0,
          onTap: (tapPosition, point) {
            _addMarker(point); // Add user marker on tap
          },
        ),
        // Use children instead of layers for v6+
        children: [
          // Base map tiles layer
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.app', // Replace with your app's package name
             // Add attribution for OpenStreetMap
            tileBuilder: (context, tileWidget, tile) {
              return tileWidget; // Basic tile builder
            },
             // Optional: Add attribution widget if needed separately
             // attributionBuilder: (_) {
             //   return Text(
             //     "© OpenStreetMap contributors",
             //     style: TextStyle(fontSize: 10, color: Colors.black54),
             //   );
             // },
          ),
          // Polyline layer connecting user-tapped markers
          PolylineLayer(
            polylines: [
              Polyline(
                points: _polylinePoints,
                strokeWidth: 4.0,
                color: Colors.deepPurple,
                // isDotted parameter removed/changed in v6+
                // For dotted lines, explore borderStrokeWidth/borderColor or custom painting
              ),
            ],
          ),
          // Marker layer for current location and user taps
          MarkerLayer(
            markers: _markers.map((markerData) {
              bool isCurrentLocation = markerData.id == currentLocMarkerId;
              IconData iconData = isCurrentLocation ? Icons.my_location : Icons.location_pin;
              Color iconColor = isCurrentLocation ? Colors.redAccent : Colors.blueAccent;
              double iconSize = isCurrentLocation ? 35.0 : 40.0;

              // Use Marker's child parameter instead of builder
              return Marker(
                width: 40.0,
                height: 40.0,
                point: markerData.position,
                // The child widget defines the marker's appearance
                child: GestureDetector(
                   onTap: () => _showMarkerInfo(markerData), // Show info on tap
                   child: Icon(
                     iconData,
                     color: iconColor,
                     size: iconSize,
                   ),
                ),
                // Optional: alignment replaces anchorPos in some contexts
                // alignment: Alignment.topCenter,
              );
            }).toList(), // Convert the Set mapping to a List
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _clearUserMarkersAndPolyline,
        tooltip: 'Clear Markers & Path',
        backgroundColor: Colors.orangeAccent,
        child: Icon(Icons.delete_sweep),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:location/location.dart';
// import 'dart:async';
// import 'package:geolocator/geolocator.dart' as geo; // Import geolocator for distance calculation

// // Define a constant for the current location marker ID
// const String currentLocMarkerId = 'currentLocationMarker';

// // Define a default location (Mbarara City)
// final LatLng defaultLocation = LatLng(-0.6049, 30.6485); // Mbarara coordinates

// // Simple class to hold marker data
// class MapMarker {
//   final String id;
//   LatLng position; // Make position mutable for the current location marker

//   MapMarker(this.id, this.position);

//   // Override equality operator and hashCode for proper comparison and Set usage
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is MapMarker && runtimeType == other.runtimeType && id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }

// class MapPage extends StatefulWidget {
//   @override
//   _MapPageState createState() => _MapPageState();
// }

// class _MapPageState extends State<MapPage> {
//   final MapController _mapController = MapController();
//   final Location _location = Location();

//   final Set<MapMarker> _markers = {};
//   final List<LatLng> _polylinePoints = [];
//   double _polylineDistance = 0.0; // To store the calculated distance

//   StreamSubscription<LocationData>? _locationSubscription;
//   LatLng? _lastKnownLocation;

//   @override
//   void initState() {
//     super.initState();
//     _initializeLocationService();
//   }

//   @override
//   void dispose() {
//     _locationSubscription?.cancel();
//     super.dispose();
//   }

//   // --- Location Handling ---

//   Future<void> _initializeLocationService() async {
//     bool serviceEnabled = await _location.serviceEnabled();
//     if (!serviceEnabled) {
//       serviceEnabled = await _location.requestService();
//       if (!serviceEnabled) {
//         print("Location service denied.");
//         _setMapToDefaultLocation();
//         return;
//       }
//     }

//     PermissionStatus permission = await _location.hasPermission();
//     if (permission == PermissionStatus.denied) {
//       permission = await _location.requestPermission();
//       if (permission != PermissionStatus.granted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Location permission denied. Please enable it in settings.")),
//         );
//         _setMapToDefaultLocation();
//         return;
//       }
//     }

//     try {
//       LocationData initialLocation = await _location.getLocation();
//       if (initialLocation.latitude != null && initialLocation.longitude != null) {
//         _updateCurrentLocation(LatLng(initialLocation.latitude!, initialLocation.longitude!), moveCamera: true);
//       } else {
//         _setMapToDefaultLocation();
//       }
//     } catch (e) {
//       print("Error getting initial location: $e");
//       _setMapToDefaultLocation();
//     }

//     _locationSubscription = _location.onLocationChanged.listen((locationData) {
//       if (locationData.latitude != null && locationData.longitude != null) {
//         final currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
//         _updateCurrentLocation(currentLocation);
//       }
//     }, onError: (error) {
//       print("Error listening to location changes: $error");
//     });
//   }

//   void _setMapToDefaultLocation() {
//     if (mounted) {
//       setState(() {
//         _lastKnownLocation = defaultLocation;
//       });
//     }
//   }

//   void _updateCurrentLocation(LatLng location, {bool moveCamera = false}) {
//     if (!mounted) return;

//     setState(() {
//       _lastKnownLocation = location;
//       MapMarker currentMarkerData = MapMarker(currentLocMarkerId, location);
//       _markers.removeWhere((m) => m.id == currentLocMarkerId);
//       _markers.add(currentMarkerData);
//     });

//     if (moveCamera) {
//       try {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (mounted) {
//             _mapController.move(location, 15.0);
//           }
//         });
//       } catch (e) {
//         print("Error moving map controller in _updateCurrentLocation: $e");
//       }
//     }
//   }

//   // --- Marker and Polyline Handling ---

//   void _addMarker(LatLng position) {
//     if (!mounted) return;
//     String markerId = DateTime.now().millisecondsSinceEpoch.toString();
//     setState(() {
//       _markers.add(MapMarker(markerId, position));
//       _polylinePoints.add(position);
//       _calculatePolylineDistance(); // Calculate distance when a new point is added
//     });
//   }

//   void _removeMarker(MapMarker markerToRemove) {
//     if (!mounted) return;
//     if (markerToRemove.id == currentLocMarkerId) return;

//     setState(() {
//       bool removed = _markers.remove(markerToRemove);
//       if (removed) {
//         _polylinePoints.remove(markerToRemove.position);
//         _calculatePolylineDistance(); // Recalculate distance when a point is removed
//       }
//     });
//   }

//   void _clearUserMarkersAndPolyline() {
//     if (!mounted) return;
//     setState(() {
//       _markers.removeWhere((marker) => marker.id != currentLocMarkerId);
//       _polylinePoints.clear();
//       _polylineDistance = 0.0; // Reset the distance
//     });
//   }

//   // Calculates the total distance of the polyline
//   void _calculatePolylineDistance() {
//     double totalDistance = 0.0;
//     if (_polylinePoints.length > 1) {
//       for (int i = 0; i < _polylinePoints.length - 1; i++) {
//         totalDistance += geo.Geolocator.distanceBetween(
//           _polylinePoints[i].latitude,
//           _polylinePoints[i].longitude,
//           _polylinePoints[i + 1].latitude,
//           _polylinePoints[i + 1].longitude,
//         );
//       }
//     }
//     setState(() {
//       _polylineDistance = totalDistance;
//     });
//   }

//   // --- UI and Dialogs ---

//   void _showMarkerInfo(MapMarker marker) {
//     if (marker.id == currentLocMarkerId) {
//       print("Tapped on current location marker.");
//       return;
//     }

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Marker Info"),
//           content: Text(
//               "ID: ${marker.id}\nLocation: ${marker.position.latitude.toStringAsFixed(5)}, ${marker.position.longitude.toStringAsFixed(5)}"),
//           actions: [
//             TextButton(
//               child: Text("Remove"),
//               onPressed: () {
//                 _removeMarker(marker);
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: Text("Close"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // --- Build Method ---

//   @override
//   Widget build(BuildContext context) {
//     LatLng initialMapCenter = _lastKnownLocation ?? defaultLocation;

//     return Scaffold(
//       body: FlutterMap(
//         mapController: _mapController,
//         options: MapOptions(
//           initialCenter: initialMapCenter,
//           initialZoom: 15.0,
//           minZoom: 3.0,
//           maxZoom: 18.0,
//           onTap: (tapPosition, point) {
//             _addMarker(point);
//           },
//         ),
//         children: [
//           TileLayer(
//             urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//             subdomains: ['a', 'b', 'c'],
//             userAgentPackageName: 'com.example.app',
//             tileBuilder: (context, tileWidget, tile) {
//               return tileWidget;
//             },
//           ),
//           PolylineLayer(
//             polylines: [
//               Polyline(
//                 points: _polylinePoints,
//                 strokeWidth: 4.0,
//                 color: Colors.deepPurple,
//               ),
//             ],
//           ),
//           MarkerLayer(
//             markers: _markers.map((markerData) {
//               bool isCurrentLocation = markerData.id == currentLocMarkerId;
//               IconData iconData = isCurrentLocation ? Icons.my_location : Icons.location_pin;
//               Color iconColor = isCurrentLocation ? Colors.redAccent : Colors.blueAccent;
//               double iconSize = isCurrentLocation ? 35.0 : 40.0;

//               return Marker(
//                 width: 40.0,
//                 height: 40.0,
//                 point: markerData.position,
//                 child: GestureDetector(
//                   onTap: () => _showMarkerInfo(markerData),
//                   child: Icon(
//                     iconData,
//                     color: iconColor,
//                     size: iconSize,
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//       floatingActionButton: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           FloatingActionButton(
//             onPressed: _clearUserMarkersAndPolyline,
//             tooltip: 'Clear Markers & Path',
//             backgroundColor: Colors.orangeAccent,
//             child: Icon(Icons.delete_sweep),
//           ),
//           SizedBox(height: 16),
//           if (_polylinePoints.isNotEmpty) // Show distance only if there are points
//             Text(
//               'Distance: ${_polylineDistance.toStringAsFixed(2)} meters',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//         ],
//       ),
//     );
//   }
// }
