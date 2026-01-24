import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:gap/gap.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../bloc/metro_cubit.dart';
import '../../domain/entities/station.dart';
import '../../data/services/place_search_service.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PlaceSearchScreen extends StatefulWidget {
  final bool isSource;
  const PlaceSearchScreen({super.key, required this.isSource});

  @override
  State<PlaceSearchScreen> createState() => _PlaceSearchScreenState();
}

class _PlaceSearchScreenState extends State<PlaceSearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  final PlaceSearchService _placeSearchService = PlaceSearchService();

  Station? _nearestStation;
  String? _searchedPlace;
  LatLng? _selectedLocation;
  double? _distanceToNearest;
  bool _isSearching = false;

  // Manual Mapping for Famous Landmarks to Specific Stations
  final Map<String, String> _landmarkToStationMap = {
    'downtown': 'Sadat',
    'tahrir': 'Sadat',
    'sadat': 'Sadat',
    'muhammad naguib': 'Mohamed Naguib',
    'opera': 'Opera',
    'dokki': 'Dokki',
    'bohooth': 'Bohooth',
    'cairo university': 'Cairo University',
    'shubra': 'Shubra El-Kheima',
    'ramses': 'Al-Shohadaa',
    'ramsiss': 'Al-Shohadaa',
    'boulaq': 'Boulaq El-Dakrour',
    'atterba': 'Attaba',
    'abbasiya': 'Abbasia',
    'fair zone': 'Fair Zone',
    'cairo stadium': 'Cairo Stadium',
    'helwan': 'Helwan',
    'maadi': 'Maadi',
    'marg': 'El-Marg',
    'new marg': 'New El-Marg',
    'shams': 'Ain Shams',
    'matareya': 'El-Matareya',
    'kobri': 'Kobri El-Qobba',
    'saray': 'Saray El-Qobba',
    'hammamat': 'Hammamat El-Qobba',
    'zytown': 'Heliet El-Zaitoun',
    'haddayeq': 'Hadayeq El-Zaitoun',
    'khalafawy': 'El-Khalafawy',
    'mezallat': 'El-Mezallat',
    'koliet el-zeraa': 'Koliet El-Zeraa',
    'gamal abdel nasser': 'Gamal Abd Al-Nasser', // Ambulance
    'ambulance': 'Gamal Abd Al-Nasser', // Esaaf
    'esaaf': 'Gamal Abd Al-Nasser',
    'orabi': 'Orabi',
    'nasser': 'Gamal Abd Al-Nasser',
  };

  // Arabic mapping
  final Map<String, String> _landmarkToStationMapAr = {
    'وسط البلد': 'Sadat',
    'التحرير': 'Sadat',
    'سادات': 'Sadat',
    'محمد نجيب': 'Mohamed Naguib',
    'الاوبرا': 'Opera',
    'الدقي': 'Dokki',
    'البحوث': 'Bohooth',
    'جامعة القاهرة': 'Cairo University',
    'شبرا': 'Shubra El-Kheima',
    'رمسيس': 'Al-Shohadaa',
    'الشهداء': 'Al-Shohadaa',
    'بولاق': 'Boulaq El-Dakrour',
    'العتبة': 'Attaba',
    'العباسية': 'Abbasia',
    'الاستاد': 'Cairo Stadium',
    'حلوان': 'Helwan',
    'المعادي': 'Maadi',
    'المرج': 'El-Marg',
    'المرج الجديدة': 'New El-Marg',
    'عين شمس': 'Ain Shams',
    'المطرية': 'El-Matareya',
    'كوبري القبة': 'Kobri El-Qobba',
    'سراي القبة': 'Saray El-Qobba',
    'حمامات القبة': 'Hammamat El-Qobba',
    'الزيتون': 'Heliet El-Zaitoun',
    'حدائق الزيتون': 'Hadayeq El-Zaitoun',
    'الخلفاوي': 'El-Khalafawy',
    'المظلات': 'El-Mezallat',
    'كلية الزراعة': 'Koliet El-Zeraa',
    'جمال عبد الناصر': 'Gamal Abd Al-Nasser',
    'الاسعاف': 'Gamal Abd Al-Nasser',
    'عرابي': 'Orabi',
  };

  Future<void> _onSearchSubmitted(String query) async {
    if (query.isEmpty) return;

    setState(() => _isSearching = true);
    final isAr = context.locale.languageCode == 'ar';
    final lowerQuery = query.toLowerCase().trim();

    // 1. Check Specific Landmark Mappings First
    String? mappedStationName;
    if (isAr) {
      _landmarkToStationMapAr.forEach((key, stationEnName) {
        if (key == lowerQuery || lowerQuery.contains(key)) {
          mappedStationName = stationEnName;
        }
      });
    } else {
      _landmarkToStationMap.forEach((key, stationEnName) {
        if (key == lowerQuery || lowerQuery.contains(key)) {
          mappedStationName = stationEnName;
        }
      });
    }

    if (mappedStationName != null) {
      final stations = context.read<MetroCubit>().state.stations;
      try {
        final targetStation = stations.firstWhere(
          (s) => s.nameEn == mappedStationName,
        );
        // Simulate finding it at the station's location
        _findNearestStation(
          targetStation.latitude,
          targetStation.longitude,
          query,
        );
        setState(() => _isSearching = false);
        return;
      } catch (e) {
        // Fallback if mapping incorrect or station not found in list logic
      }
    }

    // 2. Search in existing popular places list (local)
    for (var p in _popularPlaces) {
      if (p['name'].toLowerCase().contains(lowerQuery) ||
          p['nameAr'].contains(query)) {
        _findNearestStation(
          p['lat'],
          p['lng'],
          (isAr ? p['nameAr'] : p['name']),
        );
        setState(() => _isSearching = false);
        return;
      }
    }

    // 3. Search in station names directly
    final stations = context.read<MetroCubit>().state.stations;
    for (var s in stations) {
      if (s.nameEn.toLowerCase().contains(lowerQuery) ||
          s.nameAr.contains(query)) {
        _findNearestStation(s.latitude, s.longitude, s.getName(context));
        setState(() => _isSearching = false);
        return;
      }
    }

    // 4. Online Search via Nominatim/OSM
    try {
      final results = await _placeSearchService.searchPlaces(query);
      if (results.isNotEmpty) {
        final first = results.first;
        _findNearestStation(
          first.location.latitude,
          first.location.longitude,
          first.name,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('no_place_found'.tr())));
        }
      }
    } catch (e) {
      // Ignore network errors for now or show simplified msg
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _animateMapMove(LatLng destLocation, double destZoom) {
    if (!mounted) return;

    // Simple move if animation is too complex or fails
    _mapController.move(destLocation, destZoom);
  }

  // Expanded Popular Places List
  final List<Map<String, dynamic>> _popularPlaces = [
    {
      'name': 'Cairo Tower',
      'nameAr': 'برج القاهرة',
      'lat': 30.0459,
      'lng': 31.2243,
      'icon': Icons.location_city,
    },
    {
      'name': 'Tahrir Square',
      'nameAr': 'ميدان التحرير',
      'lat': 30.0444,
      'lng': 31.2357,
      'icon': Icons.local_activity, // Or another appropriate icon
    },
    {
      'name': 'Ramses Station',
      'nameAr': 'محطة رمسيس',
      'lat': 30.0636,
      'lng': 31.2468,
      'icon': Icons.train,
    },
    {
      'name': 'Egyptian Museum',
      'nameAr': 'المتحف المصري',
      'lat': 30.0478,
      'lng': 31.2336,
      'icon': Icons.museum,
    },
    {
      'name': 'Khan El Khalili',
      'nameAr': 'خان الخليلي',
      'lat': 30.0472,
      'lng': 31.2620,
      'icon': Icons.shopping_bag,
    },
    {
      'name': 'Downtown Cairo',
      'nameAr': 'وسط البلد',
      'lat': 30.0444, // Using Tahrir area coordinates roughly
      'lng': 31.2357,
      'icon': Icons.business,
    },
    {
      'name': 'City Stars Mall',
      'nameAr': 'سيتي ستارز',
      'lat': 30.0727,
      'lng': 31.3497,
      'icon': Icons.shopping_cart,
    },
    {
      'name': 'Cairo Festival City',
      'nameAr': 'كايرو فيستيفال',
      'lat': 30.0275,
      'lng': 31.4014,
      'icon': Icons.festival,
    },
    {
      'name': 'Mall of Arabia',
      'nameAr': 'مول العرب',
      'lat': 30.0139,
      'lng': 31.0181,
      'icon': Icons.store,
    },
    {
      'name': 'Cairo University',
      'nameAr': 'جامعة القاهرة',
      'lat': 30.0260,
      'lng': 31.2012,
      'icon': Icons.school,
    },
  ];

  void _findNearestStation(double lat, double lng, String placeName) {
    final location = LatLng(lat, lng);

    // Always force update state to ensure UI reflects new search
    setState(() {
      _selectedLocation = location;
      _searchedPlace = placeName;
    });

    _animateMapMove(location, 14.5);

    final stations = context.read<MetroCubit>().state.stations;
    Station? nearest;
    double minDistance = double.infinity;

    for (var station in stations) {
      final distance = Geolocator.distanceBetween(
        lat,
        lng,
        station.latitude,
        station.longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearest = station;
      }
    }

    setState(() {
      _nearestStation = nearest;
      _distanceToNearest = minDistance / 1000;
    });
  }

  void _useStation() {
    if (_nearestStation != null) {
      if (widget.isSource) {
        context.read<MetroCubit>().selectSource(_nearestStation!);
      } else {
        context.read<MetroCubit>().selectDestination(_nearestStation!);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    final stations = context.read<MetroCubit>().state.stations;
    final theme = Theme.of(context);

    // Filter popular places if user is typing, or show all
    // We can implement client-side filtering for better UX if needed,
    // but the main function is search field.

    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevent keyboard pushing up map
      body: Stack(
        children: [
          // Map Layer
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(30.0444, 31.2357),
              initialZoom: 12.0,
              onTap: (_, point) {
                // Remove focus from text field to hide keyboard
                FocusScope.of(context).unfocus();

                _findNearestStation(
                  point.latitude,
                  point.longitude,
                  isArabic ? 'موقع محدد' : 'Custom Location',
                );
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.metro_masr',
              ),
              // Metro Stations
              MarkerLayer(
                markers: stations.map((station) {
                  return Marker(
                    point: LatLng(station.latitude, station.longitude),
                    width: 30,
                    height: 30,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.train,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  );
                }).toList(),
              ),
              // Selected Location
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 50,
                      ),
                    ),
                  ],
                ),
              // Nearest Station Highlight
              if (_nearestStation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        _nearestStation!.latitude,
                        _nearestStation!.longitude,
                      ),
                      width: 60,
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.train,
                          color: Colors.green,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Top Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: _onSearchSubmitted,
                      textInputAction: TextInputAction.search,
                      style: theme.textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: isArabic
                            ? (widget.isSource
                                  ? 'ابحث عن محطة البداية...'
                                  : 'ابحث عن محطة الوصول...')
                            : (widget.isSource
                                  ? 'Search for starting point...'
                                  : 'Search for destination...'),
                        hintStyle: theme.textTheme.bodyMedium,
                        prefixIcon: Icon(
                          Icons.search,
                          color: theme.primaryColor,
                        ),
                        filled: true,
                        fillColor: theme.cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        suffixIcon: _isSearching
                            ? Padding(
                                padding: const EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: theme.primaryColor,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.35,
            minChildSize: 0.2,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.dividerColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Result Card (if station found)
                    if (_nearestStation != null && _searchedPlace != null)
                      Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.primaryColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Colors.white,
                                    ),
                                    const Gap(8),
                                    Expanded(
                                      child: Text(
                                        _searchedPlace!,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap(8),
                                const Divider(
                                  color: Colors.white24,
                                  height: 16,
                                ),
                                if (_distanceToNearest != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      "${_distanceToNearest!.toStringAsFixed(1)} ${'away_from_station'.tr()}",
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: Colors.white70,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                Text(
                                  'nearest_station_label'.tr(),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                                const Gap(4),
                                Text(
                                  _nearestStation!.getName(context),
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Gap(12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _useStation,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: theme.primaryColor,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                    child: Text('use_this_station'.tr()),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .animate(key: ValueKey(_searchedPlace))
                          .fade()
                          .slideY(
                            begin: 0.2,
                            end: 0,
                          ), // Key forces re-animation on change
                    // Popular Places List
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'popular_places'.tr(),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _popularPlaces.length,
                      itemBuilder: (context, index) {
                        final place = _popularPlaces[index];
                        return _buildPlaceCard(
                          isArabic ? place['nameAr'] : place['name'],
                          place['lat'],
                          place['lng'],
                          place['icon'],
                        );
                      },
                    ),
                    const Gap(20),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceCard(String name, double lat, double lng, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),
        title: Text(
          name,
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _findNearestStation(lat, lng, name),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
