import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/country_provider.dart';
import '../widgets/country_card.dart';
import 'detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CountryProvider>();

    final favoritesList = provider.countries
        .where((c) => provider.isFavorite(c))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("My Favorites")),

      body: favoritesList.isEmpty
          ? const Center(
              child: Text("No favorite countries yet ❤️"),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: favoritesList.length,
              itemBuilder: (_, i) {
                final country = favoritesList[i];
                return CountryCard(
                  country: country,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(country: country),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
