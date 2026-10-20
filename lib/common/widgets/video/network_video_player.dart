import 'dart:async';

import 'package:ecommerce_app/data/services/token_provider.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/helpers/media_url.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

class NetworkVideoPlayer extends StatefulWidget {
  const NetworkVideoPlayer({
    super.key,
    required this.url,
    this.isActive = true,
    this.accentColor = PColors.primary,
    this.debugLabel = 'network-video',
    this.showDebugInfo = kDebugMode,
  });

  final String url;
  final bool isActive;
  final Color accentColor;
  final String debugLabel;
  final bool showDebugInfo;

  @override
  State<NetworkVideoPlayer> createState() => _NetworkVideoPlayerState();
}

class _NetworkVideoPlayerState extends State<NetworkVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitializing = false;
  bool _hasError = false;
  bool _isMuted = true;
  String? _errorDetails;
  final List<String> _debugLines = <String>[];
  int _loadGeneration = 0;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      _initializeVideo();
    }
  }

  @override
  void didUpdateWidget(covariant NetworkVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.url != widget.url) {
      if (widget.isActive) {
        _initializeVideo();
      } else {
        _disposeController();
        _resetState();
      }
      return;
    }

    if (!oldWidget.isActive && widget.isActive) {
      _initializeVideo();
    } else if (oldWidget.isActive && !widget.isActive) {
      _disposeController();
      _resetState();
    }
  }

  Future<void> _initializeVideo() async {
    final source = MediaUrlHelper.resolve(widget.url);

    await _disposeController();
    final generation = ++_loadGeneration;

    if (!mounted || !widget.isActive) return;

    if (source.isEmpty) {
      _debug('empty video URL from imageUrl', showOnScreen: true);
      setState(() {
        _isInitializing = false;
        _hasError = true;
        _errorDetails = 'Empty video URL';
      });
      return;
    }

    setState(() {
      _isInitializing = true;
      _hasError = false;
      _errorDetails = null;
    });

    VideoPlayerController? controller;
    try {
      final sourceUri = _parseVideoUri(source);
      final headers = await _mediaHeadersFor(sourceUri);
      _logVideoSource(source, sourceUri, headers);
      unawaited(_debugMediaProbe(sourceUri, headers, generation));

      controller = VideoPlayerController.networkUrl(
        sourceUri,
        httpHeaders: headers,
      );
      _controller = controller;
      await controller.initialize();

      if (!mounted ||
          generation != _loadGeneration ||
          !widget.isActive ||
          _controller != controller) {
        if (_controller == controller) {
          _controller = null;
          await controller.dispose();
        }
        return;
      }

      await controller.setLooping(false);
      await controller.setVolume(_isMuted ? 0 : 1);
      _debug(
        'initialized size=${controller.value.size.width.toStringAsFixed(0)}x'
        '${controller.value.size.height.toStringAsFixed(0)} '
        'duration=${controller.value.duration.inMilliseconds}ms',
        showOnScreen: true,
      );
      setState(() {
        _isInitializing = false;
      });
      await _playIfActive(controller, generation);
    } catch (error, stackTrace) {
      final playerError = controller?.value.errorDescription;
      final details = _describeError(error, playerError);
      _debug('failed to load: $details', showOnScreen: true);
      _debugStack(stackTrace);
      if (!mounted || generation != _loadGeneration) return;
      await _disposeController();
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _hasError = true;
          _errorDetails = details;
        });
      }
    }
  }

  void _resetState() {
    if (!mounted) return;
    setState(() {
      _isInitializing = false;
      _hasError = false;
      _errorDetails = null;
    });
  }

  Future<void> _disposeController() async {
    _loadGeneration++;
    final controller = _controller;
    _controller = null;
    await controller?.dispose();
  }

  Future<void> _toggleMute() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    final nextMuted = !_isMuted;
    await controller.setVolume(nextMuted ? 0 : 1);
    if (mounted) {
      setState(() => _isMuted = nextMuted);
    }
  }

  Future<void> _playIfActive(
    VideoPlayerController controller,
    int generation,
  ) async {
    if (!mounted ||
        generation != _loadGeneration ||
        !widget.isActive ||
        _controller != controller ||
        !controller.value.isInitialized) {
      return;
    }

    try {
      await controller.play();
      _debug('play requested muted=$_isMuted', showOnScreen: true);
    } catch (error) {
      _debug('play failed: ${_describeError(error, null)}', showOnScreen: true);
      // Autoplay can be blocked on some platforms. The video is still loaded.
    }
  }

  Uri _parseVideoUri(String source) {
    try {
      return Uri.parse(source);
    } on FormatException {
      return Uri.parse(Uri.encodeFull(source));
    }
  }

  String _redactedSource(String source) {
    final uri = Uri.tryParse(source);
    if (uri == null || !uri.hasQuery) return source;
    return uri.replace(query: 'redacted=1').toString();
  }

  String _redactedUri(Uri uri) {
    if (!uri.hasQuery) return uri.toString();
    return uri.replace(query: 'redacted=1').toString();
  }

  void _logVideoSource(
    String source,
    Uri uri,
    Map<String, String> headers,
  ) {
    _debug(
      'source=${_redactedSource(source)}',
      showOnScreen: true,
    );
    _debug(
      'uri scheme=${uri.scheme} host=${uri.host} '
      'path=${uri.path} query=${uri.hasQuery ? 'yes' : 'no'}',
      showOnScreen: true,
    );
    _debug(
      'backendUri=${_isBackendUri(uri)} authHeader='
      '${headers.containsKey('Authorization')}',
      showOnScreen: true,
    );
  }

  Future<void> _debugMediaProbe(
    Uri uri,
    Map<String, String> headers,
    int generation,
  ) async {
    if (!kDebugMode) return;

    _debug('HEAD probe start ${_redactedUri(uri)}');
    try {
      final response = await http
          .head(uri, headers: headers)
          .timeout(const Duration(seconds: 8));
      if (!mounted || generation != _loadGeneration) return;

      final details = _responseDebugDetails(response);
      _debug('HEAD $details', showOnScreen: true);
    } catch (error) {
      if (!mounted || generation != _loadGeneration) return;
      _debug(
        'HEAD failed: ${_describeError(error, null)}',
        showOnScreen: true,
      );
    }

    await _debugRangeProbe(uri, headers, generation);
  }

  Future<void> _debugRangeProbe(
    Uri uri,
    Map<String, String> headers,
    int generation,
  ) async {
    final client = http.Client();
    try {
      final request = http.Request('GET', uri);
      request.headers.addAll(headers);
      request.headers['Range'] = 'bytes=0-1';

      final response =
          await client.send(request).timeout(const Duration(seconds: 8));
      if (!mounted || generation != _loadGeneration) return;

      final details = _streamedResponseDebugDetails(response);
      _debug('GET range $details', showOnScreen: true);
    } catch (error) {
      if (!mounted || generation != _loadGeneration) return;
      _debug(
        'GET range failed: ${_describeError(error, null)}',
        showOnScreen: true,
      );
    } finally {
      client.close();
    }
  }

  String _responseDebugDetails(http.Response response) {
    final headers = response.headers;
    final contentType = headers['content-type'] ?? 'missing';
    final contentLength = headers['content-length'] ?? 'missing';
    final acceptRanges = headers['accept-ranges'] ?? 'missing';
    final contentRange = headers['content-range'] ?? 'missing';
    final location = headers['location'];

    return 'status=${response.statusCode} content-type=$contentType '
        'content-length=$contentLength accept-ranges=$acceptRanges '
        'content-range=$contentRange'
        '${location == null ? '' : ' location=${_redactedSource(location)}'}';
  }

  String _streamedResponseDebugDetails(http.StreamedResponse response) {
    final headers = response.headers;
    final contentType = headers['content-type'] ?? 'missing';
    final contentLength = headers['content-length'] ?? 'missing';
    final acceptRanges = headers['accept-ranges'] ?? 'missing';
    final contentRange = headers['content-range'] ?? 'missing';
    final location = headers['location'];

    return 'status=${response.statusCode} content-type=$contentType '
        'content-length=$contentLength accept-ranges=$acceptRanges '
        'content-range=$contentRange'
        '${location == null ? '' : ' location=${_redactedSource(location)}'}';
  }

  String _describeError(Object error, String? playerError) {
    final suffix =
        playerError == null || playerError.isEmpty ? '' : ' player=$playerError';

    if (error is PlatformException) {
      final message = error.message;
      final details = error.details;
      return 'PlatformException code=${error.code}'
          '${message == null ? '' : ' message=$message'}'
          '${details == null ? '' : ' details=$details'}$suffix';
    }

    if (error is TimeoutException) {
      return 'TimeoutException ${error.message ?? ''}$suffix'.trim();
    }

    if (error is FormatException) {
      return 'FormatException ${error.message}$suffix';
    }

    return '${error.runtimeType}: $error$suffix';
  }

  void _debug(String message, {bool showOnScreen = false}) {
    if (!kDebugMode) return;

    final line = '[NetworkVideoPlayer][${widget.debugLabel}] $message';
    if (kDebugMode) debugPrint(line);

    if (!showOnScreen || !widget.showDebugInfo || !mounted) return;
    setState(() {
      _debugLines.add(message);
      if (_debugLines.length > 8) {
        _debugLines.removeRange(0, _debugLines.length - 8);
      }
    });
  }

  void _debugStack(StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint('[NetworkVideoPlayer][${widget.debugLabel}] $stackTrace');
    }
  }

  Future<Map<String, String>> _mediaHeadersFor(Uri uri) async {
    if (!_isBackendUri(uri)) return const <String, String>{};

    final tokenProvider = Get.isRegistered<TokenProvider>()
        ? TokenProvider.instance
        : TokenProvider();
    final token = await tokenProvider.getToken();
    if (token == null || token.isEmpty) return const <String, String>{};

    return <String, String>{
      'Authorization': 'Bearer $token',
    };
  }

  bool _isBackendUri(Uri uri) {
    final backendUri = _configuredBackendUri();
    if (backendUri == null) return false;

    return uri.scheme == backendUri.scheme &&
        uri.host == backendUri.host &&
        _effectivePort(uri) == _effectivePort(backendUri);
  }

  Uri? _configuredBackendUri() {
    final configuredBaseUrl = dotenv.env['APIS_BASE_URL']?.trim() ??
        dotenv.env['API_BASE_URL']?.trim();
    if (configuredBaseUrl == null || configuredBaseUrl.isEmpty) return null;
    final rawBaseUrl = configuredBaseUrl;

    return Uri.tryParse(rawBaseUrl.endsWith('/')
        ? rawBaseUrl.substring(0, rawBaseUrl.length - 1)
        : rawBaseUrl);
  }

  int _effectivePort(Uri uri) {
    if (uri.hasPort) return uri.port;
    if (uri.scheme == 'https') return 443;
    if (uri.scheme == 'http') return 80;
    return uri.port;
  }

  Widget _buildMessage({
    required IconData icon,
    required String message,
    String? details,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 46, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (kDebugMode &&
              widget.showDebugInfo &&
              details != null &&
              details.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                details,
                textAlign: TextAlign.center,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          if (kDebugMode &&
              widget.showDebugInfo &&
              _debugLines.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                _debugLines.join('\n'),
                textAlign: TextAlign.left,
                maxLines: 8,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 10,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInitializedPlayer(VideoPlayerController controller) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        if (value.hasError) {
          return _buildMessage(
            icon: Icons.error_outline,
            message: 'Unable to load video',
            details: value.errorDescription,
          );
        }

        final size = value.size;
        final width = size.width == 0 ? 16.0 : size.width;
        final height = size.height == 0 ? 9.0 : size.height;

        return Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: width,
                  height: height,
                  child: VideoPlayer(controller),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Material(
                color: Colors.black.withValues(alpha: 0.45),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _toggleMute,
                  child: SizedBox(
                    width: 42,
                    height: 42,
                    child: Icon(
                      _isMuted
                          ? Icons.volume_off_rounded
                          : Icons.volume_up_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    if (_hasError) {
      return _buildMessage(
        icon: Icons.error_outline,
        message: 'Unable to load video',
        details: _errorDetails,
      );
    }

    if (!widget.isActive) {
      return _buildMessage(
        icon: Icons.play_circle_outline_rounded,
        message: 'Video ready',
      );
    }

    if (_isInitializing ||
        controller == null ||
        !controller.value.isInitialized) {
      return Center(
        child: CircularProgressIndicator(color: widget.accentColor),
      );
    }

    return _buildInitializedPlayer(controller);
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }
}
