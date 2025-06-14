import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/car.dart';

class CarDetailsScreen extends StatefulWidget {
  final Car car;

  const CarDetailsScreen({
    super.key,
    required this.car,
  });

  @override
  _CarDetailsScreenState createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  bool _isDescriptionExpanded = false;

  void _callDealer() async {
    final uri = Uri.parse('tel:');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch dialer')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final car = widget.car;
    final description = car.description ?? '';
    final isLongDescription = description.length > 150;

    String displayDescription;
    if (!_isDescriptionExpanded && isLongDescription) {
      displayDescription = '${description.substring(0, 150)}...';
    } else {
      displayDescription = description;
    }

    return Scaffold(
      appBar: AppBar(
        title:
            Text('${widget.car.make ?? 'Unknown'} ${widget.car.model ?? ''}'),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.white,
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme),
          cardTheme: CardThemeData(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]
                : Colors.white,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Car Image
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  car.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.directions_car,
                        size: 64,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),

              // Car Details
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price and Year
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rs. ${car.price.toStringAsFixed(2)}',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.grey[800],
                              ),
                        ),
                        Text(
                          car.year ?? 'N/A',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Specifications
                    const Text(
                      'Specifications',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SpecificationItem(
                      icon: Icons.calendar_today,
                      label: 'Year',
                      value: car.year ?? 'N/A',
                    ),
                    SpecificationItem(
                      icon: Icons.directions_car,
                      label: 'Make & Model',
                      value: '${car.make ?? 'Unknown'} ${car.model ?? ''}',
                    ),
                    if (car.fuel != null)
                      SpecificationItem(
                        icon: Icons.local_gas_station,
                        label: 'Fuel Type',
                        value: car.fuel!,
                      ),

                    const SizedBox(height: 24),

                    // Description Section
                    if (description.isNotEmpty) ...[
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        displayDescription,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      if (isLongDescription)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isDescriptionExpanded = !_isDescriptionExpanded;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              _isDescriptionExpanded
                                  ? 'Show less'
                                  : 'Read more',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _callDealer,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Contact Dealer'),
          ),
        ),
      ),
    );
  }
}

class SpecificationItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const SpecificationItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
