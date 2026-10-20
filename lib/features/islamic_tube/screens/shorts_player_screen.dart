import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart'
    as yt_flutter;
import 'package:youtube_player_iframe/youtube_player_iframe.dart' as yt_iframe;

class ShortsPlayerScreen extends StatefulWidget {
  final List<dynamic> shorts;
  final int initialIndex;

  const ShortsPlayerScreen({
    super.key,
    required this.shorts,
    this.initialIndex = 0,
  });

  @override
  State<ShortsPlayerScreen> createState() => _ShortsPlayerScreenState();
}

class _ShortsPlayerScreenState extends State<ShortsPlayerScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;

  // Web scroll debounce
  DateTime _lastScrollTime = DateTime.now();
  static const _scrollCooldown = Duration(milliseconds: 400);

  // Swipe state
  double _dragStartY = 0;
  bool _isAnimating = false;
  bool _swipeHandled = false; // prevent double-firing in one drag

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(
      initialPage: widget.initialIndex + (10000 * widget.shorts.length),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNext() {
    if (_isAnimating) return;
    _isAnimating = true;
    _pageController
        .nextPage(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        )
        .then((_) => _isAnimating = false);
  }

  void _goToPrevious() {
    if (_isAnimating) return;
    _isAnimating = true;
    _pageController
        .previousPage(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        )
        .then((_) => _isAnimating = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // ── PageView — driven entirely by gesture overlay ──────────────
            Listener(
              onPointerSignal: kIsWeb
                  ? (event) {
                      if (event is PointerScrollEvent) {
                        final now = DateTime.now();
                        if (now.difference(_lastScrollTime) < _scrollCooldown) return;
                        _lastScrollTime = now;
                        if (event.scrollDelta.dy > 0) {
                          _goToNext();
                        } else if (event.scrollDelta.dy < 0) {
                          _goToPrevious();
                        }
                      }
                    }
                  : null,
              child: PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentIndex = index % widget.shorts.length);
                },
                itemBuilder: (context, index) {
                  final shortIndex = index % widget.shorts.length;
                  return _ShortPlayerPage(
                    key: ValueKey('short_$shortIndex'),
                    item: widget.shorts[shortIndex],
                    isActive: _currentIndex == shortIndex,
                  );
                },
              ),
            ),

            // ── Full-screen swipe overlay ──────────────────────────────────
            // Uses RawGestureDetector so VerticalDragGestureRecognizer wins
            // the gesture arena before the YouTube native view claims it.
            //
            // Instagram logic:
            //   - No real-time page dragging (that's what made it feel "heavy")
            //   - Instead: detect intent early in onUpdate and fire immediately
            //   - Tiny thresholds: 8px distance OR 100px/s velocity = next page
            //   - _swipeHandled flag prevents double-firing per drag sequence
            //
            Positioned.fill(
              child: RawGestureDetector(
                behavior: HitTestBehavior.translucent,
                gestures: {
                  VerticalDragGestureRecognizer:
                      GestureRecognizerFactoryWithHandlers<
                          VerticalDragGestureRecognizer>(
                    () => VerticalDragGestureRecognizer(),
                    (instance) {
                      instance
                        ..onStart = (details) {
                          _dragStartY = details.globalPosition.dy;
                          _swipeHandled = false;
                        }
                        ..onUpdate = (details) {
                          if (_swipeHandled || _isAnimating) return;

                          final dragDistance =
                              details.globalPosition.dy - _dragStartY;

                          // Fire as soon as finger moves 8px in either direction
                          // This is what makes it feel like Instagram
                          if (dragDistance < -8) {
                            _swipeHandled = true;
                            _goToNext();
                          } else if (dragDistance > 8) {
                            _swipeHandled = true;
                            _goToPrevious();
                          }
                        }
                        ..onEnd = (details) {
                          if (_swipeHandled || _isAnimating) return;

                          // Fallback: catch fast flicks that ended before 8px
                          final velocity = details.primaryVelocity ?? 0;
                          if (velocity < -100) {
                            _goToNext();
                          } else if (velocity > 100) {
                            _goToPrevious();
                          }
                        };
                    },
                  ),
                },
              ),
            ),

            // ── Close button ───────────────────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            // ── Side nav arrows ────────────────────────────────────────────
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: _goToPrevious,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.3),
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_up,
                          color: _currentIndex == 0
                              ? Colors.white.withOpacity(0.3)
                              : Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _goToNext,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.3),
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: _currentIndex == widget.shorts.length - 1
                              ? Colors.white.withOpacity(0.3)
                              : Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ShortPlayerPage extends StatefulWidget {
  final dynamic item;
  final bool isActive;

  const _ShortPlayerPage({
    super.key,
    required this.item,
    required this.isActive,
  });

  @override
  State<_ShortPlayerPage> createState() => _ShortPlayerPageState();
}

class _ShortPlayerPageState extends State<_ShortPlayerPage> {
  yt_flutter.YoutubePlayerController? _flutterCtrl;
  yt_iframe.YoutubePlayerController? _webCtrl;

  String? _videoId;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void didUpdateWidget(_ShortPlayerPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.videoUrl != oldWidget.item.videoUrl) {
      _disposePlayer();
      _initializePlayer();
    } else if (widget.isActive && !oldWidget.isActive) {
      _flutterCtrl?.play();
    } else if (!widget.isActive && oldWidget.isActive) {
      _flutterCtrl?.pause();
    }
  }

  Future<void> _initializePlayer() async {
    try {
      _videoId = widget.item.videoId.isNotEmpty
          ? widget.item.videoId
          : yt_flutter.YoutubePlayer.convertUrlToId(widget.item.videoUrl ?? '');

      if (_videoId == null || _videoId!.isEmpty) {
        _setError('Invalid video URL');
        return;
      }

      if (kIsWeb) {
        _webCtrl = yt_iframe.YoutubePlayerController.fromVideoId(
          videoId: _videoId!,
          autoPlay: true,
          params: const yt_iframe.YoutubePlayerParams(
            showControls: true,
            showFullscreenButton: false,
            mute: false,
            loop: true,
          ),
        );
      } else {
        _flutterCtrl = yt_flutter.YoutubePlayerController(
          initialVideoId: _videoId!,
          flags: const yt_flutter.YoutubePlayerFlags(
            autoPlay: true,
            mute: false,
            loop: true,
            enableCaption: false,
            hideControls: false,
            useHybridComposition: false, // TextureView — participates in gesture arena
          ),
        );
      }

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      _setError('Error loading video');
    }
  }

  void _setError(String message) {
    if (!mounted) return;
    setState(() {
      _hasError = true;
      _errorMessage = message;
      _isLoading = false;
    });
  }

  void _disposePlayer() {
    _flutterCtrl?.dispose();
    _flutterCtrl = null;
    _webCtrl?.close();
    _webCtrl = null;
  }

  @override
  void dispose() {
    _disposePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const SizedBox.expand(child: ColoredBox(color: Colors.black)),

        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(color: Color(0xFF329070)),
          )
        else if (_hasError)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.white, size: 64),
                const SizedBox(height: 16),
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          SizedBox.expand(
            child: kIsWeb
                ? yt_iframe.YoutubePlayer(
                    controller: _webCtrl!,
                    aspectRatio: 9 / 16,
                  )
                : yt_flutter.YoutubePlayer(
                    controller: _flutterCtrl!,
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: const Color(0xFF329070),
                    progressColors: const yt_flutter.ProgressBarColors(
                      playedColor: Color(0xFF329070),
                      handleColor: Color(0xFF60BEA8),
                    ),
                  ),
          ),

        // Title gradient overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.9),
                ],
              ),
            ),
            child: Text(
              widget.item.title ?? 'Untitled',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}

















// import 'package:flutter/material.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:get/get.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart'
//     as yt_flutter;
// import 'package:youtube_player_iframe/youtube_player_iframe.dart' as yt_iframe;

// class ShortsPlayerScreen extends StatefulWidget {
//   final List<dynamic> shorts;
//   final int initialIndex;

//   const ShortsPlayerScreen({
//     super.key,
//     required this.shorts,
//     this.initialIndex = 0,
//   });

//   @override
//   State<ShortsPlayerScreen> createState() => _ShortsPlayerScreenState();
// }

// class _ShortsPlayerScreenState extends State<ShortsPlayerScreen> {
//   late final PageController _pageController;
//   int _currentIndex = 0;
//   double _dragStartPosition = 0;
//   double _dragDistance = 0;
//   DateTime _dragStartTime = DateTime.now();
//   final double _swipeThreshold = 10.0; // small threshold for distance
//   final double _velocityThreshold = 300.0; // pixels per second for fast swipe

//   @override
//   void initState() {
//     super.initState();
//     _currentIndex = widget.initialIndex;

//     _pageController = PageController(
//       initialPage: widget.initialIndex + (10000 * widget.shorts.length),
//     );
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 IconButton(
//                   onPressed: () => Get.back(),
//                   icon: Container(
//                     width: 40,
//                     height: 40,
//                     decoration: BoxDecoration(
//                       color: Colors.black.withOpacity(0.6),
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(Icons.close, color: Colors.white),
//                   ),
//                 ),
//                 const Spacer(),
//               ],
//             ),
//             Expanded(
//               child: Stack(
//                 children: [
//                   GestureDetector(
//                     onVerticalDragStart: (details) {
//                       _dragStartPosition = details.globalPosition.dy;
//                       _dragDistance = 0;
//                       _dragStartTime = DateTime.now();
//                     },
//                     onVerticalDragUpdate: (details) {
//                       _dragDistance = details.globalPosition.dy - _dragStartPosition;
//                     },
//                     onVerticalDragEnd: (details) {
//                       // Calculate velocity (pixels per second)
//                       final dragDuration = DateTime.now().difference(_dragStartTime);
//                       final velocity = (_dragDistance / dragDuration.inMilliseconds) * 1000;
                      
//                       // Swipe down to go to previous page (distance or velocity)
//                       if ((_dragDistance > _swipeThreshold || velocity > _velocityThreshold) && _currentIndex > 0) {
//                         _pageController.previousPage(
//                           duration: const Duration(milliseconds: 300),
//                           curve: Curves.easeInOut,
//                         );
//                       }
//                       // Swipe up to go to next page (distance or velocity)
//                       else if ((_dragDistance < -_swipeThreshold || velocity < -_velocityThreshold) && 
//                                _currentIndex < widget.shorts.length - 1) {
//                         _pageController.nextPage(
//                           duration: const Duration(milliseconds: 300),
//                           curve: Curves.easeInOut,
//                         );
//                       }
//                       _dragDistance = 0;
//                       _dragStartPosition = 0;
//                     },
//                     child: Listener(
//                       onPointerSignal: kIsWeb
//                           ? (event) {
//                               if (event is PointerScrollEvent) {
//                                 if (event.scrollDelta.dy > 20) {
//                                   _pageController.nextPage(
//                                     duration: const Duration(milliseconds: 300),
//                                     curve: Curves.easeInOut,
//                                   );
//                                 } else if (event.scrollDelta.dy < -20) {
//                                   _pageController.previousPage(
//                                     duration: const Duration(milliseconds: 300),
//                                     curve: Curves.easeInOut,
//                                   );
//                                 }
//                               }
//                             }
//                           : null,
//                       child: PageView.builder(
//                         controller: _pageController,
//                         scrollDirection: Axis.vertical,
//                         physics: kIsWeb
//                             ? const NeverScrollableScrollPhysics()
//                             : const PageScrollPhysics(),
//                         onPageChanged: (index) {
//                           final newIndex = index % widget.shorts.length;
//                           setState(() => _currentIndex = newIndex);
//                         },
//                         itemBuilder: (context, index) {
//                           final shortIndex = index % widget.shorts.length;
//                           return _ShortPlayerPage(
//                             key: ValueKey('short_$shortIndex'),
//                             item: widget.shorts[shortIndex],
//                             isActive: _currentIndex == shortIndex,
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                   Positioned(
//                     right: 16,
//                     top: 0,
//                     bottom: 0,
//                     child: Center(
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           GestureDetector(
//                             onTap: _currentIndex == 0
//                                 ? null
//                                 : () {
//                                     _pageController.previousPage(
//                                       duration:
//                                           const Duration(milliseconds: 300),
//                                       curve: Curves.easeInOut,
//                                     );
//                                   },
//                             child: Container(
//                               width: 50,
//                               height: 50,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: Colors.black.withOpacity(0.3),
//                               ),
//                               child: Icon(
//                                 Icons.keyboard_arrow_up,
//                                 color: _currentIndex == 0
//                                     ? Colors.white.withOpacity(0.3)
//                                     : Colors.white,
//                                 size: 32,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           GestureDetector(
//                             onTap: _currentIndex == widget.shorts.length - 1
//                                 ? null
//                                 : () {
//                                     _pageController.nextPage(
//                                       duration:
//                                           const Duration(milliseconds: 300),
//                                       curve: Curves.easeInOut,
//                                     );
//                                   },
//                             child: Container(
//                               width: 50,
//                               height: 50,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: Colors.black.withOpacity(0.3),
//                               ),
//                               child: Icon(
//                                 Icons.keyboard_arrow_down,
//                                 color: _currentIndex == widget.shorts.length - 1
//                                     ? Colors.white.withOpacity(0.3)
//                                     : Colors.white,
//                                 size: 32,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _ShortPlayerPage extends StatefulWidget {
//   final dynamic item;
//   final bool isActive;

//   const _ShortPlayerPage({
//     super.key,
//     required this.item,
//     required this.isActive,
//   });

//   @override
//   State<_ShortPlayerPage> createState() => _ShortPlayerPageState();
// }

// class _ShortPlayerPageState extends State<_ShortPlayerPage> {
//   yt_flutter.YoutubePlayerController? _flutterCtrl;
//   yt_iframe.YoutubePlayerController? _webCtrl;

//   String? _videoId;
//   bool _isLoading = true;
//   bool _hasError = false;
//   String _errorMessage = '';

//   @override
//   void initState() {
//     super.initState();
//     _initializePlayer();
//   }

//   @override
//   void didUpdateWidget(_ShortPlayerPage oldWidget) {
//     super.didUpdateWidget(oldWidget);

//     if (widget.item.videoUrl != oldWidget.item.videoUrl) {
//       _disposePlayer();
//       _initializePlayer();
//     } else if (widget.isActive && !oldWidget.isActive) {
//       _flutterCtrl?.play();
//     } else if (!widget.isActive && oldWidget.isActive) {
//       _flutterCtrl?.pause();
//     }
//   }

//   Future<void> _initializePlayer() async {
//     try {
//       // First try to use the videoId from the model, then fallback to extracting from URL
//       _videoId = widget.item.videoId.isNotEmpty
//           ? widget.item.videoId
//           : yt_flutter.YoutubePlayer.convertUrlToId(widget.item.videoUrl ?? '');

//       if (_videoId == null || _videoId!.isEmpty) {
//         _setError('Invalid video URL');
//         return;
//       }

//       if (kIsWeb) {
//         _webCtrl = yt_iframe.YoutubePlayerController.fromVideoId(
//           videoId: _videoId!,
//           autoPlay: true,
//           params: const yt_iframe.YoutubePlayerParams(
//             showControls: true,
//             showFullscreenButton: false,
//             mute: false,
//             loop: true,
//           ),
//         );
//       } else {
//         _flutterCtrl = yt_flutter.YoutubePlayerController(
//           initialVideoId: _videoId!,
//           flags: yt_flutter.YoutubePlayerFlags(
//             autoPlay: true,
//             mute: false,
//             loop: true,
//             enableCaption: false,
//             hideControls: false,
//             useHybridComposition: true,
//           ),
//         );
//       }

//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     } catch (e) {
//       _setError('Error loading video');
//     }
//   }

//   void _setError(String message) {
//     if (!mounted) return;
//     setState(() {
//       _hasError = true;
//       _errorMessage = message;
//       _isLoading = false;
//     });
//   }

//   void _disposePlayer() {
//     _flutterCtrl?.dispose();
//     _flutterCtrl = null;
//     _webCtrl?.close();
//     _webCtrl = null;
//   }

//   @override
//   void dispose() {
//     _disposePlayer();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         const SizedBox.expand(
//           child: ColoredBox(color: Colors.black),
//         ),
//         if (_isLoading)
//           const Center(
//             child: CircularProgressIndicator(color: Color(0xFF329070)),
//           )
//         else if (_hasError)
//           Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.error, color: Colors.white, size: 64),
//                 const SizedBox(height: 16),
//                 Text(
//                   _errorMessage,
//                   style: const TextStyle(color: Colors.white),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           )
//         else
//           SizedBox.expand(
//             child: kIsWeb
//                 ? yt_iframe.YoutubePlayer(
//                     controller: _webCtrl!,
//                     aspectRatio: 9 / 16,
//                   )
//                 : yt_flutter.YoutubePlayer(
//                     controller: _flutterCtrl!,
//                     showVideoProgressIndicator: true,
//                     progressIndicatorColor: const Color(0xFF329070),
//                     progressColors: const yt_flutter.ProgressBarColors(
//                       playedColor: Color(0xFF329070),
//                       handleColor: Color(0xFF60BEA8),
//                     ),
//                   ),
//           ),
//         Positioned(
//           bottom: 0,
//           left: 0,
//           right: 0,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   Colors.transparent,
//                   Colors.black.withOpacity(0.7),
//                   Colors.black.withOpacity(0.9),
//                 ],
//               ),
//             ),
//             child: Text(
//               widget.item.title ?? 'Untitled',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ),
//         Positioned(
//           right: 16,
//           top: 0,
//           bottom: 0,
//           child: Center(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Removed: navigation buttons belong to parent overlay
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
