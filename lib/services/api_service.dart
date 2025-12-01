import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/country.dart';

class ApiService {
  static const _baseUrl = 'https://www.apicountries.com';

  Future<List<Country>> fetchCountries() async {
    final url = Uri.parse('$_baseUrl/countries');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Country.fromJson(e)).toList();
    } else {
      // API error handling (DH-03)
      throw Exception('Failed to load countries. Code: ${response.statusCode}');
    }
  }
}
