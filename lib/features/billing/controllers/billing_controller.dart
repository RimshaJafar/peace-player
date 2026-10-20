import 'dart:async';

import 'package:ecommerce_app/data/services/auth_service.dart';
import 'package:ecommerce_app/common/widgets/loaders/loaders.dart';
import 'package:ecommerce_app/features/billing/constants/billing_feature_keys.dart';
import 'package:ecommerce_app/features/billing/models/billing_models.dart';
import 'package:ecommerce_app/features/billing/services/billing_api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';

class BillingController extends GetxController with WidgetsBindingObserver {
  BillingController({BillingApiService? apiService})
      : _apiService = apiService ?? BillingApiService();

  static BillingController get instance => Get.find<BillingController>();

  final BillingApiService _apiService;
  final Rxn<BillingProfileModel> profile = Rxn<BillingProfileModel>();
  final Rxn<BillingApiErrorModel> lastError = Rxn<BillingApiErrorModel>();
  final RxBool isProfileLoading = false.obs;
  final RxBool isStartingCheckout = false.obs;
  final RxBool isOpeningPortal = false.obs;
  final RxBool isConfirmingPayment = false.obs;
  final RxString confirmationMessage = ''.obs;
  static const String _pendingCheckoutSessionStorageKey =
      'billing.pendingCheckoutSessionId';

  Worker? _authWorker;
  final GetStorage _storage = GetStorage();
  Future<void>? _profileLoad;
  Timer? _confirmationTimer;
  Timer? _deferredRefreshTimer;
  bool _awaitingPaymentConfirmation = false;
  int _confirmationAttempts = 0;
  String? _pendingCheckoutSessionId;

  AuthService get _authService => AuthService.instance;

  BillingProfileModel? get billingProfile => profile.value;
  BillingPricingModel? get pricing => profile.value?.pricing;
  bool get hasProfile => profile.value != null;
  bool get isPro =>
      profile.value?.plan == 'pro' &&
      profile.value?.subscriptionStatus == 'active';
  bool get isFree => !isPro;
  bool get isPastDue => profile.value?.subscriptionStatus == 'past_due';
  bool get isExpired => profile.value?.subscriptionStatus == 'expired';
  bool get hasStripeCustomer =>
      (profile.value?.stripeCustomerId?.trim().isNotEmpty ?? false);
  bool get hasPreviousStripeSubscription =>
      hasStripeCustomer ||
      (profile.value?.stripeSubscriptionId?.trim().isNotEmpty ?? false);
  bool get canManageSubscription => hasStripeCustomer;
  String get freePriceText => pricing?.free?.priceText ?? 'Free';
  String get monthlyPriceText =>
      pricing?.proMonthly?.priceText ?? BillingPlansConfig.monthlyPriceText;
  String get yearlyPriceText =>
      pricing?.proYearly?.priceText ?? BillingPlansConfig.yearlyPriceText;
  String get monthlyBillingPeriod {
    final String? period = pricing?.proMonthly?.billingPeriod;
    return period == BillingPlansConfig.monthlyBillingPeriod
        ? period!
        : BillingPlansConfig.monthlyBillingPeriod;
  }

  String get yearlyBillingPeriod {
    final String? period = pricing?.proYearly?.billingPeriod;
    return period == BillingPlansConfig.yearlyBillingPeriod
        ? period!
        : BillingPlansConfig.yearlyBillingPeriod;
  }

  String get proPriceComparisonText => '$monthlyPriceText or $yearlyPriceText';

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _authWorker = ever<User?>(_authService.currentUserRx, _onAuthChanged);
    if (_authService.isAuthenticated) {
      unawaited(loadBillingProfile());
      _restorePendingCheckoutSession();
    }
  }

  void _onAuthChanged(User? user) {
    if (user == null) {
      clearBillingState();
      return;
    }
    unawaited(loadBillingProfile(forceRefresh: true));
    _restorePendingCheckoutSession();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !_authService.isAuthenticated) {
      return;
    }
    unawaited(refreshBillingProfile());
    if (_awaitingPaymentConfirmation && !isPro) {
      _schedulePaymentConfirmation(resetAttempts: false);
    }
  }

  Future<void> loadBillingProfile({bool forceRefresh = false}) async {
    if (!_authService.isAuthenticated) {
      clearBillingState();
      return;
    }
    if (!forceRefresh && profile.value != null) return;
    if (_profileLoad != null) return _profileLoad!;

    final Future<void> operation = _fetchBillingProfile();
    _profileLoad = operation;
    try {
      await operation;
    } finally {
      if (identical(_profileLoad, operation)) _profileLoad = null;
    }
  }

  Future<void> refreshBillingProfile() =>
      loadBillingProfile(forceRefresh: true);

  Future<void> _fetchBillingProfile() async {
    isProfileLoading.value = true;
    try {
      profile.value = await _apiService.getBillingProfile();
      lastError.value = null;
      if (isPro) {
        _awaitingPaymentConfirmation = false;
        _pendingCheckoutSessionId = null;
        _clearStoredPendingCheckoutSession();
        _confirmationTimer?.cancel();
        isConfirmingPayment.value = false;
        confirmationMessage.value = '';
      }
    } on BillingApiException catch (error) {
      recordApiError(error.error);
    } catch (_) {
      recordApiError(const BillingApiErrorModel(
        success: false,
        errorCode: 'billing_network_error',
        message: 'Unable to refresh billing right now.',
      ));
    } finally {
      isProfileLoading.value = false;
    }
  }

  BillingEntitlementModel? getEntitlement(String featureKey) =>
      profile.value?.entitlements[featureKey];

  FeatureUsageModel? getUsage(String featureKey) =>
      profile.value?.usage[featureKey];

  bool isFeatureEnabled(String featureKey) {
    final BillingEntitlementModel? entitlement = getEntitlement(featureKey);
    // Billing outages must not become a client-side lock. The API remains final authority.
    return entitlement?.enabled ?? true;
  }

  bool isQuotaRequired(String featureKey) =>
      getEntitlement(featureKey)?.quotaRequired ?? false;

  bool shouldShowUpgrade(String featureKey) {
    if (!hasProfile || isPro) return false;
    final BillingEntitlementModel? entitlement = getEntitlement(featureKey);
    final UpgradeFlagModel? flag = profile.value?.upgradeFlags[featureKey];
    return !(entitlement?.enabled ?? true) ||
        entitlement?.upgradeRequired == true ||
        flag?.upgradeRequired == true ||
        hasExhaustedQuota(featureKey);
  }

  int? getRemainingDaily(String featureKey) =>
      getUsage(featureKey)?.daily?.remaining;

  int? getRemainingMonthly(String featureKey) =>
      getUsage(featureKey)?.monthly?.remaining;

  bool hasExhaustedQuota(String featureKey) {
    if (!isQuotaRequired(featureKey)) return false;
    final UsagePeriodModel? daily = getUsage(featureKey)?.daily;
    final UsagePeriodModel? monthly = getUsage(featureKey)?.monthly;
    return (daily?.limit != null && (daily?.remaining ?? 0) <= 0) ||
        (monthly?.limit != null && (monthly?.remaining ?? 0) <= 0);
  }

  Future<void> startCheckout(String billingPeriod) async {
    if (billingPeriod != BillingPlansConfig.monthlyBillingPeriod &&
        billingPeriod != BillingPlansConfig.yearlyBillingPeriod) {
      recordApiError(const BillingApiErrorModel(
        success: false,
        errorCode: 'invalid_billing_period',
        message: 'Please choose a valid billing period.',
      ));
      PLoaders.warningSnackBar(
        title: 'Billing Period',
        message: 'Please choose a valid billing period.',
      );
      return;
    }

    isStartingCheckout.value = true;
    lastError.value = null;
    try {
      final CheckoutSessionResponseModel session =
          await _apiService.createCheckoutSession(billingPeriod);
      _pendingCheckoutSessionId = session.sessionId.trim().isEmpty
          ? null
          : session.sessionId.trim();
      if (_pendingCheckoutSessionId != null) {
        _storePendingCheckoutSession(_pendingCheckoutSessionId!);
      }
      final bool launched = await launchUrl(
        Uri.parse(session.checkoutUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        _pendingCheckoutSessionId = null;
        _clearStoredPendingCheckoutSession();
        recordApiError(const BillingApiErrorModel(
          success: false,
          errorCode: 'stripe_checkout_launch_failed',
          message: 'Unable to open checkout. Please try again.',
        ));
        PLoaders.errorSnackBar(
          title: 'Checkout Failed',
          message: 'Unable to open checkout. Please try again.',
        );
        return;
      }
      _awaitingPaymentConfirmation = true;
      confirmationMessage.value = 'Confirming payment with Stripe...';
      _schedulePaymentConfirmation(resetAttempts: true);
    } on BillingApiException catch (error) {
      recordApiError(error.error);
      PLoaders.errorSnackBar(
        title: 'Checkout Failed',
        message: 'Unable to open checkout. Please try again.',
      );
    } catch (_) {
      recordApiError(const BillingApiErrorModel(
        success: false,
        errorCode: 'stripe_checkout_failed',
        message: 'Unable to open checkout. Please try again.',
      ));
      PLoaders.errorSnackBar(
        title: 'Checkout Failed',
        message: 'Unable to open checkout. Please try again.',
      );
    } finally {
      isStartingCheckout.value = false;
    }
  }

  Future<void> confirmCheckoutSession(String sessionId) async {
    final String normalizedSessionId = sessionId.trim();
    if (normalizedSessionId.isEmpty) return;

    _pendingCheckoutSessionId = normalizedSessionId;
    _storePendingCheckoutSession(normalizedSessionId);
    _awaitingPaymentConfirmation = true;
    _confirmationAttempts = 0;
    _confirmationTimer?.cancel();
    isConfirmingPayment.value = true;
    confirmationMessage.value = 'Confirming payment with Stripe...';
    await _confirmPayment();
  }

  Future<void> openCustomerPortal() async {
    isOpeningPortal.value = true;
    lastError.value = null;
    try {
      final PortalSessionResponseModel session =
          await _apiService.createPortalSession();
      final bool launched = await launchUrl(
        Uri.parse(session.portalUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        recordApiError(const BillingApiErrorModel(
          success: false,
          errorCode: 'stripe_portal_launch_failed',
          message: 'Unable to open subscription management. Please try again.',
        ));
        PLoaders.errorSnackBar(
          title: 'Subscription',
          message: 'Unable to open subscription management. Please try again.',
        );
      }
    } on BillingApiException catch (error) {
      recordApiError(error.error);
      PLoaders.errorSnackBar(
        title: 'Subscription',
        message: 'Unable to open subscription management. Please try again.',
      );
    } catch (_) {
      recordApiError(const BillingApiErrorModel(
        success: false,
        errorCode: 'stripe_portal_failed',
        message: 'Unable to open subscription management. Please try again.',
      ));
      PLoaders.errorSnackBar(
        title: 'Subscription',
        message: 'Unable to open subscription management. Please try again.',
      );
    } finally {
      isOpeningPortal.value = false;
    }
  }

  void updateUsageFromBillingMetadata(Map<String, dynamic> billingJson) {
    final Map<String, dynamic> metadata = billingJson['billing'] is Map
        ? Map<String, dynamic>.from(billingJson['billing'] as Map)
        : billingJson;
    final String featureKey = metadata['featureKey']?.toString() ?? '';
    final dynamic rawUsage = metadata['usage'];
    if (featureKey.isEmpty || rawUsage is! Map || profile.value == null) return;

    final Map<String, FeatureUsageModel> nextUsage =
        Map<String, FeatureUsageModel>.from(profile.value!.usage)
          ..[featureKey] = FeatureUsageModel.fromJson(
            Map<String, dynamic>.from(rawUsage),
          );
    profile.value = profile.value!.copyWith(usage: nextUsage);
    _scheduleDeferredRefresh();
  }

  void recordApiError(BillingApiErrorModel error) {
    lastError.value = error;
    const Set<String> refreshCodes = <String>{
      'quota_exceeded',
      'payment_past_due',
      'subscription_expired',
      'feature_not_available',
    };
    if (refreshCodes.contains(error.errorCode)) {
      _scheduleDeferredRefresh();
    }
  }

  void clearBillingState() {
    _confirmationTimer?.cancel();
    _deferredRefreshTimer?.cancel();
    _awaitingPaymentConfirmation = false;
    _pendingCheckoutSessionId = null;
    _clearStoredPendingCheckoutSession();
    _confirmationAttempts = 0;
    profile.value = null;
    lastError.value = null;
    isProfileLoading.value = false;
    isStartingCheckout.value = false;
    isOpeningPortal.value = false;
    isConfirmingPayment.value = false;
    confirmationMessage.value = '';
  }

  void _scheduleDeferredRefresh() {
    if (!_authService.isAuthenticated) return;
    _deferredRefreshTimer?.cancel();
    _deferredRefreshTimer = Timer(const Duration(seconds: 2), () {
      unawaited(refreshBillingProfile());
    });
  }

  void _schedulePaymentConfirmation({required bool resetAttempts}) {
    if (resetAttempts) _confirmationAttempts = 0;
    _confirmationTimer?.cancel();
    isConfirmingPayment.value = true;
    _confirmationTimer = Timer(const Duration(seconds: 2), _confirmPayment);
  }

  Future<void> _confirmPayment() async {
    if (!_awaitingPaymentConfirmation || !_authService.isAuthenticated) return;
    _confirmationAttempts += 1;
    final String? sessionId = _pendingCheckoutSessionId;
    if (sessionId != null && sessionId.isNotEmpty) {
      try {
        profile.value = await _apiService.confirmCheckoutSession(sessionId);
        lastError.value = null;
      } on BillingApiException catch (error) {
        recordApiError(error.error);
        if (error.error.errorCode == 'stripe_checkout_session_invalid' ||
            error.error.errorCode == 'stripe_checkout_session_forbidden') {
          _pendingCheckoutSessionId = null;
          _clearStoredPendingCheckoutSession();
          _awaitingPaymentConfirmation = false;
          isConfirmingPayment.value = false;
          return;
        }
        await refreshBillingProfile();
      } catch (_) {
        await refreshBillingProfile();
      }
    } else {
      await refreshBillingProfile();
    }
    if (isPro) return;

    if (_confirmationAttempts >= 6) {
      isConfirmingPayment.value = false;
      confirmationMessage.value =
          'Payment is still being confirmed. Refresh this page in a moment.';
      return;
    }
    _confirmationTimer = Timer(const Duration(seconds: 3), _confirmPayment);
  }

  void _restorePendingCheckoutSession() {
    final String sessionId =
        _storage.read<String>(_pendingCheckoutSessionStorageKey)?.trim() ?? '';
    if (sessionId.isEmpty || _pendingCheckoutSessionId == sessionId) return;

    _pendingCheckoutSessionId = sessionId;
    _awaitingPaymentConfirmation = true;
    confirmationMessage.value = 'Confirming payment with Stripe...';
    _schedulePaymentConfirmation(resetAttempts: true);
  }

  void _storePendingCheckoutSession(String sessionId) {
    _storage.write(_pendingCheckoutSessionStorageKey, sessionId);
  }

  void _clearStoredPendingCheckoutSession() {
    _storage.remove(_pendingCheckoutSessionStorageKey);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _authWorker?.dispose();
    _confirmationTimer?.cancel();
    _deferredRefreshTimer?.cancel();
    super.onClose();
  }
}
