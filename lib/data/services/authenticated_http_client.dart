import 'dart:async';
import 'dart:convert';

import 'package:ecommerce_app/data/services/auth_service.dart';
import 'package:ecommerce_app/data/services/http_transport.dart' as transport;
import 'package:ecommerce_app/data/services/token_provider.dart';
import 'package:ecommerce_app/utils/helpers/error_messages.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as raw;

export 'package:http/http.dart'
    show ByteStream, ClientException, MultipartFile, Response, StreamedResponse;

const Duration _requestTimeout = Duration(seconds: 60);
const int _networkErrorStatusCode = 599;

class Request extends raw.Request {
  Request(super.method, super.url);

  @override
  Future<raw.StreamedResponse> send() async {
    final Client client = Client();

    try {
      final raw.StreamedResponse response = await client.send(this);
      return _streamedResponseWithClientClose(response, client);
    } catch (_) {
      client.close();
      rethrow;
    }
  }
}

class MultipartRequest extends raw.MultipartRequest {
  MultipartRequest(super.method, super.url);

  @override
  Future<raw.StreamedResponse> send() async {
    final Client client = Client();

    try {
      final raw.StreamedResponse response = await client.send(this);
      return _streamedResponseWithClientClose(response, client);
    } catch (_) {
      client.close();
      rethrow;
    }
  }
}

raw.StreamedResponse _streamedResponseWithClientClose(
  raw.StreamedResponse response,
  Client client,
) {
  return raw.StreamedResponse(
    _closeClientWhenDone(response.stream, client),
    response.statusCode,
    contentLength: response.contentLength,
    request: response.request,
    headers: response.headers,
    isRedirect: response.isRedirect,
    persistentConnection: response.persistentConnection,
    reasonPhrase: response.reasonPhrase,
  );
}

class Client extends raw.BaseClient {
  Client([raw.Client? inner])
      : _inner = inner ?? transport.createTransportClient(),
        _ownsInner = inner == null;

  final raw.Client _inner;
  final bool _ownsInner;

  @override
  Future<raw.StreamedResponse> send(raw.BaseRequest request) async {
    _prepareRequest(request);
    final raw.BaseRequest? networkRetryRequest = _cloneRequest(request);
    final raw.BaseRequest? authRetryRequest = _cloneRequest(request);

    final bool canSend = await _applyAuthHeader(
      request,
      forceRefresh: false,
    );
    if (!canSend) return _authRequiredStreamedResponse(request);

    final raw.StreamedResponse firstResponse = await _sendWithNetworkRetry(
      request,
      retryRequest: networkRetryRequest,
    );
    if (firstResponse.statusCode != 401 || !_isBackendUri(request.url)) {
      return firstResponse;
    }

    await _drainResponse(firstResponse);
    if (authRetryRequest == null) {
      await _handleUnauthorized();
      return _unauthorizedStreamedResponse(request);
    }

    final bool canRetry = await _applyAuthHeader(
      authRetryRequest,
      forceRefresh: true,
    );
    if (!canRetry) return _authRequiredStreamedResponse(authRetryRequest);

    final raw.BaseRequest? refreshedNetworkRetryRequest =
        _cloneRequest(authRetryRequest);
    final raw.StreamedResponse retryResponse = await _sendWithNetworkRetry(
      authRetryRequest,
      retryRequest: refreshedNetworkRetryRequest,
    );
    if (retryResponse.statusCode == 401 &&
        _isBackendUri(authRetryRequest.url)) {
      await _handleUnauthorized();
    }

    return retryResponse;
  }

  Future<raw.StreamedResponse> _sendWithNetworkRetry(
    raw.BaseRequest request, {
    required raw.BaseRequest? retryRequest,
  }) async {
    try {
      return await _sendOnce(request);
    } catch (error, stackTrace) {
      _logCaughtException(request, error, stackTrace);

      if (!_isRetryableNetworkException(error)) rethrow;

      if (retryRequest == null) {
        return _networkErrorStreamedResponse(request);
      }

      _logDebug(
        '[HTTP] retrying once after network failure: ${request.method} '
        '${request.url}',
      );

      try {
        _prepareRequest(retryRequest);
        final bool canRetry = await _applyAuthHeader(
          retryRequest,
          forceRefresh: false,
        );
        if (!canRetry) return _authRequiredStreamedResponse(retryRequest);
        return await _sendOnce(retryRequest);
      } catch (retryError, retryStackTrace) {
        _logCaughtException(retryRequest, retryError, retryStackTrace);
        if (!_isRetryableNetworkException(retryError)) rethrow;
        return _networkErrorStreamedResponse(retryRequest);
      }
    }
  }

  Future<raw.StreamedResponse> _sendOnce(raw.BaseRequest request) async {
    _logDebug(
      '[HTTP] ${request.method} ${request.url} '
      'transport=${transport.transportDebugLabel}',
    );

    final raw.StreamedResponse response =
        await _inner.send(request).timeout(_requestTimeout);

    _logDebug(
      '[HTTP] statusCode=${response.statusCode} ${request.method} '
      '${request.url}',
    );

    return response;
  }

  @override
  void close() {
    if (_ownsInner) _inner.close();
    super.close();
  }
}

Future<raw.Response> get(Uri url, {Map<String, String>? headers}) {
  return _sendUnstreamed('GET', url, headers: headers);
}

Future<raw.Response> head(Uri url, {Map<String, String>? headers}) {
  return _sendUnstreamed('HEAD', url, headers: headers);
}

Future<raw.Response> post(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
}) {
  return _sendUnstreamed(
    'POST',
    url,
    headers: headers,
    body: body,
    encoding: encoding,
  );
}

Future<raw.Response> patch(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
}) {
  return _sendUnstreamed(
    'PATCH',
    url,
    headers: headers,
    body: body,
    encoding: encoding,
  );
}

Future<raw.Response> delete(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
}) {
  return _sendUnstreamed(
    'DELETE',
    url,
    headers: headers,
    body: body,
    encoding: encoding,
  );
}

Future<raw.Response> _sendUnstreamed(
  String method,
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
}) async {
  final raw.Request request = Request(method, url);
  if (headers != null) request.headers.addAll(headers);
  if (encoding != null) request.encoding = encoding;

  if (body != null) {
    if (body is String) {
      request.body = body;
    } else if (body is List<int>) {
      request.bodyBytes = body;
    } else if (body is Map<String, String>) {
      request.bodyFields = body;
    } else {
      throw ArgumentError('Invalid request body "$body".');
    }
  }

  final raw.BaseRequest? retryRequest = _cloneRequest(request);
  final Client client = Client();
  try {
    return await _sendUnstreamedOnce(client, request);
  } catch (error, stackTrace) {
    _logCaughtException(request, error, stackTrace);

    if (!_isRetryableNetworkException(error)) rethrow;

    if (retryRequest == null) {
      return _networkErrorResponse(request);
    }

    _logDebug(
      '[HTTP] retrying once while receiving body: $method $url',
    );

    try {
      return await _sendUnstreamedOnce(client, retryRequest);
    } catch (retryError, retryStackTrace) {
      _logCaughtException(retryRequest, retryError, retryStackTrace);
      if (!_isRetryableNetworkException(retryError)) rethrow;
      return _networkErrorResponse(retryRequest);
    }
  } finally {
    client.close();
  }
}

Future<raw.Response> _sendUnstreamedOnce(
  Client client,
  raw.BaseRequest request,
) async {
  final raw.StreamedResponse streamedResponse = await client.send(request);
  final raw.Response response =
      await raw.Response.fromStream(streamedResponse).timeout(_requestTimeout);
  _logResponse(response);
  return response;
}

void _prepareRequest(raw.BaseRequest request) {
  request.persistentConnection = false;
  request.headers.putIfAbsent('Accept', () => 'application/json');
  if (transport.supportsConnectionCloseHeader) {
    request.headers['Connection'] = 'close';
  }
}

Future<bool> _applyAuthHeader(
  raw.BaseRequest request, {
  required bool forceRefresh,
}) async {
  if (!_isBackendUri(request.url)) return true;

  final String? token = await _tokenProvider().getToken(
    forceRefresh: forceRefresh,
  );
  if (token == null || token.isEmpty) return false;

  request.headers['Authorization'] = 'Bearer $token';
  return true;
}

raw.BaseRequest? _cloneRequest(raw.BaseRequest request) {
  if (request is raw.Request) {
    final raw.Request clone = Request(request.method, request.url)
      ..bodyBytes = request.bodyBytes
      ..encoding = request.encoding;
    _copyBaseRequestSettings(request, clone);
    return clone;
  }

  if (request is raw.MultipartRequest) {
    final raw.MultipartRequest clone = MultipartRequest(
      request.method,
      request.url,
    )
      ..fields.addAll(request.fields)
      ..files.addAll(request.files);
    _copyBaseRequestSettings(request, clone);
    return clone;
  }

  return null;
}

Future<void> _drainResponse(raw.StreamedResponse response) async {
  try {
    await response.stream.drain<void>().timeout(_requestTimeout);
  } catch (error, stackTrace) {
    _logCaughtException(response.request, error, stackTrace);
  }
}

void _copyBaseRequestSettings(raw.BaseRequest source, raw.BaseRequest target) {
  target.headers.addAll(source.headers);
  target.followRedirects = source.followRedirects;
  target.maxRedirects = source.maxRedirects;
  target.persistentConnection = source.persistentConnection;
}

bool _isBackendUri(Uri uri) {
  final Uri baseUri = _configuredBackendUri();

  return uri.scheme == baseUri.scheme &&
      uri.host == baseUri.host &&
      _effectivePort(uri) == _effectivePort(baseUri);
}

Uri _configuredBackendUri() {
  final String primaryBaseUrl = dotenv.env['APIS_BASE_URL']?.trim() ?? '';
  final String legacyBaseUrl = dotenv.env['API_BASE_URL']?.trim() ?? '';
  final String configuredBaseUrl =
      primaryBaseUrl.isNotEmpty ? primaryBaseUrl : legacyBaseUrl;
  if (configuredBaseUrl.isEmpty) {
    throw const AppConfigurationException(
      'The service is temporarily unavailable. Please try again later.',
    );
  }

  final String normalizedBaseUrl = configuredBaseUrl.endsWith('/')
      ? configuredBaseUrl.substring(0, configuredBaseUrl.length - 1)
      : configuredBaseUrl;
  final Uri? baseUri = Uri.tryParse(normalizedBaseUrl);
  if (baseUri == null ||
      !baseUri.hasScheme ||
      (baseUri.scheme != 'http' && baseUri.scheme != 'https') ||
      baseUri.host.isEmpty) {
    throw const AppConfigurationException(
      'The service is temporarily unavailable. Please try again later.',
    );
  }

  return baseUri;
}

int _effectivePort(Uri uri) {
  if (uri.hasPort) return uri.port;
  if (uri.scheme == 'https') return 443;
  if (uri.scheme == 'http') return 80;
  return uri.port;
}

TokenProvider _tokenProvider() {
  if (Get.isRegistered<TokenProvider>()) return TokenProvider.instance;
  return TokenProvider();
}

Future<void> _handleUnauthorized() async {
  if (Get.isRegistered<AuthService>()) {
    await AuthService.instance.handleUnauthorized();
    return;
  }

  await AuthService().handleUnauthorized();
}

bool _isRetryableNetworkException(Object error) {
  return error is TimeoutException ||
      transport.isTransportNetworkException(error);
}

raw.Response _networkErrorResponse(
  raw.BaseRequest request,
) {
  return raw.Response(
    _networkErrorBody(),
    _networkErrorStatusCode,
    request: request,
    headers: const <String, String>{
      'content-type': 'application/json',
    },
    reasonPhrase: 'Network Error',
  );
}

raw.StreamedResponse _networkErrorStreamedResponse(
  raw.BaseRequest request,
) {
  return _jsonStreamedResponse(
    request,
    _networkErrorStatusCode,
    _networkErrorBody(),
    reasonPhrase: 'Network Error',
  );
}

String _networkErrorBody() {
  return jsonEncode({
    'detail': 'Network request failed',
  });
}

raw.StreamedResponse _authRequiredStreamedResponse(raw.BaseRequest request) {
  return _jsonStreamedResponse(
    request,
    401,
    '{"detail":"Authentication required"}',
    reasonPhrase: 'Authentication Required',
  );
}

raw.StreamedResponse _unauthorizedStreamedResponse(raw.BaseRequest request) {
  return _jsonStreamedResponse(
    request,
    401,
    '{"detail":"Unauthorized"}',
    reasonPhrase: 'Unauthorized',
  );
}

raw.StreamedResponse _jsonStreamedResponse(
  raw.BaseRequest request,
  int statusCode,
  String body, {
  String? reasonPhrase,
}) {
  final List<int> bytes = utf8.encode(body);
  return raw.StreamedResponse(
    Stream<List<int>>.value(bytes),
    statusCode,
    contentLength: bytes.length,
    request: request,
    headers: const <String, String>{
      'content-type': 'application/json',
      'connection': 'close',
    },
    reasonPhrase: reasonPhrase,
  );
}

void _logResponse(raw.Response response) {
  final request = response.request;
  final bodyBytes = response.bodyBytes;
  final snippetLength = bodyBytes.length < 200 ? bodyBytes.length : 200;
  final snippet = snippetLength == 0
      ? ''
      : utf8.decode(
          bodyBytes.sublist(0, snippetLength),
          allowMalformed: true,
        );

  _logDebug(
    '[HTTP] response ${request?.method ?? ''} ${request?.url ?? ''} '
    'statusCode=${response.statusCode} bodyLength=${bodyBytes.length} '
    'bodyStart=${jsonEncode(snippet)}',
  );
}

void _logCaughtException(
  raw.BaseRequest? request,
  Object error,
  StackTrace stackTrace,
) {
  _logDebug(
    '[HTTP] exception ${request?.method ?? ''} ${request?.url ?? ''}: '
    '$error',
  );
  _logDebug(stackTrace.toString());
}

void _logDebug(String message) {
  if (kDebugMode) debugPrint(_sanitizeDebugMessage(message));
}

String _sanitizeDebugMessage(String value) {
  return value.replaceAll('\uFFFD', '?');
}

Stream<List<int>> _closeClientWhenDone(
  Stream<List<int>> stream,
  Client client,
) async* {
  try {
    await for (final List<int> chunk in stream) {
      yield chunk;
    }
  } finally {
    client.close();
  }
}
