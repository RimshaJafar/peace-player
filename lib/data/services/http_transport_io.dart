import 'dart:io';

import 'package:http/http.dart' as raw;
import 'package:http/io_client.dart';

raw.Client createTransportClient() {
  final httpClient = HttpClient()
    ..connectionTimeout = const Duration(seconds: 30)
    ..idleTimeout = Duration.zero
    ..maxConnectionsPerHost = 4;

  return IOClient(httpClient);
}

bool get supportsConnectionCloseHeader => true;

String get transportDebugLabel => 'io';

bool isTransportNetworkException(Object error) {
  if (error is SocketException || error is HttpException) return true;
  return error is raw.ClientException && _looksLikeNetworkError(error.message);
}

bool _looksLikeNetworkError(String message) {
  final lowerMessage = message.toLowerCase();
  return lowerMessage.contains('connection') ||
      lowerMessage.contains('network') ||
      lowerMessage.contains('closed') ||
      lowerMessage.contains('reset') ||
      lowerMessage.contains('aborted') ||
      lowerMessage.contains('failed');
}
