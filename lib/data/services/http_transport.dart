import 'package:http/http.dart' as raw;

import 'http_transport_stub.dart' if (dart.library.io) 'http_transport_io.dart'
    as transport;

raw.Client createTransportClient() => transport.createTransportClient();

bool get supportsConnectionCloseHeader =>
    transport.supportsConnectionCloseHeader;

String get transportDebugLabel => transport.transportDebugLabel;

bool isTransportNetworkException(Object error) {
  return transport.isTransportNetworkException(error);
}
