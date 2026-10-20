import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:ecommerce_app/app_startup.dart' deferred as app_startup;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.runStartup = false});

  final bool runStartup;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isStarting = false;
  bool _hasStartupError = false;

  @override
  void initState() {
    super.initState();
    if (!widget.runStartup) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAndOpenApp();
    });
  }

  Future<void> _initializeAndOpenApp() async {
    if (_isStarting) return;
    final startedAt = DateTime.now();
    setState(() {
      _isStarting = true;
      _hasStartupError = false;
    });

    try {
      await Future<void>.delayed(const Duration(milliseconds: 150));
      await app_startup.loadLibrary();

      if (!mounted) return;

      await app_startup.initializeAndOpenApp(startedAt);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[Startup] Splash startup failed: $error');
        debugPrint(stackTrace.toString());
      }
      if (!mounted) return;
      setState(() {
        _hasStartupError = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isStarting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            PImages.splashLogo,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          if (_hasStartupError)
            ColoredBox(
              color: Colors.black.withValues(alpha: 0.42),
              child: Center(
                child: Container(
                  width: 280,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Unable to start Peace Player',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF1C3D35),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please check your connection and try again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF64726D),
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _isStarting ? null : _initializeAndOpenApp,
                        child: Container(
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF329070),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _isStarting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Retry',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
