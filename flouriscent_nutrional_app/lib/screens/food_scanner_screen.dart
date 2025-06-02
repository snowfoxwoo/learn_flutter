import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:flutter_tflite/flutter_tflite.dart';

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
  List<dynamic>? _results;
  String? _capturedImagePath;
  bool _isModelLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel();
  }

  @override
  void dispose() {
    _controller?.dispose();
    Tflite.close();
    super.dispose();
  }

  Future<void> _loadModel() async {
    try {
      await Tflite.loadModel(
        model: "assets/food101.tflite",
        labels: "assets/labels.txt",
      );
      if (mounted) {
        setState(() => _isModelLoaded = true);
      }
      debugPrint('Model loaded successfully');
    } catch (e) {
      debugPrint('Error loading model: $e');
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _onCapturePressed() async {
    if (!mounted) return;

    final imagePath = await _takePicture();
    if (!mounted || imagePath == null) return;

    setState(() => _capturedImagePath = imagePath);
    await _classifyImage(imagePath);
  }

  Future<String?> _takePicture() async {
    if (_isCapturing || _controller?.value.isInitialized != true) {
      return null;
    }

    setState(() => _isCapturing = true);
    try {
      final directory = await getTemporaryDirectory();
      final path = join(directory.path, '${DateTime.now()}.png');
      final XFile file = await _controller!.takePicture();
      await file.saveTo(path);
      return path;
    } catch (e) {
      debugPrint('Error taking picture: $e');
      return null;
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  Future<void> _classifyImage(String imagePath) async {
    if (!_isModelLoaded) {
      debugPrint("Model not loaded");
      return;
    }

    try {
      final recognitions = await Tflite.runModelOnImage(
        path: imagePath,
        imageMean: 127.5,
        imageStd: 127.5,
        numResults: 3,
        threshold: 0.5,
      );

      if (mounted) {
        setState(() => _results = recognitions);
      }

      if (recognitions != null) {
        for (var result in recognitions) {
          debugPrint(
            "Label: ${result['label']}, Confidence: ${result['confidence']}",
          );
        }
      }
    } catch (e) {
      debugPrint("Error during classification: $e");
      if (mounted) {
        setState(() => _results = null);
      }
    }
  }

  void _toggleFlash() {
    final controller = _controller;
    if (controller == null) return;

    final isFlashOn = controller.value.flashMode != FlashMode.off;
    controller.setFlashMode(isFlashOn ? FlashMode.off : FlashMode.torch);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Food'),
        actions: [
          IconButton(icon: const Icon(Icons.flash_on), onPressed: _toggleFlash),
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
                      child: Center(
                        child:
                            _controller?.value.isInitialized == true
                                ? CameraPreview(_controller!)
                                : const Text('Camera not available'),
                      ),
                    ),
                  ),
                  if (_capturedImagePath != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.file(File(_capturedImagePath!), height: 100),
                    ),
                  if (_results != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            _results!
                                .map(
                                  (result) => Text(
                                    "${result['label']} - ${(result['confidence'] * 100).toStringAsFixed(1)}%",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                )
                                .toList(),
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
