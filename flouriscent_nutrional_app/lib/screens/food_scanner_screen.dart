import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class FoodScannerScreen extends StatefulWidget {
  const FoodScannerScreen({super.key});

  @override
  State<FoodScannerScreen> createState() => _FoodScannerScreenState();
}

class _FoodScannerScreenState extends State<FoodScannerScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isLoading = true;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _onCapturePressed() async {
    if (!mounted) return; // Early exit if disposed

    final imagePath = await _takePicture();

    if (!mounted) return; // Check again after async operation

    if (imagePath != null && mounted) {
      unawaited(Navigator.of(context as BuildContext).maybePop(imagePath));
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(firstCamera, ResolutionPreset.medium);

      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;
    } catch (e) {
      debugPrint('Camera error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String?> _takePicture() async {
    if (_isCapturing || !_controller!.value.isInitialized) return null;

    setState(() => _isCapturing = true);
    try {
      final directory = await getTemporaryDirectory();
      final path = join(directory.path, '${DateTime.now()}.png');
      await _controller!.takePicture().then((XFile file) => file.saveTo(path));
      return path;
    } catch (e) {
      debugPrint('Error taking picture: $e');
      return null;
    } finally {
      setState(() => _isCapturing = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Food'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed:
                () => _controller?.setFlashMode(
                  _controller?.value.flashMode == FlashMode.off
                      ? FlashMode.torch
                      : FlashMode.off,
                ),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(child: CameraPreview(_controller!)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FloatingActionButton(
                      onPressed: _isCapturing ? null : _onCapturePressed,
                      child:
                          _isCapturing
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Icon(Icons.camera),
                    ),
                  ),
                ],
              ),
    );
  }
}
