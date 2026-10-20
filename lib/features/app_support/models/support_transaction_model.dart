class SupportTransactionModel {
  final String transactionId;
  final String? userId;
  final String? userName;
  final String? userEmail;
  final double amount;
  final String currency;
  final String paymentMethod;
  final String? stripePaymentIntentId;
  final String? stripeStatus;
  final String? screenshotUrl;
  final String? screenshotUploadedAt;
  final String? manualVerificationStatus;
  final String? adminNote;
  final String? supporterMessage;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  const SupportTransactionModel({
    required this.transactionId,
    this.userId,
    this.userName,
    this.userEmail,
    required this.amount,
    this.currency = 'PKR',
    required this.paymentMethod,
    this.stripePaymentIntentId,
    this.stripeStatus,
    this.screenshotUrl,
    this.screenshotUploadedAt,
    this.manualVerificationStatus,
    this.adminNote,
    this.supporterMessage,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory SupportTransactionModel.fromJson(Map<String, dynamic> json) {
    return SupportTransactionModel(
      transactionId: json['transaction_id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      userName: json['user_name']?.toString(),
      userEmail: json['user_email']?.toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'PKR',
      paymentMethod: json['payment_method']?.toString() ?? '',
      stripePaymentIntentId: json['stripe_payment_intent_id']?.toString(),
      stripeStatus: json['stripe_status']?.toString(),
      screenshotUrl: json['screenshot_url']?.toString(),
      screenshotUploadedAt: json['screenshot_uploaded_at']?.toString(),
      manualVerificationStatus: json['manual_verification_status']?.toString(),
      adminNote: json['admin_note']?.toString(),
      supporterMessage: json['supporter_message']?.toString(),
      status: json['status']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}
