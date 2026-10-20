import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/features/digital_will/controllers/digital_will_controller.dart';
import 'package:ecommerce_app/features/digital_will/screens/final_distribution.dart';
import 'package:ecommerce_app/features/digital_will/models/digital_will_request_model.dart';
import 'package:ecommerce_app/features/digital_will/models/spouse_model.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class HeirsInformationScreen extends StatefulWidget {
  final SpouseData spouseData;

  const HeirsInformationScreen({
    required this.spouseData,
    super.key,
  });

  @override
  State<HeirsInformationScreen> createState() => _HeirsInformationScreenState();
}

class _HeirsInformationScreenState extends State<HeirsInformationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // Global state variables
  late String gender;
  String? maritalStatus;
  int wivesCount = 0;
  final List<bool> wifeStatuses = [];
  final List<TextEditingController> wifeNameControllers = [];
  final List<TextEditingController> sonNameControllers = [];
  final List<TextEditingController> daughterNameControllers = [];

  bool husbandAlive = false;
  bool fatherAlive = false;
  bool motherAlive = false;

  int sonsCount = 0;
  int daughtersCount = 0;

  bool grandfatherAlive = false;
  bool grandmotherAlive = false;

  int brothersCount = 0;
  int sistersCount = 0;

  int nephewsCount = 0;
  int unclesCount = 0;
  int cousinsCount = 0;

  final List<String> _maritalStatuses = const [
    'Single',
    'Married',
    'Widowed',
    'Divorced',
  ];

  final List<String> _wivesOptions = const ['1', '2', '3', '4'];

  @override
  void initState() {
    super.initState();
    // Initialize gender from spouseData
    gender = widget.spouseData.gender.toLowerCase();
    maritalStatus = widget.spouseData.maritalStatus;
  }

  // Derived flags
  bool get hasChildren => sonsCount > 0 || daughtersCount > 0;
  bool get hasSons => sonsCount > 0;
  bool get hasOnlyDaughters => sonsCount == 0 && daughtersCount > 0;
  bool get siblingsPresent => brothersCount + sistersCount >= 2;
  bool get showChildrenSection => maritalStatus != 'Single';

  bool get showGrandparentsSection => !fatherAlive;
  bool get showSiblingsSection => !fatherAlive && !hasSons;
  bool get showExtendedRelativesSection => !fatherAlive && !hasChildren;

  int get revealedSectionsCount {
    int count = 2;
    if (showChildrenSection) {
      count++;
    }
    if (showGrandparentsSection) {
      count++;
    }
    if (showSiblingsSection) {
      count++;
    }
    if (showExtendedRelativesSection) {
      count++;
    }
    return count;
  }

  @override
  void dispose() {
    for (final controller in wifeNameControllers) {
      controller.dispose();
    }
    for (final controller in sonNameControllers) {
      controller.dispose();
    }
    for (final controller in daughterNameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateWizardState(VoidCallback updates) {
    setState(() {
      updates();
      _normalizeState();
    });
  }

  void _normalizeState() {
    wivesCount = wivesCount.clamp(0, 4);

    if (sonsCount < 0) {
      sonsCount = 0;
    }
    if (daughtersCount < 0) {
      daughtersCount = 0;
    }
    if (brothersCount < 0) {
      brothersCount = 0;
    }
    if (sistersCount < 0) {
      sistersCount = 0;
    }
    if (nephewsCount < 0) {
      nephewsCount = 0;
    }
    if (unclesCount < 0) {
      unclesCount = 0;
    }
    if (cousinsCount < 0) {
      cousinsCount = 0;
    }

    _syncWivesLists();
    _syncChildrenLists();

    if (gender == 'female') {
      wivesCount = 0;
      _syncWivesLists();
      if (maritalStatus != 'Married') {
        husbandAlive = false;
      }
    } else {
      husbandAlive = false;
    }

    if (!showGrandparentsSection) {
      grandfatherAlive = false;
      grandmotherAlive = false;
    }

    if (!showSiblingsSection) {
      brothersCount = 0;
      sistersCount = 0;
    }

    if (!showExtendedRelativesSection) {
      nephewsCount = 0;
      unclesCount = 0;
      cousinsCount = 0;
    }
  }

  void _syncChildrenLists() {
    while (sonNameControllers.length < sonsCount) {
      sonNameControllers.add(TextEditingController());
    }

    while (sonNameControllers.length > sonsCount) {
      sonNameControllers.removeLast().dispose();
    }

    while (daughterNameControllers.length < daughtersCount) {
      daughterNameControllers.add(TextEditingController());
    }

    while (daughterNameControllers.length > daughtersCount) {
      daughterNameControllers.removeLast().dispose();
    }
  }

  void _syncWivesLists() {
    while (wifeStatuses.length < wivesCount) {
      wifeStatuses.add(true);
      wifeNameControllers.add(TextEditingController());
    }

    while (wifeStatuses.length > wivesCount) {
      wifeStatuses.removeLast();
      wifeNameControllers.removeLast().dispose();
    }
  }

  List<String> _wifeStatusesAsStrings() {
    return wifeStatuses.map((status) => status ? 'alive' : 'deceased').toList();
  }

  List<String> _controllerTexts(List<TextEditingController> controllers) {
    return controllers.map((controller) => controller.text.trim()).toList();
  }

  Step5HeirsRequest _buildHeirsRequest() {
    return Step5HeirsRequest(
      maritalStatus: maritalStatus ?? 'Single',
      wivesCount: wivesCount,
      wifeStatuses: _wifeStatusesAsStrings(),
      wifeNames: _controllerTexts(wifeNameControllers),
      fatherAlive: fatherAlive,
      motherAlive: motherAlive,
      sons: sonsCount,
      daughters: daughtersCount,
      sonNames: _controllerTexts(sonNameControllers),
      daughterNames: _controllerTexts(daughterNameControllers),
      grandfatherAlive: grandfatherAlive,
      grandmotherMaternalAlive: grandmotherAlive,
      grandmotherPaternalAlive: false,
      brothersCount: brothersCount,
      sistersCount: sistersCount,
      brothersFull: brothersCount,
      sistersFull: sistersCount,
      brothersPaternal: 0,
      sistersPaternal: 0,
      brothersMaternal: 0,
      sistersMaternal: 0,
      nephews: nephewsCount,
      uncles: unclesCount,
      cousins: cousinsCount,
    );
  }

  bool _validateAndSaveHeirs() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return false;
    }

    Get.find<DigitalWillController>().setHeirs(_buildHeirsRequest());
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final int aliveWivesCount = wifeStatuses.where((status) => status).length;

    return Scaffold(
      appBar: const PAppBar(
        title: Text(
          'Heirs Information',
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
                    _StepProgress(
                        currentStep: revealedSectionsCount, totalSteps: 6),
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
                            'Heirs Input Wizard',
                            style: GoogleFonts.roboto(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E3F35),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Provide heirs in order. The wizard will reveal only valid Hanafi heirs and explain exclusions automatically.',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF6E7874),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _RuleMessageStack(
                            fatherAlive: fatherAlive,
                            hasSons: hasSons,
                            siblingsPresent: siblingsPresent,
                          ),
                          const SizedBox(height: 20),

                          // 1) Spouse
                          _WizardSection(
                            title: '1. Spouse',
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFAFCFB),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: const Color(0xFFE0E5E2)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Deceased Gender',
                                        style: GoogleFonts.roboto(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF404040),
                                        ),
                                      ),
                                      Text(
                                        gender == 'male' ? 'Male' : 'Female',
                                        style: GoogleFonts.roboto(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1C5D4E),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _DropdownField(
                                  hint: 'Marital Status',
                                  value: maritalStatus,
                                  items: _maritalStatuses,
                                  isRequired: true,
                                  validator: (value) =>
                                      PValidator.validateRequiredSelection(
                                    'Marital Status',
                                    value,
                                  ),
                                  onChanged: (value) {
                                    _updateWizardState(() {
                                      maritalStatus = value;
                                      if (value == 'Single') {
                                        wivesCount = 0;
                                        _syncWivesLists();
                                        sonsCount = 0;
                                        daughtersCount = 0;
                                        _syncChildrenLists();
                                      } else if (value != 'Married') {
                                        wivesCount = 0;
                                        _syncWivesLists();
                                      }
                                    });
                                  },
                                ),
                                if (gender == 'male' &&
                                    maritalStatus == 'Married') ...[
                                  const SizedBox(height: 10),
                                  _DropdownField(
                                    hint: 'Number of Wives',
                                    value: wivesCount > 0
                                        ? wivesCount.toString()
                                        : null,
                                    items: _wivesOptions,
                                    isRequired: true,
                                    validator: (value) =>
                                        PValidator.validateRequiredSelection(
                                      'Number of Wives',
                                      value,
                                    ),
                                    onChanged: (value) {
                                      _updateWizardState(() {
                                        wivesCount = value != null
                                            ? int.parse(value)
                                            : 0;
                                        _syncWivesLists();
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  for (int i = 0; i < wivesCount; i++) ...[
                                    _WifeDetailsCard(
                                      index: i,
                                      controller: wifeNameControllers[i],
                                      isAlive: wifeStatuses[i],
                                      onStatusChanged: (isAlive) {
                                        _updateWizardState(() {
                                          wifeStatuses[i] = isAlive;
                                        });
                                      },
                                    ),
                                    if (i < wivesCount - 1)
                                      const SizedBox(height: 8),
                                  ],
                                  if (wivesCount > 0) ...[
                                    const SizedBox(height: 10),
                                    _InlineInfoNote(
                                      message:
                                          'Only alive wives are counted as heirs. Currently alive: $aliveWivesCount.',
                                    ),
                                  ],
                                ] else if (gender == 'female' &&
                                    maritalStatus == 'Married') ...[
                                  const SizedBox(height: 10),
                                  _FamilyMemberToggle(
                                    label: 'Husband',
                                    isAlive: husbandAlive,
                                    onChanged: (value) {
                                      _updateWizardState(() {
                                        husbandAlive = value;
                                      });
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 2) Parents
                          _WizardSection(
                            title: '2. Parents',
                            child: Column(
                              children: [
                                _FamilyMemberToggle(
                                  label: 'Father',
                                  isAlive: fatherAlive,
                                  onChanged: (value) {
                                    _updateWizardState(() {
                                      fatherAlive = value;
                                    });
                                  },
                                ),
                                const SizedBox(height: 10),
                                _FamilyMemberToggle(
                                  label: 'Mother',
                                  isAlive: motherAlive,
                                  onChanged: (value) {
                                    _updateWizardState(() {
                                      motherAlive = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          if (showChildrenSection) ...[
                            // 3) Children
                            _WizardSection(
                              title: '3. Children',
                              child: Column(
                                children: [
                                  _FamilyMemberCounter(
                                    label: 'Son(s)',
                                    value: sonsCount,
                                    onChanged: (value) {
                                      _updateWizardState(() {
                                        sonsCount = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  _FamilyMemberCounter(
                                    label: 'Daughter(s)',
                                    value: daughtersCount,
                                    onChanged: (value) {
                                      _updateWizardState(() {
                                        daughtersCount = value;
                                      });
                                    },
                                  ),
                                  if (sonsCount > 0) ...[
                                    const SizedBox(height: 10),
                                    for (int i = 0; i < sonsCount; i++) ...[
                                      _FamilyNameField(
                                        label: 'Son ${i + 1} Name',
                                        controller: sonNameControllers[i],
                                        isRequired: true,
                                        validator: (value) =>
                                            PValidator.validateEmptyText(
                                          'Son ${i + 1} Name',
                                          value,
                                        ),
                                      ),
                                      if (i < sonsCount - 1)
                                        const SizedBox(height: 8),
                                    ],
                                  ],
                                  if (daughtersCount > 0) ...[
                                    const SizedBox(height: 10),
                                    for (int i = 0;
                                        i < daughtersCount;
                                        i++) ...[
                                      _FamilyNameField(
                                        label: 'Daughter ${i + 1} Name',
                                        controller: daughterNameControllers[i],
                                        isRequired: true,
                                        validator: (value) =>
                                            PValidator.validateEmptyText(
                                          'Daughter ${i + 1} Name',
                                          value,
                                        ),
                                      ),
                                      if (i < daughtersCount - 1)
                                        const SizedBox(height: 8),
                                    ],
                                  ],
                                  if (hasOnlyDaughters) ...[
                                    const SizedBox(height: 10),
                                    const _InlineInfoNote(
                                      message:
                                          'Only daughters are present, so grandfather (if father is deceased) and siblings may still be considered.',
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // 4) Grandparents
                          _AnimatedSectionSwitcher(
                            showSection: showGrandparentsSection,
                            shownChild: _WizardSection(
                              title: '4. Grandparents',
                              child: Column(
                                children: [
                                  _FamilyMemberToggle(
                                    label: 'Grandfather',
                                    isAlive: grandfatherAlive,
                                    onChanged: (value) {
                                      _updateWizardState(() {
                                        grandfatherAlive = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  _FamilyMemberToggle(
                                    label: 'Grandmother',
                                    isAlive: grandmotherAlive,
                                    onChanged: (value) {
                                      _updateWizardState(() {
                                        grandmotherAlive = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 5) Siblings
                          _AnimatedSectionSwitcher(
                            showSection: showSiblingsSection,
                            shownChild: _WizardSection(
                              title: '5. Siblings',
                              child: Column(
                                children: [
                                  _FamilyMemberCounter(
                                    label: 'Brother(s)',
                                    value: brothersCount,
                                    onChanged: (value) {
                                      _updateWizardState(() {
                                        brothersCount = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  _FamilyMemberCounter(
                                    label: 'Sister(s)',
                                    value: sistersCount,
                                    onChanged: (value) {
                                      _updateWizardState(() {
                                        sistersCount = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 6) Extended Relatives
                          _AnimatedSectionSwitcher(
                            showSection: showExtendedRelativesSection,
                            shownChild: _WizardSection(
                              title: '6. Extended Relatives',
                              child: Column(
                                children: [
                                  _FamilyMemberCounter(
                                    label: 'Nephew(s)',
                                    value: nephewsCount,
                                    onChanged: (value) {
                                      _updateWizardState(() {
                                        nephewsCount = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  _FamilyMemberCounter(
                                    label: 'Uncle(s)',
                                    value: unclesCount,
                                    onChanged: (value) {
                                      _updateWizardState(() {
                                        unclesCount = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  _FamilyMemberCounter(
                                    label: 'Cousin(s)',
                                    value: cousinsCount,
                                    onChanged: (value) {
                                      _updateWizardState(() {
                                        cousinsCount = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),
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
                                    if (!_validateAndSaveHeirs()) {
                                      return;
                                    }
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) =>
                                            const FinalDistributionScreen(),
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

class _RuleMessageStack extends StatelessWidget {
  const _RuleMessageStack({
    required this.fatherAlive,
    required this.hasSons,
    required this.siblingsPresent,
  });

  final bool fatherAlive;
  final bool hasSons;
  final bool siblingsPresent;

  @override
  Widget build(BuildContext context) {
    final List<String> messages = [];

    if (hasSons) {
      messages.add(
        'Sons exist -> siblings and extended relatives are automatically excluded.',
      );
    }

    if (fatherAlive) {
      messages.add(
        'Father is alive -> grandfather, siblings, and extended relatives are excluded.',
      );
    }

    if (siblingsPresent) {
      messages.add(
          'Multiple siblings present -> mother\'s share will be reduced to 1/6.');
    }

    if (messages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        for (int i = 0; i < messages.length; i++) ...[
          _InlineInfoNote(message: messages[i]),
          if (i != messages.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.hint,
    required this.items,
    required this.value,
    required this.onChanged,
    this.validator,
    this.isRequired = false,
  });

  final String hint;
  final List<String> items;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final String? safeValue =
        value != null && items.contains(value) ? value : null;

    return DropdownButtonFormField<String>(
      value: safeValue,
      validator: validator,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      style: GoogleFonts.roboto(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
      decoration: _heirsFieldDecoration(
        hint,
        isRequired: isRequired,
      ),
      dropdownColor: Colors.white,
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _AnimatedSectionSwitcher extends StatelessWidget {
  const _AnimatedSectionSwitcher({
    required this.showSection,
    required this.shownChild,
  });

  final bool showSection;
  final Widget shownChild;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            axisAlignment: -1,
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey<bool>(showSection),
        child: showSection ? shownChild : const SizedBox.shrink(),
      ),
    );
  }
}

class _InlineInfoNote extends StatelessWidget {
  const _InlineInfoNote({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7F4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD8EAE2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.info_outline_rounded,
              size: 14,
              color: Color(0xFF5D7B73),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.roboto(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF49665E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WizardSection extends StatelessWidget {
  const _WizardSection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFCFDFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5ECE9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: GoogleFonts.roboto(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E3F35),
              ),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _FamilyNameField extends StatelessWidget {
  const _FamilyNameField({
    required this.label,
    required this.controller,
    this.validator,
    this.isRequired = false,
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      cursorColor: const Color(0xFF1C5D4E),
      style: GoogleFonts.roboto(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
      decoration: _heirsFieldDecoration(
        label,
        isRequired: isRequired,
      ),
    );
  }
}

InputDecoration _heirsFieldDecoration(
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

class _SegmentedChoice extends StatelessWidget {
  const _SegmentedChoice({
    required this.label,
    required this.leftLabel,
    required this.rightLabel,
    required this.isLeftSelected,
    required this.onLeftTap,
    required this.onRightTap,
    this.isDisabled = false,
  });

  final String label;
  final String leftLabel;
  final String rightLabel;
  final bool isLeftSelected;
  final VoidCallback onLeftTap;
  final VoidCallback onRightTap;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFCFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E5E2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF404040),
            ),
          ),
          Row(
            children: [
              _ToggleOption(
                label: leftLabel,
                isSelected: isLeftSelected,
                onTap: onLeftTap,
                isDisabled: isDisabled,
              ),
              const SizedBox(width: 6),
              _ToggleOption(
                label: rightLabel,
                isSelected: !isLeftSelected,
                onTap: onRightTap,
                isDisabled: isDisabled,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WifeDetailsCard extends StatelessWidget {
  const _WifeDetailsCard({
    required this.index,
    required this.controller,
    required this.isAlive,
    required this.onStatusChanged,
  });

  final int index;
  final TextEditingController controller;
  final bool isAlive;
  final ValueChanged<bool> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFCFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E5E2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Wife ${index + 1}',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF404040),
                  ),
                ),
              ),
              _ToggleOption(
                label: 'Alive',
                isSelected: isAlive,
                onTap: () => onStatusChanged(true),
              ),
              const SizedBox(width: 6),
              _ToggleOption(
                label: 'Dead',
                isSelected: !isAlive,
                onTap: () => onStatusChanged(false),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Name (optional)',
              hintStyle: GoogleFonts.roboto(
                fontSize: 13,
                color: const Color(0xFF8B9491),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD8E1DE)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD8E1DE)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Color(0xFF2F8C6E), width: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FamilyMemberToggle extends StatelessWidget {
  const _FamilyMemberToggle({
    required this.label,
    required this.isAlive,
    required this.onChanged,
  });

  final String label;
  final bool isAlive;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFCFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E5E2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF404040),
            ),
          ),
          Row(
            children: [
              _ToggleOption(
                label: 'Alive',
                isSelected: isAlive,
                onTap: () => onChanged(true),
              ),
              const SizedBox(width: 6),
              _ToggleOption(
                label: 'Dead',
                isSelected: !isAlive,
                onTap: () => onChanged(false),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FamilyMemberYesNo extends StatelessWidget {
  const _FamilyMemberYesNo({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFCFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E5E2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF404040),
            ),
          ),
          Row(
            children: [
              _ToggleOption(
                label: 'Yes',
                isSelected: value,
                onTap: () => onChanged(true),
              ),
              const SizedBox(width: 6),
              _ToggleOption(
                label: 'No',
                isSelected: !value,
                onTap: () => onChanged(false),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FamilyMemberCounter extends StatelessWidget {
  const _FamilyMemberCounter({
    required this.label,
    required this.value,
    required this.onChanged,
    this.maxValue,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final int? maxValue;

  @override
  Widget build(BuildContext context) {
    final bool isAtMax = maxValue != null && value >= maxValue!;
    final bool isAtMin = value <= 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFCFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E5E2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF404040),
            ),
          ),
          Row(
            children: [
              _CounterButton(
                icon: Icons.remove_rounded,
                isDisabled: isAtMin,
                onTap: isAtMin ? () {} : () => onChanged(value - 1),
              ),
              SizedBox(
                width: 50,
                child: Text(
                  value.toString(),
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1C5D4E),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              _CounterButton(
                icon: Icons.add_rounded,
                isDisabled: isAtMax,
                onTap: isAtMax ? () {} : () => onChanged(value + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  const _ToggleOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isDisabled = false,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: isDisabled ? () {} : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE7F5EF) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF2F8C6E)
                  : isDisabled
                      ? const Color(0xFFE8E8E8)
                      : const Color(0xFFD4DDDA),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? const Color(0xFF1C5D4E)
                  : isDisabled
                      ? const Color(0xFFA0A0A0)
                      : const Color(0xFF556560),
            ),
          ),
        ),
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  const _CounterButton({
    required this.icon,
    required this.isDisabled,
    required this.onTap,
  });

  final IconData icon;
  final bool isDisabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: isDisabled ? () {} : onTap,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFCFB),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isDisabled
                  ? const Color(0xFFE8E8E8)
                  : const Color(0xFFD4DDDA),
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color:
                isDisabled ? const Color(0xFFA0A0A0) : const Color(0xFF2F8C6E),
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
          'Sections Active: $currentStep of $totalSteps',
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
