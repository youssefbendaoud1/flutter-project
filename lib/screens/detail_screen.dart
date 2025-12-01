import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/country.dart';
import '../providers/country_provider.dart';

class DetailScreen extends StatefulWidget {
  final Country country;

  const DetailScreen({super.key, required this.country});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CountryProvider>();
    final country = widget.country;

    return Scaffold(
      appBar: AppBar(
        title: Text(country.name),
        actions: [
          IconButton(
            icon: Icon(
              provider.isFavorite(country)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: provider.isFavorite(country) ? Colors.red : null,
            ),
            onPressed: () {
              provider.toggleFavorite(country);
            },
          )
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: country.flagUrl.isNotEmpty
                  ? Image.network(country.flagUrl, height: 150)
                  : const Icon(Icons.flag, size: 100),
            ),
            const SizedBox(height: 20),

            Text("Capital: ${country.capital}",
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),

            Text("Region: ${country.region}"),
            const SizedBox(height: 10),

            Text("Population: ${country.population}"),
          ],
        ),
      ),
    );
  }
}
