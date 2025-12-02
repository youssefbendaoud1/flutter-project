import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/country.dart';
import 'package:flutter_application_1/models/quote.dart';
import 'package:flutter_application_1/services/quote_service.dart';
import 'package:provider/provider.dart';

import '../providers/country_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/country_card.dart';
import 'detail_screen.dart';
import 'favorites_screen.dart';

// Sorting options
enum SortOption { name, population, region }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = '';
  SortOption _sortOption = SortOption.name; // default sorting

  // BONUS 6 – Quote API (random quote)
  Quote? _quote;
  bool _isQuoteLoading = false;
  final _quoteService = QuoteService();

  Future<void> _loadQuote() async {
    setState(() => _isQuoteLoading = true);
    try {
      final q = await _quoteService.fetchRandomQuote();
      setState(() => _quote = q);
    } catch (_) {} 
    finally {
      setState(() => _isQuoteLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await context.read<CountryProvider>().loadCountries();
      await context.read<CountryProvider>().loadFavorites();
      await _loadQuote(); // Load 2nd API quote
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CountryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Country Explorer"),

        actions: [
          // Sorting menu
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() => _sortOption = value);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: SortOption.name,
                child: Text('Name (A–Z)'),
              ),
              PopupMenuItem(
                value: SortOption.population,
                child: Text('Population (high → low)'),
              ),
              PopupMenuItem(
                value: SortOption.region,
                child: Text('Region (A–Z)'),
              ),
            ],
          ),

          // Favorites page
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              );
            },
          ),

          // Dark/Light theme toggle
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
          // BONUS 6 : Quote Card (2nd API)
          if (_quote != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _isQuoteLoading
                          ? const LinearProgressIndicator()
                          : const SizedBox.shrink(),
                      Text(
                        '"${_quote!.content}"',
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "- ${_quote!.author}",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Search bar
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
              onRefresh: () async {
                await provider.loadCountries();
                await _loadQuote();
              },
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

    // Search filter
    List<Country> countries = searchQuery.isEmpty
        ? provider.countries
        : provider.search(searchQuery);

    // Sorting
    final sorted = List<Country>.from(countries);

    switch (_sortOption) {
      case SortOption.name:
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.population:
        sorted.sort((a, b) => b.population.compareTo(a.population));
        break;
      case SortOption.region:
        sorted.sort((a, b) => a.region.compareTo(b.region));
        break;
    }

    // AnimatedSwitcher for smooth transition
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: GridView.builder(
        key: ValueKey('${searchQuery}_${_sortOption}_${sorted.length}'),
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: sorted.length,
        itemBuilder: (_, index) {
          final c = sorted[index];
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
      ),
    );
  }
}
