import 'package:flutter/material.dart';
import '../models/car.dart';
import '../services/api_service.dart';
import '../widgets/car_card.dart';
import 'car_details_screen.dart';

class VehicleListingScreen extends StatefulWidget {
  const VehicleListingScreen({super.key});

  @override
  State<VehicleListingScreen> createState() => _VehicleListingScreenState();
}

class _VehicleListingScreenState extends State<VehicleListingScreen> {
  late Future<List<Car>> futureVehicles;

  @override
  void initState() {
    super.initState();
    futureVehicles = ApiService.fetchVehicles();
  }

  void _refreshVehicles() {
    setState(() {
      futureVehicles = ApiService.fetchVehicles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Vehicles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshVehicles,
          ),
        ],
      ),
      body: FutureBuilder<List<Car>>(
        future: futureVehicles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshVehicles,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final cars = snapshot.data ?? [];
          if (cars.isEmpty) {
            return const Center(
              child: Text('No vehicles available'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: cars.length,
            itemBuilder: (context, index) {
              final car = cars[index];
              return CarCard(
                car: car,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CarDetailsScreen(car: car),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
