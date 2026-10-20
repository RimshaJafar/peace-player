import 'package:flutter/material.dart';
import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/containers/boycott_product_container.dart';
import 'package:ecommerce_app/features/boycott/controllers/boycott_controller.dart';
import 'package:ecommerce_app/features/boycott/models/boycott_model.dart';
import 'package:ecommerce_app/features/boycott/screens/boycott_product_detail_screen.dart';
import 'package:ecommerce_app/features/boycott/screens/boycott_scanner_screen.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:get/get.dart';

class BoycottProductsScreen extends StatefulWidget {
  const BoycottProductsScreen({Key? key}) : super(key: key);

  @override
  State<BoycottProductsScreen> createState() => _BoycottProductsScreenState();
}

class _BoycottProductsScreenState extends State<BoycottProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  late final BoycottController boycottController;

  // Filter states
  final Set<String> _selectedCountries = {};
  String? _selectedLevel;

  final RxList<BoycottProduct> currentProducts = <BoycottProduct>[].obs;

  // Anchor and size tracking for filter popup positioning (under search bar)
  final LayerLink _searchBarLink = LayerLink();
  final GlobalKey _searchBarKey = GlobalKey();
  double _searchBarWidth = 0;
  double _searchBarHeight = 0;
  OverlayEntry? _filterOverlayEntry;

  List<String> get _categories {
    final seenCategories = <String>{};
    final dynamicCategories = boycottController.boycottCategories
        .map((c) => c.category.trim())
        .where(_isVisibleCategory)
        .where((category) => seenCategories.add(category.toLowerCase()))
        .toList();
    return ['All', ...dynamicCategories];
  }

  bool _isVisibleCategory(String category) {
    final normalized = category.trim().toLowerCase();
    return normalized.isNotEmpty &&
        normalized != 'unknown' &&
        normalized != 'uncategorized' &&
        normalized != 'n/a' &&
        normalized != 'na' &&
        normalized != 'null';
  }

  String _normalizeFilterValue(String? value) {
    return (value ?? '').trim().toLowerCase();
  }

  String _normalizeLevelValue(String? value) {
    final normalized = _normalizeFilterValue(value);
    if (normalized.contains('high')) return 'high';
    if (normalized.contains('medium')) return 'medium';
    if (normalized.contains('low')) return 'low';
    return normalized;
  }

  bool _matchesSelectedFilter(String productValue, String selectedValue) {
    final normalizedProductValue = _normalizeFilterValue(productValue);
    return normalizedProductValue.isEmpty ||
        normalizedProductValue == selectedValue;
  }

  bool _matchesSelectedLevel(String productLevel, String selectedLevel) {
    final normalizedProductLevel = _normalizeLevelValue(productLevel);
    final normalizedSelectedLevel = _normalizeLevelValue(selectedLevel);
    return normalizedProductLevel.isEmpty ||
        normalizedProductLevel == normalizedSelectedLevel;
  }

  List<BoycottProduct> get _filteredProducts {
    final query = _normalizeFilterValue(_searchQuery);
    final selectedCategory = _selectedCategory == 'All'
        ? ''
        : _normalizeFilterValue(_selectedCategory);
    final selectedLevel = _normalizeFilterValue(_selectedLevel);
    final selectedCountries =
        _selectedCountries.map(_normalizeFilterValue).toSet();
    final cachedProductsBySlug = {
      for (final product in boycottController.boycottProducts)
        if (product.slug.isNotEmpty) product.slug: product,
    };

    return currentProducts.where((product) {
      final cachedProduct = cachedProductsBySlug[product.slug];
      final productCategory = product.category.isNotEmpty
          ? product.category
          : cachedProduct?.category ?? '';
      final productLevel = (product.boycottLevel?.isNotEmpty ?? false)
          ? product.boycottLevel!
          : cachedProduct?.boycottLevel ?? '';

      final bool matchesQuery =
          query.isEmpty || product.name.toLowerCase().contains(query);
      final bool matchesCategory = selectedCategory.isEmpty ||
          _matchesSelectedFilter(productCategory, selectedCategory);
      final bool matchesCountries = selectedCountries.isEmpty ||
          selectedCountries.contains(_normalizeFilterValue(product.country));
      final bool matchesLevel = selectedLevel.isEmpty ||
          _matchesSelectedLevel(productLevel, selectedLevel);

      return matchesQuery &&
          matchesCategory &&
          matchesCountries &&
          matchesLevel;
    }).toList();
  }

  Map<String, List<BoycottProduct>> get _groupedProducts {
    final Map<String, List<BoycottProduct>> grouped = {};
    for (var product in _filteredProducts) {
      final country = product.country.isEmpty ? 'Unknown' : product.country;
      if (!grouped.containsKey(country)) {
        grouped[country] = [];
      }
      grouped[country]!.add(product);
    }
    return grouped;
  }

  void _openProductDetail(BoycottProduct product) async {
    await boycottController.fetchProductDetail(product.slug);
    if (boycottController.detailedProduct.value != null) {
      Get.to(() => BoycottProductDetailScreen(
          product: boycottController.detailedProduct.value!));
    }
  }

  @override
  void initState() {
    super.initState();
    // Use Get.find if already registered, otherwise put a new instance
    if (Get.isRegistered<BoycottController>()) {
      boycottController = Get.find<BoycottController>();
    } else {
      boycottController = Get.put(BoycottController());
    }
    boycottController.fetchBoycottCountries();
    boycottController.fetchBoycottCategories();
    boycottController.fetchBoycottProducts().then((_) {
      currentProducts.assignAll(boycottController.boycottProducts);
    });
  }

  Future<void> _applyActiveFilters() async {
    final selectedCategory =
        _selectedCategory == 'All' ? null : _selectedCategory;
    final selectedLevel = _normalizeLevelValue(_selectedLevel);

    if (selectedCategory != null || selectedLevel.isNotEmpty) {
      await boycottController.fetchFilteredProducts(
        category: selectedCategory,
        level: selectedLevel.isEmpty ? null : selectedLevel,
      );
      currentProducts.assignAll(boycottController.filteredProducts);
    } else {
      currentProducts.assignAll(boycottController.boycottProducts);
    }
  }

  void _showFilterDialog() {
    _updateSearchBarMetrics();
    if (_filterOverlayEntry != null) return;

    _filterOverlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _hideFilterOverlay,
        child: Stack(
          children: [
            CompositedTransformFollower(
              link: _searchBarLink,
              offset: Offset(0, _searchBarHeight + 6),
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                  child: Container(
                    width: _searchBarWidth > 0 ? _searchBarWidth : null,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                          color: const Color(0xFF2E8B57).withOpacity(0.3)),
                    ),
                    child: FilterDialog(
                      boycottController: boycottController,
                      selectedCountries: _selectedCountries,
                      selectedLevel: _selectedLevel,
                      onApply: (countries, level) async {
                        setState(() {
                          _selectedCountries.clear();
                          _selectedCountries.addAll(countries);
                          _selectedLevel = level;
                        });
                        await _applyActiveFilters();
                      },
                      onClear: () {
                        setState(() {
                          _selectedCountries.clear();
                          _selectedLevel = null;
                          _selectedCategory = 'All';
                        });
                        currentProducts
                            .assignAll(boycottController.boycottProducts);
                      },
                      asPopupPanel: true,
                      onClose: _hideFilterOverlay,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_filterOverlayEntry!);
  }

  void _hideFilterOverlay() {
    _filterOverlayEntry?.remove();
    _filterOverlayEntry = null;
  }

  void _updateSearchBarMetrics() {
    final ctx = _searchBarKey.currentContext;
    if (ctx != null) {
      final box = ctx.findRenderObject() as RenderBox?;
      if (box != null) {
        setState(() {
          _searchBarWidth = box.size.width;
          _searchBarHeight = box.size.height;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PAppBar(
        title: Text(
          'Boycott Products',
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
        if (boycottController.isLoadingProducts.value) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              /// Search Bar Section
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: CompositedTransformTarget(
                  link: _searchBarLink,
                  child: Container(
                    key: _searchBarKey,
                    child: Row(
                      children: [
                        // Search TextField - 80%
                        Expanded(
                          flex: 4,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFEBE7E7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            height: 48,
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Search Product',
                                hintStyle: const TextStyle(
                                  color: Color(0xFFACACAC),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Image.asset(
                                      'assets/icons/search-interface-symbol (2).png',
                                      width: 20,
                                      height: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Filter Button - 20%
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            onPressed: _showFilterDialog,
                            style: ButtonStyle(
                              backgroundColor: const MaterialStatePropertyAll(
                                  Color(0xFF329070)),
                              overlayColor: const MaterialStatePropertyAll(
                                  Colors.transparent),
                              elevation: const MaterialStatePropertyAll(0),
                              shadowColor: const MaterialStatePropertyAll(
                                  Colors.transparent),
                              shape: MaterialStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              side: const MaterialStatePropertyAll(
                                BorderSide(color: Colors.transparent),
                              ),
                              splashFactory: NoSplash.splashFactory,
                              fixedSize: const MaterialStatePropertyAll(
                                  Size.fromHeight(48)),
                              foregroundColor:
                                  const MaterialStatePropertyAll(Colors.white),
                            ),
                            child: Image.asset(
                              'assets/icons/filter.png',
                              width: 32,
                              height: 32,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// Category Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Obx(() {
                  if (boycottController.isLoadingCategories.value) {
                    return const SizedBox(
                      height: 50,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((category) {
                        final bool isSelected = _selectedCategory == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOutCubic,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Color.fromRGBO(119, 197, 162, 0.9)
                                  : const Color(0XFFE6F0EF),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF329070)
                                    : Colors.grey,
                                width: 1,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () async {
                                  setState(() {
                                    _selectedCategory = category;
                                  });
                                  await _applyActiveFilters();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  child: AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOutCubic,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0XFF627C75),
                                    ),
                                    child: Text(category),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              /// Dynamic Product List
              if (_filteredProducts.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Column(
                  children: _groupedProducts.entries.map((entry) {
                    final products = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...products.map((product) {
                          return BoycottProductContainer(
                            productName: product.name,
                            imagePath: product.image,
                            country: product.country,
                            onViewDetailsTap: () => _openProductDetail(product),
                          );
                        }),
                        const SizedBox(height: 16),
                      ],
                    );
                  }).toList(),
                ),

              const SizedBox(height: 40),
            ],
          );
        }
      }),
      floatingActionButton: SizedBox.square(
        dimension: 72,
        child: FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () {
            Get.to(() => const BoycottScannerScreen());
          },
          child: Image.asset(
            'assets/icons/scan (2).png',
            width: 72,
            height: 72,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class FilterDialog extends StatefulWidget {
  final BoycottController boycottController;
  final Set<String> selectedCountries;
  final String? selectedLevel;
  final Function(Set<String>, String?) onApply;
  final Function() onClear;
  final bool asPopupPanel;
  final VoidCallback? onClose;

  const FilterDialog({
    Key? key,
    required this.boycottController,
    required this.selectedCountries,
    required this.selectedLevel,
    required this.onApply,
    required this.onClear,
    this.asPopupPanel = false,
    this.onClose,
  }) : super(key: key);

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late String? _tempSelectedCountry;
  late String? _tempSelectedLevel;
  late final TextEditingController _countrySearchController;
  late final FocusNode _countryFocusNode;
  String _countryQuery = '';
  bool _showCountriesDropdown = false;
  final LayerLink _countriesFieldLink = LayerLink();
  final GlobalKey _countryFieldKey = GlobalKey();
  double _countryFieldWidth = 0;
  double _countryFieldHeight = 0;

  @override
  void initState() {
    super.initState();
    _tempSelectedCountry = widget.selectedCountries.isNotEmpty
        ? widget.selectedCountries.first
        : null;
    _tempSelectedLevel = widget.selectedLevel;
    _countrySearchController = TextEditingController(
      text: _tempSelectedCountry ?? '',
    );
    _countryFocusNode = FocusNode();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _updateCountryFieldMetrics());
  }

  void _closeCountriesDropdown() {
    setState(() {
      _showCountriesDropdown = false;
    });
  }

  @override
  void dispose() {
    _countrySearchController.dispose();
    _countryFocusNode.dispose();
    super.dispose();
  }

  void _toggleCountry(String country) {
    setState(() {
      if (_tempSelectedCountry == country) {
        _tempSelectedCountry = null;
      } else {
        _tempSelectedCountry = country;
      }
      _countrySearchController.text = _tempSelectedCountry ?? '';
      _countrySearchController.selection = TextSelection.collapsed(
        offset: _countrySearchController.text.length,
      );
      _countryQuery = '';
      _showCountriesDropdown = false;
    });
  }

  void _updateCountryFieldMetrics() {
    final ctx = _countryFieldKey.currentContext;
    if (ctx != null) {
      final box = ctx.findRenderObject() as RenderBox?;
      if (box != null) {
        setState(() {
          _countryFieldWidth = box.size.width;
          _countryFieldHeight = box.size.height;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = GestureDetector(
        onTap: () {
          if (_showCountriesDropdown) {
            _closeCountriesDropdown();
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Products',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Countries',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              CompositedTransformTarget(
                link: _countriesFieldLink,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _showCountriesDropdown = !_showCountriesDropdown;
                    });
                  },
                  child: TextField(
                    key: _countryFieldKey,
                    controller: _countrySearchController,
                    focusNode: _countryFocusNode,
                    readOnly: true,
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: 'Select Countries',
                      filled: true,
                      fillColor: const Color(0xFFEBE7E7),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: Icon(
                        _showCountriesDropdown
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: const Color(0xFF2E8B57),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_tempSelectedCountry != null)
                Chip(
                  label: Text(_tempSelectedCountry!),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => _toggleCountry(_tempSelectedCountry!),
                  backgroundColor: const Color(0xFF2E8B57).withOpacity(0.15),
                  labelStyle: const TextStyle(
                    color: Color(0xFF2E8B57),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const SizedBox(height: 16),
              const Text(
                'Level',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(3, (index) {
                  final levels = ['High', 'Medium', 'Low'];
                  final level = levels[index];
                  final isSelected = _tempSelectedLevel == level;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: index < 2 ? 8 : 0),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _tempSelectedLevel = isSelected ? null : level;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Color.fromRGBO(119, 197, 162, 0.9)
                                : const Color(0XFFE6F0EF),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF329070)
                                  : Colors.grey,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              level,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0XFF627C75),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 48),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _tempSelectedCountry = null;
                          _countrySearchController.text = '';
                          _countrySearchController.selection =
                              TextSelection.collapsed(offset: 0);
                          _countryQuery = '';
                          _showCountriesDropdown = false;
                          _tempSelectedLevel = null;
                        });
                        widget.onClear();
                        if (widget.onClose != null) {
                          widget.onClose!();
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFFBDBDBD),
                          width: 1,
                        ),
                        minimumSize: const Size(0, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        splashFactory: NoSplash.splashFactory,
                        overlayColor: Colors.transparent,
                      ),
                      child: const Text(
                        'Clear',
                        style: TextStyle(
                          color: Color(0xFF666666),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final selectedCountries = _tempSelectedCountry != null
                            ? {_tempSelectedCountry!}
                            : <String>{};
                        widget.onApply(selectedCountries, _tempSelectedLevel);
                        if (widget.onClose != null) {
                          widget.onClose!();
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF329070),
                        minimumSize: const Size(0, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        splashFactory: NoSplash.splashFactory,
                        overlayColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        side: BorderSide.none,
                      ),
                      child: const Text(
                        'Apply',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (!widget.asPopupPanel)
          Dialog(
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.15),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.88,
              child: SizedBox(
                height: 420,
                child: content,
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            constraints: const BoxConstraints(minHeight: 380),
            child: content,
          ),
        if (_showCountriesDropdown)
          CompositedTransformFollower(
            link: _countriesFieldLink,
            offset: Offset(0, _countryFieldHeight + 6),
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: Container(
                  width: _countryFieldWidth > 0 ? _countryFieldWidth : null,
                  constraints: const BoxConstraints(maxHeight: 220),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFF2E8B57).withOpacity(0.3),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Obx(() {
                    if (widget.boycottController.isLoadingCountries.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final countries = widget.boycottController.boycottCountries
                        .where((c) =>
                            _countryQuery.isEmpty ||
                            (c.country
                                .toLowerCase()
                                .contains(_countryQuery.toLowerCase())))
                        .toList();
                    return SingleChildScrollView(
                      child: Column(
                        children: List.generate(
                          countries.length,
                          (index) {
                            final country = countries[index];
                            final isSelected =
                                _tempSelectedCountry == country.country;
                            return InkWell(
                              onTap: () => _toggleCountry(country.country),
                              child: Container(
                                alignment: Alignment.centerLeft,
                                color: isSelected
                                    ? const Color(0xFF2E8B57).withOpacity(0.08)
                                    : Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                                child: Text(
                                  country.country,
                                  style: TextStyle(
                                    color: isSelected
                                        ? const Color(0xFF2E8B57)
                                        : Colors.black87,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
