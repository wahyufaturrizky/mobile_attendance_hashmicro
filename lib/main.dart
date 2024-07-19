/*
 * Attendance Hashmicro Mobile App
 * Created by Wahyu Fatur Rizki
 * https://www.linkedin.com/in/wahyu-fatur-rizky/
 * 
 * Copyright (c) 2024 Wahyu Fatur Rizki, LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile Attendance',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mobile Attendance'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateLocationScreen()),
                );
              },
              child: Text('Create Location'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Example Location, replace with actual saved location
                Location exampleLocation = Location(
                  id: '1',
                  name: 'Office',
                  latitude: -6.200000,
                  longitude: 106.816666,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CreateAttendanceScreen(location: exampleLocation),
                  ),
                );
              },
              child: Text('Create Attendance'),
            ),
          ],
        ),
      ),
    );
  }
}

class Location {
  final String id;
  final String name;
  final double latitude;
  final double longitude;

  Location({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

class CreateLocationScreen extends StatefulWidget {
  @override
  _CreateLocationScreenState createState() => _CreateLocationScreenState();
}

class _CreateLocationScreenState extends State<CreateLocationScreen> {
  final TextEditingController _nameController = TextEditingController();
  LatLng? _selectedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Location')),
      body: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Location Name'),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition:
                  CameraPosition(target: LatLng(0, 0), zoom: 2),
              onTap: (position) {
                setState(() {
                  _selectedLocation = position;
                });
              },
              markers: _selectedLocation != null
                  ? {
                      Marker(
                          markerId: MarkerId('selected'),
                          position: _selectedLocation!)
                    }
                  : {},
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_selectedLocation != null &&
                  _nameController.text.isNotEmpty) {
                // Save location to your data storage (e.g., local database or API)
                print(
                    'Location saved: ${_nameController.text}, $_selectedLocation');
              }
            },
            child: Text('Save Location'),
          ),
        ],
      ),
    );
  }
}

class Attendance {
  final String id;
  final String locationId;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final bool isWithinRange;

  Attendance({
    required this.id,
    required this.locationId,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.isWithinRange,
  });
}

class CreateAttendanceScreen extends StatefulWidget {
  final Location location;

  CreateAttendanceScreen({required this.location});

  @override
  _CreateAttendanceScreenState createState() => _CreateAttendanceScreenState();
}

class _CreateAttendanceScreenState extends State<CreateAttendanceScreen> {
  bool _isLoading = false;

  Future<void> _createAttendance() async {
    setState(() {
      _isLoading = true;
    });

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    double distanceInMeters = Geolocator.distanceBetween(
      widget.location.latitude,
      widget.location.longitude,
      position.latitude,
      position.longitude,
    );

    bool isWithinRange = distanceInMeters <= 50;

    Attendance attendance = Attendance(
      id: UniqueKey().toString(),
      locationId: widget.location.id,
      timestamp: DateTime.now(),
      latitude: position.latitude,
      longitude: position.longitude,
      isWithinRange: isWithinRange,
    );

    // Save attendance to your data storage (e.g., local database or API)
    setState(() {
      _isLoading = false;
    });

    if (isWithinRange) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Attendance successful!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You are too far from the location!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Attendance')),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _createAttendance,
                child: Text('Submit Attendance'),
              ),
      ),
    );
  }
}
