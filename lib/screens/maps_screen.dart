import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/dealer_location.dart';
import '../services/api_service.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  late final MapController _mapController;
  List<Marker> _markers = [];
  Position? _currentPosition;
  bool _isLoading = true;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _loadDealers();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadDealers() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      await _getCurrentLocation();
      final dealers = await ApiService.fetchDealerLocations();

      print(
          'Current Location: ${_currentPosition?.latitude}, ${_currentPosition?.longitude}');
      print('Dealers found: ${dealers.length}');
      dealers.forEach(
          (d) => print('Dealer: ${d.name} at ${d.latitude}, ${d.longitude}'));

      if (!mounted) return;

      setState(() {
        _markers = [
          if (_currentPosition != null)
            Marker(
              point: LatLng(
                  _currentPosition!.latitude, _currentPosition!.longitude),
              width: 40,
              height: 40,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.7),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.my_location,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ...dealers.map(
            (dealer) => Marker(
              point: LatLng(dealer.latitude, dealer.longitude),
              width: 100,
              height: 100,
              child: GestureDetector(
                onTap: () => _showDealerInfo(dealer),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.9),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.car_repair,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        dealer.name,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ];
        _isLoading = false;
      });

      if (_mapReady) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _fitBounds();
        });
      }
    } catch (e) {
      if (!mounted) return;
      print('Error loading dealers: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading dealers: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getCurrentLocation() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }

    try {
      _currentPosition = await Geolocator.getCurrentPosition();
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _showDealerInfo(DealerLocation dealer) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dealer.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (dealer.address != null) ...[
              const SizedBox(height: 8),
              Text(dealer.address!),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openDirections(dealer),
                    icon: const Icon(Icons.directions),
                    label: const Text('Get Directions'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDirections(DealerLocation dealer) async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to get current location')),
      );
      return;
    }

    try {
      final url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&origin=${_currentPosition!.latitude},${_currentPosition!.longitude}&destination=${dealer.latitude},${dealer.longitude}',
      );

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        final osmUrl = Uri.parse(
          'https://www.openstreetmap.org/directions?engine=osrm_car&route=${_currentPosition!.latitude},${_currentPosition!.longitude};${dealer.latitude},${dealer.longitude}',
        );
        if (await canLaunchUrl(osmUrl)) {
          await launchUrl(osmUrl, mode: LaunchMode.externalApplication);
        } else {
          throw 'Could not launch maps';
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening directions: $e')),
        );
      }
    }
  }

  void _fitBounds() {
    if (_markers.isEmpty) return;

    final bounds = LatLngBounds.fromPoints(
      _markers.map((marker) => marker.point).toList(),
    );
    _mapController.fitBounds(
      bounds,
      options: const FitBoundsOptions(
        padding: EdgeInsets.all(50.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dealer Locations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDealers,
          ),
          IconButton(
            icon: const Icon(Icons.fit_screen),
            onPressed: _fitBounds,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _currentPosition != null
                    ? LatLng(
                        _currentPosition!.latitude, _currentPosition!.longitude)
                    : const LatLng(7.8731, 80.7718),
                zoom: 8.0,
                onMapReady: () {
                  _mapReady = true;
                  if (_markers.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _fitBounds();
                    });
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.flutter_application_1',
                  tileProvider: CancellableNetworkTileProvider(),
                ),
                MarkerLayer(markers: _markers),
              ],
            ),
    );
  }
}
