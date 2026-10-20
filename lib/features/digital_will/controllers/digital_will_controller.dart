import 'dart:convert';

import 'package:ecommerce_app/features/digital_will/models/digital_will_request_model.dart';
import 'package:ecommerce_app/features/digital_will/models/digital_will_response_model.dart';
import 'package:ecommerce_app/features/digital_will/models/saved_will_model.dart';
import 'package:ecommerce_app/features/billing/constants/billing_feature_keys.dart';
import 'package:ecommerce_app/features/billing/controllers/billing_controller.dart';
import 'package:ecommerce_app/features/billing/helpers/billing_gate_helper.dart';
import 'package:ecommerce_app/features/billing/models/billing_models.dart';
import 'package:ecommerce_app/features/billing/services/billing_api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:ecommerce_app/data/services/authenticated_http_client.dart'
    as http;

class DigitalWillController extends GetxController {
  static const int _networkErrorStatusCode = 599;

  final String? apisBaseUrl = dotenv.env['APIS_BASE_URL'];
  final Rxn<DigitalWillCalculationResponse> lastResponse =
      Rxn<DigitalWillCalculationResponse>();
  final RxnString lastError = RxnString();
  final isSubmitting = false.obs;

  Step1BasicInfoRequest? basicInfo;
  Step2AssetsRequest? assets;
  Step3LiabilitiesRequest? liabilities;
  Step4WasiyyahRequest? wasiyyah;
  Step5HeirsRequest? heirs;

  final String digitalWillEndpoint = dotenv.env['DIGITAL_WILL_ENDPOINT'] ??
      '/digital-will/calculate-comprehensive';

  void reset() {
    basicInfo = null;
    assets = null;
    liabilities = null;
    wasiyyah = null;
    heirs = null;
    lastResponse.value = null;
    lastError.value = null;
    isSubmitting.value = false;
  }

  void setBasicInfo(Step1BasicInfoRequest value) {
    basicInfo = value;
  }

  void setAssets(Step2AssetsRequest value) {
    assets = value;
  }

  void setLiabilities(Step3LiabilitiesRequest value) {
    liabilities = value;
  }

  void setWasiyyah(Step4WasiyyahRequest value) {
    wasiyyah = value;
  }

  void setHeirs(Step5HeirsRequest value) {
    heirs = value;
  }

  double _sumAssets(List<DigitalWillAssetItemRequest>? items) {
    return (items ?? <DigitalWillAssetItemRequest>[]).fold<double>(0.0,
        (double total, DigitalWillAssetItemRequest item) {
      return total + item.estimatedValue;
    });
  }

  double _sumLiabilities(List<DigitalWillLiabilityItemRequest>? items) {
    return (items ?? <DigitalWillLiabilityItemRequest>[]).fold<double>(0.0,
        (double total, DigitalWillLiabilityItemRequest item) {
      return total + item.estimatedValue;
    });
  }

  double get totalAssets {
    final Step2AssetsRequest? currentAssets = assets;
    if (currentAssets == null) {
      return 0.0;
    }

    return _sumAssets(currentAssets.realEstate) +
        _sumAssets(currentAssets.vehicles) +
        _sumAssets(currentAssets.financialAssets) +
        _sumAssets(currentAssets.businessAssets) +
        _sumAssets(currentAssets.preciousMetals) +
        _sumAssets(currentAssets.otherAssets);
  }

  double get totalLiabilities {
    final Step3LiabilitiesRequest? currentLiabilities = liabilities;
    if (currentLiabilities == null) {
      return 0.0;
    }

    return _sumLiabilities(currentLiabilities.debts) +
        _sumLiabilities(currentLiabilities.mahrDue) +
        _sumLiabilities(currentLiabilities.funeralExpenses);
  }

  double get netEstate => totalAssets - totalLiabilities;

  bool get hasCompleteDraft =>
      basicInfo != null &&
      assets != null &&
      liabilities != null &&
      wasiyyah != null &&
      heirs != null;

  DigitalWillRequest? buildRequest() {
    final Step1BasicInfoRequest? currentBasicInfo = basicInfo;
    final Step2AssetsRequest? currentAssets = assets;
    final Step3LiabilitiesRequest? currentLiabilities = liabilities;
    final Step4WasiyyahRequest? currentWasiyyah = wasiyyah;
    final Step5HeirsRequest? currentHeirs = heirs;

    if (currentBasicInfo == null ||
        currentAssets == null ||
        currentLiabilities == null ||
        currentWasiyyah == null ||
        currentHeirs == null) {
      return null;
    }

    return DigitalWillRequest(
      step1BasicInfo: currentBasicInfo,
      step2Assets: currentAssets,
      step3Liabilities: currentLiabilities,
      step4Wasiyyah: currentWasiyyah,
      step5Heirs: currentHeirs,
    );
  }

  Future<DigitalWillCalculationResponse?> submitDigitalWill() async {
    if (isSubmitting.value) {
      return null;
    }

    isSubmitting.value = true;
    lastError.value = null;

    try {
      if (!await BillingGateHelper.ensureFeatureAccess(
        BillingFeatureKeys.digitalWill,
      )) {
        return null;
      }

      final DigitalWillRequest? request = buildRequest();
      if (request == null) {
        lastError.value = 'Digital will draft is incomplete.';
        return null;
      }

      final String? validationError = _validateRequest(request);
      if (validationError != null) {
        lastError.value = validationError;
        return null;
      }

      if (apisBaseUrl == null || apisBaseUrl!.isEmpty) {
        lastError.value = 'APIS_BASE_URL is not configured.';
        return null;
      }

      final Uri uri = Uri.parse('$apisBaseUrl$digitalWillEndpoint');
      final http.Response response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Idempotency-Key': BillingRequestId.newKey(),
        },
        body: jsonEncode(request.toJson()),
      );

      final dynamic decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        lastError.value = 'Unexpected response format.';
        return null;
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic billing = decoded['billing'];
        if (billing is Map && Get.isRegistered<BillingController>()) {
          BillingController.instance.updateUsageFromBillingMetadata(
            Map<String, dynamic>.from(billing),
          );
        }
        final DigitalWillCalculationResponse parsed =
            DigitalWillCalculationResponse.fromJson(decoded);
        lastResponse.value = parsed;
        return parsed;
      }

      if (response.statusCode == _networkErrorStatusCode) {
        lastError.value = _networkErrorMessage(decoded);
        return null;
      }

      final BillingApiErrorModel billingError =
          billingApiExceptionFromJson(decoded, statusCode: response.statusCode)
              .error;
      BillingGateHelper.handleError(billingError);
      lastError.value = billingError.message ??
          _extractErrorMessage(decoded) ??
          'Request failed with status ${response.statusCode}.';
      return null;
    } catch (error) {
      lastError.value = error.toString();
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }

  String _networkErrorMessage(Map<String, dynamic> data) {
    final String? message = _extractErrorMessage(data);
    if (message != null && message.isNotEmpty) {
      return message;
    }

    return 'Unable to reach the Digital Will service. Please check your connection and try again.';
  }

  bool _isBlank(String value) => value.trim().isEmpty;

  String? _validateRequest(DigitalWillRequest request) {
    return _validateBasicInfo(request.step1BasicInfo) ??
        _validateAssets(request.step2Assets) ??
        _validateLiabilities(request.step3Liabilities) ??
        _validateWasiyyah(request.step4Wasiyyah) ??
        _validateHeirs(
          request.step5Heirs,
          request.step1BasicInfo.gender,
        );
  }

  String? _validateBasicInfo(Step1BasicInfoRequest basicInfo) {
    if (_isBlank(basicInfo.firebaseUserId)) {
      return 'User ID is required.';
    }
    if (_isBlank(basicInfo.userName)) {
      return 'User name is required.';
    }
    if (_isBlank(basicInfo.userEmail)) {
      return 'User email is required.';
    }
    if (_isBlank(basicInfo.fullName)) {
      return 'Full Name is required.';
    }
    if (_isBlank(basicInfo.gender)) {
      return 'Gender is required.';
    }
    if (_isBlank(basicInfo.dateOfBirth)) {
      return 'Date of Birth is required.';
    }
    if (_isBlank(basicInfo.dateOfDeath)) {
      return 'Date of Death is required.';
    }
    if (_isBlank(basicInfo.countryJurisdiction)) {
      return 'Country Jurisdiction is required.';
    }
    if (_isBlank(basicInfo.executorName)) {
      return 'Executor Name is required.';
    }
    if (_isBlank(basicInfo.executorContact)) {
      return 'Executor Contact is required.';
    }

    return null;
  }

  String? _validateAssetItems(
    String label,
    List<DigitalWillAssetItemRequest> items,
  ) {
    for (final DigitalWillAssetItemRequest item in items) {
      if (_isBlank(item.name)) {
        return '$label asset name is required.';
      }
      if (item.estimatedValue <= 0) {
        return '$label estimated value must be greater than zero.';
      }
    }

    return null;
  }

  String? _validateAssets(Step2AssetsRequest assets) {
    final List<List<DigitalWillAssetItemRequest>> groups =
        <List<DigitalWillAssetItemRequest>>[
      assets.realEstate,
      assets.vehicles,
      assets.financialAssets,
      assets.businessAssets,
      assets.preciousMetals,
      assets.otherAssets,
    ];

    final bool hasAsset = groups.any((items) => items.isNotEmpty);
    if (!hasAsset) {
      return 'Add at least one asset before calculating the will.';
    }

    return _validateAssetItems('Real estate', assets.realEstate) ??
        _validateAssetItems('Vehicle', assets.vehicles) ??
        _validateAssetItems('Financial', assets.financialAssets) ??
        _validateAssetItems('Business', assets.businessAssets) ??
        _validateAssetItems('Precious metals', assets.preciousMetals) ??
        _validateAssetItems('Other', assets.otherAssets);
  }

  String? _validateLiabilityItems(
    String label,
    List<DigitalWillLiabilityItemRequest> items,
  ) {
    for (final DigitalWillLiabilityItemRequest item in items) {
      if (_isBlank(item.name)) {
        return '$label name is required.';
      }
      if (item.estimatedValue <= 0) {
        return '$label amount must be greater than zero.';
      }
    }

    return null;
  }

  String? _validateLiabilities(Step3LiabilitiesRequest liabilities) {
    return _validateLiabilityItems('Debt', liabilities.debts) ??
        _validateLiabilityItems('Mahr', liabilities.mahrDue) ??
        _validateLiabilityItems(
          'Funeral expense',
          liabilities.funeralExpenses,
        );
  }

  String? _validateWasiyyah(Step4WasiyyahRequest wasiyyah) {
    if (!wasiyyah.hasWasiyyah) {
      return null;
    }

    if (wasiyyah.beneficiaries.isEmpty) {
      return 'Add at least one Wasiyyah beneficiary.';
    }

    for (final DigitalWillBeneficiaryRequest beneficiary
        in wasiyyah.beneficiaries) {
      if (_isBlank(beneficiary.name)) {
        return 'Beneficiary Name is required.';
      }
      if (_isBlank(beneficiary.type)) {
        return 'Beneficiary Type is required.';
      }
      if (beneficiary.isHeir) {
        return 'Wasiyyah beneficiaries must not be heirs.';
      }

      final double amount = beneficiary.amount ?? 0;
      final double percentage = beneficiary.percentage ?? 0;
      if (amount <= 0 && percentage <= 0) {
        return 'Wasiyyah amount or percentage is required.';
      }
      if (percentage > 100) {
        return 'Wasiyyah percentage must be 100 or less.';
      }
    }

    if (wasiyyah.totalWasiyyahAmount <= 0) {
      return 'Total Wasiyyah amount must be greater than zero.';
    }

    return null;
  }

  String? _validateHeirs(Step5HeirsRequest heirs, String gender) {
    if (_isBlank(heirs.maritalStatus)) {
      return 'Marital Status is required.';
    }

    final bool isMale = gender.toLowerCase() == 'male';
    final bool isMarried = heirs.maritalStatus.toLowerCase() == 'married';
    if (isMale && isMarried && (heirs.wivesCount < 1 || heirs.wivesCount > 4)) {
      return 'Number of Wives is required.';
    }

    final List<int> counts = <int>[
      heirs.wivesCount,
      heirs.sons,
      heirs.daughters,
      heirs.brothersCount,
      heirs.sistersCount,
      heirs.brothersFull,
      heirs.sistersFull,
      heirs.brothersPaternal,
      heirs.sistersPaternal,
      heirs.brothersMaternal,
      heirs.sistersMaternal,
      heirs.nephews,
      heirs.uncles,
      heirs.cousins,
    ];
    if (counts.any((count) => count < 0)) {
      return 'Heir counts cannot be negative.';
    }

    if (heirs.sonNames.length != heirs.sons || heirs.sonNames.any(_isBlank)) {
      return 'All son names are required.';
    }
    if (heirs.daughterNames.length != heirs.daughters ||
        heirs.daughterNames.any(_isBlank)) {
      return 'All daughter names are required.';
    }
    if (heirs.wifeStatuses.length != heirs.wivesCount ||
        heirs.wifeNames.length != heirs.wivesCount) {
      return 'Wife details are incomplete.';
    }

    return null;
  }

  String? _extractErrorMessage(Map<String, dynamic> data) {
    final dynamic detail = data['detail'];
    if (detail is List && detail.isNotEmpty) {
      final List<String> messages = <String>[];
      for (final dynamic item in detail) {
        if (item is Map<String, dynamic>) {
          final dynamic loc = item['loc'];
          final String path = loc is List
              ? loc.skip(1).map((segment) => segment.toString()).join('.')
              : '';
          final String message = item['msg']?.toString() ?? 'Validation error';
          messages.add(path.isEmpty ? message : '$path: $message');
        } else {
          messages.add(item.toString());
        }
      }
      if (messages.isNotEmpty) {
        return messages.join('\n');
      }
    }

    final dynamic error = data['error'];
    if (error == null) {
      final dynamic message = data['message'];
      if (message == null) {
        return null;
      }
      return message.toString();
    }
    return error.toString();
  }

  Future<SavedWillHistoryResponse?> fetchWillHistory({
    required String firebaseUserId,
  }) async {
    if (apisBaseUrl == null || apisBaseUrl!.isEmpty) {
      lastError.value = 'APIS_BASE_URL is not configured.';
      return null;
    }

    isSubmitting.value = true;
    lastError.value = null;

    try {
      final Uri uri = Uri.parse(
        '$apisBaseUrl/digital-will/history?firebase_user_id=$firebaseUserId',
      );
      final http.Response response = await http.get(
        uri,
        headers: const <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      final dynamic decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        lastError.value = 'Unexpected response format.';
        return null;
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return SavedWillHistoryResponse.fromJson(decoded);
      }

      lastError.value = _extractErrorMessage(decoded) ??
          'Request failed with status ${response.statusCode}.';
      return null;
    } catch (error) {
      lastError.value = error.toString();
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<DigitalWillCalculationResponse?> fetchWillDetail({
    required String savedRecordId,
    required String firebaseUserId,
    bool silent = false,
  }) async {
    if (apisBaseUrl == null || apisBaseUrl!.isEmpty) {
      if (!silent) {
        lastError.value = 'APIS_BASE_URL is not configured.';
      }
      return null;
    }

    if (!silent) {
      isSubmitting.value = true;
      lastError.value = null;
    }

    try {
      final Uri uri = Uri.parse(
        '$apisBaseUrl/digital-will/detail/$savedRecordId?firebase_user_id=$firebaseUserId',
      );
      final http.Response response = await http.get(
        uri,
        headers: const <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      final dynamic decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        if (!silent) {
          lastError.value = 'Unexpected response format.';
        }
        return null;
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final DigitalWillCalculationResponse parsed =
            DigitalWillCalculationResponse.fromJson(decoded);
        if (!silent) {
          lastResponse.value = parsed;
        }
        return parsed;
      }

      if (!silent) {
        lastError.value = _extractErrorMessage(decoded) ??
            'Request failed with status ${response.statusCode}.';
      }
      return null;
    } catch (error) {
      if (!silent) {
        lastError.value = error.toString();
      }
      return null;
    } finally {
      if (!silent) {
        isSubmitting.value = false;
      }
    }
  }
}
