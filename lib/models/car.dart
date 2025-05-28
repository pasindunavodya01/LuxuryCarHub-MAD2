class Car {
  final String? id;
  final String? make;
  final String? model;
  final String? year;
  final double price;
  final String? fuel;
  final String? images;
  final String? description;

  Car({
    this.id,
    this.make,
    this.model,
    this.year,
    required this.price,
    this.fuel,
    this.images,
    this.description,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id']?.toString(),
      make: json['make']?.toString(),
      model: json['model']?.toString(),
      year: json['year']?.toString(),
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      fuel: json['fuel']?.toString(),
      images: json['images']?.toString(),
      description: json['description']?.toString(),
    );
  }

  String get imageUrl {
    if (images == null || images!.isEmpty) {
      return 'https://skyblue-goshawk-195189.hostingersite.com/storage/cars/default.jpg';
    }

    const baseUrl = 'https://skyblue-goshawk-195189.hostingersite.com';
    final cleanPath = images!.startsWith('/') ? images!.substring(1) : images!;

    if (cleanPath.startsWith('http')) {
      return cleanPath;
    }

    return '$baseUrl/storage/$cleanPath';
  }
}
