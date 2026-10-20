import 'dart:math';

class BillingFeatureKeys {
  const BillingFeatureKeys._();

  static const String quranListeningAgent = 'quran_listening_agent';
  static const String peaceGuiderAiChat = 'peace_guider_ai_chat';
  static const String imageAiChat = 'image_ai_chat';
  static const String voiceInput = 'voice_input';
  static const String textToSpeech = 'text_to_speech';
  static const String voiceNavigation = 'voice_navigation';
  static const String boycottScanner = 'boycott_scanner';
  static const String digitalWill = 'digital_will';
  static const String digitalWillPdfReport = 'digital_will_pdf_report';
  static const String chatHistory = 'chat_history';
}

class BillingPlansConfig {
  const BillingPlansConfig._();

  static const String monthlyBillingPeriod = 'monthly';
  static const String yearlyBillingPeriod = 'yearly';
  static const String monthlyPriceText = 'PKR 499/month';
  static const String yearlyPriceText = 'PKR 4,999/year';
}

/// Generates RFC 4122 version-4 request identifiers without adding a package.
class BillingRequestId {
  BillingRequestId._();

  static final Random _random = Random.secure();

  static String newKey() {
    final List<int> bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final String hex =
        bytes.map((int byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}
