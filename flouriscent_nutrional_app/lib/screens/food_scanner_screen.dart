import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

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
  FlashMode _currentFlashMode = FlashMode.off;
  bool _showScanningOverlay = false;
  String _debugInfo = '';

  // TensorFlow Lite
  Interpreter? _interpreter;
  List<String>? _labels;
  final int _inputSize = 224; // Standard input size for most models
  final int _numResults = 5;

  void _updateDebugInfo(String info) {
    debugPrint(info);
    setState(() {
      _debugInfo += '$info\n';
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeResources();
  }

  Future<void> _initializeResources() async {
    try {
      _updateDebugInfo('Starting initialization...');

      await _initializeCamera();
      _updateDebugInfo('Camera initialized successfully');

      await _loadModel();
      _updateDebugInfo('Model loading completed');
    } catch (e) {
      _updateDebugInfo('Initialization error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadModel() async {
    try {
      _updateDebugInfo('Loading TensorFlow Lite model...');

      // Load model
      _interpreter = await Interpreter.fromAsset('assets/models/food.tflite');
      _updateDebugInfo('Model loaded successfully');

      // Load labels
      final labelsData = await rootBundle.loadString(
        'assets/models/labels.txt',
      );
      _labels =
          labelsData.split('\n').where((label) => label.isNotEmpty).toList();
      _updateDebugInfo('Loaded ${_labels!.length} labels');

      // Get model input/output info
      final inputTensors = _interpreter!.getInputTensors();
      final outputTensors = _interpreter!.getOutputTensors();

      _updateDebugInfo('Input shape: ${inputTensors.first.shape}');
      _updateDebugInfo('Output shape: ${outputTensors.first.shape}');

      setState(() => _isModelLoaded = true);
      _updateDebugInfo('✓ Model initialization complete!');
    } catch (e) {
      _updateDebugInfo('✗ Error loading model: $e');
      setState(() => _isModelLoaded = false);
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _updateDebugInfo('No cameras available');
        return;
      }

      final firstCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        firstCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;
      _updateDebugInfo('Camera initialized successfully');
    } catch (e) {
      _updateDebugInfo('Camera initialization error: $e');
      rethrow;
    }
  }

  Future<void> _onCapturePressed() async {
    if (!mounted || _isCapturing) return;

    setState(() {
      _showScanningOverlay = true;
      _debugInfo = 'Starting capture...\n';
    });

    await Future.delayed(const Duration(milliseconds: 300));

    final imagePath = await _takePicture();
    if (!mounted || imagePath == null) {
      setState(() => _showScanningOverlay = false);
      return;
    }

    setState(() {
      _capturedImagePath = imagePath;
      _results = null;
    });

    await _classifyImage(imagePath);
    if (mounted) {
      setState(() => _showScanningOverlay = false);
    }
  }

  // New method to load test image
  Future<void> _loadTestImage() async {
    if (!mounted || _isCapturing) return;

    setState(() {
      _showScanningOverlay = true;
      _debugInfo = 'Loading test image...\n';
    });

    try {
      // Load the image from assets
      final byteData = await rootBundle.load('assets/food_test.jpg');
      final bytes = byteData.buffer.asUint8List();

      // Save to temporary directory
      final directory = await getTemporaryDirectory();
      final path = join(directory.path, 'food_test.jpg');
      await File(path).writeAsBytes(bytes);

      setState(() {
        _capturedImagePath = path;
        _results = null;
      });

      await _classifyImage(path);
    } catch (e) {
      _updateDebugInfo('Error loading test image: $e');
    } finally {
      if (mounted) {
        setState(() => _showScanningOverlay = false);
      }
    }
  }

  Future<String?> _takePicture() async {
    if (_controller?.value.isInitialized != true) {
      _updateDebugInfo('Camera not initialized');
      return null;
    }

    setState(() => _isCapturing = true);
    try {
      final directory = await getTemporaryDirectory();
      final path = join(
        directory.path,
        '${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final XFile file = await _controller!.takePicture();
      await file.saveTo(path);

      _updateDebugInfo('Picture saved to: $path');
      return path;
    } catch (e) {
      _updateDebugInfo('Error taking picture: $e');
      return null;
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  Future<void> _classifyImage(String imagePath) async {
    if (!_isModelLoaded || _interpreter == null || _labels == null) {
      _updateDebugInfo("Model not loaded - cannot classify");
      return;
    }

    try {
      _updateDebugInfo("Starting classification for: $imagePath");

      // Read and decode image
      final imageBytes = await File(imagePath).readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image == null) {
        _updateDebugInfo("Failed to decode image");
        return;
      }

      // Resize image to model input size
      final resizedImage = img.copyResize(
        image,
        width: _inputSize,
        height: _inputSize,
      );

      // Convert to the correct input format (uint8)
      final input = _imageToInput(resizedImage);

      // Prepare output - check if your model outputs float32 or uint8
      // Most classification models output float32, so keep this as double
      final output = List.generate(1, (_) => List.filled(_labels!.length, 0.0));

      _updateDebugInfo("Running inference...");

      // Run inference
      _interpreter!.run(input, output);

      // Process results
      final results = <Map<String, dynamic>>[];
      final outputList = output[0] as List<double>;

      for (int i = 0; i < outputList.length; i++) {
        if (i < _labels!.length) {
          results.add({
            'label': _formatLabel(_labels![i]),
            'confidence': outputList[i],
          });
        }
      }

      // Sort by confidence
      results.sort(
        (a, b) =>
            (b['confidence'] as double).compareTo(a['confidence'] as double),
      );

      // Take top results
      final topResults = results.take(_numResults).toList();

      _updateDebugInfo(
        "Classification complete - ${topResults.length} results",
      );

      if (mounted) {
        setState(() => _results = topResults);
      }

      // Log results
      for (var result in topResults) {
        final confidence = (result['confidence'] as double) * 100;
        _updateDebugInfo(
          "${result['label']}: ${confidence.toStringAsFixed(2)}%",
        );
      }
    } catch (e) {
      _updateDebugInfo("Classification error: $e");
      if (mounted) {
        setState(() {
          _results = [
            {
              'label': 'Classification error: ${e.toString()}',
              'confidence': 0.0,
            },
          ];
        });
      }
    }
  }

  List<List<List<List<int>>>> _imageToInput(img.Image image) {
    final input = List.generate(
      1,
      (_) => List.generate(
        _inputSize,
        (_) => List.generate(_inputSize, (_) => List.filled(3, 0)),
      ),
    );

    for (int i = 0; i < _inputSize; i++) {
      for (int j = 0; j < _inputSize; j++) {
        final pixel = image.getPixel(j, i);

        // Keep pixel values as integers (0-255) for uint8 input
        input[0][i][j][0] = img.getRed(pixel);
        input[0][i][j][1] = img.getGreen(pixel);
        input[0][i][j][2] = img.getBlue(pixel);
      }
    }

    return input;
  }

  String _formatLabel(String rawLabel) {
    return rawLabel
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .toLowerCase()
        .split(' ')
        .map(
          (word) =>
              word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '',
        )
        .join(' ');
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final newMode =
          _currentFlashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
      await _controller!.setFlashMode(newMode);
      setState(() => _currentFlashMode = newMode);
    } catch (e) {
      _updateDebugInfo('Error toggling flash: $e');
    }
  }

  Widget _buildCameraPreview(BuildContext context) {
    return Stack(
      children: [
        if (_controller != null && _controller!.value.isInitialized)
          CameraPreview(_controller!),

        // Camera overlay
        Center(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withOpacity(0.8),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.width * 0.8,
          ),
        ),

        // Scanning overlay
        if (_showScanningOverlay)
          Container(
            color: Colors.black.withOpacity(0.7),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Analyzing Food...',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Bottom guidance
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Text(
            'Center your food in the frame',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              shadows: [Shadow(color: Colors.black, blurRadius: 5)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
    if (_results == null || _results!.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detection Results:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._results!
              .take(5)
              .map(
                (result) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          result['label']?.toString() ?? 'Unknown',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${((result['confidence'] as double) * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildDebugInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bug_report, color: Colors.orange, size: 16),
              const SizedBox(width: 8),
              const Text(
                'Debug Info:',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.clear, color: Colors.white, size: 16),
                onPressed: () => setState(() => _debugInfo = ''),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: SingleChildScrollView(
              child: Text(
                _debugInfo.isEmpty ? 'No debug info yet...' : _debugInfo,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text('Initializing camera and model...'),
              const SizedBox(height: 20),
              if (_debugInfo.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _debugInfo,
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    if (!_isModelLoaded) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 50, color: Colors.red),
              const SizedBox(height: 20),
              const Text(
                'Model failed to load',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _loadModel,
                child: const Text('Retry Loading Model'),
              ),
              const SizedBox(height: 20),
              _buildDebugInfo(),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Scanner'),
        actions: [
          IconButton(
            icon: Icon(
              _currentFlashMode == FlashMode.off
                  ? Icons.flash_off
                  : Icons.flash_on,
            ),
            onPressed: _toggleFlash,
          ),
          // Add test button to app bar
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: _loadTestImage,
            tooltip: 'Load test image',
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child:
                _controller?.value.isInitialized == true
                    ? _buildCameraPreview(context)
                    : const Center(child: Text('Camera not available')),
          ),

          // Captured image thumbnail
          if (_capturedImagePath != null)
            Positioned(
              top: 20,
              right: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(_capturedImagePath!),
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ),

          // Debug info (top left)
          Positioned(top: 20, left: 20, right: 100, child: _buildDebugInfo()),

          // Results and capture button
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (_results != null) _buildResults(),
                const SizedBox(height: 16),
                FloatingActionButton(
                  onPressed: _isCapturing ? null : _onCapturePressed,
                  backgroundColor: Theme.of(context).primaryColor,
                  child:
                      _isCapturing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Icon(Icons.camera, size: 32),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _interpreter?.close();
    super.dispose();
  }
}
