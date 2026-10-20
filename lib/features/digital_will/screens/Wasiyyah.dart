import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/features/digital_will/controllers/digital_will_controller.dart';
import 'package:ecommerce_app/features/digital_will/screens/heirs.dart';
import 'package:ecommerce_app/features/digital_will/models/digital_will_request_model.dart';
import 'package:ecommerce_app/features/digital_will/models/spouse_model.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecommerce_app/common/controllers/external_service_controller.dart';
import 'package:ecommerce_app/common/models/country_model.dart';
import 'package:ecommerce_app/features/digital_will/controllers/pdf_generation_controller.dart';

String _formatCurrency(double value,
    {String? countryName, String? currencyCode}) {
  final String fixed = value.toStringAsFixed(2);
  final List<String> parts = fixed.split('.');
  final String whole = parts.first;
  final String decimal = parts.last;

  final StringBuffer formatted = StringBuffer();
  for (int i = 0; i < whole.length; i++) {
    final int reverseIndex = whole.length - i;
    formatted.write(whole[i]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      formatted.write(',');
    }
  }

  String symbol = '';
  String flag = '';
  String code = currencyCode ?? '';

  if ((countryName == null || countryName.isEmpty) &&
      Get.isRegistered<DigitalWillController>()) {
    countryName =
        Get.find<DigitalWillController>().basicInfo?.countryJurisdiction;
  }

  if (Get.isRegistered<ExternalServiceController>()) {
    final ext = Get.find<ExternalServiceController>();
    Country? country;
    if (countryName != null && countryName.isNotEmpty) {
      country = ext.getCountryByName(countryName);
    }
    if (country != null) {
      if (country.currencies.isNotEmpty) {
        symbol = country.currencies.values.first;
        code = country.currencies.keys.first;
      }
      if (country.code.isNotEmpty) {
        flag = ExternalServiceController.flagEmojiFromCountryCode(country.code);
      }
    } else {
      if (code.isEmpty && Get.isRegistered<PdfGenerationController>()) {
        code = Get.find<PdfGenerationController>().selectedCurrency.value;
      }
      if (code.isNotEmpty) {
        final extSymbol = ext.findCurrencySymbolByCode(code);
        if (extSymbol != null) symbol = extSymbol;
      }
    }
  } else {
    if (code.isEmpty && Get.isRegistered<PdfGenerationController>()) {
      code = Get.find<PdfGenerationController>().selectedCurrency.value;
    }
  }

  if (symbol.isEmpty) {
    const Map<String, String> fallback = {
      'PKR': 'Rs',
      'SAR': 'SAR',
      'USD': r'$',
      'AED': 'AED',
      'GBP': '£',
      'EUR': '€',
      'INR': '₹'
    };
    if (code.isNotEmpty && fallback.containsKey(code)) {
      symbol = fallback[code]!;
    }
  }
  if (symbol.isEmpty) symbol = 'SAR';

  String result = '$symbol ${formatted.toString()}.$decimal';
  if (flag.isNotEmpty) {
    result = '$result $flag';
  }
  return result;
}

String _currencyCode({String? countryName, String? currencyCode}) {
  String code = currencyCode ?? '';
  if ((countryName == null || countryName.isEmpty) &&
      Get.isRegistered<DigitalWillController>()) {
    countryName =
        Get.find<DigitalWillController>().basicInfo?.countryJurisdiction;
  }
  if (Get.isRegistered<ExternalServiceController>()) {
    final ext = Get.find<ExternalServiceController>();
    Country? country;
    if (countryName != null && countryName.isNotEmpty) {
      country = ext.getCountryByName(countryName);
    }
    if (country != null && country.currencies.isNotEmpty) {
      code = country.currencies.keys.first;
    } else {
      if (code.isEmpty && Get.isRegistered<PdfGenerationController>()) {
        code = Get.find<PdfGenerationController>().selectedCurrency.value;
      }
    }
  } else {
    if (code.isEmpty && Get.isRegistered<PdfGenerationController>()) {
      code = Get.find<PdfGenerationController>().selectedCurrency.value;
    }
  }
  if (code.isEmpty) code = 'SAR';
  return code;
}

class WasiyyahScreen extends StatefulWidget {
  final SpouseData spouseData;

  const WasiyyahScreen({
    required this.spouseData,
    super.key,
    this.netEstate = 100000.0,
  });

  final double netEstate;

  @override
  State<WasiyyahScreen> createState() => _WasiyyahScreenState();
}

class _WasiyyahScreenState extends State<WasiyyahScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late List<_WasiyyahEntryModel> _entries;
  bool hasWasiyyah = false;
  String _wasiyyahMode = 'Partial Wasiyyah';
  String? _validationError;
  bool _showHeirFieldError = false;
  bool _showFieldValidationErrors = false;
  int _currentEntryIndex = 0;

  @override
  void initState() {
    super.initState();
    _entries = <_WasiyyahEntryModel>[];
  }

  @override
  void dispose() {
    for (final _WasiyyahEntryModel entry in _entries) {
      entry.dispose();
    }
    super.dispose();
  }

  bool _hasBeneficiaryData(_WasiyyahEntryModel entry) {
    return entry.nameController.text.trim().isNotEmpty ||
        entry.typeController.text.trim().isNotEmpty ||
        entry.amountController.text.trim().isNotEmpty ||
        entry.notesController.text.trim().isNotEmpty;
  }

  String _normalizeBeneficiaryType(String rawType) {
    final String normalizedType = rawType.trim().toLowerCase();

    switch (normalizedType) {
      case 'charity':
        return 'charity';
      case 'person':
      case 'individual':
        return 'person';
      case 'institution':
      case 'organization':
        return 'institution';
      default:
        return 'institution';
    }
  }

  String _wasiyyahAllowedAmountLabel() {
    return _formatCurrency(_maximumWasiyyah);
  }

  String _wasiyyahCurrentAmountLabel() {
    return _formatCurrency(_calculateTotalAllocated());
  }

  String? _wasiyyahValidationMessage() {
    if (!hasWasiyyah || _entries.isEmpty) {
      return null;
    }

    if (_entries.any((entry) => entry.isHeir)) {
      return 'Beneficiaries must not be marked as heirs.';
    }

    final double totalAllocated = _calculateTotalAllocated();
    final String allowedAmount = _wasiyyahAllowedAmountLabel();
    final String currentAmount = _wasiyyahCurrentAmountLabel();

    if (_wasiyyahMode == 'Full Wasiyyah') {
      if (!_isApproximatelyEqual(totalAllocated, _maximumWasiyyah)) {
        return 'Full Wasiyyah requires the total allocated amount to equal $allowedAmount. Current total: $currentAmount.';
      }
      return 'Full Wasiyyah validated: total is $currentAmount.';
    }

    if (totalAllocated >= _maximumWasiyyah) {
      return 'Partial Wasiyyah requires the total allocated amount to be less than $allowedAmount. Current total: $currentAmount.';
    }

    return 'Partial Wasiyyah validated: total is $currentAmount.';
  }

  List<DigitalWillBeneficiaryRequest> _collectBeneficiaries() {
    final List<DigitalWillBeneficiaryRequest> beneficiaries =
        <DigitalWillBeneficiaryRequest>[];

    for (final _WasiyyahEntryModel entry in _entries) {
      if (!entry.isHeir && !_hasBeneficiaryData(entry)) {
        continue;
      }

      final String type = entry.typeController.text.trim().isEmpty
          ? 'person'
          : _normalizeBeneficiaryType(entry.typeController.text);
      final String name = entry.nameController.text.trim();
      final String rawAmount = entry.amountController.text.trim();
      final double parsedValue = double.tryParse(rawAmount) ?? 0;
      final bool isPercentage =
          entry.allocationTypeController.text == 'Percentage';

      beneficiaries.add(
        DigitalWillBeneficiaryRequest(
          type: type,
          name: name,
          amount: isPercentage ? null : parsedValue,
          percentage: isPercentage ? parsedValue : null,
          isHeir: entry.isHeir,
          description: entry.notesController.text.trim(),
        ),
      );
    }

    return beneficiaries;
  }

  Step4WasiyyahRequest _buildWasiyyahRequest() {
    if (!hasWasiyyah) {
      return const Step4WasiyyahRequest(
        hasWasiyyah: false,
        wasiyyahType: 'no',
        beneficiaries: <DigitalWillBeneficiaryRequest>[],
        totalWasiyyahAmount: 0,
        notes: '',
      );
    }

    final List<DigitalWillBeneficiaryRequest> beneficiaries =
        _collectBeneficiaries();
    final bool isFullWasiyyah = _wasiyyahMode == 'Full Wasiyyah';
    final double totalWasiyyahAmount = _calculateTotalAllocated();

    return Step4WasiyyahRequest(
      hasWasiyyah: true,
      wasiyyahType: isFullWasiyyah ? 'full' : 'partial',
      beneficiaries: beneficiaries,
      totalWasiyyahAmount: totalWasiyyahAmount,
      notes: _wasiyyahMode == 'Full Wasiyyah'
          ? 'Full wasiyyah selected'
          : 'Partial wasiyyah selected',
    );
  }

  double get _maximumWasiyyah => widget.netEstate / 3;

  double _calculateTotalAllocated() {
    double total = 0.0;
    for (final _WasiyyahEntryModel entry in _entries) {
      if (entry.allocationTypeController.text == 'Percentage') {
        final double percentage =
            double.tryParse(entry.amountController.text) ?? 0.0;
        total += (widget.netEstate * percentage / 100);
      } else {
        final double amount =
            double.tryParse(entry.amountController.text) ?? 0.0;
        total += amount;
      }
    }
    return total;
  }

  double get _remainingAllowable =>
      _maximumWasiyyah - _calculateTotalAllocated();

  /// Check if two double values are approximately equal within tolerance
  /// Tolerance is 1% of maximum or 0.01, whichever is larger
  bool _isApproximatelyEqual(double value1, double value2) {
    final double tolerance =
        (_maximumWasiyyah * 0.01).clamp(0.01, double.infinity);
    return (value1 - value2).abs() <= tolerance;
  }

  bool get _isValid {
    if (!hasWasiyyah) {
      return true;
    }

    // If wasiyyah is enabled but no beneficiaries added yet, invalid
    if (_entries.isEmpty) {
      return false;
    }

    // Check no entries are marked as heirs (invalid for wasiyyah)
    if (_entries.any((entry) => entry.isHeir)) {
      return false;
    }

    final double totalAllocated = _calculateTotalAllocated();

    if (_wasiyyahMode == 'Full Wasiyyah') {
      // Full wasiyyah: total must equal exactly 1/3 of net estate (within tolerance)
      return _isApproximatelyEqual(totalAllocated, _maximumWasiyyah);
    } else {
      // Partial wasiyyah: total must be strictly less than 1/3
      return totalAllocated < _maximumWasiyyah;
    }
  }

  bool get _isExceeded => _calculateTotalAllocated() > _maximumWasiyyah;

  String? _validateBeneficiaryName(String? value) {
    return PValidator.validateEmptyText('Beneficiary Name', value);
  }

  String? _validateBeneficiaryType(_WasiyyahEntryModel entry) {
    return PValidator.validateRequiredSelection(
      'Beneficiary Type',
      entry.typeController.text,
    );
  }

  String? _validateBeneficiaryAmount(
    _WasiyyahEntryModel entry,
    String? value,
  ) {
    if (entry.allocationTypeController.text == 'Percentage') {
      return PValidator.validateRequiredPercentage('Percentage', value);
    }

    return PValidator.validateRequiredPositiveNumber('Amount', value);
  }

  int _firstInvalidBeneficiaryIndex() {
    for (int i = 0; i < _entries.length; i++) {
      final _WasiyyahEntryModel entry = _entries[i];
      if (_validateBeneficiaryName(entry.nameController.text) != null ||
          _validateBeneficiaryType(entry) != null ||
          _validateBeneficiaryAmount(entry, entry.amountController.text) !=
              null) {
        return i;
      }
    }

    return -1;
  }

  void _addWasiyyahEntry() {
    setState(() {
      _entries.add(_WasiyyahEntryModel());
      if (_entries.length == 1) {
        _currentEntryIndex = 0;
      }
    });
  }

  void _removeWasiyyahEntry(int index) {
    setState(() {
      _entries[index].dispose();
      _entries.removeAt(index);
      if (_entries.isEmpty) {
        _currentEntryIndex = 0;
      } else if (_currentEntryIndex >= _entries.length) {
        _currentEntryIndex = _entries.length - 1;
      }
    });
  }

  Future<void> _showAddCustomTypeDialog(_WasiyyahEntryModel targetEntry) async {
    final TextEditingController customTypeController = TextEditingController();

    final String? customType = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Add Custom Beneficiary Type',
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
              hintText: 'Type name (e.g., Mosque, School)',
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
      targetEntry.customTypes.add(customType);
    });
  }

  void _onContinue() {
    if (!hasWasiyyah) {
      setState(() {
        _validationError = null;
      });
      // Ensure controller is updated to reflect no Wasiyyah selection
      try {
        Get.find<DigitalWillController>().setWasiyyah(_buildWasiyyahRequest());
      } catch (_) {
        // ignore if controller not registered
      }
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => HeirsInformationScreen(
            spouseData: widget.spouseData,
          ),
        ),
      );
      return;
    }

    // Check if beneficiaries are added
    if (_entries.isEmpty) {
      setState(() {
        _validationError = 'Please add at least one beneficiary.';
        _showHeirFieldError = false;
      });
      return;
    }

    // Check if any entry is marked as heir (invalid for wasiyyah)
    final int firstHeirIndex = _entries.indexWhere((entry) => entry.isHeir);
    if (firstHeirIndex != -1) {
      setState(() {
        _validationError = null;
        _showHeirFieldError = true;
        _showFieldValidationErrors = false;
        _currentEntryIndex = firstHeirIndex;
      });
      return;
    }

    final int firstInvalidEntryIndex = _firstInvalidBeneficiaryIndex();
    final bool currentFormValid = _formKey.currentState?.validate() ?? false;
    if (firstInvalidEntryIndex != -1 || !currentFormValid) {
      setState(() {
        _validationError = 'Complete all required beneficiary details.';
        _showHeirFieldError = false;
        _showFieldValidationErrors = true;
        if (firstInvalidEntryIndex != -1) {
          _currentEntryIndex = firstInvalidEntryIndex;
        }
      });
      return;
    }

    final double totalAllocated = _calculateTotalAllocated();

    if (_wasiyyahMode == 'Partial Wasiyyah') {
      // Partial wasiyyah: total must be strictly less than 1/3
      if (totalAllocated >= _maximumWasiyyah) {
        setState(() {
          _validationError =
              'Total allocation must be less than ${_formatCurrency(_maximumWasiyyah)} (one-third of the estate). Current total: ${_formatCurrency(totalAllocated)}.';
          _showHeirFieldError = false;
        });
        return;
      }
    } else {
      // Full wasiyyah: total must equal exactly 1/3 of net estate (within tolerance)
      if (!_isApproximatelyEqual(totalAllocated, _maximumWasiyyah)) {
        final String expectedAmount = _formatCurrency(_maximumWasiyyah);
        final String actualAmount = _formatCurrency(totalAllocated);
        setState(() {
          _validationError =
              'Full wasiyyah must equal exactly $expectedAmount. Current total: $actualAmount.';
          _showHeirFieldError = false;
        });
        return;
      }
    }

    setState(() {
      _validationError = null;
      _showHeirFieldError = false;
      _showFieldValidationErrors = false;
    });
    Get.find<DigitalWillController>().setWasiyyah(_buildWasiyyahRequest());
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HeirsInformationScreen(
          spouseData: widget.spouseData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PAppBar(
        title: Text(
          'Wasiyyah',
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
                    const _StepProgress(currentStep: 4, totalSteps: 6),
                    const SizedBox(height: 16),
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
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
                            'Wasiyyah',
                            style: GoogleFonts.roboto(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E3F35),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Optionally allocate up to one-third of your estate to non-heirs.',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF6E7874),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Yes/No Choice
                          Text(
                            'Do you want to assign Wasiyyah?',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF404040),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _WasiyyahChoiceButton(
                                  label: 'No',
                                  isSelected: !hasWasiyyah,
                                  onTap: () {
                                    setState(() {
                                      hasWasiyyah = false;
                                      _validationError = null;
                                      _showHeirFieldError = false;
                                      _showFieldValidationErrors = false;
                                      _currentEntryIndex = 0;
                                      // Clear entries when switching to No
                                      for (final entry in _entries) {
                                        entry.dispose();
                                      }
                                      _entries.clear();
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _WasiyyahChoiceButton(
                                  label: 'Yes',
                                  isSelected: hasWasiyyah,
                                  onTap: () {
                                    setState(() {
                                      if (!hasWasiyyah) {
                                        _wasiyyahMode = 'Full Wasiyyah';
                                      }
                                      hasWasiyyah = true;
                                      _validationError = null;
                                      _showHeirFieldError = false;
                                      _showFieldValidationErrors = false;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          // Expanded content if Yes
                          if (hasWasiyyah) ...[
                            const SizedBox(height: 20),
                            Text(
                              'Wasiyyah Type *',
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF404040),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAFCFB),
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: const Color(0xFFCFE0D9)),
                              ),
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _wasiyyahMode,
                                underline: const SizedBox.shrink(),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Partial Wasiyyah',
                                    child: Text('Partial Wasiyyah'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Full Wasiyyah',
                                    child: Text('Full Wasiyyah'),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _wasiyyahMode = value;
                                      _validationError = null;
                                      _showHeirFieldError = false;
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5FAF8),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFD4E6DF),
                                ),
                              ),
                              child: Text(
                                _wasiyyahMode == 'Full Wasiyyah'
                                    ? 'In Full Wasiyyah, the total amount for all beneficiaries must equal one-third of the estate.'
                                    : 'In Partial Wasiyyah, you can assign any amount up to one-third of the estate.',
                                style: GoogleFonts.roboto(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF6E7874),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Beneficiaries *',
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF404040),
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (_entries.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _WasiyyahEntryCard(
                                  entry: _entries[_currentEntryIndex],
                                  currentIndex: _currentEntryIndex,
                                  totalEntries: _entries.length,
                                  onPrevious: _currentEntryIndex > 0
                                      ? () {
                                          setState(() {
                                            _currentEntryIndex--;
                                            _validationError = null;
                                            _showHeirFieldError = false;
                                          });
                                        }
                                      : null,
                                  onNext:
                                      _currentEntryIndex < _entries.length - 1
                                          ? () {
                                              setState(() {
                                                _currentEntryIndex++;
                                                _validationError = null;
                                                _showHeirFieldError = false;
                                              });
                                            }
                                          : null,
                                  onRemove: () =>
                                      _removeWasiyyahEntry(_currentEntryIndex),
                                  onAddCustomType: () =>
                                      _showAddCustomTypeDialog(
                                    _entries[_currentEntryIndex],
                                  ),
                                  showHeirValidationError: _showHeirFieldError,
                                  showFieldValidationErrors:
                                      _showFieldValidationErrors,
                                  nameValidator: _validateBeneficiaryName,
                                  typeValidator: _validateBeneficiaryType,
                                  amountValidator: _validateBeneficiaryAmount,
                                  onChanged: () {
                                    setState(() {
                                      _validationError = null;
                                      _showHeirFieldError = false;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            SizedBox(
                              height: 44,
                              child: OutlinedButton.icon(
                                onPressed: _addWasiyyahEntry,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFF2F8C6E),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.add,
                                  color: Color(0xFF2F8C6E),
                                ),
                                label: Text(
                                  '+ Add Beneficiary',
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF2F8C6E),
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5FAF8),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFD4E6DF),
                                ),
                              ),
                              child: Text(
                                'You can skip this step and proceed without assigning any Wasiyyah.',
                                style: GoogleFonts.roboto(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF6E7874),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          // Continue Button
                          SizedBox(
                            height: 56,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: _isValid
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFF2F8C6E),
                                          Color(0xFF1C5D4E),
                                        ],
                                      )
                                    : LinearGradient(
                                        colors: [
                                          const Color(0xFF2F8C6E)
                                              .withOpacity(0.5),
                                          const Color(0xFF1C5D4E)
                                              .withOpacity(0.5),
                                        ],
                                      ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  if (_isValid)
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
                                  onTap: _onContinue,
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
                          if (_validationError != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              _validationError!,
                              style: GoogleFonts.roboto(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFC44747),
                              ),
                            ),
                          ],
                          if (hasWasiyyah && _entries.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              _wasiyyahValidationMessage() ?? '',
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _isValid
                                    ? const Color(0xFF2E8D6F)
                                    : const Color(0xFFC44747),
                              ),
                            ),
                          ],
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

class _WasiyyahEntryModel {
  _WasiyyahEntryModel()
      : nameController = TextEditingController(),
        allocationTypeController = TextEditingController(text: 'Amount'),
        typeController = TextEditingController(),
        amountController = TextEditingController(),
        notesController = TextEditingController(),
        customTypes = <String>[];

  final TextEditingController nameController;
  final TextEditingController allocationTypeController;
  final TextEditingController typeController;
  final TextEditingController amountController;
  final TextEditingController notesController;
  final List<String> customTypes;
  bool isHeir = false;

  final List<String> defaultTypes = const <String>[
    'Charity',
    'Person',
    'Institution',
  ];

  List<String> get allTypes => <String>[...defaultTypes, ...customTypes];

  void dispose() {
    nameController.dispose();
    allocationTypeController.dispose();
    typeController.dispose();
    amountController.dispose();
    notesController.dispose();
  }
}

class _WasiyyahEntryCard extends StatefulWidget {
  const _WasiyyahEntryCard({
    required this.entry,
    required this.currentIndex,
    required this.totalEntries,
    required this.onPrevious,
    required this.onNext,
    required this.onRemove,
    required this.onAddCustomType,
    required this.showHeirValidationError,
    required this.showFieldValidationErrors,
    required this.nameValidator,
    required this.typeValidator,
    required this.amountValidator,
    required this.onChanged,
  });

  final _WasiyyahEntryModel entry;
  final int currentIndex;
  final int totalEntries;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback onRemove;
  final VoidCallback onAddCustomType;
  final bool showHeirValidationError;
  final bool showFieldValidationErrors;
  final String? Function(String? value) nameValidator;
  final String? Function(_WasiyyahEntryModel entry) typeValidator;
  final String? Function(_WasiyyahEntryModel entry, String? value)
      amountValidator;
  final VoidCallback onChanged;

  @override
  State<_WasiyyahEntryCard> createState() => _WasiyyahEntryCardState();
}

class _WasiyyahEntryCardState extends State<_WasiyyahEntryCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE0E5E2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.totalEntries > 1) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: widget.onPrevious,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                  color: const Color(0xFF2F8C6E),
                  splashRadius: 18,
                ),
                Text(
                  '${widget.currentIndex + 1}/${widget.totalEntries}',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1C5D4E),
                  ),
                ),
                IconButton(
                  onPressed: widget.onNext,
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  color: const Color(0xFF2F8C6E),
                  splashRadius: 18,
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
          // Header with delete
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _WasiyyahTextField(
                  controller: widget.entry.nameController,
                  hint: 'Beneficiary Name',
                  isRequired: true,
                  validator: widget.nameValidator,
                  autovalidateMode: widget.showFieldValidationErrors
                      ? AutovalidateMode.always
                      : AutovalidateMode.disabled,
                  onChanged: (_) => widget.onChanged(),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 36,
                height: 36,
                child: IconButton(
                  onPressed: widget.onRemove,
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFFFEFEF),
                  ),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFC44747),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Type Dropdown
          DropdownButtonFormField<String>(
            value: widget.entry.typeController.text.isEmpty
                ? null
                : widget.entry.typeController.text,
            isExpanded: true,
            validator: (_) => widget.typeValidator(widget.entry),
            autovalidateMode: widget.showFieldValidationErrors
                ? AutovalidateMode.always
                : AutovalidateMode.disabled,
            decoration: _wasiyyahFieldDecoration(
              'Select Type',
              isRequired: true,
            ),
            dropdownColor: Colors.white,
            items: [
              ...widget.entry.allTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(
                    type,
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                );
              }),
              DropdownMenuItem<String>(
                value: '__ADD_CUSTOM__',
                child: Text(
                  '+ Add Custom Type',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2A6E58),
                  ),
                ),
              ),
            ],
            onChanged: (value) {
              if (value == '__ADD_CUSTOM__') {
                widget.onAddCustomType();
              } else if (value != null) {
                setState(() {
                  widget.entry.typeController.text = value;
                  widget.onChanged();
                });
              }
            },
          ),
          const SizedBox(height: 10),
          // Allocation Type and Amount
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 140,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFCFB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFCFE0D9)),
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: widget.entry.allocationTypeController.text,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(
                        value: 'Amount',
                        child: Text('Amount'),
                      ),
                      DropdownMenuItem(
                        value: 'Percentage',
                        child: Text('Percentage'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          widget.entry.allocationTypeController.text = value;
                          widget.entry.amountController.clear();
                          widget.onChanged();
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _WasiyyahTextField(
                  controller: widget.entry.amountController,
                  hint:
                      widget.entry.allocationTypeController.text == 'Percentage'
                          ? 'Percentage (%)'
                          : 'Amount (${_currencyCode()})',
                  isRequired: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) =>
                      widget.amountValidator(widget.entry, value),
                  autovalidateMode: widget.showFieldValidationErrors
                      ? AutovalidateMode.always
                      : AutovalidateMode.disabled,
                  onChanged: (_) => widget.onChanged(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Heir',
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF404040),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFCFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCFE0D9)),
            ),
            child: DropdownButton<bool>(
              isExpanded: true,
              value: widget.entry.isHeir,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem<bool>(
                  value: false,
                  child: Text('false'),
                ),
                DropdownMenuItem<bool>(
                  value: true,
                  child: Text('true'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    widget.entry.isHeir = value;
                  });
                  widget.onChanged();
                }
              },
            ),
          ),
          if (widget.showHeirValidationError && widget.entry.isHeir) ...[
            const SizedBox(height: 6),
            Text(
              'The is_heir should be false.',
              style: GoogleFonts.roboto(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFC44747),
              ),
            ),
          ],
          const SizedBox(height: 10),
          _WasiyyahNotesTextField(controller: widget.entry.notesController),
        ],
      ),
    );
  }
}

class _WasiyyahNotesTextField extends StatelessWidget {
  const _WasiyyahNotesTextField({required this.controller});

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
          disabledBorder: InputBorder.none,
          hintStyle: GoogleFonts.roboto(
            fontSize: 14,
            color: const Color(0xFF8C9591),
          ),
        ),
      ),
    );
  }
}

class _WasiyyahSummaryCard extends StatelessWidget {
  const _WasiyyahSummaryCard({
    required this.maximumWasiyyah,
    required this.totalAllocated,
    required this.remainingAllowable,
    required this.isExceeded,
  });

  final double maximumWasiyyah;
  final double totalAllocated;
  final double remainingAllowable;
  final bool isExceeded;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isExceeded ? const Color(0xFFFFF3F3) : const Color(0xFFF5FAF8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExceeded ? const Color(0xFFFFD9D9) : const Color(0xFFD4E6DF),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isExceeded) ...[
            Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFC44747),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Total exceeds one-third limit',
                    style: GoogleFonts.roboto(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFC44747),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Maximum Allowed',
                style: GoogleFonts.roboto(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6E7874),
                ),
              ),
              Text(
                _formatCurrency(maximumWasiyyah),
                style: GoogleFonts.roboto(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1C5D4E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Allocated',
                style: GoogleFonts.roboto(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6E7874),
                ),
              ),
              Text(
                _formatCurrency(totalAllocated),
                style: GoogleFonts.roboto(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isExceeded
                      ? const Color(0xFFC44747)
                      : const Color(0xFF1C5D4E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 1,
            color: const Color(0xFFD4E6DF),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Remaining Allowed',
                style: GoogleFonts.roboto(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6E7874),
                ),
              ),
              Text(
                _formatCurrency(remainingAllowable.clamp(0, double.infinity)),
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isExceeded
                      ? const Color(0xFFC44747)
                      : const Color(0xFF2E8D6F),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WasiyyahTextField extends StatelessWidget {
  const _WasiyyahTextField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.onChanged,
    this.validator,
    this.autovalidateMode,
    this.isRequired = false,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
      autovalidateMode: autovalidateMode,
      cursorColor: const Color(0xFF1C5D4E),
      style: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
      decoration: _wasiyyahFieldDecoration(
        hint,
        isRequired: isRequired,
      ),
    );
  }
}

InputDecoration _wasiyyahFieldDecoration(
  String label, {
  bool isRequired = false,
}) {
  final OutlineInputBorder enabledBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: Color(0xFFCFE0D9)),
  );

  return InputDecoration(
    filled: true,
    fillColor: const Color(0xFFFAFCFB),
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
      fontSize: 13,
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

class _WasiyyahChoiceButton extends StatelessWidget {
  const _WasiyyahChoiceButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE7F5EF) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF2F8C6E)
                  : const Color(0xFFD4DDDA),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? const Color(0xFF1C5D4E)
                  : const Color(0xFF556560),
            ),
          ),
        ),
      ),
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
