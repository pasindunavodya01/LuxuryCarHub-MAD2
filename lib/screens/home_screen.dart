import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shake_detector/shake_detector.dart';
import '../screens/support_screen.dart';
import '../constants/colors.dart';
import '../models/car.dart';
import '../models/dealer.dart';
import '../services/api_service.dart';
import 'vehicle_listing_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Car>> futureCars;
  late Future<List<Dealer>> futureDealers;
  ShakeDetector? _shakeDetector;
  bool _supportSnackBarActive = false;

  @override
  void initState() {
    super.initState();
    _refreshData();

    _shakeDetector = ShakeDetector.autoStart(
      onShake: () {
        if (mounted && !_supportSnackBarActive) {
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
                    textColor:
                        isDark ? Colors.amber : Theme.of(context).primaryColor,
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
            // Wait briefly before resetting flag
            Future.delayed(const Duration(milliseconds: 1000), () {
              _supportSnackBarActive = false;
            });
          });
        }
      },
    );
  }

  void _refreshData() {
    setState(() {
      futureCars = ApiService.fetchVehicles();
      futureDealers = ApiService.fetchDealers();
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
        title: const Text('LuxuryCarHub'),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.grey[800],
            ),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero section with overlay
              Stack(
                children: [
                  Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: Center(
                      child: Image.asset(
                        'assets/images/BYD-Song-L-Side-Single-BYD.webp',
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    height: 200,
                    color: Colors.black.withOpacity(0.4),
                    alignment: Alignment.center,
                    child: const Text(
                      'Find your dream car today!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              // Featured Vehicles Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Featured Vehicles',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: AppColors.getTextColor(context),
                                  ) ??
                              const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Browse our latest collection of luxury vehicles',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),

              // Featured Cars Horizontal List
              SizedBox(
                height: 220,
                child: FutureBuilder<List<Car>>(
                  future: futureCars,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No vehicles available'));
                    }

                    final cars = snapshot.data!;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount:
                          cars.length > 6 ? 6 : cars.length, // Show max 6 cars
                      itemBuilder: (context, index) {
                        final car = cars[index];
                        return Container(
                          width: 200,
                          margin: const EdgeInsets.only(right: 16),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Car Image
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  child: Container(
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                    ),
                                    child: Image.network(
                                      car.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Icon(
                                          Icons.directions_car,
                                          size: 50,
                                          color: Colors.grey[400],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                // Car Details
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${car.make} ${car.model}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Rs. ${car.price.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white70
                                              : Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Show All Cars Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const VehicleListingScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Show All Cars'),
                ),
              ),

              // Dealers Section Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Our Dealers',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Our network of verified dealers is at your service',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),

              // Dealers List
              SizedBox(
                height: 160,
                child: FutureBuilder<List<Dealer>>(
                  future: futureDealers,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No dealers available'));
                    }

                    final dealers = snapshot.data!;
                    final int dealerCount =
                        dealers.length > 6 ? 6 : dealers.length;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: dealerCount,
                      itemBuilder: (context, index) {
                        final dealer = dealers[index];
                        return Container(
                          width: 200,
                          margin: const EdgeInsets.only(right: 16, bottom: 16),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    dealer.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  if (dealer.phoneNumber.isNotEmpty)
                                    Text(
                                      dealer.phoneNumber,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  OutlinedButton(
                                    onPressed: dealer.phoneNumber.isNotEmpty
                                        ? () async {
                                            final Uri launchUri = Uri(
                                              scheme: 'tel',
                                              path: dealer.phoneNumber,
                                            );
                                            try {
                                              await launchUrl(launchUri);
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'Could not launch dialer: $e'),
                                                  ),
                                                );
                                              }
                                            }
                                          }
                                        : null,
                                    child: const Text('Contact'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
