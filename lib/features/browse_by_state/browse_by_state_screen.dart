import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/debug_navigation_drawer.dart';
import '../../models/india_states.dart';
import '../../services/destination_repository.dart';
import 'providers/state_provider.dart';

/*
================================================================================
TODO: CHOROPLETH / SHAPE MAP UPGRADE ROADMAP
================================================================================
To upgrade this text list into an interactive visual choropleth map of India:
1. Obtain an official GeoJSON file of Indian States & Union Territories
   (e.g., india_states.geojson).
2. Add `flutter_map` (or `maplibre_gl`) and `latlong2` packages to pubspec.yaml.
3. Render a `FlutterMap` widget with a custom `PolygonLayer` parsing feature
   geometry boundaries from the GeoJSON dataset.
4. Fill polygon colors dynamically based on destination count per state
   (e.g. darker green shade for higher spot count).
5. Add tap listeners to polygons to select state boundaries with interactive
   tooltip overlays.
================================================================================
*/

class BrowseByStateScreen extends ConsumerStatefulWidget {
  const BrowseByStateScreen({super.key});

  @override
  ConsumerState<BrowseByStateScreen> createState() => _BrowseByStateScreenState();
}

class _BrowseByStateScreenState extends ConsumerState<BrowseByStateScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncDestinations = ref.watch(allDestinationsProvider);
    final allDestinations = asyncDestinations.asData?.value ?? [];

    // Calculate destination counts per state name
    final Map<String, int> destinationCounts = {};
    for (final dest in allDestinations) {
      final stateKey = dest.state.toLowerCase();
      destinationCounts[stateKey] = (destinationCounts[stateKey] ?? 0) + 1;
    }

    // Filter states by search query
    final filteredStates = IndiaStates.statesAndUtList.where((stateName) {
      if (_searchQuery.isEmpty) return true;
      return stateName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList()
      ..sort();

    // Group states alphabetically by first letter
    final Map<String, List<String>> groupedStates = {};
    for (final stateName in filteredStates) {
      final firstLetter = stateName.substring(0, 1).toUpperCase();
      groupedStates.putIfAbsent(firstLetter, () => []).add(stateName);
    }

    final alphabetKeys = groupedStates.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse by State'),
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu),
              tooltip: 'Open Route Menu',
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: const DebugNavigationDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Search Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explore India State by State',
                    style: AppTypography.textTheme.headlineMedium?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select a state to filter map locations and trails',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Real-time Search Field
                  TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.trim();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search 28 states & 8 union territories...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Alphabetically Sectioned List of States & UTs
            Expanded(
              child: filteredStates.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off, size: 48, color: AppColors.textSecondary),
                          const SizedBox(height: 8),
                          Text(
                            'No states match "$_searchQuery"',
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                      itemCount: alphabetKeys.length,
                      itemBuilder: (context, sectionIndex) {
                        final letter = alphabetKeys[sectionIndex];
                        final statesInGroup = groupedStates[letter]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section Alphabet Header
                            Padding(
                              padding: const EdgeInsets.only(top: 12.0, bottom: 6.0),
                              child: Text(
                                letter,
                                style: AppTypography.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  fontSize: 18,
                                ),
                              ),
                            ),

                            // State Rows
                            ...statesInGroup.map((stateName) {
                              final count = destinationCounts[stateName.toLowerCase()] ?? 0;
                              return _StateTile(
                                stateName: stateName,
                                spotCount: count,
                                onTap: () {
                                  // Set state filter in Riverpod & navigate to map
                                  ref.read(selectedStateProvider.notifier).selectState(stateName);
                                  context.go('/map');
                                },
                              );
                            }),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StateTile extends StatelessWidget {
  final String stateName;
  final int spotCount;
  final VoidCallback onTap;

  const _StateTile({
    required this.stateName,
    required this.spotCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasSpots = spotCount > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.0),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: hasSpots ? AppColors.primaryLight.withValues(alpha: 0.4) : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  hasSpots ? Icons.location_on : Icons.location_on_outlined,
                  color: hasSpots ? AppColors.accent : AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    stateName,
                    style: AppTypography.textTheme.bodyLarge?.copyWith(
                      fontWeight: hasSpots ? FontWeight.bold : FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                // Spot Count Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: hasSpots
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    hasSpots ? '$spotCount spots' : '0 spots',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      fontWeight: hasSpots ? FontWeight.bold : FontWeight.normal,
                      color: hasSpots ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
