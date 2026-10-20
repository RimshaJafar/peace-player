import 'dart:io';

import 'package:ecommerce_app/features/digital_will/models/pdf_generation_request_model.dart';
import 'package:ecommerce_app/features/digital_will/models/pdf_generation_response_model.dart';
import 'package:ecommerce_app/features/digital_will/models/pdf_history_record_model.dart';
import 'package:ecommerce_app/features/digital_will/controllers/pdf_generation_service.dart';
import 'package:ecommerce_app/utils/constants/pdf_constants.dart';
import 'package:ecommerce_app/utils/helpers/error_messages.dart';
import 'package:ecommerce_app/utils/local_storage/pdf_history_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Enum representing the current state of PDF generation.
enum PdfGenerationState {
  idle,
  configuring,
  generating,
  downloading,
  success,
  error,
}

/// Controller for the PDF generation workflow.
class PdfGenerationController extends GetxController {
  // ─── Dependencies ────────────────────────────────────────────────────
  final PdfGenerationService _service = PdfGenerationService.instance;
  final PdfHistoryStorage _storage = PdfHistoryStorage.instance;

  // ─── Observable State ────────────────────────────────────────────────
  final Rx<PdfGenerationState> state = PdfGenerationState.idle.obs;
  final RxnString errorMessage = RxnString();
  final RxDouble downloadProgress = 0.0.obs;
  final Rxn<PdfGenerationResponse> lastGeneratedPdf =
      Rxn<PdfGenerationResponse>();
  final RxList<PdfHistoryRecord> history = <PdfHistoryRecord>[].obs;

  // ─── PDF Options (Observable) ────────────────────────────────────────
  final RxString selectedLanguage = 'en'.obs;
  final RxString selectedTemplate = 'modern'.obs;
  final RxString selectedNarrationStyle = 'formal'.obs;
  final RxString selectedCurrency = 'PKR'.obs;
  final RxString selectedTimezone = 'Asia/Karachi'.obs;

  // Content toggles
  final RxBool includeIslamicExplanation = true.obs;
  final RxBool includeLegalNarration = true.obs;
  final RxBool includeRules = true.obs;
  final RxBool includeValidationNotes = true.obs;
  final RxBool includeWarnings = true.obs;
  final RxBool includeReferences = true.obs;
  final RxBool includeSignatures = true.obs;
  final RxBool includeTables = true.obs;

  // Advanced options
  final RxBool forceRegenerate = false.obs;
  final RxBool includeHtml = false.obs;
  final RxBool includeBase64Pdf = false.obs;

  // ─── Context Data ────────────────────────────────────────────────────
  String? _recordId;
  String? _firebaseUserId;
  final RxnString _deceasedName = RxnString();
  final RxnString _countryName = RxnString();

  // ─── Lifecycle ───────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _detectTimezone();
    loadHistory();
  }

  // ─── Initialize with Record Data ────────────────────────────────────
  void initializeForRecord({
    required String recordId,
    required String firebaseUserId,
    String? deceasedName,
    String? countryName,
  }) {
    _recordId = recordId;
    _firebaseUserId = firebaseUserId;
    setDeceasedName(deceasedName);
    setCountryName(countryName);
    state.value = PdfGenerationState.configuring;
    errorMessage.value = null;

    if (kDebugMode) {
      debugPrint('PdfGenerationController initialized');
      debugPrint('recordId: $recordId');
      debugPrint('firebaseUserId: $firebaseUserId');
      debugPrint('deceasedName: ${_deceasedName.value}');
      debugPrint('countryName: ${_countryName.value}');
    }
  }

  // ─── Auto-detect Timezone ────────────────────────────────────────────
  void _detectTimezone() {
    try {
      final String tz = DateTime.now().timeZoneName;
      // Map common abbreviations to IANA timezone names
      final Map<String, String> tzMap = <String, String>{
        'PKT': 'Asia/Karachi',
        'IST': 'Asia/Kolkata',
        'GMT': 'Europe/London',
        'BST': 'Europe/London',
        'EST': 'America/New_York',
        'EDT': 'America/New_York',
        'CST': 'America/Chicago',
        'CDT': 'America/Chicago',
        'PST': 'America/Los_Angeles',
        'PDT': 'America/Los_Angeles',
        'AST': 'Asia/Riyadh',
        'GST': 'Asia/Dubai',
      };

      final String? detected = tzMap[tz];
      if (detected != null) {
        selectedTimezone.value = detected;
      }
    } catch (_) {
      // Fallback already set to Asia/Karachi
    }
  }

  // ─── Build Request ───────────────────────────────────────────────────
  PdfGenerationRequest? _buildRequest() {
    if (_recordId == null || _recordId!.isEmpty) {
      errorMessage.value =
          'Record ID is missing. The will must be saved before generating PDF.';
      return null;
    }
    if (_firebaseUserId == null || _firebaseUserId!.isEmpty) {
      errorMessage.value = 'Firebase User ID is missing.';
      return null;
    }

    final PdfGenerationOptions options = PdfGenerationOptions(
      language: selectedLanguage.value,
      template: selectedTemplate.value,
      currencyCode: selectedCurrency.value,
      narrationStyle: selectedNarrationStyle.value,
      timezone: selectedTimezone.value,
      locale: PdfConstants.localeForLanguage(selectedLanguage.value),
      includeIslamicExplanation: includeIslamicExplanation.value,
      includeLegalNarration: includeLegalNarration.value,
      includeRules: includeRules.value,
      includeValidationNotes: includeValidationNotes.value,
      includeWarnings: includeWarnings.value,
      includeReferences: includeReferences.value,
      includeSignatures: includeSignatures.value,
      includeTables: includeTables.value,
    );

    return PdfGenerationRequest(
      recordId: _recordId!,
      firebaseUserId: _firebaseUserId!,
      options: options,
      forceRegenerate: forceRegenerate.value,
      includeHtml: includeHtml.value,
      includeBase64Pdf: includeBase64Pdf.value,
    );
  }

  // ─── Generate PDF ────────────────────────────────────────────────────
  Future<PdfGenerationResponse?> generatePdf() async {
    final PdfGenerationRequest? request = _buildRequest();
    if (request == null) {
      errorMessage.value = 'Missing record ID or user ID.';
      state.value = PdfGenerationState.error;
      return null;
    }

    state.value = PdfGenerationState.generating;
    errorMessage.value = null;

    try {
      final PdfGenerationResponse response =
          await _service.generatePdf(request);

      if (!response.success) {
        errorMessage.value = response.error ?? 'PDF generation failed.';
        state.value = PdfGenerationState.error;
        return null;
      }

      lastGeneratedPdf.value = response;

      // Save to history
      final PdfHistoryRecord record = PdfHistoryRecord(
        recordId: response.recordId,
        pdfId: response.pdfId,
        template: response.template,
        language: response.language,
        generatedAt: response.generatedAt,
        downloadUrl: response.downloadUrl,
        deceasedName: _deceasedName.value,
        narrationStyle: selectedNarrationStyle.value,
        currencyCode: selectedCurrency.value,
      );
      await _storage.addRecord(record);
      loadHistory();

      state.value = PdfGenerationState.success;
      return response;
    } on PdfServiceException catch (e) {
      errorMessage.value = e.message;
      state.value = PdfGenerationState.error;
      return null;
    } catch (error, stackTrace) {
      _logDebug('PDF generation failed', error, stackTrace);
      errorMessage.value = AppErrorMessage.fromException(
        error,
        fallback: 'Unable to generate the PDF. Please try again.',
      );
      state.value = PdfGenerationState.error;
      return null;
    }
  }

  // ─── Download PDF ────────────────────────────────────────────────────
  Future<String?> downloadPdf({
    required String downloadUrl,
    required String pdfId,
  }) async {
    state.value = PdfGenerationState.downloading;
    downloadProgress.value = 0.0;
    errorMessage.value = null;

    try {
      final String fileName =
          'islamic_will_${pdfId}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      final String filePath = await _service.downloadPdf(
        downloadUrl: downloadUrl,
        fileName: fileName,
        onProgress: (double progress) {
          downloadProgress.value = progress;
        },
      );

      // Update history with cached path
      await _storage.updateCachedPath(pdfId, filePath);
      loadHistory();

      state.value = PdfGenerationState.success;
      return filePath;
    } on PdfServiceException catch (e) {
      errorMessage.value = e.message;
      state.value = PdfGenerationState.error;
      return null;
    } catch (error, stackTrace) {
      _logDebug('PDF download failed', error, stackTrace);
      errorMessage.value = AppErrorMessage.fromException(
        error,
        fallback: 'Unable to download the PDF. Please try again.',
      );
      state.value = PdfGenerationState.error;
      return null;
    }
  }

  // ─── Open PDF ────────────────────────────────────────────────────────
  Future<void> openPdf(String filePath) async {
    try {
      final File file = File(filePath);
      if (await file.exists()) {
        await OpenFilex.open(filePath);
      } else {
        errorMessage.value = 'File not found. Please re-download.';
      }
    } catch (error, stackTrace) {
      _logDebug('Open PDF failed', error, stackTrace);
      errorMessage.value = AppErrorMessage.fromException(
        error,
        fallback: 'Could not open the PDF. Please try again.',
      );
    }
  }

  // ─── Share PDF ───────────────────────────────────────────────────────
  Future<void> sharePdf(String filePath) async {
    try {
      final File file = File(filePath);
      if (await file.exists()) {
        await Share.shareXFiles(
          <XFile>[XFile(filePath)],
          subject: 'Islamic Will Document',
          text: 'Sharing Islamic Will PDF generated by Peace Player',
        );
      } else {
        errorMessage.value = 'File not found. Please re-download.';
      }
    } catch (error, stackTrace) {
      _logDebug('Share PDF failed', error, stackTrace);
      errorMessage.value = AppErrorMessage.fromException(
        error,
        fallback: 'Could not share the PDF. Please try again.',
      );
    }
  }

  // ─── Open URL Externally ─────────────────────────────────────────────
  Future<void> openUrlExternally(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        errorMessage.value = 'Could not open URL.';
      }
    } catch (error, stackTrace) {
      _logDebug('Open URL failed', error, stackTrace);
      errorMessage.value = AppErrorMessage.fromException(
        error,
        fallback: 'Could not open the link. Please try again.',
      );
    }
  }

  // ─── History Management ──────────────────────────────────────────────
  void loadHistory() {
    history.value = _storage.getHistory();
  }

  Future<void> deleteHistoryRecord(PdfHistoryRecord record) async {
    if (record.cachedFilePath != null) {
      await _service.deleteCachedPdf(record.cachedFilePath!);
    }
    await _storage.removeRecord(record.pdfId);
    loadHistory();
  }

  Future<void> clearAllHistory() async {
    await _service.clearAllCache();
    await _storage.clearHistory();
    loadHistory();
  }

  Future<void> deleteCacheOnly(PdfHistoryRecord record) async {
    if (record.cachedFilePath != null) {
      await _service.deleteCachedPdf(record.cachedFilePath!);
      await _storage.updateCachedPath(record.pdfId, null);
      loadHistory();
    }
  }

  // ─── Reset State ────────────────────────────────────────────────────
  void resetState() {
    state.value = PdfGenerationState.idle;
    errorMessage.value = null;
    downloadProgress.value = 0.0;
    lastGeneratedPdf.value = null;
  }

  void resetOptions() {
    selectedLanguage.value = 'en';
    selectedTemplate.value = 'modern';
    selectedNarrationStyle.value = 'formal';
    selectedCurrency.value = 'PKR';
    _detectTimezone();
    includeIslamicExplanation.value = true;
    includeLegalNarration.value = true;
    includeRules.value = true;
    includeValidationNotes.value = true;
    includeWarnings.value = true;
    includeReferences.value = true;
    includeSignatures.value = true;
    includeTables.value = true;
    forceRegenerate.value = false;
    includeHtml.value = false;
    includeBase64Pdf.value = false;
  }

  // ─── Getters ─────────────────────────────────────────────────────────
  String? get recordId => _recordId;
  String? get firebaseUserId => _firebaseUserId;
  String? get deceasedName => _deceasedName.value;
  String? get countryName => _countryName.value;
  bool get isGenerating => state.value == PdfGenerationState.generating;
  bool get isDownloading => state.value == PdfGenerationState.downloading;
  bool get hasError => state.value == PdfGenerationState.error;
  bool get isSuccess => state.value == PdfGenerationState.success;
  bool get isRtl =>
      selectedLanguage.value == 'ur' || selectedLanguage.value == 'ar';

  void setCountryName(String? name) {
    final String normalized = name?.trim() ?? '';
    if (normalized.isEmpty) return;
    _countryName.value = normalized;
  }

  void setDeceasedName(String? name) {
    final String normalized = name?.trim() ?? '';
    if (normalized.isEmpty) return;
    _deceasedName.value = normalized;
  }

  void _logDebug(String message, Object error, StackTrace stackTrace) {
    if (!kDebugMode) return;
    debugPrint('$message: $error');
    debugPrint(stackTrace.toString());
  }
}
