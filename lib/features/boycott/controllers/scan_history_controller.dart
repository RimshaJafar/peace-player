import 'package:get/get.dart';
import 'package:ecommerce_app/features/boycott/models/scan_response_model.dart';
import 'package:ecommerce_app/features/boycott/controllers/boycott_scanner_service.dart';
import 'package:ecommerce_app/utils/helpers/error_messages.dart';

class ScanHistoryController extends GetxController {
  final BoycottScannerService _service = BoycottScannerService();

  final historyItems = <ScanHistoryItem>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final selectedScan = Rxn<ScanResponse>();
  final isLoadingDetail = false.obs;

  Future<void> fetchHistory(String firebaseUserId,
      {int limit = 50, int skip = 0}) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await _service.getScanHistory(
        firebaseUserId: firebaseUserId,
        limit: limit,
        skip: skip,
      );
      historyItems.assignAll(response.history);
    } catch (error) {
      errorMessage.value = AppErrorMessage.fromException(
        error,
        fallback: 'Unable to load scan history. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchScanDetail(String scanId) async {
    isLoadingDetail.value = true;
    errorMessage.value = '';
    try {
      final result = await _service.getScanById(scanId);
      selectedScan.value = result;
    } catch (error) {
      errorMessage.value = AppErrorMessage.fromException(
        error,
        fallback: 'Unable to load scan details. Please try again.',
      );
    } finally {
      isLoadingDetail.value = false;
    }
  }

  void clearSelectedScan() {
    selectedScan.value = null;
  }
}
