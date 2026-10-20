import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/features/authentication/controllers/user_controller.dart';
import 'package:ecommerce_app/features/digital_will/controllers/digital_will_controller.dart';
import 'package:ecommerce_app/common/controllers/external_service_controller.dart';
import 'package:ecommerce_app/features/digital_will/screens/assets.dart';
import 'package:ecommerce_app/features/digital_will/models/digital_will_request_model.dart';
import 'package:ecommerce_app/features/digital_will/models/spouse_model.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class BasicInformationScreen extends StatefulWidget {
  const BasicInformationScreen({super.key});

  @override
  State<BasicInformationScreen> createState() => _BasicInformationScreenState();
}

class _BasicInformationScreenState extends State<BasicInformationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _dodController = TextEditingController();
  final TextEditingController _executorNameController = TextEditingController();
  final TextEditingController _executorContactController =
      TextEditingController();
  final TextEditingController _executorInstructionsController =
      TextEditingController();

  String? _selectedGender;
  String? _selectedMaritalStatus;
  String? _selectedCountry;

  final List<String> _maritalStatuses = const [
    'Single',
    'Married',
    'Widowed',
    'Divorced',
  ];

  late final ExternalServiceController _externalController;

  @override
  void dispose() {
    _fullNameController.dispose();
    _dobController.dispose();
    _dodController.dispose();
    _executorNameController.dispose();
    _executorContactController.dispose();
    _executorInstructionsController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _externalController = Get.isRegistered<ExternalServiceController>()
        ? Get.find<ExternalServiceController>()
        : Get.put(ExternalServiceController());
    if (_externalController.countries.isEmpty &&
        !_externalController.isLoadingCountries.value) {
      _externalController.fetchCountries();
    }
    if (_externalController.languages.isEmpty &&
        !_externalController.isLoadingLanguages.value) {
      _externalController.fetchLanguages();
    }
  }

  Future<void> _pickDateOfBirth() async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = DateTime(now.year - 30, now.month, now.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1C5D4E),
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final String formatted =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      setState(() {
        _dobController.text = formatted;
      });
    }
  }

  Future<void> _pickDateOfDeath() async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = now;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1C5D4E),
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final String formatted =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      setState(() {
        _dodController.text = formatted;
      });
    }
  }

  String _toIsoDate(String input) {
    final List<String> parts = input.split('/');
    if (parts.length != 3) {
      return input;
    }

    final String day = parts[0].padLeft(2, '0');
    final String month = parts[1].padLeft(2, '0');
    final String year = parts[2];
    return '$year-$month-$day';
  }

  String? _validateDateOfDeath(String? value) {
    final String? requiredError =
        PValidator.validateRequiredPastOrPresentDate('Date of Death', value);
    if (requiredError != null) {
      return requiredError;
    }

    final DateTime? dob = PValidator.parseSlashDate(_dobController.text);
    final DateTime? dod = PValidator.parseSlashDate(value);
    if (dob != null && dod != null && dod.isBefore(dob)) {
      return 'Date of Death cannot be before Date of Birth.';
    }

    return null;
  }

  bool _saveBasicInformation() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return false;
    }

    final DigitalWillController controller = Get.find<DigitalWillController>();
    final UserController userController = Get.find<UserController>();
    final user = userController.user.value;

    // Normalize/validate executor contact with country phone code when possible
    String executorContact = _executorContactController.text.trim();
    final country = _externalController.getCountryByName(_selectedCountry);
    if (country != null && country.phoneCode.isNotEmpty) {
      final String normalized =
          executorContact.replaceAll(RegExp(r'[^0-9+]'), '');
      if (!normalized.startsWith(country.phoneCode)) {
        // If user omitted international prefix, prefix it
        String cleaned = normalized;
        // remove leading zeros
        cleaned = cleaned.replaceFirst(RegExp(r'^0+'), '');
        executorContact = '${country.phoneCode}$cleaned';
      } else {
        executorContact = normalized;
      }
    }

    controller.setBasicInfo(
      Step1BasicInfoRequest(
        firebaseUserId: user.id,
        userName: user.username,
        userEmail: user.email,
        fullName: _fullNameController.text.trim(),
        gender: _selectedGender ?? '',
        dateOfBirth: _toIsoDate(_dobController.text.trim()),
        dateOfDeath: _toIsoDate(_dodController.text.trim()),
        countryJurisdiction: _selectedCountry ?? '',
        executorName: _executorNameController.text.trim(),
        executorContact: executorContact,
      ),
    );

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PAppBar(
        title: Text(
          'Basic Information',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        centerTitle: true,
        gradient: PColors.linearGradient,
        showBackArrow: true,
      ),
      backgroundColor: const Color(0xFFF4F3EE),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
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
                          currentStep: 1,
                          totalSteps: 6,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F3C2F)
                                    .withValues(alpha: 0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          margin: const EdgeInsets.only(bottom: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _BasicInfoTextField(
                                controller: _fullNameController,
                                hint: 'Full Name',
                                isRequired: true,
                                validator: (value) =>
                                    PValidator.validateEmptyText(
                                  'Full Name',
                                  value,
                                ),
                              ),
                              const SizedBox(height: 14),
                              _DropdownField(
                                hint: 'Marital Status',
                                value: _selectedMaritalStatus,
                                items: _maritalStatuses,
                                isRequired: true,
                                validator: (value) =>
                                    PValidator.validateRequiredSelection(
                                  'Marital Status',
                                  value,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedMaritalStatus = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 14),
                              _GenderSelector(
                                selectedGender: _selectedGender,
                                validator: (value) =>
                                    PValidator.validateRequiredSelection(
                                  'Gender',
                                  value,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedGender = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 14),
                              _DatePickerField(
                                controller: _dobController,
                                hint: 'Date of Birth',
                                isRequired: true,
                                validator: (value) => PValidator
                                    .validateRequiredPastOrPresentDate(
                                  'Date of Birth',
                                  value,
                                ),
                                onTap: _pickDateOfBirth,
                              ),
                              const SizedBox(height: 14),
                              _DatePickerField(
                                controller: _dodController,
                                hint: 'Date of Death',
                                isRequired: true,
                                validator: _validateDateOfDeath,
                                onTap: _pickDateOfDeath,
                              ),
                              const SizedBox(height: 14),
                              _BasicInfoTextField(
                                controller: _executorNameController,
                                hint: 'Executor Name',
                                isRequired: true,
                                validator: (value) =>
                                    PValidator.validateEmptyText(
                                  'Executor Name',
                                  value,
                                ),
                              ),
                              const SizedBox(height: 14),
                              _BasicInfoTextField(
                                controller: _executorContactController,
                                hint: 'Executor Contact',
                                isRequired: true,
                                keyboardType: TextInputType.phone,
                                validator: (value) =>
                                    PValidator.validateFlexiblePhoneNumber(
                                  'Executor Contact',
                                  value,
                                ),
                              ),
                              const SizedBox(height: 14),
                              _BasicInfoTextField(
                                controller: _executorInstructionsController,
                                hint: 'Executor Instructions',
                              ),
                              const SizedBox(height: 14),
                              _CountryJurisdictionSelector(
                                externalController: _externalController,
                                value: _selectedCountry,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCountry = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 22),
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
                                            .withValues(alpha: 0.25),
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
                                        if (!_saveBasicInformation()) {
                                          return;
                                        }
                                        final SpouseData spouseData =
                                            SpouseData(
                                          gender: _selectedGender ?? '',
                                          maritalStatus: _selectedMaritalStatus,
                                          wivesCount: 0,
                                        );
                                        Navigator.of(context).push(
                                          MaterialPageRoute<void>(
                                            builder: (_) =>
                                                AssetsCollectionScreen(
                                              spouseData: spouseData,
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
            );
          },
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

class _GenderSelector extends StatelessWidget {
  const _GenderSelector({
    required this.selectedGender,
    required this.onChanged,
    this.validator,
  });

  final String? selectedGender;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: selectedGender,
      validator: validator,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FieldLabel(
              text: 'Gender',
              isRequired: true,
              fontSize: 14,
              color: const Color(0xFF404040),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _GenderOption(
                    label: 'Male',
                    hasError: state.hasError,
                    isSelected: selectedGender == 'Male',
                    onTap: () {
                      state.didChange('Male');
                      onChanged('Male');
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _GenderOption(
                    label: 'Female',
                    hasError: state.hasError,
                    isSelected: selectedGender == 'Female',
                    onTap: () {
                      state.didChange('Female');
                      onChanged('Female');
                    },
                  ),
                ),
              ],
            ),
            if (state.hasError) ...[
              const SizedBox(height: 6),
              Text(
                state.errorText!,
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFD32F2F),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _GenderOption extends StatelessWidget {
  const _GenderOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.hasError,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          height: 56,
          decoration: BoxDecoration(
            color:
                isSelected ? const Color(0xFFEAF6F1) : const Color(0xFFFAFAF8),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF2E8D6F)
                  : hasError
                      ? const Color(0xFFD32F2F)
                      : const Color(0xFFCFCFCF),
              width: hasError ? 1.5 : 1.2,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF1C5D4E)
                    : const Color(0xFF666666),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.controller,
    required this.hint,
    required this.onTap,
    this.validator,
    this.isRequired = false,
  });

  final TextEditingController controller;
  final String hint;
  final VoidCallback onTap;
  final String? Function(String?)? validator;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5),
      child: IgnorePointer(
        child: _BasicInfoTextField(
          controller: controller,
          hint: hint,
          suffixIconPath: 'assets/icons/calendar.png',
          isRequired: isRequired,
          validator: validator,
        ),
      ),
    );
  }
}

class _CountryJurisdictionSelector extends StatelessWidget {
  const _CountryJurisdictionSelector({
    required this.externalController,
    required this.value,
    required this.onChanged,
  });

  final ExternalServiceController externalController;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isLoading = externalController.isLoadingCountries.value;
      final List<String> countryNames = {
        for (final country in externalController.countries)
          if (country.name.trim().isNotEmpty) country.name.trim(),
      }.toList()
        ..sort(
          (a, b) => a.toLowerCase().compareTo(b.toLowerCase()),
        );

      final bool hasCountries = countryNames.isNotEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DropdownField(
            hint: 'Country Jurisdiction',
            value: value,
            items: countryNames,
            enabled: hasCountries,
            disabledHint: hasCountries
                ? null
                : isLoading
                    ? 'Loading countries...'
                    : 'Countries unavailable',
            icon: isLoading && !hasCountries
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF2F8C6E),
                    ),
                  )
                : null,
            isRequired: true,
            validator: (value) => PValidator.validateRequiredSelection(
              'Country Jurisdiction',
              value,
            ),
            onChanged: onChanged,
          ),
          if (!hasCountries) ...[
            const SizedBox(height: 8),
            _CountryLoadStatus(
              isLoading: isLoading,
              onRetry: () {
                externalController.fetchCountries();
              },
            ),
          ],
        ],
      );
    });
  }
}

class _CountryLoadStatus extends StatelessWidget {
  const _CountryLoadStatus({
    required this.isLoading,
    required this.onRetry,
  });

  final bool isLoading;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final TextStyle messageStyle = GoogleFonts.roboto(
      fontSize: 12.5,
      fontWeight: FontWeight.w500,
      color: const Color(0xFF50675E),
      height: 1.35,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6F1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD3E8DF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            isLoading ? Icons.cloud_sync_rounded : Icons.cloud_off_rounded,
            size: 18,
            color: const Color(0xFF2F8C6E),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isLoading
                  ? 'Fetching country list from the central service.'
                  : 'Country list could not be loaded from the central service.',
              style: messageStyle,
            ),
          ),
          if (!isLoading) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1C5D4E),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
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
    this.enabled = true,
    this.disabledHint,
    this.icon,
  });

  final String hint;
  final List<String> items;
  final String? value;
  final ValueChanged<String?>? onChanged;
  final String? Function(String?)? validator;
  final bool isRequired;
  final bool enabled;
  final String? disabledHint;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final String? safeValue =
        value != null && items.contains(value) ? value : null;
    final bool canSelect = enabled && items.isNotEmpty;
    final TextStyle fieldStyle = GoogleFonts.roboto(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      color: Colors.black,
    );
    final TextStyle hintStyle = fieldStyle.copyWith(
      color: const Color(0xFF808080).withValues(alpha: 0.72),
    );

    return DropdownButtonFormField<String>(
      initialValue: safeValue,
      validator: validator,
      isExpanded: true,
      icon: icon ?? const Icon(Icons.keyboard_arrow_down_rounded),
      hint: Text(
        hint,
        overflow: TextOverflow.ellipsis,
        style: hintStyle,
      ),
      disabledHint: Text(
        disabledHint ?? hint,
        overflow: TextOverflow.ellipsis,
        style: hintStyle,
      ),
      style: fieldStyle,
      decoration: _fieldDecoration(
        hint,
        isRequired: isRequired,
      ),
      dropdownColor: Colors.white,
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: canSelect ? onChanged : null,
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({
    required this.text,
    required this.isRequired,
    this.fontSize = 18,
    this.color = const Color(0xFF808080),
  });

  final String text;
  final bool isRequired;
  final double fontSize;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = GoogleFonts.roboto(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: color,
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

InputDecoration _fieldDecoration(
  String label, {
  bool isRequired = false,
  Widget? suffixIcon,
}) {
  final OutlineInputBorder enabledBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(5),
    borderSide: BorderSide(
      color: const Color(0xFFC3BEBE).withValues(alpha: 0.6),
    ),
  );

  return InputDecoration(
    filled: true,
    fillColor: Colors.white,
    label: _FieldLabel(
      text: label,
      isRequired: isRequired,
      color: const Color(0xFF808080).withValues(alpha: 0.6),
    ),
    floatingLabelBehavior: FloatingLabelBehavior.never,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: enabledBorder,
    enabledBorder: enabledBorder,
    focusedBorder: enabledBorder.copyWith(
      borderSide: const BorderSide(color: Color(0xFF2F8C6E), width: 1.4),
    ),
    errorBorder: enabledBorder.copyWith(
      borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.4),
    ),
    focusedErrorBorder: enabledBorder.copyWith(
      borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.6),
    ),
    errorStyle: GoogleFonts.roboto(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: const Color(0xFFD32F2F),
    ),
    suffixIcon: suffixIcon,
    suffixIconConstraints: const BoxConstraints(
      minWidth: 44,
      minHeight: 44,
    ),
  );
}

class _BasicInfoTextField extends StatelessWidget {
  const _BasicInfoTextField({
    required this.controller,
    required this.hint,
    this.suffixIconPath,
    this.keyboardType,
    this.validator,
    this.isRequired = false,
  });

  final TextEditingController controller;
  final String hint;
  final String? suffixIconPath;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      textAlignVertical: TextAlignVertical.center,
      style: GoogleFonts.roboto(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
      decoration: _fieldDecoration(
        hint,
        isRequired: isRequired,
        suffixIcon: suffixIconPath != null
            ? Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Image.asset(
                  suffixIconPath!,
                  width: 20,
                  height: 20,
                ),
              )
            : null,
      ),
    );
  }
}
