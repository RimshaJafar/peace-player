import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/features/digital_will/controllers/digital_will_controller.dart';
import 'package:ecommerce_app/features/digital_will/screens/Wasiyyah.dart';
import 'package:ecommerce_app/features/digital_will/models/digital_will_request_model.dart';
import 'package:ecommerce_app/features/digital_will/models/spouse_model.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class LiabilitiesScreen extends StatefulWidget {
  final SpouseData spouseData;

  const LiabilitiesScreen({
    required this.spouseData,
    super.key,
  });

  @override
  State<LiabilitiesScreen> createState() => _LiabilitiesScreenState();
}

class _LiabilitiesScreenState extends State<LiabilitiesScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final _DebtsCategoryModel _debts;
  late final _MahrModel _mahr;
  late final TextEditingController _funeralExpenseController;
  late final TextEditingController _funeralNotesController;

  @override
  void initState() {
    super.initState();
    _debts = _DebtsCategoryModel(
      types: const <String>[
        'Loans',
        'Credit Cards',
        'Personal Debts',
      ],
    );
    _mahr = _MahrModel();
    _funeralExpenseController = TextEditingController();
    _funeralNotesController = TextEditingController();
  }

  @override
  void dispose() {
    _debts.dispose();
    _mahr.dispose();
    _funeralExpenseController.dispose();
    _funeralNotesController.dispose();
    super.dispose();
  }

  bool _hasLiabilityEntryData(_DebtEntryModel entry) {
    final String name = entry.nameController.text.trim();
    return (name.isNotEmpty && name != entry.prefillName) ||
        entry.amountController.text.trim().isNotEmpty ||
        entry.notesController.text.trim().isNotEmpty;
  }

  String? _validateDebtAmount(_DebtEntryModel entry, String? value) {
    if (!_hasLiabilityEntryData(entry)) {
      return null;
    }

    return PValidator.validateRequiredPositiveNumber('Amount', value);
  }

  String? _validateMahrAmount(String? value) {
    if (!_mahr.isUnpaid) {
      return PValidator.validateOptionalPositiveNumber('Mahr Amount', value);
    }

    return PValidator.validateRequiredPositiveNumber('Mahr Amount', value);
  }

  String? _validateFuneralAmount(String? value) {
    final bool hasFuneralNotes = _funeralNotesController.text.trim().isNotEmpty;
    final bool hasAmount = (value ?? '').trim().isNotEmpty;

    if (!hasFuneralNotes && !hasAmount) {
      return null;
    }

    return PValidator.validateRequiredPositiveNumber('Funeral Cost', value);
  }

  List<DigitalWillLiabilityItemRequest> _collectDebtEntries() {
    final List<DigitalWillLiabilityItemRequest> items =
        <DigitalWillLiabilityItemRequest>[];

    for (final MapEntry<String, List<_DebtEntryModel>> entry
        in _debts.entriesByType.entries) {
      final String typeName = entry.key;
      for (final _DebtEntryModel debtEntry in entry.value) {
        if (!_hasLiabilityEntryData(debtEntry)) {
          continue;
        }

        final double value =
            double.tryParse(debtEntry.amountController.text.trim()) ?? 0;
        if (value <= 0 && debtEntry.nameController.text.trim().isEmpty) {
          continue;
        }

        items.add(
          DigitalWillLiabilityItemRequest(
            name: debtEntry.nameController.text.trim().isEmpty
                ? typeName
                : debtEntry.nameController.text.trim(),
            estimatedValue: value,
            notes: debtEntry.notesController.text.trim(),
          ),
        );
      }
    }

    return items;
  }

  Step3LiabilitiesRequest _buildLiabilitiesRequest() {
    final List<DigitalWillLiabilityItemRequest> mahrItems =
        <DigitalWillLiabilityItemRequest>[];
    final double mahrAmount =
        double.tryParse(_mahr.amountController.text.trim()) ?? 0;
    if (_mahr.isUnpaid && mahrAmount > 0) {
      mahrItems.add(
        DigitalWillLiabilityItemRequest(
          name: 'Unpaid Mahr',
          estimatedValue: mahrAmount,
          notes: _mahr.notesController.text.trim(),
        ),
      );
    }

    final List<DigitalWillLiabilityItemRequest> funeralItems =
        <DigitalWillLiabilityItemRequest>[];
    final double funeralAmount =
        double.tryParse(_funeralExpenseController.text.trim()) ?? 0;
    if (funeralAmount > 0) {
      funeralItems.add(
        DigitalWillLiabilityItemRequest(
          name: 'Burial and funeral',
          estimatedValue: funeralAmount,
          notes: _funeralNotesController.text.trim(),
        ),
      );
    }

    return Step3LiabilitiesRequest(
      debts: _collectDebtEntries(),
      mahrDue: mahrItems,
      funeralExpenses: funeralItems,
    );
  }

  bool _validateAndSaveLiabilities() {
    final bool isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      setState(() {
        if (_debts.entriesByType.values
            .expand((entries) => entries)
            .any(_hasLiabilityEntryData)) {
          _debts.isExpanded = true;
        }
        if (_mahr.isUnpaid) {
          _mahr.isExpanded = true;
        }
      });
      return false;
    }

    Get.find<DigitalWillController>().setLiabilities(
      _buildLiabilitiesRequest(),
    );
    return true;
  }

  Future<void> _showAddCustomDebtTypeDialog() async {
    final TextEditingController customTypeController = TextEditingController();

    final String? customType = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Add Custom Debt Type',
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
              hintText: 'Debt type name',
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
      _debts.addCustomType(customType);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool showMahrSection =
        (widget.spouseData.maritalStatus ?? '').toLowerCase() != 'single';

    return Scaffold(
      appBar: const PAppBar(
        title: Text(
          'Liabilities',
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
                    const _StepProgress(currentStep: 3, totalSteps: 6),
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
                            'Liabilities',
                            style: GoogleFonts.roboto(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E3F35),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Enter debts and obligations that must be settled first.',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF6E7874),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Debts Section
                          _DebtsCategoryCard(
                            category: _debts,
                            amountValidator: _validateDebtAmount,
                            onToggleExpanded: () {
                              setState(() {
                                _debts.isExpanded = !_debts.isExpanded;
                              });
                            },
                            onAddCustomType: _showAddCustomDebtTypeDialog,
                            onRemoveType: (type) {
                              setState(() {
                                _debts.removeType(type);
                              });
                            },
                          ),
                          if (showMahrSection) ...[
                            const SizedBox(height: 12),
                            // Mahr Section
                            _MahrCard(
                              mahr: _mahr,
                              amountValidator: _validateMahrAmount,
                              onToggleExpanded: () {
                                setState(() {
                                  _mahr.isExpanded = !_mahr.isExpanded;
                                });
                              },
                              onUnpaidChanged: (value) {
                                setState(() {
                                  _mahr.isUnpaid = value;
                                });
                              },
                            ),
                          ],
                          const SizedBox(height: 12),
                          // Funeral Expenses Section
                          _FuneralExpensesCard(
                            funeralExpenseController: _funeralExpenseController,
                            funeralNotesController: _funeralNotesController,
                            amountValidator: _validateFuneralAmount,
                          ),
                          const SizedBox(height: 20),
                          // Continue Button
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
                                    if (!_validateAndSaveLiabilities()) {
                                      return;
                                    }
                                    final double netEstate =
                                        Get.find<DigitalWillController>()
                                            .netEstate;
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => WasiyyahScreen(
                                          spouseData: widget.spouseData,
                                          netEstate: netEstate,
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

class _DebtsCategoryModel {
  _DebtsCategoryModel({required List<String> types})
      : defaultTypes = List<String>.from(types) {
    for (final String type in defaultTypes) {
      entriesByType[type] = <_DebtEntryModel>[
        _DebtEntryModel(prefillName: type),
      ];
    }
  }

  final String title = 'Debts';
  final List<String> defaultTypes;
  final List<String> customTypes = <String>[];
  final Set<String> removedDefaultTypes = <String>{};
  final Map<String, List<_DebtEntryModel>> entriesByType =
      <String, List<_DebtEntryModel>>{};
  bool isExpanded = false;

  List<String> get allTypes => <String>[
        ...defaultTypes.where((type) => !removedDefaultTypes.contains(type)),
        ...customTypes,
      ];

  bool isCustomType(String type) => customTypes.contains(type);

  void addCustomType(String type) {
    if (!customTypes.contains(type) && !defaultTypes.contains(type)) {
      customTypes.add(type);
      entriesByType[type] = <_DebtEntryModel>[
        _DebtEntryModel(prefillName: type),
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

    final List<_DebtEntryModel> entries =
        entriesByType.remove(type) ?? <_DebtEntryModel>[];
    for (final _DebtEntryModel entry in entries) {
      entry.dispose();
    }
  }

  void dispose() {
    for (final List<_DebtEntryModel> entries in entriesByType.values) {
      for (final _DebtEntryModel entry in entries) {
        entry.dispose();
      }
    }
  }
}

class _DebtEntryModel {
  _DebtEntryModel({String? prefillName})
      : nameController = TextEditingController(text: prefillName ?? ''),
        prefillName = prefillName ?? '',
        amountController = TextEditingController(),
        notesController = TextEditingController();

  final TextEditingController nameController;
  final String prefillName;
  final TextEditingController amountController;
  final TextEditingController notesController;

  void dispose() {
    nameController.dispose();
    amountController.dispose();
    notesController.dispose();
  }
}

class _MahrModel {
  _MahrModel()
      : amountController = TextEditingController(),
        notesController = TextEditingController();

  final TextEditingController amountController;
  final TextEditingController notesController;
  bool isUnpaid = false;
  bool isExpanded = false;

  void dispose() {
    amountController.dispose();
    notesController.dispose();
  }
}

class _DebtsCategoryCard extends StatelessWidget {
  const _DebtsCategoryCard({
    required this.category,
    required this.onToggleExpanded,
    required this.onAddCustomType,
    required this.onRemoveType,
    required this.amountValidator,
  });

  final _DebtsCategoryModel category;
  final VoidCallback onToggleExpanded;
  final VoidCallback onAddCustomType;
  final ValueChanged<String> onRemoveType;
  final String? Function(_DebtEntryModel entry, String? value) amountValidator;

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
                      tooltip: 'Add custom debt type',
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
                    final List<_DebtEntryModel> entries =
                        category.entriesByType[type] ?? <_DebtEntryModel>[];
                    if (entries.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _DebtTypeFormBox(
                        type: type,
                        entry: entries.first,
                        isCustomType: category.isCustomType(type),
                        amountValidator: amountValidator,
                        onRemoveType: () => onRemoveType(type),
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

class _DebtTypeFormBox extends StatelessWidget {
  const _DebtTypeFormBox({
    required this.type,
    required this.entry,
    required this.isCustomType,
    required this.amountValidator,
    this.onRemoveType,
  });

  final String type;
  final _DebtEntryModel entry;
  final bool isCustomType;
  final String? Function(_DebtEntryModel entry, String? value) amountValidator;
  final VoidCallback? onRemoveType;

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
                onPressed: onRemoveType,
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
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _LiabilityTextField(
                  controller: entry.nameController,
                  hint: 'Debt Name',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _LiabilityTextField(
                  controller: entry.amountController,
                  hint: 'Amount',
                  isRequired: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) => amountValidator(entry, value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _LiabilityNotesField(controller: entry.notesController),
        ],
      ),
    );
  }
}

class _DebtEntryRow extends StatelessWidget {
  const _DebtEntryRow({
    required this.nameController,
    required this.amountController,
    required this.notesController,
    required this.onRemove,
  });

  final TextEditingController nameController;
  final TextEditingController amountController;
  final TextEditingController notesController;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFCFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE3E8E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _LiabilityTextField(
                  controller: nameController,
                  hint: 'Debt Name',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _LiabilityTextField(
                  controller: amountController,
                  hint: 'Amount',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 36,
                height: 36,
                child: IconButton(
                  onPressed: onRemove,
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
          const SizedBox(height: 8),
          _LiabilityNotesField(controller: notesController),
        ],
      ),
    );
  }
}

class _MahrCard extends StatelessWidget {
  const _MahrCard({
    required this.mahr,
    required this.onToggleExpanded,
    required this.onUnpaidChanged,
    required this.amountValidator,
  });

  final _MahrModel mahr;
  final VoidCallback onToggleExpanded;
  final ValueChanged<bool> onUnpaidChanged;
  final String? Function(String?) amountValidator;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCFA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: mahr.isExpanded
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
                      'Mahr (Dowry)',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF21473C),
                      ),
                    ),
                  ),
                  if (mahr.isUnpaid)
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F4EF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Unpaid',
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2A6E58),
                        ),
                      ),
                    ),
                  AnimatedRotation(
                    turns: mahr.isExpanded ? 0.5 : 0,
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
            crossFadeState: mahr.isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Is there any unpaid Mahr?',
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
                        child: _DebtChoiceButton(
                          label: 'Yes',
                          isSelected: mahr.isUnpaid,
                          onTap: () => onUnpaidChanged(true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _DebtChoiceButton(
                          label: 'No',
                          isSelected: !mahr.isUnpaid,
                          onTap: () => onUnpaidChanged(false),
                        ),
                      ),
                    ],
                  ),
                  if (mahr.isUnpaid) ...[
                    const SizedBox(height: 12),
                    _LiabilityTextField(
                      controller: mahr.amountController,
                      hint: 'Mahr Amount',
                      isRequired: true,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: amountValidator,
                    ),
                    const SizedBox(height: 8),
                    _LiabilityNotesField(controller: mahr.notesController),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FuneralExpensesCard extends StatelessWidget {
  const _FuneralExpensesCard({
    required this.funeralExpenseController,
    required this.funeralNotesController,
    required this.amountValidator,
  });

  final TextEditingController funeralExpenseController;
  final TextEditingController funeralNotesController;
  final String? Function(String?) amountValidator;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCFA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFD9DFDC),
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Funeral Expenses',
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF21473C),
            ),
          ),
          const SizedBox(height: 10),
          _LiabilityTextField(
            controller: funeralExpenseController,
            hint: 'Estimated or Actual Cost',
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            validator: amountValidator,
          ),
          const SizedBox(height: 8),
          _LiabilityNotesField(controller: funeralNotesController),
        ],
      ),
    );
  }
}

class _LiabilityNotesField extends StatelessWidget {
  const _LiabilityNotesField({required this.controller});

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

class _LiabilityTextField extends StatelessWidget {
  const _LiabilityTextField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.maxLines = 1,
    this.onChanged,
    this.validator,
    this.isRequired = false,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      minLines: 1,
      onChanged: onChanged,
      validator: validator,
      cursorColor: const Color(0xFF1C5D4E),
      style: GoogleFonts.roboto(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
      decoration: _liabilityFieldDecoration(
        hint,
        isRequired: isRequired,
      ),
    );
  }
}

InputDecoration _liabilityFieldDecoration(
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

class _DebtChoiceButton extends StatelessWidget {
  const _DebtChoiceButton({
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
          padding: const EdgeInsets.symmetric(vertical: 10),
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
