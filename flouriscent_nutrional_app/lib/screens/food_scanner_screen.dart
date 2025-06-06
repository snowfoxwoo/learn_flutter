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
import 'dart:math' as math;

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
  late int _inputSize;
  final int _numResults = 5;
  late TensorType _inputType;
  late List<int> _inputShape;
  late List<int> _outputShape;

  void _updateDebugInfo(String info) {
    debugPrint(info);
    if (mounted) {
      setState(() {
        _debugInfo += '$info\n';
      });
    }
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
      final inputTensor = _interpreter!.getInputTensor(0);
      final outputTensor = _interpreter!.getOutputTensor(0);

      _inputShape = inputTensor.shape;
      _outputShape = outputTensor.shape;
      _inputType = inputTensor.type;

      // Extract input size (assuming square input like 224x224)
      _inputSize =
          _inputShape[1]; // Assuming shape is [1, height, width, channels]

      _updateDebugInfo('Input shape: $_inputShape');
      _updateDebugInfo('Input type: $_inputType');
      _updateDebugInfo('Input size: $_inputSize');
      _updateDebugInfo('Output shape: $_outputShape');

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
    if (!mounted || _isCapturing || !_isModelLoaded) return;

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

  Future<void> _loadTestImage() async {
    if (!mounted || _isCapturing || !_isModelLoaded) return;

    setState(() {
      _showScanningOverlay = true;
      _debugInfo = 'Loading test image...\n';
    });

    try {
      final byteData = await rootBundle.load('assets/food_test.jpg');
      final bytes = byteData.buffer.asUint8List();

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

      _updateDebugInfo("Original image size: ${image.width}x${image.height}");

      // Resize image to model input size
      final resizedImage = img.copyResize(
        image,
        width: _inputSize,
        height: _inputSize,
      );

      _updateDebugInfo(
        "Resized image to: ${resizedImage.width}x${resizedImage.height}",
      );

      // Convert image to appropriate input format
      final input = _imageToInput(resizedImage);
      _updateDebugInfo("Input prepared with type: ${input.runtimeType}");

      // Prepare output
      final output = _prepareOutput();
      _updateDebugInfo("Output prepared with shape: ${_outputShape}");

      // Run inference
      _interpreter!.run(input, output);
      _updateDebugInfo("Inference completed successfully");

      // Process results
      final results = _processResults(output);

      if (mounted) {
        setState(() => _results = results);
      }

      // Log top results
      for (int i = 0; i < math.min(results.length, 3); i++) {
        final result = results[i];
        final confidence = (result['confidence'] as double) * 100;
        _updateDebugInfo(
          "${result['label']}: ${confidence.toStringAsFixed(2)}%",
        );
      }
    } catch (e, stackTrace) {
      _updateDebugInfo("Classification error: $e");
      _updateDebugInfo("Stack trace: $stackTrace");
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

  dynamic _imageToInput(img.Image image) {
    _updateDebugInfo('Converting image to input format: $_inputType');

    if (_inputType == TensorType.uint8) {
      // For uint8 models (quantized) - use Uint8List for better performance
      var input = Uint8List(
        _inputShape[0] * _inputShape[1] * _inputShape[2] * _inputShape[3],
      );
      int pixelIndex = 0;

      for (int i = 0; i < _inputSize; i++) {
        for (int j = 0; j < _inputSize; j++) {
          final pixel = image.getPixel(j, i);
          input[pixelIndex++] = img.getRed(pixel);
          input[pixelIndex++] = img.getGreen(pixel);
          input[pixelIndex++] = img.getBlue(pixel);
        }
      }

      // Reshape to proper dimensions
      return input.buffer.asUint8List().reshape(_inputShape);
    } else {
      // For float32 models - use Float32List for better performance
      var input = Float32List(
        _inputShape[0] * _inputShape[1] * _inputShape[2] * _inputShape[3],
      );
      int pixelIndex = 0;

      for (int i = 0; i < _inputSize; i++) {
        for (int j = 0; j < _inputSize; j++) {
          final pixel = image.getPixel(j, i);
          input[pixelIndex++] = img.getRed(pixel) / 255.0;
          input[pixelIndex++] = img.getGreen(pixel) / 255.0;
          input[pixelIndex++] = img.getBlue(pixel) / 255.0;
        }
      }

      // Reshape to proper dimensions
      return input.buffer.asFloat32List().reshape(_inputShape);
    }
  }

  dynamic _prepareOutput() {
    final outputSize = _outputShape.reduce((a, b) => a * b);

    if (_interpreter!.getOutputTensor(0).type == TensorType.uint8) {
      return Uint8List(outputSize).reshape(_outputShape);
    } else {
      return Float32List(outputSize).reshape(_outputShape);
    }
  }

  List<Map<String, dynamic>> _processResults(dynamic output) {
    final results = <Map<String, dynamic>>[];

    // Get the output data as a flat list
    List<num> outputData;
    if (output is List) {
      outputData = _flattenOutput(output);
    } else {
      outputData = output.cast<num>();
    }

    // Convert to confidences (normalize if uint8)
    List<double> confidences;
    if (_interpreter!.getOutputTensor(0).type == TensorType.uint8) {
      confidences = outputData.map((e) => e.toDouble() / 255.0).toList();
    } else {
      confidences = outputData.map((e) => e.toDouble()).toList();
    }

    // Create results with labels
    final numResults = math.min(confidences.length, _labels!.length);
    for (int i = 0; i < numResults; i++) {
      results.add({
        'label': _formatLabel(_labels![i]),
        'confidence': confidences[i],
      });
    }

    // Sort by confidence and return top results
    results.sort(
      (a, b) =>
          (b['confidence'] as double).compareTo(a['confidence'] as double),
    );
    return results.take(_numResults).toList();
  }

  List<num> _flattenOutput(dynamic output) {
    final List<num> flattened = [];

    void flatten(dynamic item) {
      if (item is List) {
        for (var element in item) {
          flatten(element);
        }
      } else if (item is num) {
        flattened.add(item);
      }
    }

    flatten(output);
    return flattened;
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
          ..._results!.map(
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
          Positioned(top: 20, left: 20, right: 100, child: _buildDebugInfo()),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (_results != null) _buildResults(),
                const SizedBox(height: 16),
                FloatingActionButton(
                  onPressed:
                      (_isCapturing || !_isModelLoaded)
                          ? null
                          : _onCapturePressed,
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
