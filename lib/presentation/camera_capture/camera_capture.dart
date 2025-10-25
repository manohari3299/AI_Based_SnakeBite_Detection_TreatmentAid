import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/camera_controls_widget.dart';
import './widgets/camera_overlay_widget.dart';
import './widgets/focus_indicator_widget.dart';
import './widgets/photo_preview_widget.dart';
import './widgets/viewfinder_widget.dart';

class CameraCapture extends StatefulWidget {
  const CameraCapture({Key? key}) : super(key: key);

  @override
  State<CameraCapture> createState() => _CameraCaptureState();
}

class _CameraCaptureState extends State<CameraCapture>
    with WidgetsBindingObserver {
  // Camera Controllers
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isCapturing = false;

  // UI State
  bool _isConnected = true;
  bool _isFlashOn = false;
  bool _isTorchOn = false;
  String _compositionHint = 'Position snake in center frame';
  Color _hintColor = AppTheme.tertiaryLight;

  // Focus and Interaction
  Offset? _focusPoint;
  bool _showFocusIndicator = false;
  double _currentZoom = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 8.0;

  // Image Handling
  XFile? _capturedImage;
  String? _lastImagePath;
  final ImagePicker _imagePicker = ImagePicker();

  // Mock composition analysis data
  final List<Map<String, dynamic>> _compositionStates = [
    {
      "hint": "Move closer for better detail",
      "color": AppTheme.warningLight,
      "confidence": 0.3,
    },
    {
      "hint": "Hold steady",
      "color": AppTheme.warningLight,
      "confidence": 0.6,
    },
    {
      "hint": "Good positioning",
      "color": AppTheme.successLight,
      "confidence": 0.9,
    },
    {
      "hint": "Perfect - ready to capture",
      "color": AppTheme.successLight,
      "confidence": 1.0,
    },
  ];

  int _currentCompositionIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeApp() async {
    await _checkConnectivity();
    await _requestCameraPermission();
    await _initializeCamera();
    _startCompositionAnalysis();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = connectivityResult != ConnectivityResult.none;
    });

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (mounted) {
        setState(() {
          _isConnected = result != ConnectivityResult.none;
        });
      }
    });
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;

    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      final camera = kIsWeb
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first,
            )
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first,
            );

      _cameraController = CameraController(
        camera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (!kIsWeb) {
        _minZoom = await _cameraController!.getMinZoomLevel();
        _maxZoom = await _cameraController!.getMaxZoomLevel();
        await _cameraController!.setFocusMode(FocusMode.auto);
        await _cameraController!.setFlashMode(FlashMode.auto);
      }

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  void _startCompositionAnalysis() {
    // Simulate AI composition analysis
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _updateCompositionHint();
        _startCompositionAnalysis();
      }
    });
  }

  void _updateCompositionHint() {
    final state = _compositionStates[_currentCompositionIndex];
    setState(() {
      _compositionHint = state["hint"] as String;
      _hintColor = state["color"] as Color;
    });

    _currentCompositionIndex =
        (_currentCompositionIndex + 1) % _compositionStates.length;
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    try {
      setState(() {
        _isCapturing = true;
      });

      // Provide haptic feedback
      HapticFeedback.mediumImpact();

      final XFile photo = await _cameraController!.takePicture();

      setState(() {
        _capturedImage = photo;
        _lastImagePath = photo.path;
        _isCapturing = false;
      });

      // Brief flash overlay effect
      _showCaptureFlash();
    } catch (e) {
      setState(() {
        _isCapturing = false;
      });
      debugPrint('Photo capture error: $e');
    }
  }

  void _showCaptureFlash() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.white,
      builder: (context) => const SizedBox.shrink(),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  Future<void> _selectFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _capturedImage = image;
          _lastImagePath = image.path;
        });
      }
    } catch (e) {
      debugPrint('Gallery selection error: $e');
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || kIsWeb) return;

    try {
      final newFlashMode = _isFlashOn ? FlashMode.off : FlashMode.torch;
      await _cameraController!.setFlashMode(newFlashMode);
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      debugPrint('Flash toggle error: $e');
    }
  }

  Future<void> _toggleTorch() async {
    if (_cameraController == null || kIsWeb) return;

    try {
      final newFlashMode = _isTorchOn ? FlashMode.off : FlashMode.torch;
      await _cameraController!.setFlashMode(newFlashMode);
      setState(() {
        _isTorchOn = !_isTorchOn;
      });
    } catch (e) {
      debugPrint('Torch toggle error: $e');
    }
  }

  void _onTapToFocus(TapDownDetails details) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset localPoint = renderBox.globalToLocal(details.globalPosition);

    setState(() {
      _focusPoint = localPoint;
      _showFocusIndicator = true;
    });

    // Hide focus indicator after animation
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showFocusIndicator = false;
        });
      }
    });

    if (!kIsWeb) {
      try {
        final double x = localPoint.dx / renderBox.size.width;
        final double y = localPoint.dy / renderBox.size.height;
        _cameraController!.setFocusPoint(Offset(x, y));
        _cameraController!.setExposurePoint(Offset(x, y));
      } catch (e) {
        debugPrint('Focus setting error: $e');
      }
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_cameraController == null || kIsWeb) return;

    final double newZoom =
        (_currentZoom * details.scale).clamp(_minZoom, _maxZoom);

    if (newZoom != _currentZoom) {
      _cameraController!.setZoomLevel(newZoom);
      setState(() {
        _currentZoom = newZoom;
      });
    }
  }

  void _usePhoto() {
    if (_capturedImage != null) {
      Navigator.pushNamed(
        context,
        '/species-identification-results',
        arguments: {
          'imagePath': _capturedImage!.path,
          'timestamp': DateTime.now(),
        },
      );
    }
  }

  void _retakePhoto() {
    setState(() {
      _capturedImage = null;
    });
  }

  void _closeCamera() {
    Navigator.pushReplacementNamed(context, '/landing-page');
  }

  @override
  Widget build(BuildContext context) {
    // Show photo preview if image captured
    if (_capturedImage != null) {
      return Scaffold(
        body: PhotoPreviewWidget(
          imagePath: _capturedImage!.path,
          onUsePhoto: _usePhoto,
          onRetake: _retakePhoto,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: _isCameraInitialized
          ? Stack(
              children: [
                // Camera Preview
                Positioned.fill(
                  child: GestureDetector(
                    onTapDown: _onTapToFocus,
                    onScaleUpdate: _onScaleUpdate,
                    child: CameraPreview(_cameraController!),
                  ),
                ),

                // Top Overlay
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: CameraOverlayWidget(
                    isConnected: _isConnected,
                    isFlashOn: _isFlashOn,
                    onFlashToggle: _toggleFlash,
                    onClose: _closeCamera,
                  ),
                ),

                // Viewfinder and Composition Guide
                ViewfinderWidget(
                  compositionHint: _compositionHint,
                  hintColor: _hintColor,
                ),

                // Focus Indicator
                FocusIndicatorWidget(
                  focusPoint: _focusPoint,
                  isVisible: _showFocusIndicator,
                ),

                // Bottom Controls
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: CameraControlsWidget(
                    onCapture: _capturePhoto,
                    onGallery: _selectFromGallery,
                    onTorch: _toggleTorch,
                    isTorchOn: _isTorchOn,
                    lastImagePath: _lastImagePath,
                    isCapturing: _isCapturing,
                  ),
                ),

                // Zoom Level Indicator
                if (!kIsWeb && _currentZoom > 1.0)
                  Positioned(
                    top: 15.h,
                    right: 4.w,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_currentZoom.toStringAsFixed(1)}x',
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                  ),
              ],
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 12.w,
                    height: 12.w,
                    child: CircularProgressIndicator(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      strokeWidth: 3,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'Initializing Camera...',
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
