import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/country.dart';
import '../services/api_service.dart';

class CountryProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Country> _countries = [];
  bool _isLoading = false;
  String? _error;

  List<String> favorites = []; // BONUS 2

  List<Country> get countries => _countries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch API
  Future<void> loadCountries() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _countries = await _api.fetchCountries();
    } catch (e) {
      _error = e.toString();
      _countries = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // BONUS 1 : Search
  List<Country> search(String query) {
    final q = query.toLowerCase();
    return _countries
        .where((c) => c.name.toLowerCase().contains(q))
        .toList();
  }

  // BONUS 2 : FAVORIS
  bool isFavorite(Country c) => favorites.contains(c.name);

  void toggleFavorite(Country c) async {
    if (isFavorite(c)) {
      favorites.remove(c.name);
    } else {
      favorites.add(c.name);
    }
    notifyListeners();
    saveFavorites();
  }

  Future<void> saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favorites', favorites);
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    favorites = prefs.getStringList('favorites') ?? [];
    notifyListeners();
  }
}
