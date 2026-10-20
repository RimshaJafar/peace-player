typedef JsonMap = Map<String, dynamic>;

class BillingProfileModel {
  const BillingProfileModel({
    required this.success,
    required this.plan,
    required this.subscriptionStatus,
    required this.billingPeriod,
    required this.currentPeriodStart,
    required this.currentPeriodEnd,
    required this.stripeCustomerId,
    required this.stripeSubscriptionId,
    required this.entitlements,
    required this.usage,
    required this.upgradeFlags,
    required this.appExperience,
    required this.support,
    required this.pricing,
    required this.serverTime,
  });

  final bool success;
  final String plan;
  final String subscriptionStatus;
  final String? billingPeriod;
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;
  final String? stripeCustomerId;
  final String? stripeSubscriptionId;
  final Map<String, BillingEntitlementModel> entitlements;
  final Map<String, FeatureUsageModel> usage;
  final Map<String, UpgradeFlagModel> upgradeFlags;
  final AppExperienceModel appExperience;
  final SupportModel support;
  final BillingPricingModel? pricing;
  final DateTime? serverTime;

  factory BillingProfileModel.fromJson(JsonMap json) {
    return BillingProfileModel(
      success: _asBool(json['success']),
      plan: _asString(json['plan'], fallback: 'free').toLowerCase(),
      subscriptionStatus:
          _asString(json['subscriptionStatus'], fallback: 'expired')
              .toLowerCase(),
      billingPeriod: _asNullableString(json['billingPeriod']),
      currentPeriodStart: _asDateTime(json['currentPeriodStart']),
      currentPeriodEnd: _asDateTime(json['currentPeriodEnd']),
      stripeCustomerId: _asNullableString(json['stripeCustomerId']),
      stripeSubscriptionId: _asNullableString(json['stripeSubscriptionId']),
      entitlements: _asMap(json['entitlements']).map(
        (String key, dynamic value) => MapEntry(
          key,
          BillingEntitlementModel.fromJson(_asMap(value)),
        ),
      ),
      usage: _asMap(json['usage']).map(
        (String key, dynamic value) => MapEntry(
          key,
          FeatureUsageModel.fromJson(_asMap(value)),
        ),
      ),
      upgradeFlags: _asMap(json['upgradeFlags']).map(
        (String key, dynamic value) => MapEntry(
          key,
          UpgradeFlagModel.fromJson(_asMap(value)),
        ),
      ),
      appExperience: AppExperienceModel.fromJson(_asMap(json['appExperience'])),
      support: SupportModel.fromJson(_asMap(json['support'])),
      pricing: json['pricing'] == null
          ? null
          : BillingPricingModel.fromJson(_asMap(json['pricing'])),
      serverTime: _asDateTime(json['serverTime']),
    );
  }

  BillingProfileModel copyWith({Map<String, FeatureUsageModel>? usage}) {
    return BillingProfileModel(
      success: success,
      plan: plan,
      subscriptionStatus: subscriptionStatus,
      billingPeriod: billingPeriod,
      currentPeriodStart: currentPeriodStart,
      currentPeriodEnd: currentPeriodEnd,
      stripeCustomerId: stripeCustomerId,
      stripeSubscriptionId: stripeSubscriptionId,
      entitlements: entitlements,
      usage: usage ?? this.usage,
      upgradeFlags: upgradeFlags,
      appExperience: appExperience,
      support: support,
      pricing: pricing,
      serverTime: serverTime,
    );
  }
}

class BillingEntitlementModel {
  const BillingEntitlementModel({
    required this.enabled,
    required this.quotaRequired,
    this.dailyLimit,
    this.monthlyLimit,
    this.responseQuality,
    this.contextMemory,
    this.priority,
    this.accessLevel,
    this.maxSavedChats,
    this.maxSavedRecords,
    this.pdfReport,
    this.fairUseProtection,
    this.upgradeRequired,
    this.historyAccess,
  });

  final bool enabled;
  final bool quotaRequired;
  final int? dailyLimit;
  final int? monthlyLimit;
  final String? responseQuality;
  final String? contextMemory;
  final bool? priority;
  final String? accessLevel;
  final int? maxSavedChats;
  final int? maxSavedRecords;
  final bool? pdfReport;
  final bool? fairUseProtection;
  final bool? upgradeRequired;
  final String? historyAccess;

  factory BillingEntitlementModel.fromJson(JsonMap json) {
    return BillingEntitlementModel(
      enabled: _asBool(json['enabled']),
      quotaRequired: _asBool(json['quotaRequired']),
      dailyLimit: _asInt(json['dailyLimit']),
      monthlyLimit: _asInt(json['monthlyLimit']),
      responseQuality: _asNullableString(json['responseQuality']),
      contextMemory: _asNullableString(json['contextMemory']),
      priority: _asNullableBool(json['priority']),
      accessLevel: _asNullableString(json['accessLevel']),
      maxSavedChats: _asInt(json['maxSavedChats']),
      maxSavedRecords: _asInt(json['maxSavedRecords']),
      pdfReport: _asNullableBool(json['pdfReport']),
      fairUseProtection: _asNullableBool(json['fairUseProtection']),
      upgradeRequired: _asNullableBool(json['upgradeRequired']),
      historyAccess: _asNullableString(json['historyAccess']),
    );
  }
}

class FeatureUsageModel {
  const FeatureUsageModel({this.daily, this.monthly});

  final UsagePeriodModel? daily;
  final UsagePeriodModel? monthly;

  factory FeatureUsageModel.fromJson(JsonMap json) {
    return FeatureUsageModel(
      daily: json['daily'] == null
          ? null
          : UsagePeriodModel.fromJson(_asMap(json['daily'])),
      monthly: json['monthly'] == null
          ? null
          : UsagePeriodModel.fromJson(_asMap(json['monthly'])),
    );
  }
}

class UsagePeriodModel {
  const UsagePeriodModel({
    required this.used,
    this.limit,
    this.remaining,
    this.resetAt,
  });

  final int used;
  final int? limit;
  final int? remaining;
  final DateTime? resetAt;

  factory UsagePeriodModel.fromJson(JsonMap json) {
    return UsagePeriodModel(
      used: _asInt(json['used']) ?? 0,
      limit: _asInt(json['limit']),
      remaining: _asInt(json['remaining']),
      resetAt: _asDateTime(json['resetAt']),
    );
  }
}

class UpgradeFlagModel {
  const UpgradeFlagModel({required this.upgradeRequired});

  final bool upgradeRequired;

  factory UpgradeFlagModel.fromJson(JsonMap json) =>
      UpgradeFlagModel(upgradeRequired: _asBool(json['upgradeRequired']));
}

class AppExperienceModel {
  const AppExperienceModel({required this.upgradeReminders});

  final bool upgradeReminders;

  factory AppExperienceModel.fromJson(JsonMap json) =>
      AppExperienceModel(upgradeReminders: _asBool(json['upgradeReminders']));
}

class SupportModel {
  const SupportModel({required this.level});

  final String level;

  factory SupportModel.fromJson(JsonMap json) =>
      SupportModel(level: _asString(json['level'], fallback: 'standard'));
}

class BillingPricingModel {
  const BillingPricingModel({
    this.currency,
    this.free,
    this.proMonthly,
    this.proYearly,
  });

  final String? currency;
  final BillingPlanPriceModel? free;
  final BillingPlanPriceModel? proMonthly;
  final BillingPlanPriceModel? proYearly;

  factory BillingPricingModel.fromJson(JsonMap json) {
    final JsonMap pro = _asMap(json['pro']);
    return BillingPricingModel(
      currency: _asNullableString(json['currency']),
      free: json['free'] == null
          ? null
          : BillingPlanPriceModel.fromJson(_asMap(json['free'])),
      proMonthly: pro['monthly'] == null
          ? null
          : BillingPlanPriceModel.fromJson(_asMap(pro['monthly'])),
      proYearly: pro['yearly'] == null
          ? null
          : BillingPlanPriceModel.fromJson(_asMap(pro['yearly'])),
    );
  }
}

class BillingPlanPriceModel {
  const BillingPlanPriceModel({
    this.plan,
    this.displayName,
    this.priceText,
    this.amountMinor,
    this.currency,
    this.billingPeriod,
  });

  final String? plan;
  final String? displayName;
  final String? priceText;
  final int? amountMinor;
  final String? currency;
  final String? billingPeriod;

  factory BillingPlanPriceModel.fromJson(JsonMap json) {
    return BillingPlanPriceModel(
      plan: _asNullableString(json['plan']),
      displayName: _asNullableString(json['displayName']),
      priceText: _asNullableString(json['priceText']),
      amountMinor: _asInt(json['amountMinor']),
      currency: _asNullableString(json['currency']),
      billingPeriod: _asNullableString(json['billingPeriod']),
    );
  }
}

class CheckoutSessionResponseModel {
  const CheckoutSessionResponseModel({
    required this.success,
    required this.checkoutUrl,
    required this.sessionId,
  });

  final bool success;
  final String checkoutUrl;
  final String sessionId;

  factory CheckoutSessionResponseModel.fromJson(JsonMap json) {
    return CheckoutSessionResponseModel(
      success: _asBool(json['success']),
      checkoutUrl: _asString(json['checkoutUrl']),
      sessionId: _asString(json['sessionId']),
    );
  }
}

class PortalSessionResponseModel {
  const PortalSessionResponseModel({
    required this.success,
    required this.portalUrl,
  });

  final bool success;
  final String portalUrl;

  factory PortalSessionResponseModel.fromJson(JsonMap json) {
    return PortalSessionResponseModel(
      success: _asBool(json['success']),
      portalUrl: _asString(json['portalUrl']),
    );
  }
}

class BillingApiErrorModel {
  const BillingApiErrorModel({
    required this.success,
    this.errorCode,
    this.message,
    this.featureKey,
    this.plan,
    this.upgradeRequired,
    this.usage,
    this.subscriptionStatus,
    this.resetAt,
    this.statusCode,
  });

  final bool success;
  final String? errorCode;
  final String? message;
  final String? featureKey;
  final String? plan;
  final bool? upgradeRequired;
  final FeatureUsageModel? usage;
  final String? subscriptionStatus;
  final DateTime? resetAt;
  final int? statusCode;

  factory BillingApiErrorModel.fromJson(JsonMap json, {int? statusCode}) {
    final dynamic detail = json['detail'];
    final String? message = _asNullableString(json['message']) ??
        (detail is String ? detail : null);
    return BillingApiErrorModel(
      success: _asBool(json['success']),
      errorCode: _asNullableString(json['errorCode']),
      message: message,
      featureKey: _asNullableString(json['featureKey']),
      plan: _asNullableString(json['plan']),
      upgradeRequired: _asNullableBool(json['upgradeRequired']),
      usage: json['usage'] == null
          ? null
          : FeatureUsageModel.fromJson(_asMap(json['usage'])),
      subscriptionStatus: _asNullableString(json['subscriptionStatus']),
      resetAt: _asDateTime(json['resetAt']),
      statusCode: statusCode,
    );
  }
}

JsonMap _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value
        .map((dynamic key, dynamic item) => MapEntry(key.toString(), item));
  }
  return <String, dynamic>{};
}

String _asString(dynamic value, {String fallback = ''}) {
  final String? text = _asNullableString(value);
  return text ?? fallback;
}

String? _asNullableString(dynamic value) {
  if (value == null) return null;
  final String text = value.toString().trim();
  return text.isEmpty ? null : text;
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  return value?.toString().toLowerCase() == 'true';
}

bool? _asNullableBool(dynamic value) => value == null ? null : _asBool(value);

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

DateTime? _asDateTime(dynamic value) {
  if (value is DateTime) return value.toUtc();
  if (value == null) return null;
  return DateTime.tryParse(value.toString())?.toUtc();
}
