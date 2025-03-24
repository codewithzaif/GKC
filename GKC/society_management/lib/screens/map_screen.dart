import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/member.dart';
import '../services/database_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = true;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  
  // Default camera position
  final CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(28.7041, 77.1025), // Default to Delhi, India
    zoom: 14.0,
  );

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() {
      _isLoading = true;
    });

    final members = await _databaseService.getMembers();
    _setupMarkers(members);
    
    setState(() {
      _isLoading = false;
    });
  }

  void _setupMarkers(List<Member> members) {
    final markers = <Marker>{};
    
    for (final member in members) {
      final LatLng position = LatLng(member.latitude, member.longitude);
      
      markers.add(
        Marker(
          markerId: MarkerId(member.id),
          position: position,
          infoWindow: InfoWindow(
            title: member.name,
            snippet: 'House: ${member.houseNumber} | ${member.hasPaid ? 'Paid' : 'Unpaid'}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            member.hasPaid ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
          ),
        ),
      );
    }
    
    setState(() {
      _markers = markers;
    });
    
    // Center the map if markers are available
    if (markers.isNotEmpty && _mapController != null) {
      _centerMap(members);
    }
  }

  void _centerMap(List<Member> members) {
    if (members.isEmpty) return;
    
    // Calculate the average latitude and longitude to center the map
    double avgLat = 0;
    double avgLng = 0;
    
    for (final member in members) {
      avgLat += member.latitude;
      avgLng += member.longitude;
    }
    
    avgLat /= members.length;
    avgLng /= members.length;
    
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(avgLat, avgLng),
          zoom: 14.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map Widget
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            markers: _markers,
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            onMapCreated: (controller) {
              _mapController = controller;
              
              // Center the map after it's created if we have members
              _databaseService.getMembers().then((members) {
                if (members.isNotEmpty) {
                  _centerMap(members);
                }
              });
            },
          ),
          
          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            
          // Legend
          Positioned(
            left: 16,
            bottom: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Legend',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Paid'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Unpaid'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.refresh),
        onPressed: _loadMembers,
      ),
    );
  }
} 