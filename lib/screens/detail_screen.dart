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
          // ❤️ Favorite toggle button
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
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FLAG WITH HERO ANIMATION
            Center(
              child: SizedBox(
                height: 180,
                child: country.flagUrl.isNotEmpty
                    ? Hero(
                        tag: 'flag_${country.name}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            country.flagUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : const Icon(Icons.flag, size: 120),
              ),
            ),

            const SizedBox(height: 30),

            // COUNTRY INFO
            Text(
              country.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 15),

            _buildInfoRow("Capital", country.capital),
            _buildInfoRow("Region", country.region),
            _buildInfoRow("Population", country.population.toString()),
          ],
        ),
      ),
    );
  }

  // Small reusable info row
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

