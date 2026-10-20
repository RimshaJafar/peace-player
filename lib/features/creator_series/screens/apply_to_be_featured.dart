import 'package:ecommerce_app/common/widgets/appbar/appbar.dart';
import 'package:ecommerce_app/common/widgets/loaders/loaders.dart';
import 'package:ecommerce_app/features/creator_series/screens/register_creator.dart';
import 'package:flutter/material.dart';
import '../../../utils/constants/colors.dart';

import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/features/creator_series/controllers/creator_series_controller.dart';
import 'package:ecommerce_app/features/creator_series/controllers/videos_controller.dart';
import 'package:ecommerce_app/features/creator_series/models/video_upload_model.dart';
import 'package:ecommerce_app/common/controllers/external_service_controller.dart';
import 'package:ecommerce_app/utils/validators/validation.dart';

class ApplyToBeFeaturedScreen extends StatefulWidget {
  const ApplyToBeFeaturedScreen({Key? key}) : super(key: key);

  @override
  State<ApplyToBeFeaturedScreen> createState() =>
      _ApplyToBeFeaturedScreenState();
}

class _ApplyToBeFeaturedScreenState extends State<ApplyToBeFeaturedScreen> {
  DateTime? _preferredDateValue;

  String _formatDateForDisplay(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateForApi(DateTime date) {
    return DateTime(date.year, date.month, date.day).toIso8601String();
  }

  Future<void> _pickPreferredDate() async {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime initialDate =
        _preferredDateValue != null && !_preferredDateValue!.isBefore(today)
            ? _preferredDateValue!
            : today;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today,
      lastDate: DateTime(now.year + 10),
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
      setState(() {
        _preferredDateValue = picked;
        _preferredDateController.text = _formatDateForDisplay(picked);
      });
    }
  }

  String? _preferredDateForSubmit() {
    if (_preferredDateValue != null) {
      return _formatDateForApi(_preferredDateValue!);
    }

    final rawValue = _preferredDateController.text.trim();
    if (rawValue.isEmpty) {
      return null;
    }

    final parsedFromDisplay =
        RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(rawValue);
    if (parsedFromDisplay != null) {
      final day = int.parse(parsedFromDisplay.group(1)!);
      final month = int.parse(parsedFromDisplay.group(2)!);
      final year = int.parse(parsedFromDisplay.group(3)!);
      return DateTime(year, month, day).toIso8601String();
    }

    final parsedIso = DateTime.tryParse(rawValue);
    if (parsedIso != null) {
      return _formatDateForApi(parsedIso);
    }

    return rawValue;
  }

  String? _selectedCategory;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  final _sourcePlatformController = TextEditingController();
  final _preferredDateController = TextEditingController();
  final _durationController = TextEditingController();
  final _languageController = TextEditingController();
  bool _showVideoError = false;
  bool _showThumbnailError = false;
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedVideo;
  XFile? _selectedThumbnail;
  late CreatorSeriesController _creatorController;
  late VideosController _videosController;
  late ExternalServiceController _externalController;
  bool _isEditModeForVideo = false;
  String? _existingVideoId;
  String? _selectedLanguageCode;

  final List<String> _categories = [
    'Islamic Talks',
    'Quran Recitation',
    'Nasheed',
    'Kids Content',
    'Education',
    'Motivation',
    'Other',
  ];
  final List<String> _languages = [
    'English',
    'Urdu',
    'Arabic',
    'Malay',
    'Indonesian',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _sourcePlatformController.dispose();
    _preferredDateController.dispose();
    _durationController.dispose();
    _languageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _creatorController = Get.isRegistered<CreatorSeriesController>()
        ? Get.find<CreatorSeriesController>()
        : Get.put(CreatorSeriesController());
    _videosController = Get.put(VideosController());
    _externalController = Get.isRegistered<ExternalServiceController>()
        ? Get.find<ExternalServiceController>()
        : Get.put(ExternalServiceController());
    _externalController.fetchCountries();
    _externalController.fetchLanguages().then((_) {
      if (!mounted) return;
      if (_languageController.text.trim().isNotEmpty) {
        _syncLanguageSelectionFromValue(_languageController.text.trim());
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _creatorController.fetchCreatorProfile();
      if (!_creatorController.canUploadCreatorVideos) {
        return;
      }

      await _videosController.fetchLatestUserUpload();
      if (mounted && _videosController.isVideoUploaded.value) {
        _showAlreadyUploadedPopup();
      }
    });
  }

  void _showAlreadyUploadedPopup() {
    final existing = _videosController.uploadedVideo.value;
    if (existing == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
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
                  Icons.video_collection_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),

              const SizedBox(height: 20),

              // Title
              const Text(
                'Already Uploaded',
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
              Text(
                existing.scheduledDate != null
                    ? 'You already uploaded a video which is scheduled on ${existing.scheduledDate}. Please wait until then to upload another.'
                    : 'You already uploaded a video which is pending review. You can edit that upload or cancel this action.',
                textAlign: TextAlign.center,
                style: const TextStyle(
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
                        Navigator.of(ctx).pop();
                      },
                      child: const Text(
                        'Cancel',
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
                        Navigator.of(ctx).pop();
                        _enterEditMode(existing);
                      },
                      child: const Text(
                        'Edit',
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
      ),
    );
  }

  void _enterEditMode(VideoUploadModel item) {
    setState(() {
      _isEditModeForVideo = true;
      _existingVideoId = item.videoId;
      _titleController.text = item.title ?? '';
      _descriptionController.text = item.description ?? '';
      _selectedCategory = item.category;
      _tagsController.text = (item.tags ?? []).join(',');
      _sourcePlatformController.text = item.sourcePlatform ?? '';
      final preferredDate = item.preferredDate;
      final parsedPreferredDate =
          preferredDate != null ? DateTime.tryParse(preferredDate) : null;
      _preferredDateValue = parsedPreferredDate;
      _preferredDateController.text = parsedPreferredDate != null
          ? _formatDateForDisplay(parsedPreferredDate)
          : (preferredDate ?? '');
      _durationController.text = item.duration?.toString() ?? '';
      _syncLanguageSelectionFromValue(item.language);
      _selectedVideo = null;
      _selectedThumbnail = null;
    });
  }

  void _syncLanguageSelectionFromValue(String? rawValue) {
    final String value = rawValue?.trim() ?? '';
    if (value.isEmpty) {
      _languageController.text = '';
      _selectedLanguageCode = null;
      return;
    }

    if (_externalController.languages.isEmpty) {
      _languageController.text = value;
      _selectedLanguageCode = null;
      return;
    }

    try {
      final matchByCode = _externalController.languages.firstWhere(
        (lang) => lang.code.toLowerCase() == value.toLowerCase(),
      );
      _languageController.text = matchByCode.name;
      _selectedLanguageCode = matchByCode.code;
      return;
    } catch (_) {
      // ignore
    }

    try {
      final matchByName = _externalController.languages.firstWhere(
        (lang) => lang.name.toLowerCase() == value.toLowerCase(),
      );
      _languageController.text = matchByName.name;
      _selectedLanguageCode = matchByName.code;
      return;
    } catch (_) {
      // ignore
    }

    _languageController.text = value;
    _selectedLanguageCode = null;
  }

  String? _resolveLanguageForSubmit() {
    if (_selectedLanguageCode != null && _selectedLanguageCode!.isNotEmpty) {
      return _selectedLanguageCode;
    }
    final String trimmed = _languageController.text.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String? _resolveCreatorTimezone() {
    final profile = _creatorController.creatorProfile.value;
    if (profile == null || profile.country.trim().isEmpty) {
      return null;
    }

    final country =
        _externalController.getCountryByName(profile.country.trim());
    if (country == null || country.timezones.isEmpty) {
      return null;
    }

    return country.timezones.first;
  }

  String? _validateTags(String? value) {
    final tags = value
            ?.split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList() ??
        [];

    if (tags.isEmpty) {
      return 'Tags are required.';
    }

    return null;
  }

  String? _validatePreferredDate(String? value) {
    final rawValue = value?.trim() ?? '';
    if (rawValue.isEmpty) return null;

    DateTime? parsedDate;
    final displayMatch =
        RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(rawValue);
    if (displayMatch != null) {
      final day = int.tryParse(displayMatch.group(1)!);
      final month = int.tryParse(displayMatch.group(2)!);
      final year = int.tryParse(displayMatch.group(3)!);
      if (day != null && month != null && year != null) {
        parsedDate = DateTime.tryParse(
          '${year.toString().padLeft(4, '0')}-'
          '${month.toString().padLeft(2, '0')}-'
          '${day.toString().padLeft(2, '0')}',
        );
      }
    } else {
      parsedDate = DateTime.tryParse(rawValue);
    }

    if (parsedDate == null) {
      return 'Enter a valid preferred date.';
    }

    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final normalizedDate =
        DateTime(parsedDate.year, parsedDate.month, parsedDate.day);

    if (normalizedDate.isBefore(normalizedToday)) {
      return 'Preferred date cannot be in the past.';
    }

    return null;
  }

  bool _hasExistingVideoForSubmit() {
    final videoUrl = _videosController.uploadedVideo.value?.videoUrl?.trim();
    return _isEditModeForVideo && videoUrl != null && videoUrl.isNotEmpty;
  }

  bool _hasExistingThumbnailForSubmit() {
    final thumbnailUrl =
        _videosController.uploadedVideo.value?.thumbnailUrl?.trim();
    return _isEditModeForVideo &&
        thumbnailUrl != null &&
        thumbnailUrl.isNotEmpty;
  }

  Future<void> _pickVideo() async {
    final XFile? picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (picked != null) {
      final extension = picked.name.split('.').last.toLowerCase();
      if (!['mp4', 'mov', 'm4v'].contains(extension)) {
        if (mounted) {
          PLoaders.warningSnackBar(
            title: 'Invalid Video',
            message: 'Please choose an MP4, MOV, or M4V video file.',
            context: context,
          );
        }
        return;
      }

      final bytes = await picked.readAsBytes();
      final fileSizeMB = bytes.length / (1024 * 1024);
      if (fileSizeMB > 500) {
        if (mounted) {
          PLoaders.warningSnackBar(
            title: 'Video Too Large',
            message:
                'Video size must be less than 500MB (Current: ${fileSizeMB.toStringAsFixed(2)}MB).',
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

  Future<void> _pickThumbnail() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final extension = picked.name.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
        if (mounted) {
          PLoaders.warningSnackBar(
            title: 'Invalid Thumbnail',
            message: 'Please choose a JPG, PNG, or WEBP image.',
            context: context,
          );
        }
        return;
      }

      final bytes = await picked.readAsBytes();
      final fileSizeMB = bytes.length / (1024 * 1024);
      if (fileSizeMB > 10) {
        if (mounted) {
          PLoaders.warningSnackBar(
            title: 'Thumbnail Too Large',
            message:
                'Thumbnail size must be less than 10MB (Current: ${fileSizeMB.toStringAsFixed(2)}MB).',
            context: context,
          );
        }
        return;
      }

      setState(() {
        _selectedThumbnail = picked;
        _showThumbnailError = false;
      });
    }
  }

  void _deleteVideo() {
    setState(() {
      _selectedVideo = null;
    });
  }

  void _deleteThumbnail() {
    setState(() {
      _selectedThumbnail = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PAppBar(
        title: Text(
          'Upload Content',
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
        child: Obx(() {
          if (_creatorController.isProfileLoading.value &&
              _creatorController.creatorProfile.value == null) {
            return const Center(
              child: CircularProgressIndicator(color: PColors.primary),
            );
          }

          if (!_creatorController.canUploadCreatorVideos) {
            return _UploadApprovalRequiredView(
              message: _creatorController.creatorUploadRestrictionMessage,
              onRegister: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const RegisterCreatorScreen(),
                  ),
                );
              },
            );
          }

          final String? timezoneLabel = _resolveCreatorTimezone();

          return SingleChildScrollView(
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
                            const SectionTitle(title: 'Video Details'),
                            const SizedBox(height: 12),
                            CustomTextField(
                              hintText: 'Title',
                              controller: _titleController,
                              isRequired: true,
                              validator: (value) =>
                                  PValidator.validateEmptyText('Title', value),
                            ),
                            const SizedBox(height: 12),
                            CustomTextField(
                              hintText: 'Description',
                              controller: _descriptionController,
                              isRequired: true,
                              validator: (value) =>
                                  PValidator.validateEmptyText(
                                'Description',
                                value,
                              ),
                              maxLines: 4,
                              maxLength: 300,
                              showCounter: true,
                            ),
                            const SizedBox(height: 12),
                            CustomTextField(
                              hintText: 'Category',
                              controller: null,
                              isDropdown: true,
                              isRequired: true,
                              validator: (value) =>
                                  PValidator.validateRequiredSelection(
                                'Category',
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
                            const SizedBox(height: 12),
                            CustomTextField(
                              hintText: 'Tags',
                              controller: _tagsController,
                              isRequired: true,
                              validator: _validateTags,
                            ),
                            const SizedBox(height: 12),
                            CustomTextField(
                              hintText: 'Source Platform',
                              controller: _sourcePlatformController,
                              isRequired: true,
                              validator: (value) =>
                                  PValidator.validateEmptyText(
                                'Source platform',
                                value,
                              ),
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: _pickPreferredDate,
                              child: AbsorbPointer(
                                child: CustomTextField(
                                  hintText: 'Preferred Date',
                                  controller: _preferredDateController,
                                  validator: _validatePreferredDate,
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Icon(Icons.calendar_today,
                                        color: Colors.grey[600]),
                                  ),
                                ),
                              ),
                            ),
                            if (timezoneLabel != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Timezone: $timezoneLabel',
                                style: const TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 12,
                                  color: Color(0xFF7A7A7A),
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            CustomTextField(
                              hintText: 'Duration (minutes)',
                              controller: _durationController,
                              keyboardType: TextInputType.number,
                              validator: (value) =>
                                  PValidator.validateOptionalPositiveNumber(
                                'Duration in minutes',
                                value,
                              ),
                              suffixIcon: const Padding(
                                padding: EdgeInsets.only(right: 12),
                                child: Center(
                                  widthFactor: 1,
                                  child: Text(
                                    'min',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF777777),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Builder(
                              builder: (context) {
                                final List<String> languageItems =
                                    _externalController.languages.isNotEmpty
                                        ? _externalController.languages
                                            .map((l) => l.name)
                                            .toList()
                                        : _languages;
                                final String? selectedLanguage =
                                    _languageController.text.trim().isEmpty
                                        ? null
                                        : _languageController.text.trim();
                                final List<String> dropdownItems =
                                    List<String>.from(languageItems);
                                if (selectedLanguage != null &&
                                    !dropdownItems.contains(selectedLanguage)) {
                                  dropdownItems.add(selectedLanguage);
                                }

                                return CustomTextField(
                                  hintText: 'Language',
                                  controller: null,
                                  isDropdown: true,
                                  dropdownItems: dropdownItems,
                                  value: selectedLanguage,
                                  onChanged: (val) {
                                    setState(() {
                                      _languageController.text = val ?? '';
                                      _selectedLanguageCode =
                                          _externalController
                                              .getLanguageCodeByName(val);
                                    });
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 22),
                            const SectionTitle(
                              title: 'Video File',
                              isRequired: true,
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: _pickVideo,
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
                                        width: 280,
                                        height: 180,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: _selectedVideo != null
                                            ? Stack(
                                                children: [
                                                  Center(
                                                    child: Icon(
                                                      Icons.check_circle,
                                                      color: PColors.primary,
                                                      size: 52,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 8,
                                                    right: 8,
                                                    child: GestureDetector(
                                                      onTap: _deleteVideo,
                                                      child: const Icon(
                                                        Icons.cancel_rounded,
                                                        color: Colors.red,
                                                        size: 24,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Center(
                                                child: Image.asset(
                                                  'assets/icons/video-posting.png',
                                                  width: 52,
                                                  height: 52,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),

                                  // VIDEO NAME
                                  if (_selectedVideo != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Text(
                                        _selectedVideo!.name,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 13,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),

                                  // FILE SIZE
                                  if (_selectedVideo != null)
                                    FutureBuilder<int>(
                                      future: _selectedVideo!
                                          .readAsBytes()
                                          .then((bytes) => bytes.length),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return const SizedBox.shrink();
                                        }

                                        final sizeMB =
                                            snapshot.data! / (1024 * 1024);

                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4),
                                          child: Text(
                                            '${sizeMB.toStringAsFixed(2)} MB',
                                            style: const TextStyle(
                                              fontFamily: 'Roboto',
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                            if (_showVideoError)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'Please select a video file.',
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            const SizedBox(height: 18),
                            const SectionTitle(
                              title: 'Thumbnail',
                              isRequired: true,
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: _pickThumbnail,
                                    child: CustomPaint(
                                      painter: DottedBorderPainter(
                                        color: _showThumbnailError
                                            ? const Color(0xFFD32F2F)
                                            : _selectedThumbnail != null
                                                ? PColors.primary
                                                : Colors.grey.shade400,
                                        borderRadius: 16,
                                        strokeWidth: 2,
                                      ),
                                      child: Container(
                                        width: 280,
                                        height: 180,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: _selectedThumbnail != null
                                            ? Stack(
                                                children: [
                                                  Center(
                                                    child: Icon(
                                                      Icons.check_circle,
                                                      color: PColors.primary,
                                                      size: 52,
                                                    ),
                                                  ),

                                                  // DELETE ICON
                                                  Positioned(
                                                    top: 8,
                                                    right: 8,
                                                    child: GestureDetector(
                                                      onTap: _deleteThumbnail,
                                                      child: const Icon(
                                                        Icons.cancel_rounded,
                                                        color: Colors.red,
                                                        size: 24,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Center(
                                                child: Icon(
                                                  Icons.add_photo_alternate,
                                                  color: Colors.grey,
                                                  size: 52,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),

                                  // THUMBNAIL NAME
                                  if (_selectedThumbnail != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Text(
                                        _selectedThumbnail!.name,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 13,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),

                                  // THUMBNAIL SIZE
                                  if (_selectedThumbnail != null)
                                    FutureBuilder<int>(
                                      future: _selectedThumbnail!
                                          .readAsBytes()
                                          .then((bytes) => bytes.length),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return const SizedBox.shrink();
                                        }

                                        final sizeKB = snapshot.data! / 1024;

                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4),
                                          child: Text(
                                            '${sizeKB.toStringAsFixed(2)} KB',
                                            style: const TextStyle(
                                              fontFamily: 'Roboto',
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                            if (_showThumbnailError)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'Please select a thumbnail image.',
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            const SizedBox(height: 18),
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
                                      onTap: _videosController
                                              .isUploadLoading.value
                                          ? null
                                          : () async {
                                              await _creatorController
                                                  .fetchCreatorProfile();
                                              if (!context.mounted) return;

                                              if (!_creatorController
                                                  .canUploadCreatorVideos) {
                                                PLoaders.warningSnackBar(
                                                  title: 'Upload Restricted',
                                                  message: _creatorController
                                                      .creatorUploadRestrictionMessage,
                                                  context: context,
                                                );
                                                return;
                                              }

                                              final isFormValid = _formKey
                                                      .currentState
                                                      ?.validate() ??
                                                  false;

                                              setState(() {
                                                _showVideoError = _selectedVideo ==
                                                        null &&
                                                    !_hasExistingVideoForSubmit();
                                                _showThumbnailError =
                                                    _selectedThumbnail ==
                                                            null &&
                                                        !_hasExistingThumbnailForSubmit();
                                              });

                                              if (!isFormValid ||
                                                  _showVideoError ||
                                                  _showThumbnailError) {
                                                return;
                                              }

                                              // If user already has an uploaded video and not in edit mode, show popup
                                              if (!_isEditModeForVideo &&
                                                  _videosController
                                                      .isVideoUploaded.value) {
                                                _showAlreadyUploadedPopup();
                                                return;
                                              }

                                              // Perform upload or update
                                              if (_isEditModeForVideo &&
                                                  _existingVideoId != null) {
                                                await _videosController
                                                    .updateVideo(
                                                  videoId: _existingVideoId!,
                                                  title: _titleController.text
                                                      .trim(),
                                                  description:
                                                      _descriptionController
                                                          .text
                                                          .trim(),
                                                  category:
                                                      _selectedCategory ?? '',
                                                  tags: _tagsController.text
                                                      .trim(),
                                                  sourcePlatform:
                                                      _sourcePlatformController
                                                          .text
                                                          .trim(),
                                                  preferredDate:
                                                      _preferredDateForSubmit(),
                                                  videoFile: _selectedVideo,
                                                  thumbnailFile:
                                                      _selectedThumbnail,
                                                  language:
                                                      _resolveLanguageForSubmit(),
                                                  duration: _durationController
                                                          .text
                                                          .trim()
                                                          .isEmpty
                                                      ? null
                                                      : _durationController.text
                                                          .trim(),
                                                );

                                                if (_videosController
                                                        .uploadError.value ==
                                                    null) {
                                                  PLoaders.successSnackBar(
                                                    title: 'Success',
                                                    message:
                                                        'Upload updated successfully!',
                                                    context: context,
                                                  );
                                                  Navigator.of(context).pop();
                                                } else {
                                                  PLoaders.errorSnackBar(
                                                    title: 'Update Failed',
                                                    message: _videosController
                                                            .uploadError
                                                            .value ??
                                                        'Update failed',
                                                    context: context,
                                                  );
                                                }
                                              } else {
                                                await _videosController
                                                    .uploadVideo(
                                                  title: _titleController.text
                                                      .trim(),
                                                  description:
                                                      _descriptionController
                                                          .text
                                                          .trim(),
                                                  category:
                                                      _selectedCategory ?? '',
                                                  tags: _tagsController.text
                                                      .trim(),
                                                  sourcePlatform:
                                                      _sourcePlatformController
                                                          .text
                                                          .trim(),
                                                  preferredDate:
                                                      _preferredDateForSubmit(),
                                                  videoFile: _selectedVideo,
                                                  thumbnailFile:
                                                      _selectedThumbnail,
                                                  language:
                                                      _resolveLanguageForSubmit(),
                                                  duration: _durationController
                                                          .text
                                                          .trim()
                                                          .isEmpty
                                                      ? null
                                                      : _durationController.text
                                                          .trim(),
                                                );
                                                if (_videosController
                                                        .uploadError.value ==
                                                    null) {
                                                  PLoaders.successSnackBar(
                                                    title: 'Success',
                                                    message:
                                                        'Upload submitted successfully!',
                                                    context: context,
                                                  );
                                                  Navigator.of(context).pop();
                                                } else {
                                                  PLoaders.errorSnackBar(
                                                    title: 'Upload Failed',
                                                    message: _videosController
                                                            .uploadError
                                                            .value ??
                                                        'Upload failed',
                                                    context: context,
                                                  );
                                                }
                                              }
                                            },
                                      child: Center(
                                        child: _videosController
                                                .isUploadLoading.value
                                            ? const SizedBox(
                                                width: 24,
                                                height: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(
                                                    Colors.white,
                                                  ),
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Text(
                                                _isEditModeForVideo
                                                    ? 'Update'
                                                    : 'Submit',
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
                            if (_isEditModeForVideo && _existingVideoId != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: Center(
                                  child: TextButton(
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Delete upload'),
                                          content: const Text(
                                              'Are you sure you want to delete your uploaded video and metadata? This cannot be undone.'),
                                          actions: [
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.of(ctx)
                                                        .pop(false),
                                                child: const Text('Cancel')),
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.of(ctx).pop(true),
                                                child: const Text('Delete',
                                                    style: TextStyle(
                                                        color: Colors.red))),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        final success =
                                            await _videosController.deleteVideo(
                                                videoId: _existingVideoId!);
                                        if (success) {
                                          PLoaders.successSnackBar(
                                            title: 'Deleted',
                                            message: 'Upload deleted',
                                            context: context,
                                          );
                                          setState(() {
                                            _isEditModeForVideo = false;
                                            _existingVideoId = null;
                                          });
                                        } else {
                                          PLoaders.errorSnackBar(
                                            title: 'Delete Failed',
                                            message: 'Delete failed',
                                            context: context,
                                          );
                                        }
                                      }
                                    },
                                    child: const Text('Delete Upload',
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const Center(
                      child: Text(
                        'We will review your submission and contact you soon',
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
          );
        }),
      ),
    );
  }
}

class _UploadApprovalRequiredView extends StatelessWidget {
  final String message;
  final VoidCallback onRegister;

  const _UploadApprovalRequiredView({
    required this.message,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F3C2F).withOpacity(0.08),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 68,
                  width: 68,
                  decoration: BoxDecoration(
                    gradient: PColors.linearGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: PColors.primary.withOpacity(0.22),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_clock_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Approval Required',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    height: 1.5,
                    color: Color(0xFF777777),
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: BorderSide.none,
                      ),
                      elevation: 0,
                    ),
                    onPressed: onRegister,
                    child: const Text(
                      'Manage Creator Registration',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final bool isRequired;

  const SectionTitle({
    Key? key,
    required this.title,
    this.isRequired = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const titleStyle = TextStyle(
      fontFamily: 'Roboto',
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Colors.black,
      letterSpacing: 0,
    );

    if (!isRequired) {
      return Text(
        title.toUpperCase(),
        style: titleStyle,
      );
    }

    return Text.rich(
      TextSpan(
        text: title.toUpperCase(),
        style: titleStyle,
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
    );
  }
}

class _RequiredFieldLabel extends StatelessWidget {
  final String text;
  final bool isRequired;

  const _RequiredFieldLabel({
    required this.text,
    required this.isRequired,
  });

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(
      fontFamily: 'Roboto',
      fontSize: 15,
      color: Color(0xFF808080),
      fontWeight: FontWeight.w400,
    );

    if (!isRequired) {
      return Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: labelStyle,
      );
    }

    return Text.rich(
      TextSpan(
        text: text,
        style: labelStyle,
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

class _CustomFieldDecoration {
  static const double _singleLineFieldHeight = 54;

  static InputDecoration input({
    required String hintText,
    required bool isRequired,
    Widget? suffixIcon,
    Widget? prefixIcon,
    bool showCounter = false,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      label: _RequiredFieldLabel(text: hintText, isRequired: isRequired),
      floatingLabelBehavior: FloatingLabelBehavior.never,
      isDense: true,
      constraints: const BoxConstraints(minHeight: _singleLineFieldHeight),
      contentPadding: contentPadding ??
          const EdgeInsets.symmetric(
            vertical: 17,
            horizontal: 12,
          ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(
          color: const Color(0xFFC3BEBE).withOpacity(0.6),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(
          color: const Color(0xFFC3BEBE).withOpacity(0.6),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: PColors.primary, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.4),
      ),
      labelStyle: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 15,
        color: Color(0xFF808080),
      ),
      errorStyle: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 12,
        color: Color(0xFFD32F2F),
      ),
      errorMaxLines: 2,
      counterText: showCounter ? null : '',
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
      prefixIconConstraints: prefixIcon == null
          ? null
          : const BoxConstraints(
              minWidth: 44,
              minHeight: 40,
            ),
      suffixIconConstraints: suffixIcon == null
          ? null
          : const BoxConstraints(
              minWidth: 44,
              minHeight: 40,
            ),
    );
  }

  static InputDecoration dropdown({
    required String hintText,
    required bool isRequired,
  }) {
    return input(
      hintText: hintText,
      isRequired: isRequired,
      // Dropdown content includes a 24px arrow, so 14px vertical padding
      // matches the 54px single-line text-field height.
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 14,
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool isDropdown;
  final List<String>? dropdownItems;
  final String? value;
  final void Function(String?)? onChanged;
  final int maxLines;
  final int? maxLength;
  final bool showCounter;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool isRequired;

  final Widget? suffixIcon;
  final Widget? prefixIcon;

  const CustomTextField({
    Key? key,
    required this.hintText,
    this.controller,
    this.isDropdown = false,
    this.dropdownItems,
    this.value,
    this.onChanged,
    this.maxLines = 1,
    this.maxLength,
    this.showCounter = false,
    this.keyboardType,
    this.validator,
    this.isRequired = false,
    this.suffixIcon,
    this.prefixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isDropdown && dropdownItems != null) {
      final items = List<String>.from(dropdownItems!);
      if (value != null && value!.isNotEmpty && !items.contains(value)) {
        items.add(value!);
      }
      final effectiveValue =
          value != null && items.contains(value) ? value : null;

      return DropdownButtonFormField<String>(
        initialValue: effectiveValue,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        decoration: _CustomFieldDecoration.dropdown(
          hintText: hintText,
          isRequired: isRequired,
        ),
        hint: _RequiredFieldLabel(text: hintText, isRequired: isRequired),
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 16,
          color: Colors.black,
        ),
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
        validator: validator,
      );
    }

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
      decoration: _CustomFieldDecoration.input(
        hintText: hintText,
        isRequired: isRequired,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        showCounter: showCounter,
      ),
    );
  }
}
