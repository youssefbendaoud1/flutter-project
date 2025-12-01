class Country {
  final String name;
  final String capital;
  final String region;
  final int population;
  final String flagUrl;

  Country({
    required this.name,
    required this.capital,
    required this.region,
    required this.population,
    required this.flagUrl,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    final flags = json['flags'] ?? {};
    return Country(
      name: json['name'] ?? 'Unknown',
      capital: json['capital'] ?? 'N/A',
      region: json['region'] ?? 'Unknown',
      population: (json['population'] ?? 0) as int,
      flagUrl: flags['png'] ?? '',
    );
  }
}
