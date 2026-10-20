import 'package:http/http.dart' as raw;

raw.Client createTransportClient() => raw.Client();

bool get supportsConnectionCloseHeader => false;

String get transportDebugLabel => 'default';

bool isTransportNetworkException(Object error) {
  return error is raw.ClientException && _looksLikeNetworkError(error.message);
}

bool _looksLikeNetworkError(String message) {
  final lowerMessage = message.toLowerCase();
  return lowerMessage.contains('connection') ||
      lowerMessage.contains('network') ||
      lowerMessage.contains('closed') ||
      lowerMessage.contains('reset') ||
      lowerMessage.contains('aborted') ||
      lowerMessage.contains('failed') ||
      lowerMessage.contains('xmlhttprequest');
}
