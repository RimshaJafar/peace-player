import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/features/digital_will/controllers/digital_will_controller.dart';
import 'package:ecommerce_app/features/digital_will/screens/liabilities.dart';
import 'package:ecommerce_app/features/digital_will/models/digital_will_request_model.dart';
import 'package:ecommerce_app/features/digital_will/models/spouse_model.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AssetsCollectionScreen extends StatefulWidget {
  final SpouseData spouseData;

  const AssetsCollectionScreen({
    required this.spouseData,
    super.key,
  });

  @override
  State<AssetsCollectionScreen> createState() => _AssetsCollectionScreenState();
}

class _AssetsCollectionScreenState extends State<AssetsCollectionScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final List<_AssetCategoryModel> _categories;
  String? _assetsValidationError;

  @override
  void initState() {
    super.initState();
    _categories = <_AssetCategoryModel>[
      _AssetCategoryModel(
        title: 'Real Estate',
        options: const <String>[
          'House',
          'Apartment',
          'Land',
          'Commercial Property',
        ],
      ),
      _AssetCategoryModel(
        title: 'Vehicles',
        options: const <String>[
          'Car',
          'Motorcycle',
          'Boat',
        ],
      ),
      _AssetCategoryModel(
        title: 'Financial Assets',
        options: const <String>[
          'Bank Account',
          'Cash',
          'Investments',
          'Stocks',
          'Crypto',
          'Retirement Funds',
        ],
      ),
      _AssetCategoryModel(
        title: 'Business Assets',
        options: const <String>[
          'Company Shares',
          'Business Ownership',
          'Partnership Shares',
        ],
      ),
      _AssetCategoryModel(
        title: 'Gold & Jewelry',
        options: const <String>[
          'Gold',
          'Silver',
          'Jewelry',
        ],
      ),
      _AssetCategoryModel(
        title: 'Other Assets',
        options: const <String>[
          'Digital Assets',
          'Intellectual Property',
          'Valuable Items',
        ],
      ),
    ];
  }

  @override
  void dispose() {
    for (final _AssetCategoryModel category in _categories) {
      category.dispose();
    }
    super.dispose();
  }

  String _categoryKey(String title) {
    switch (title) {
      case 'Real Estate':
        return 'realEstate';
      case 'Vehicles':
        return 'vehicles';
      case 'Financial Assets':
        return 'financialAssets';
      case 'Business Assets':
        return 'businessAssets';
      case 'Gold & Jewelry':
        return 'preciousMetals';
      case 'Other Assets':
        return 'otherAssets';
      default:
        return 'otherAssets';
    }
  }

  bool _hasAssetEntryData(_AssetEntryModel entry) {
    return entry.nameController.text.trim().isNotEmpty ||
        entry.valueController.text.trim().isNotEmpty ||
        entry.notesController.text.trim().isNotEmpty;
  }

  List<DigitalWillAssetItemRequest> _collectCategoryEntries(
    _AssetCategoryModel category,
  ) {
    final List<DigitalWillAssetItemRequest> items =
        <DigitalWillAssetItemRequest>[];

    for (final MapEntry<String, List<_AssetEntryModel>> entry
        in category.entriesByType.entries) {
      final String typeName = entry.key;
      for (final _AssetEntryModel assetEntry in entry.value) {
        if (!_hasAssetEntryData(assetEntry)) {
          continue;
        }

        final double value =
            double.tryParse(assetEntry.valueController.text.trim()) ?? 0;
        if (value <= 0 && assetEntry.nameController.text.trim().isEmpty) {
          continue;
        }

        items.add(
          DigitalWillAssetItemRequest(
            name: assetEntry.nameController.text.trim().isEmpty
                ? typeName
                : assetEntry.nameController.text.trim(),
            estimatedValue: value,
            notes: assetEntry.notesController.text.trim(),
          ),
        );
      }
    }

    return items;
  }

  Step2AssetsRequest _buildAssetsRequest() {
    final Map<String, List<DigitalWillAssetItemRequest>> byCategory =
        <String, List<DigitalWillAssetItemRequest>>{
      'realEstate': <DigitalWillAssetItemRequest>[],
      'vehicles': <DigitalWillAssetItemRequest>[],
      'financialAssets': <DigitalWillAssetItemRequest>[],
      'businessAssets': <DigitalWillAssetItemRequest>[],
      'preciousMetals': <DigitalWillAssetItemRequest>[],
      'otherAssets': <DigitalWillAssetItemRequest>[],
    };

    for (final _AssetCategoryModel category in _categories) {
      byCategory[_categoryKey(category.title)] =
          _collectCategoryEntries(category);
    }

    return Step2AssetsRequest(
      realEstate: byCategory['realEstate'] ?? <DigitalWillAssetItemRequest>[],
      vehicles: byCategory['vehicles'] ?? <DigitalWillAssetItemRequest>[],
      financialAssets:
          byCategory['financialAssets'] ?? <DigitalWillAssetItemRequest>[],
      businessAssets:
          byCategory['businessAssets'] ?? <DigitalWillAssetItemRequest>[],
      preciousMetals:
          byCategory['preciousMetals'] ?? <DigitalWillAssetItemRequest>[],
      otherAssets: byCategory['otherAssets'] ?? <DigitalWillAssetItemRequest>[],
    );
  }

  bool _requestHasAssets(Step2AssetsRequest request) {
    return request.realEstate.isNotEmpty ||
        request.vehicles.isNotEmpty ||
        request.financialAssets.isNotEmpty ||
        request.businessAssets.isNotEmpty ||
        request.preciousMetals.isNotEmpty ||
        request.otherAssets.isNotEmpty;
  }

  bool _categoryHasStartedEntry(_AssetCategoryModel category) {
    for (final entries in category.entriesByType.values) {
      for (final entry in entries) {
        if (_hasAssetEntryData(entry)) {
          return true;
        }
      }
    }
    return false;
  }

  void _expandFirstRelevantCategory() {
    for (final category in _categories) {
      if (_categoryHasStartedEntry(category)) {
        category.isExpanded = true;
        return;
      }
    }

    if (_categories.isNotEmpty) {
      _categories.first.isExpanded = true;
    }
  }

  String? _validateAssetValue(_AssetEntryModel entry, String? value) {
    if (!_hasAssetEntryData(entry)) {
      return null;
    }

    return PValidator.validateRequiredPositiveNumber(
      'Estimated Value',
      value,
    );
  }

  bool _validateAndSaveAssets() {
    final bool fieldsValid = _formKey.currentState?.validate() ?? false;
    final Step2AssetsRequest request = _buildAssetsRequest();
    final bool hasAssets = _requestHasAssets(request);

    setState(() {
      _assetsValidationError = hasAssets
          ? null
          : 'Add at least one asset with a positive estimated value.';
      if (!fieldsValid || !hasAssets) {
        _expandFirstRelevantCategory();
      }
    });

    if (!fieldsValid || !hasAssets) {
      return false;
    }

    Get.find<DigitalWillController>().setAssets(request);
    return true;
  }

  Future<void> _showAddCustomTypeDialog(_AssetCategoryModel category) async {
    final TextEditingController customTypeController = TextEditingController();

    final String? customType = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Add Custom Asset Type',
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1C5D4E),
            ),
          ),
          content: TextField(
            controller: customTypeController,
            autofocus: true,
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              hintText: 'Custom type name',
              hintStyle: GoogleFonts.roboto(
                fontSize: 15,
                color: const Color(0xFF808080),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF1C5D4E)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.roboto(
                  color: const Color(0xFF6C6C6C),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                final String value = customTypeController.text.trim();
                if (value.isEmpty) {
                  return;
                }
                Navigator.of(context).pop(value);
              },
              child: Text(
                'Add',
                style: GoogleFonts.roboto(
                  color: const Color(0xFF1C5D4E),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    customTypeController.dispose();

    if (customType == null || customType.isEmpty) {
      return;
    }

    setState(() {
      category.addCustomType(customType);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PAppBar(
        title: Text(
          'Assets Information',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        centerTitle: true,
        gradient: PColors.linearGradient,
        showBackArrow: true,
      ),
      backgroundColor: const Color(0xFFF4F3EE),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _StepProgress(currentStep: 2, totalSteps: 6),
                    const SizedBox(height: 16),
                    Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F3C2F).withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Assets Collection',
                            style: GoogleFonts.roboto(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E3F35),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Select categories and add your assets with estimated values.',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF6E7874),
                            ),
                          ),
                          const SizedBox(height: 18),
                          ..._categories.map((category) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _AssetCategoryCard(
                                category: category,
                                valueValidator: _validateAssetValue,
                                onToggleExpanded: () {
                                  setState(() {
                                    category.isExpanded = !category.isExpanded;
                                    _assetsValidationError = null;
                                  });
                                },
                                onAddCustomType: () =>
                                    _showAddCustomTypeDialog(category),
                                onRemoveType: (type) {
                                  setState(() {
                                    category.removeType(type);
                                  });
                                },
                              ),
                            );
                          }),
                          if (_assetsValidationError != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              _assetsValidationError!,
                              style: GoogleFonts.roboto(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFD32F2F),
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 56,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2F8C6E),
                                    Color(0xFF1C5D4E),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1C5D4E)
                                        .withOpacity(0.25),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () {
                                    if (!_validateAndSaveAssets()) {
                                      return;
                                    }
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => LiabilitiesScreen(
                                          spouseData: widget.spouseData,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Center(
                                    child: Text(
                                      'Continue',
                                      style: GoogleFonts.roboto(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AssetCategoryModel {
  _AssetCategoryModel({
    required this.title,
    required List<String> options,
  }) : defaultTypes = List<String>.from(options) {
    for (final String type in defaultTypes) {
      entriesByType[type] = <_AssetEntryModel>[
        _AssetEntryModel(),
      ];
    }
  }

  final String title;
  final List<String> defaultTypes;
  final List<String> customTypes = <String>[];
  final Set<String> removedDefaultTypes = <String>{};
  final Map<String, List<_AssetEntryModel>> entriesByType =
      <String, List<_AssetEntryModel>>{};
  bool isExpanded = false;

  List<String> get allTypes => <String>[
        ...defaultTypes.where((type) => !removedDefaultTypes.contains(type)),
        ...customTypes,
      ];

  bool isCustomType(String type) => customTypes.contains(type);

  void addCustomType(String type) {
    if (!customTypes.contains(type) && !defaultTypes.contains(type)) {
      customTypes.add(type);
      entriesByType[type] = <_AssetEntryModel>[
        _AssetEntryModel(),
      ];
    }
  }

  void removeType(String type) {
    if (customTypes.contains(type)) {
      customTypes.remove(type);
    } else if (defaultTypes.contains(type)) {
      removedDefaultTypes.add(type);
    } else {
      return;
    }

    final List<_AssetEntryModel> entries =
        entriesByType.remove(type) ?? <_AssetEntryModel>[];
    for (final _AssetEntryModel entry in entries) {
      entry.dispose();
    }
  }

  void dispose() {
    for (final List<_AssetEntryModel> entries in entriesByType.values) {
      for (final _AssetEntryModel entry in entries) {
        entry.dispose();
      }
    }
  }
}

class _AssetEntryModel {
  _AssetEntryModel()
      : nameController = TextEditingController(),
        valueController = TextEditingController(),
        notesController = TextEditingController();

  final TextEditingController nameController;
  final TextEditingController valueController;
  final TextEditingController notesController;

  void dispose() {
    nameController.dispose();
    valueController.dispose();
    notesController.dispose();
  }
}

class _AssetCategoryCard extends StatelessWidget {
  const _AssetCategoryCard({
    required this.category,
    required this.onToggleExpanded,
    required this.onAddCustomType,
    required this.onRemoveType,
    required this.valueValidator,
  });

  final _AssetCategoryModel category;
  final VoidCallback onToggleExpanded;
  final VoidCallback onAddCustomType;
  final ValueChanged<String> onRemoveType;
  final String? Function(_AssetEntryModel entry, String? value) valueValidator;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCFA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: category.isExpanded
              ? const Color(0xFF2F8C6E)
              : const Color(0xFFD9DFDC),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onToggleExpanded,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      category.title,
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF21473C),
                      ),
                    ),
                  ),
                  if (category.isExpanded)
                    IconButton(
                      onPressed: onAddCustomType,
                      tooltip: 'Add custom type',
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(
                        Icons.add_circle_outline_rounded,
                        color: Color(0xFF2A6E58),
                      ),
                    ),
                  AnimatedRotation(
                    turns: category.isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF2A6E58),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: category.isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Divider(color: Color(0xFFE2E8E5), height: 18),
                  ...category.allTypes.map((type) {
                    final List<_AssetEntryModel> entries =
                        category.entriesByType[type] ?? <_AssetEntryModel>[];
                    if (entries.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _AssetTypeFormBox(
                        type: type,
                        entry: entries.first,
                        isCustomType: category.isCustomType(type),
                        valueValidator: valueValidator,
                        onRemoveCustomType: () => onRemoveType(type),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssetTypeFormBox extends StatelessWidget {
  const _AssetTypeFormBox({
    required this.type,
    required this.entry,
    required this.isCustomType,
    required this.valueValidator,
    this.onRemoveCustomType,
  });

  final String type;
  final _AssetEntryModel entry;
  final bool isCustomType;
  final String? Function(_AssetEntryModel entry, String? value) valueValidator;
  final VoidCallback? onRemoveCustomType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCE5E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  type,
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF21473C),
                  ),
                ),
              ),
              IconButton(
                onPressed: onRemoveCustomType,
                tooltip:
                    isCustomType ? 'Remove custom type' : 'Remove this option',
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFFFEFEF),
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFC44747),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _EntryTextField(
                  controller: entry.nameController,
                  hint: 'Asset Name',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _EntryTextField(
                  controller: entry.valueController,
                  hint: 'Estimated Value',
                  isRequired: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) => valueValidator(entry, value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _NotesTextField(controller: entry.notesController),
        ],
      ),
    );
  }
}

class _NotesTextField extends StatelessWidget {
  const _NotesTextField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCFE0D9)),
      ),
      child: TextField(
        controller: controller,
        minLines: 3,
        maxLines: 4,
        cursorColor: const Color(0xFF1C5D4E),
        style: GoogleFonts.roboto(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          hintText: 'Notes',
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintStyle: GoogleFonts.roboto(
            fontSize: 14,
            color: const Color(0xFF8C9591),
          ),
        ),
      ),
    );
  }
}

class _EntryTextField extends StatelessWidget {
  const _EntryTextField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.validator,
    this.isRequired = false,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      cursorColor: const Color(0xFF1C5D4E),
      style: GoogleFonts.roboto(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
      decoration: _entryDecoration(
        hint,
        isRequired: isRequired,
      ),
    );
  }
}

InputDecoration _entryDecoration(
  String label, {
  bool isRequired = false,
}) {
  final OutlineInputBorder enabledBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: Color(0xFFCFE0D9)),
  );

  return InputDecoration(
    filled: true,
    fillColor: Colors.white,
    label: _RequiredLabel(text: label, isRequired: isRequired),
    floatingLabelBehavior: FloatingLabelBehavior.never,
    border: enabledBorder,
    enabledBorder: enabledBorder,
    focusedBorder: enabledBorder.copyWith(
      borderSide: const BorderSide(color: Color(0xFF2F8C6E), width: 1.3),
    ),
    errorBorder: enabledBorder.copyWith(
      borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.3),
    ),
    focusedErrorBorder: enabledBorder.copyWith(
      borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
    ),
    errorStyle: GoogleFonts.roboto(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: const Color(0xFFD32F2F),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  );
}

class _RequiredLabel extends StatelessWidget {
  const _RequiredLabel({
    required this.text,
    required this.isRequired,
  });

  final String text;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = GoogleFonts.roboto(
      fontSize: 14,
      color: const Color(0xFF8C9591),
    );

    if (!isRequired) {
      return Text(
        text,
        style: style,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Text.rich(
      TextSpan(
        text: text,
        style: style,
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(
              color: Color(0xFFD32F2F),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _StepProgress extends StatelessWidget {
  const _StepProgress({
    required this.currentStep,
    required this.totalSteps,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final double progress = currentStep / totalSteps;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step $currentStep of $totalSteps',
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2A4F43),
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            color: const Color(0xFF2E8D6F),
            backgroundColor: const Color(0xFFE5EEE9),
          ),
        ),
      ],
    );
  }
}
