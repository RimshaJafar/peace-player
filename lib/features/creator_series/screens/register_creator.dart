import 'dart:ui';

import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/loaders/loaders.dart';
import 'package:ecommerce_app/features/creator_series/screens/creator_profile.dart';
import 'package:ecommerce_app/features/creator_series/screens/apply_to_be_featured.dart';
import 'package:ecommerce_app/features/creator_series/controllers/creator_series_controller.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/validators/validation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/common/controllers/external_service_controller.dart';

class RegisterCreatorScreen extends StatefulWidget {
  const RegisterCreatorScreen({Key? key}) : super(key: key);

  @override
  State<RegisterCreatorScreen> createState() => _RegisterCreatorScreenState();
}

class _RegisterCreatorScreenState extends State<RegisterCreatorScreen> {
  late CreatorSeriesController _creatorController;
  bool _isEditMode = false;
  bool _alreadyRegisteredDialogShown = false;

  @override
  void initState() {
    super.initState();
    _creatorController = Get.put(CreatorSeriesController());
    // External service controller provides countries & languages
    if (Get.isRegistered<ExternalServiceController>()) {
      _externalController = Get.find<ExternalServiceController>();
    } else {
      _externalController = Get.put(ExternalServiceController());
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingCreatorData();
      _externalController.fetchCountries();
      _externalController.fetchLanguages();
    });
  }

  Future<void> _loadExistingCreatorData() async {
    await _creatorController.fetchCreatorProfile();
    final profile = _creatorController.creatorProfile.value;
    if (!mounted || profile == null) {
      return;
    }

    _fillFormFromProfile(profile);
    if (_creatorController.isCreatorRegistered.value &&
        !_alreadyRegisteredDialogShown) {
      _alreadyRegisteredDialogShown = true;
      _isEditMode = true;
      _showAlreadyRegisteredDialog();
    }
  }

  void _fillFormFromProfile(dynamic profile) {
    _fullNameController.text = profile.fullName ?? '';
    _countryController.text = profile.country ?? '';
    _categoryController.text = profile.contentCategory ?? '';
    _bioController.text = profile.bio ?? '';
    _instagramController.text = profile.socialLinks?.instagramUrl ?? '';
    _youtubeController.text = profile.socialLinks?.youtubeUrl ?? '';
    _tiktokController.text = profile.socialLinks?.tiktokUrl ?? '';
    _facebookController.text = profile.socialLinks?.facebookUrl ?? '';
    _selectedCountry = profile.country;
    _selectedCategory = profile.contentCategory;
    _selectedVideo = null;
  }

  void _showAlreadyRegisteredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Icon
                Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                    gradient: PColors.linearGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: PColors.primary.withOpacity(0.25),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.verified_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),

                const SizedBox(height: 20),

                // Title
                const Text(
                  'Already Registered',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: PColors.primary,
                    fontFamily: 'Roboto',
                  ),
                ),

                const SizedBox(height: 12),

                // Description
                const Text(
                  'You already have a creator registration.\nYou can view your profile or edit your existing registration.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Color(0xFF777777),
                    fontFamily: 'Roboto',
                  ),
                ),

                const SizedBox(height: 26),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: PColors.primary.withOpacity(0.4),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          setState(() {
                            _isEditMode = true;
                          });
                        },
                        child: const Text(
                          'Edit',
                          style: TextStyle(
                            color: PColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: PColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CreatorProfileScreen(
                                firebaseUserId:
                                    _creatorController.firebaseUserId,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'View Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _showAgreementError = false;
  bool _showVideoError = false;
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedVideo;
  Future<void> _pickVideo() async {
    final XFile? picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (picked != null) {
      // Validate file extension
      if (!picked.name.toLowerCase().endsWith('.mp4')) {
        if (mounted) {
          PLoaders.warningSnackBar(
            title: 'Invalid Video',
            message: 'Only MP4 videos are allowed',
            context: context,
          );
        }
        return;
      }

      // Validate file size (e.g., max 100MB)
      final bytes = await picked.readAsBytes();
      final fileSizeMB = bytes.length / (1024 * 1024);
      if (fileSizeMB > 100) {
        if (mounted) {
          PLoaders.warningSnackBar(
            title: 'Video Too Large',
            message:
                'Video size must be less than 100MB (Current: ${fileSizeMB.toStringAsFixed(2)}MB)',
            context: context,
          );
        }
        return;
      }

      setState(() {
        _selectedVideo = picked;
        _showVideoError = false;
      });
    }
  }

  Widget _buildSampleVideoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDCE9E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionTitle(
            title: 'Sample Video File',
            isRequired: true,
          ),
          const SizedBox(height: 6),
          const Text(
            'Upload one MP4 sample video (maximum 100 MB).',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
              color: Color(0xFF777777),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _pickVideo,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: AspectRatio(
                      aspectRatio: 14 / 9,
                      child: CustomPaint(
                        painter: DottedBorderPainter(
                          color: _showVideoError
                              ? const Color(0xFFD32F2F)
                              : _selectedVideo != null
                                  ? PColors.primary
                                  : Colors.grey.shade400,
                          borderRadius: 16,
                          strokeWidth: 2,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: _selectedVideo != null
                                ? const Icon(
                                    Icons.check_circle,
                                    color: PColors.primary,
                                    size: 52,
                                  )
                                : Image.asset(
                                    'assets/icons/video-posting.png',
                                    width: 52,
                                    height: 52,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (_selectedVideo != null) ...[
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: Text(
                      _selectedVideo!.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 13,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  FutureBuilder<int>(
                    future: _selectedVideo!
                        .readAsBytes()
                        .then((bytes) => bytes.length),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox.shrink();

                      final sizeMB = snapshot.data! / (1024 * 1024);
                      return Text(
                        '${sizeMB.toStringAsFixed(2)} MB',
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12,
                          color: Color(0xFF888888),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
          if (_showVideoError)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                'Please select a video.',
                style: TextStyle(color: Colors.red[700], fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _countryController = TextEditingController();
  final _categoryController = TextEditingController();
  final _bioController = TextEditingController();
  final _instagramController = TextEditingController();
  final _youtubeController = TextEditingController();
  final _tiktokController = TextEditingController();
  final _facebookController = TextEditingController();
  bool _agreed = false;
  String? _selectedCountry;
  String? _selectedCategory;
  late ExternalServiceController _externalController;
  String? _selectedVideoLanguageName;
  String? _selectedVideoLanguageCode;

  final List<String> _countries = [
    'United States',
    'United Kingdom',
    'Canada',
    'Australia',
    'India',
    'Pakistan',
    'Bangladesh',
    'Malaysia',
    'Indonesia',
    'Saudi Arabia',
    'UAE',
    'Turkey',
    'Egypt',
    'Nigeria',
    'Other',
  ];

  final List<String> _categories = [
    'Islamic Talks',
    'Quran Recitation',
    'Nasheed',
    'Kids Content',
    'Education',
    'Motivation',
    'Other',
  ];

  String? _validateRequiredSocialProfile(String fieldName, String? value) {
    final profileValue = value?.trim() ?? '';
    if (profileValue.isEmpty) {
      return '$fieldName is required.';
    }

    return _validateSocialProfileFormat(fieldName, profileValue);
  }

  String? _validateOptionalSocialProfile(String fieldName, String? value) {
    final profileValue = value?.trim() ?? '';
    if (profileValue.isEmpty) return null;

    return _validateSocialProfileFormat(fieldName, profileValue);
  }

  String? _validateSocialProfileFormat(String fieldName, String value) {
    final looksLikeUrl = value.startsWith('http://') ||
        value.startsWith('https://') ||
        value.startsWith('www.') ||
        (value.contains('.') && !value.contains(' '));

    if (looksLikeUrl) {
      return PValidator.validateOptionalUrl(fieldName, value);
    }

    if (value.length < 2) {
      return 'Enter a valid $fieldName.';
    }

    if (value.contains(RegExp(r'[<>]'))) {
      return 'Enter a valid $fieldName.';
    }

    return null;
  }

  bool _hasSampleVideoForSubmit() {
    final existingVideoUrl =
        _creatorController.creatorProfile.value?.sampleVideoUrl.trim();
    return _selectedVideo != null ||
        (_isEditMode &&
            existingVideoUrl != null &&
            existingVideoUrl.isNotEmpty);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _countryController.dispose();
    _categoryController.dispose();
    _bioController.dispose();
    _instagramController.dispose();
    _youtubeController.dispose();
    _tiktokController.dispose();
    _facebookController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PAppBar(
        title: Text(
          'Register as Creator',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        showBackArrow: true,
        backgroundColor: Colors.white,
        gradient: PColors.linearGradient,
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF4F3EE),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Container(
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
                    margin: const EdgeInsets.only(bottom: 15),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SectionTitle(title: 'Personal Information'),
                          const SizedBox(height: 12),
                          CustomTextField(
                            hintText: 'Full Name',
                            controller: _fullNameController,
                            isRequired: true,
                            validator: (value) => PValidator.validateEmptyText(
                              'Full name',
                              value,
                            ),
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            hintText: 'Country',
                            controller: _countryController,
                            isDropdown: true,
                            isRequired: true,
                            validator: (value) =>
                                PValidator.validateRequiredSelection(
                              'Country',
                              value,
                            ),
                            dropdownItems:
                                _externalController.countries.isNotEmpty
                                    ? _externalController.countries
                                        .map((c) => c.name)
                                        .toList()
                                    : _countries,
                            value: _selectedCountry,
                            onChanged: (val) {
                              setState(() {
                                _selectedCountry = val;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          const SectionTitle(title: 'Social Media Links'),
                          const SizedBox(height: 12),
                          CustomTextField(
                            hintText: 'Instagram Username',
                            controller: _instagramController,
                            isRequired: true,
                            validator: (value) =>
                                _validateRequiredSocialProfile(
                              'Instagram username',
                              value,
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Image.asset('assets/logos/instagram.png',
                                  width: 22, height: 22),
                            ),
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            hintText: 'YouTube Channel',
                            controller: _youtubeController,
                            isRequired: true,
                            validator: (value) =>
                                _validateRequiredSocialProfile(
                              'YouTube channel',
                              value,
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Image.asset('assets/logos/youtube.png',
                                  width: 22, height: 22),
                            ),
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            hintText: 'TikTok Username',
                            controller: _tiktokController,
                            isRequired: true,
                            validator: (value) =>
                                _validateRequiredSocialProfile(
                              'TikTok username',
                              value,
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Image.asset('assets/logos/tiktok.png',
                                  width: 22, height: 22),
                            ),
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            hintText: 'Facebook Page (Optional)',
                            controller: _facebookController,
                            validator: (value) =>
                                _validateOptionalSocialProfile(
                              'Facebook page',
                              value,
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Image.asset('assets/logos/facebook.png',
                                  width: 22, height: 22),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const SectionTitle(title: 'Short Bio'),
                          const SizedBox(height: 12),
                          CustomTextField(
                            hintText: 'Tell us about yourself',
                            controller: _bioController,
                            isRequired: true,
                            validator: (value) =>
                                PValidator.validateEmptyText('Bio', value),
                            maxLines: 4,
                            maxLength: 300,
                            showCounter: true,
                          ),
                          const SizedBox(height: 16),
                          const SectionTitle(title: 'Content Category'),
                          const SizedBox(height: 12),
                          CustomTextField(
                            hintText: 'Select Category',
                            controller: _categoryController,
                            isDropdown: true,
                            isRequired: true,
                            validator: (value) =>
                                PValidator.validateRequiredSelection(
                              'Content category',
                              value,
                            ),
                            dropdownItems: _categories,
                            value: _selectedCategory,
                            onChanged: (val) {
                              setState(() {
                                _selectedCategory = val;
                              });
                            },
                          ),
                          const SizedBox(height: 24),
                          _buildSampleVideoSection(),
                          const SizedBox(height: 22),
                          // Video language selector
                          Obx(() {
                            final langItems = _externalController
                                    .languages.isNotEmpty
                                ? _externalController.languages
                                    .map((l) => l.name)
                                    .toList()
                                : const <String>['English', 'Urdu', 'Arabic'];
                            return CustomTextField(
                              hintText: 'Video Language',
                              controller: null,
                              isDropdown: true,
                              isRequired: true,
                              validator: (value) =>
                                  PValidator.validateRequiredSelection(
                                'Video language',
                                value,
                              ),
                              dropdownItems: langItems,
                              value: _selectedVideoLanguageName,
                              onChanged: (val) {
                                setState(() {
                                  _selectedVideoLanguageName = val;
                                  _selectedVideoLanguageCode =
                                      _externalController
                                          .getLanguageCodeByName(val);
                                });
                              },
                            );
                          }),
                          const SizedBox(height: 18),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Checkbox(
                                value: _agreed,
                                onChanged: (val) {
                                  setState(() {
                                    _agreed = val ?? false;
                                    if (_agreed) {
                                      _showAgreementError = false;
                                    }
                                  });
                                },
                              ),
                              Expanded(
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    const Text('I agree to the '),
                                    GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text(
                                              'agreement',
                                              style: TextStyle(
                                                color: PColors.primary,
                                              ),
                                            ),
                                            content:
                                                const SingleChildScrollView(
                                              child: Text(
                                                'Your full terms and conditions go here.\n\n1. You agree to ...\n2. You will not ...\n3. ...',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                child: const Text('Close',
                                                    style: TextStyle(
                                                        color:
                                                            PColors.primary)),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'terms and conditions',
                                        style: TextStyle(
                                          color: PColors.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const Text(
                                      ' *',
                                      style: TextStyle(
                                        color: Color(0xFFD32F2F),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (_showAgreementError)
                            Padding(
                              padding: const EdgeInsets.only(left: 12, top: 4),
                              child: Text(
                                'You must accept the terms and conditions.',
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          const SizedBox(height: 10),
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
                                child: Obx(
                                  () => InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: _creatorController
                                            .isRegisterLoading.value
                                        ? null
                                        : () {
                                            final isFormValid = _formKey
                                                    .currentState
                                                    ?.validate() ??
                                                false;

                                            setState(() {
                                              _showVideoError =
                                                  !_hasSampleVideoForSubmit();
                                              _showAgreementError = !_agreed;
                                            });

                                            if (!isFormValid ||
                                                _showVideoError ||
                                                _showAgreementError) {
                                              return;
                                            }

                                            if (_isEditMode) {
                                              // Update existing profile
                                              final existingProfile =
                                                  _creatorController
                                                      .creatorProfile.value;
                                              _creatorController
                                                  .updateCreatorProfile(
                                                fullName: _fullNameController
                                                    .text
                                                    .trim(),
                                                email: existingProfile?.email ??
                                                    _creatorController
                                                        .userController
                                                        .user
                                                        .value
                                                        .email,
                                                firebaseUserId:
                                                    _creatorController
                                                        .firebaseUserId!,
                                                country: _selectedCountry ?? '',
                                                bio: _bioController.text.trim(),
                                                contentCategory:
                                                    _selectedCategory ?? '',
                                                instagramUrl:
                                                    _instagramController.text
                                                        .trim(),
                                                youtubeUrl: _youtubeController
                                                    .text
                                                    .trim(),
                                                tiktokUrl: _tiktokController
                                                    .text
                                                    .trim(),
                                                facebookUrl: _facebookController
                                                    .text
                                                    .trim(),
                                                videoFiles:
                                                    _selectedVideo != null
                                                        ? [_selectedVideo!]
                                                        : [],
                                                videoLanguage:
                                                    _selectedVideoLanguageCode,
                                                existingSampleVideoUrl:
                                                    existingProfile
                                                        ?.sampleVideoUrl,
                                                agreementAccepted: _agreed,
                                              )
                                                  .then((_) {
                                                if (_creatorController
                                                        .registerError.value ==
                                                    null) {
                                                  PLoaders.successSnackBar(
                                                    title: 'Success',
                                                    message:
                                                        'Profile updated successfully!',
                                                    context: context,
                                                  );
                                                  // Navigate back
                                                  Future.delayed(
                                                    const Duration(seconds: 1),
                                                    () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  );
                                                } else {
                                                  PLoaders.errorSnackBar(
                                                    title: 'Update Failed',
                                                    message: _creatorController
                                                            .registerError
                                                            .value ??
                                                        'Profile update failed',
                                                    duration: 5,
                                                    context: context,
                                                  );
                                                  if (kDebugMode) {
                                                    debugPrint(
                                                      'Creator update error: ${_creatorController.registerError.value}',
                                                    );
                                                  }
                                                }
                                              });
                                            } else {
                                              // Register new profile
                                              _creatorController
                                                  .registerCreator(
                                                fullName: _fullNameController
                                                    .text
                                                    .trim(),
                                                country: _selectedCountry ?? '',
                                                bio: _bioController.text.trim(),
                                                contentCategory:
                                                    _selectedCategory ?? '',
                                                instagramUrl:
                                                    _instagramController.text
                                                        .trim(),
                                                youtubeUrl: _youtubeController
                                                    .text
                                                    .trim(),
                                                tiktokUrl: _tiktokController
                                                    .text
                                                    .trim(),
                                                facebookUrl: _facebookController
                                                    .text
                                                    .trim(),
                                                videoFiles:
                                                    _selectedVideo != null
                                                        ? [_selectedVideo!]
                                                        : [],
                                                videoLanguage:
                                                    _selectedVideoLanguageCode,
                                                existingSampleVideoUrl:
                                                    _creatorController
                                                        .creatorProfile
                                                        .value
                                                        ?.sampleVideoUrl,
                                                agreementAccepted: _agreed,
                                              )
                                                  .then((_) {
                                                if (_creatorController
                                                        .registerError.value ==
                                                    null) {
                                                  PLoaders.successSnackBar(
                                                    title: 'Success',
                                                    message:
                                                        'Registration submitted successfully!',
                                                    context: context,
                                                  );
                                                  // Navigate back
                                                  Future.delayed(
                                                    const Duration(seconds: 1),
                                                    () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  );
                                                } else {
                                                  PLoaders.errorSnackBar(
                                                    title:
                                                        'Registration Failed',
                                                    message: _creatorController
                                                            .registerError
                                                            .value ??
                                                        'Registration failed',
                                                    duration: 5,
                                                    context: context,
                                                  );
                                                  if (kDebugMode) {
                                                    debugPrint(
                                                      'Creator registration error: ${_creatorController.registerError.value}',
                                                    );
                                                  }
                                                }
                                              });
                                            }
                                          },
                                    child: Center(
                                      child: _creatorController
                                              .isRegisterLoading.value
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  Colors.white,
                                                ),
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Text(
                                              _isEditMode
                                                  ? 'Update'
                                                  : 'Register',
                                              style: const TextStyle(
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
                          ),

                          // Dotted border painter for video boxes
                        ],
                      ),
                    ),
                  ),
                  const Center(
                    child: Text(
                      'We will review your registration and contact you soon',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12,
                        color: Color(0xFF888888),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Reuse SectionTitle and CustomTextField from apply_to_be_featured.dart
class DottedBorderPainter extends CustomPainter {
  final Color color;
  final double borderRadius;
  final double strokeWidth;
  final double gap;
  DottedBorderPainter({
    required this.color,
    this.borderRadius = 16,
    this.strokeWidth = 2,
    this.gap = 5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    final RRect rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(borderRadius),
    );
    _drawDashedRRect(canvas, rrect, paint, gap);
  }

  void _drawDashedRRect(Canvas canvas, RRect rrect, Paint paint, double gap) {
    final Path path = Path()..addRRect(rrect);
    final PathMetrics metrics = path.computeMetrics();
    for (final PathMetric metric in metrics) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final double len = gap;
        if (draw) {
          canvas.drawPath(
            metric.extractPath(distance, distance + len),
            paint,
          );
        }
        distance += len;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
