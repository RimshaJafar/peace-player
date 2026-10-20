import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/common/widgets/searchbar/custom_search_bar.dart';
import 'package:ecommerce_app/common/widgets/distance_selector/custom_distance_selector.dart';
import 'package:ecommerce_app/features/mosque/controllers/mosque_controller.dart';
import 'package:ecommerce_app/features/mosque/models/mosque_model.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchNearbyMosqueScreen extends StatefulWidget {
  const SearchNearbyMosqueScreen({Key? key}) : super(key: key);

  @override
  State<SearchNearbyMosqueScreen> createState() =>
      _SearchNearbyMosqueScreenState();
}

class _SearchNearbyMosqueScreenState extends State<SearchNearbyMosqueScreen> {
  late final MosqueController _controller;
  String _searchQuery = '';
  int _distance = 10;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<MosqueController>()) {
      Get.put(MosqueController());
    }
    _controller = Get.find<MosqueController>();
    _controller.radiusKm.value = _distance;
    _initializeSearch();
  }

  Future<void> _initializeSearch() async {
    if (!_controller.hasLocation.value) {
      await _controller.getCurrentLocation();
    }
    if (_controller.hasLocation.value) {
      await _controller.fetchNearbyMosques();
    }
  }

  Future<void> _searchPlace(String query) async {
    if (query.trim().isEmpty) {
      if (_controller.hasLocation.value) {
        await _controller.fetchNearbyMosques();
      }
      return;
    }
    await _controller.geocodeSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F8F6), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(Icons.arrow_back, size: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Search Mosque',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A2E26),
                            ),
                          ),
                          Text(
                            'Find nearby locations and select one',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFF6F857C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Material(
                  elevation: 8,
                  shadowColor: Colors.black.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                  child: CustomSearchBar(
                    width: double.infinity,
                    backgroundColor: Colors.white,
                    hintText: 'Search place...',
                    showTrailingIcon: false,
                    onChanged: (value) {
                      _searchQuery = value;
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (_searchQuery == value) _searchPlace(value);
                      });
                    },
                    onLeadingIconTap: () {
                      FocusScope.of(context).unfocus();
                      _searchPlace(_searchQuery);
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Obx(() {
                    final count = _controller.nearbyMosques.length;
                    return Text(
                      'Nearby Results • $count',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF3A564B),
                      ),
                    );
                  }),
                ),
              ),
              Expanded(
                child: Obx(() {
                  final isLoading = _controller.isLoadingNearby.value ||
                      _controller.isSearching.value;
                  final mosques = _controller.nearbyMosques;

                  if (isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (mosques.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.mosque_outlined,
                              size: 44, color: Color(0xFF8FA39A)),
                          const SizedBox(height: 10),
                          Text(
                            'No mosques found in $_distance km range',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF8FA39A),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: mosques.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final mosque = mosques[index];
                      return _buildMosqueTile(mosque);
                    },
                  );
                }),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Center(
                  child: CustomDistanceSelector(
                    width: MediaQuery.of(context).size.width * 0.9,
                    backgroundColor: const Color(0xFFF0F4F2),
                    textColor: const Color(0xFF4B5B55),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMosqueTile(Mosque mosque) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context, mosque);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5EEE9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF1A4D2E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  const Icon(Icons.mosque, color: Color(0xFF1A4D2E), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mosque.displayName,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A2E26),
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (mosque.address != null)
                    Text(
                      mosque.address!,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF7A8C84),
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F6F3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                mosque.distanceKm < 1
                    ? '${mosque.distanceM.toStringAsFixed(0)} m'
                    : '${mosque.distanceKm.toStringAsFixed(1)} km',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A4D2E),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
