import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/common/widgets/searchbar/custom_search_bar.dart';
import 'package:ecommerce_app/common/widgets/distance_selector/custom_distance_selector.dart';
import 'package:ecommerce_app/features/mosque/controllers/mosque_controller.dart';
import 'package:ecommerce_app/features/mosque/models/mosque_model.dart';
import 'package:ecommerce_app/features/mosque/screens/search_nearby_mosque_screen.dart';
import 'package:ecommerce_app/features/mosque/screens/mosque_directions_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class NearbyMosqueScreen extends StatefulWidget {
  const NearbyMosqueScreen({Key? key}) : super(key: key);

  @override
  State<NearbyMosqueScreen> createState() => _NearbyMosqueScreenState();
}

class _NearbyMosqueScreenState extends State<NearbyMosqueScreen> {
  late final MosqueController _controller;
  final MapController _mapController = MapController();
  int _distance = 10;

  // Selected mosque from search screen
  Mosque? _selectedMosque;

  @override
  void initState() {
    super.initState();
    // Register controller if not already registered
    if (!Get.isRegistered<MosqueController>()) {
      Get.put(MosqueController());
    }
    _controller = Get.find<MosqueController>();
    _controller.radiusKm.value = _distance;
    _controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PAppBar(
        title: Text(
          'Nearby Mosque',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        gradient: PColors.linearGradient,
        showBackArrow: true,
      ),
      body: Obx(() {
        final isLoading = !_controller.hasLocation.value &&
            _controller.nearbyError.value == null;
        final error = _controller.nearbyError.value;

        return Stack(
          children: [
            // ── Map or loading/error state ─────────────────
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (error != null && !_controller.hasLocation.value)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_off,
                          size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(error, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _controller.initialize(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else
              _buildMap(),

            if (!isLoading && _controller.hasLocation.value)
              Positioned(
                top: 16,
                left: 16,
                child: _buildMapBadge(),
              ),

            // ── Bottom search + distance panel ─────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 216,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0E3B2C).withOpacity(0.92),
                      const Color(0xFF061B14).withOpacity(0.96),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 18,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Find a Mosque Nearby',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _panelCard(
                          child: CustomSearchBar(
                            width: double.infinity,
                            height: 48,
                            backgroundColor: Colors.white,
                            hintText: 'Search Mosques',
                            showTrailingIcon: false,
                            readOnly: true,
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const SearchNearbyMosqueScreen(),
                                ),
                              );

                              if (result != null) {
                                if (result is Mosque) {
                                  setState(() {
                                    _selectedMosque = result;
                                  });

                                  _mapController.move(
                                    LatLng(
                                      result.location.lat,
                                      result.location.lon,
                                    ),
                                    15.0,
                                  );
                                  return;
                                }

                                if (result is Map<String, dynamic>) {
                                  final lat =
                                      (result['latitude'] as num).toDouble();
                                  final lon =
                                      (result['longitude'] as num).toDouble();
                                  final name = result['name'] as String? ??
                                      'Selected Mosque';

                                  final matched =
                                      _matchNearbyMosque(name, lat, lon);
                                  if (matched != null) {
                                    setState(() {
                                      _selectedMosque = matched;
                                    });

                                    _mapController.move(
                                      LatLng(lat, lon),
                                      15.0,
                                    );
                                    return;
                                  }

                                  final denomination =
                                      result['denomination'] as String?;
                                  final address = result['address'] as String?;

                                  final distanceM =
                                      _controller.hasLocation.value
                                          ? Geolocator.distanceBetween(
                                              _controller.currentLat.value,
                                              _controller.currentLon.value,
                                              lat,
                                              lon,
                                            )
                                          : 0.0;

                                  setState(() {
                                    _selectedMosque = Mosque(
                                      osmId: 0,
                                      osmType: 'node',
                                      name: name,
                                      nameEn: result['name_en'] as String?,
                                      nameAr: result['name_ar'] as String?,
                                      nameUr: result['name_ur'] as String?,
                                      mosqueType: 'mosque',
                                      location:
                                          MosqueLocation(lat: lat, lon: lon),
                                      distanceM: distanceM,
                                      distanceKm: distanceM / 1000,
                                      rankScore: 0,
                                      address: address,
                                      amenities: denomination != null
                                          ? MosqueAmenities(
                                              denomination: denomination,
                                            )
                                          : const MosqueAmenities(),
                                    );
                                  });

                                  _mapController.move(
                                    LatLng(lat, lon),
                                    15.0,
                                  );
                                }
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        _panelCard(
                          child: CustomDistanceSelector(
                            width: MediaQuery.of(context).size.width * 0.88,
                            height: 48,
                            backgroundColor: Colors.white,
                            textColor: const Color(0xFF808080),
                            initialDistance: _distance,
                            maxDistance: 10,
                            onDistanceChanged: (newDistance) {
                              setState(() {
                                _distance = newDistance;
                              });
                              _controller.updateRadius(newDistance);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: LatLng(
          _controller.currentLat.value,
          _controller.currentLon.value,
        ),
        initialZoom: 13.0,
      ),
      children: [
        // ── OpenStreetMap tile layer ──────────────────────
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.peaceplayer.app',
        ),

        // ── Markers ──────────────────────────────────────
        MarkerLayer(
          markers: _buildMarkers(),
        ),
      ],
    );
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    // Current location marker
    if (_controller.hasLocation.value) {
      markers.add(
        Marker(
          point: LatLng(
            _controller.currentLat.value,
            _controller.currentLon.value,
          ),
          width: 40,
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              color: PColors.primary.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.my_location,
                color: PColors.primary,
                size: 22,
              ),
            ),
          ),
        ),
      );
    }

    // Nearby mosque markers
    for (final mosque in _controller.nearbyMosques) {
      markers.add(
        Marker(
          point: LatLng(
            mosque.location.lat,
            mosque.location.lon,
          ),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () => _showMosqueInfo(mosque),
            child: const Icon(
              Icons.mosque,
              color: Color(0xFF1A4D2E),
              size: 30,
            ),
          ),
        ),
      );
    }

    // Selected mosque marker (from search)
    if (_selectedMosque != null) {
      markers.add(
        Marker(
          point: LatLng(
            _selectedMosque!.location.lat,
            _selectedMosque!.location.lon,
          ),
          width: 50,
          height: 50,
          child: GestureDetector(
            onTap: () => _showMosqueInfo(_selectedMosque!),
            child: const Icon(
              Icons.mosque,
              color: Colors.red,
              size: 36,
            ),
          ),
        ),
      );
    }

    return markers;
  }

  Mosque? _matchNearbyMosque(String? name, double lat, double lon) {
    if (_controller.nearbyMosques.isEmpty) return null;

    final lowerName = name?.toLowerCase().trim();
    Mosque? bestMatch;
    double bestDistance = double.infinity;

    for (final mosque in _controller.nearbyMosques) {
      final isNameMatch = lowerName != null && lowerName.isNotEmpty
          ? mosque.displayName.toLowerCase().contains(lowerName)
          : false;

      final distance = Geolocator.distanceBetween(
        lat,
        lon,
        mosque.location.lat,
        mosque.location.lon,
      );

      if (isNameMatch && distance < bestDistance) {
        bestMatch = mosque;
        bestDistance = distance;
      } else if (distance < 60 && distance < bestDistance) {
        bestMatch = mosque;
        bestDistance = distance;
      }
    }

    return bestMatch;
  }

  void _showMosqueInfo(Mosque mosque) {
    _controller.selectMosque(mosque, fetchRoute: true);
    final distanceKm = _popupDistanceKm(mosque);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E6E3),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF4F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.mosque,
                    color: Color(0xFF1A4D2E),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    mosque.displayName,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A2E26),
                    ),
                  ),
                ),
              ],
            ),
            if (mosque.address != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.place_outlined,
                      size: 16, color: Color(0xFF6F857C)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      mosque.address!,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF6F857C),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _routeDistanceChip(distanceKm, mosque),
                if (mosque.amenities.denomination != null)
                  _infoChip(
                    icon: Icons.menu_book_rounded,
                    label: mosque.amenities.denomination!,
                  ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _controller.selectMosque(mosque, fetchRoute: true);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MosqueDirectionsScreen(mosque: mosque),
                    ),
                  );
                },
                icon: const Icon(Icons.directions_walk, size: 18),
                label: Text(
                  'Get Directions',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Live Map',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A4D2E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_controller.nearbyMosques.length} mosques • $_distance km',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: const Color(0xFF6F857C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F6F3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1ECE7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF1A4D2E)),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A4D2E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _routeDistanceChip(double fallbackKm, Mosque mosque) {
    return Obx(() {
      final route = _controller.currentRoute.value;
      final isLoading = _controller.isLoadingRoute.value;
      final selected = _controller.selectedMosque.value;
      final sameMosque = selected != null && _isSameMosque(selected, mosque);

      if (isLoading) {
        return _infoChip(
          icon: Icons.alt_route_rounded,
          label: 'Route: loading...',
        );
      }

      if (route != null && sameMosque) {
        return _infoChip(
          icon: Icons.alt_route_rounded,
          label: 'Route: ${route.summary.distanceKm.toStringAsFixed(2)} km',
        );
      }

      return _infoChip(
        icon: Icons.route_rounded,
        label: 'Direct: ${fallbackKm.toStringAsFixed(2)} km',
      );
    });
  }

  bool _isSameMosque(Mosque a, Mosque b) {
    if (a.osmId != 0 && b.osmId != 0) {
      return a.osmId == b.osmId && a.osmType == b.osmType;
    }
    final distance = Geolocator.distanceBetween(
      a.location.lat,
      a.location.lon,
      b.location.lat,
      b.location.lon,
    );
    return distance < 60;
  }

  double _popupDistanceKm(Mosque mosque) {
    if (mosque.distanceKm > 0) {
      return mosque.distanceKm;
    }
    if (!_controller.hasLocation.value) {
      return 0;
    }
    final meters = Geolocator.distanceBetween(
      _controller.currentLat.value,
      _controller.currentLon.value,
      mosque.location.lat,
      mosque.location.lon,
    );
    return meters / 1000;
  }

  Widget _panelCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
