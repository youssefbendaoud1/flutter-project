import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/country_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/country_card.dart';
import 'detail_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CountryProvider>().loadCountries();
      context.read<CountryProvider>().loadFavorites(); // BONUS 2
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CountryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Country Explorer"),

        actions: [
          // ❤️ Page Favoris
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              );
            },
          ),

          // 🌙 Dark/Light Mode
          IconButton(
            icon: Icon(
              context.watch<ThemeProvider>().isDark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme();
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // 🔍 Search
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (value) {
                setState(() => searchQuery = value);
              },
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Search country...",
                border: OutlineInputBorder(),
              ),
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () => provider.loadCountries(),
              child: _buildBody(provider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(CountryProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(child: Text(provider.error!));
    }

    final countries = searchQuery.isEmpty
        ? provider.countries
        : provider.search(searchQuery);

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: countries.length,
      itemBuilder: (_, index) {
        final c = countries[index];
        return CountryCard(
          country: c,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DetailScreen(country: c)),
            );
          },
        );
      },
    );
  }
}

