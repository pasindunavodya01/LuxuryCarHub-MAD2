import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/car.dart';

class FavoriteProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  Set<String> _favoriteIds = {};

  Set<String> get favoriteIds => _favoriteIds;

  FavoriteProvider() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final ids = await _databaseHelper.getFavoriteIds();
    _favoriteIds = ids.toSet();
    notifyListeners();
  }

  Future<void> toggleFavorite(Car car) async {
    await _databaseHelper.toggleFavorite(car);
    if (_favoriteIds.contains(car.id)) {
      _favoriteIds.remove(car.id);
    } else {
      _favoriteIds.add(car.id!);
    }
    notifyListeners();
  }

  bool isFavorite(String? carId) {
    return carId != null && _favoriteIds.contains(carId);
  }
}
