import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shake_detector/shake_detector.dart';
import 'package:provider/provider.dart';
import '../models/car.dart';
import '../services/api_service.dart';
import '../widgets/car_card.dart';
import '../providers/favorite_provider.dart';
import 'car_details_screen.dart';
import 'support_screen.dart';

class VehicleListingScreen extends StatefulWidget {
  const VehicleListingScreen({super.key});

  @override
  State<VehicleListingScreen> createState() => _VehicleListingScreenState();
}

class _VehicleListingScreenState extends State<VehicleListingScreen> {
  late Future<List<Car>> futureVehicles;
  ShakeDetector? _shakeDetector;
  bool _supportSnackBarActive = false;
  bool _showOnlyFavorites = false;

  @override
  void initState() {
    super.initState();
    futureVehicles = ApiService.fetchVehicles();
    _setupShakeDetector();
  }

  void _setupShakeDetector() {
    _shakeDetector = ShakeDetector.autoStart(
      onShake: () {
        if (mounted && !_supportSnackBarActive) {
          _showSupportSnackBar();
        }
      },
    );
  }

  void _showSupportSnackBar() {
    _supportSnackBarActive = true;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            backgroundColor: isDark ? Colors.grey[900] : Colors.white,
            content: Text(
              'Need help?',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            action: SnackBarAction(
              label: 'Contact Support',
              textColor: isDark ? Colors.amber : Theme.of(context).primaryColor,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ContactSupportScreen(),
                  ),
                );
              },
            ),
            duration: const Duration(seconds: 3),
          ),
        )
        .closed
        .then((_) {
      _supportSnackBarActive = false;
    });
  }

  void _refreshVehicles() {
    setState(() {
      futureVehicles = ApiService.fetchVehicles();
    });
  }

  List<Car> _sortAndFilterCars(List<Car> cars, Set<String> favoriteIds) {
    if (_showOnlyFavorites) {
      return cars.where((car) => favoriteIds.contains(car.id)).toList()
        ..sort((a, b) => a.make!.compareTo(b.make!));
    }

    return [...cars]..sort((a, b) {
        final aIsFavorite = favoriteIds.contains(a.id);
        final bIsFavorite = favoriteIds.contains(b.id);
        if (aIsFavorite && !bIsFavorite) return -1;
        if (!aIsFavorite && bIsFavorite) return 1;
        return a.make!.compareTo(b.make!);
      });
  }

  @override
  void dispose() {
    _shakeDetector?.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Vehicles'),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.white,
        actions: [
          // Favorites Filter Button
          IconButton(
            icon: Icon(
              _showOnlyFavorites ? Icons.favorite : Icons.favorite_border,
              color: _showOnlyFavorites
                  ? Colors.red
                  : (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.grey[800]),
            ),
            onPressed: () {
              setState(() {
                _showOnlyFavorites = !_showOnlyFavorites;
              });
            },
          ),
          // Refresh Button
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.grey[800],
            ),
            onPressed: _refreshVehicles,
          ),
        ],
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme),
        ),
        child: Consumer<FavoriteProvider>(
          builder: (context, favoriteProvider, _) {
            return FutureBuilder<List<Car>>(
              future: futureVehicles,
              builder: (context, AsyncSnapshot<List<Car>> snapshot) {
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
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.red),
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
                final processedCars = _sortAndFilterCars(
                  cars,
                  favoriteProvider.favoriteIds,
                );

                if (processedCars.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _showOnlyFavorites
                              ? Icons.favorite_border
                              : Icons.directions_car_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _showOnlyFavorites
                              ? 'No favorite vehicles yet'
                              : 'No vehicles available',
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                final isLandscape =
                    MediaQuery.of(context).orientation == Orientation.landscape;

                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: processedCars.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isLandscape ? 2 : 1,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.2,
                  ),
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final car = processedCars[index];
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
            );
          },
        ),
      ),
    );
  }
}
