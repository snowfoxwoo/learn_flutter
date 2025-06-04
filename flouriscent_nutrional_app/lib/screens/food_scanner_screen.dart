import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:flutter/services.dart';

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

  Future<void> _testWithSampleImage() async {
    if (!_isModelLoaded) {
      _updateDebugInfo("Model not loaded - cannot test");
      return;
    }

    setState(() {
      _showScanningOverlay = true;
      _results = null;
      _debugInfo = 'Starting sample image test...';
    });

    try {
      // Get the image path from assets
      final byteData = await rootBundle.load('assets/test_food.jpg');
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/food_test.jpg');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      _updateDebugInfo('Sample image saved to: ${file.path}');
      _updateDebugInfo('File exists: ${await file.exists()}');
      _updateDebugInfo('File size: ${await file.length()} bytes');

      setState(() => _capturedImagePath = file.path);
      await _classifyImage(file.path);
    } catch (e) {
      _updateDebugInfo('Error testing with sample image: $e');
      if (mounted) {
        setState(() {
          _results = [
            {'label': 'Error loading sample image: $e', 'confidence': 0.0},
          ];
        });
      }
    } finally {
      if (mounted) {
        setState(() => _showScanningOverlay = false);
      }
    }
  }

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

      // Initialize camera first
      _updateDebugInfo('Initializing camera...');
      await _initializeCamera();
      _updateDebugInfo('Camera initialized successfully');

      // Then load model with timeout
      _updateDebugInfo('Loading model...');
      await _loadModel().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          _updateDebugInfo('Model loading timeout after 30 seconds');
          throw TimeoutException(
            'Model loading timeout',
            const Duration(seconds: 30),
          );
        },
      );
      _updateDebugInfo('Model loaded successfully');
    } catch (e) {
      _updateDebugInfo('Initialization error: $e');
      // Continue anyway to show debug info
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadModel() async {
    try {
      _updateDebugInfo('Attempting to load model...');

      // First close any existing model
      await Tflite.close();
      _updateDebugInfo('Closed any existing models');

      // Add timeout to the model loading
      _updateDebugInfo('Loading food.tflite with 10 second timeout...');

      String? res = await Tflite.loadModel(
        model: "assets/models/food.tflite",
        labels: "assets/models/labels.txt",
        numThreads: 1,
        isAsset: true,
        useGpuDelegate: false,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _updateDebugInfo('⏰ Model loading timed out after 10 seconds');
          throw TimeoutException(
            'Model loading timeout',
            const Duration(seconds: 10),
          );
        },
      );

      _updateDebugInfo('Model load completed with result: $res');

      if (res != null) {
        if (res == 'success' || res.toLowerCase().contains('success')) {
          if (mounted) {
            setState(() => _isModelLoaded = true);
          }
          _updateDebugInfo('✓ Model loaded successfully!');
        } else {
          _updateDebugInfo('✗ Model load failed with result: $res');
          if (mounted) {
            setState(() => _isModelLoaded = false);
          }
        }
      } else {
        _updateDebugInfo('✗ Model load returned null - likely file path issue');
        if (mounted) {
          setState(() => _isModelLoaded = false);
        }
      }
    } on TimeoutException catch (e) {
      _updateDebugInfo('⏰ Timeout: ${e.message}');
      _updateDebugInfo(
        'This usually means the model file is corrupted or incompatible',
      );
      if (mounted) {
        setState(() => _isModelLoaded = false);
      }
    } catch (e) {
      _updateDebugInfo('✗ Error loading model: $e');
      _updateDebugInfo('Error type: ${e.runtimeType}');
      if (mounted) {
        setState(() => _isModelLoaded = false);
      }
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
        ResolutionPreset
            .medium, // Changed from high to medium for better compatibility
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
        '${DateTime.now().millisecondsSinceEpoch}.jpg', // Changed to .jpg
      );

      final XFile file = await _controller!.takePicture();
      await file.saveTo(path);

      _updateDebugInfo('Picture saved to: $path');
      _updateDebugInfo('File size: ${await File(path).length()} bytes');

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
    if (!_isModelLoaded) {
      _updateDebugInfo("Model not loaded - cannot classify");
      return;
    }

    try {
      _updateDebugInfo("Starting classification for: $imagePath");

      final file = File(imagePath);
      final exists = await file.exists();
      final size = exists ? await file.length() : 0;

      _updateDebugInfo("File exists: $exists, Size: $size bytes");

      if (!exists || size == 0) {
        _updateDebugInfo("Invalid image file");
        setState(() {
          _results = [
            {'label': 'Invalid image file', 'confidence': 0.0},
          ];
        });
        return;
      }

      _updateDebugInfo("Running model inference...");

      // Try different parameter combinations for debugging
      final recognitions = await Tflite.runModelOnImage(
        path: imagePath,
        imageMean: 0.0, // Try different normalization
        imageStd: 255.0, // Try different normalization
        numResults: 10, // Get more results for debugging
        threshold:
            0.001, // Very low threshold to see if model produces any output
        asynch: true,
      );

      _updateDebugInfo("Model output received: ${recognitions != null}");
      _updateDebugInfo("Number of results: ${recognitions?.length ?? 0}");

      if (recognitions != null && recognitions.isNotEmpty) {
        _updateDebugInfo("Raw results: $recognitions");

        // Process and format results
        final processedResults =
            recognitions.map((result) {
              final label = result['label']?.toString() ?? 'Unknown';
              final confidence =
                  (result['confidence'] as num?)?.toDouble() ?? 0.0;

              return {'label': _formatLabel(label), 'confidence': confidence};
            }).toList();

        if (mounted) {
          setState(() {
            _results = processedResults;
          });
        }

        _updateDebugInfo("Processed ${processedResults.length} results");
        for (var result in processedResults) {
          final confidence = (result['confidence'] as num?) ?? 0.0;
          _updateDebugInfo(
            "${result['label']}: ${(confidence * 100).toStringAsFixed(2)}%",
          );
        }
      } else {
        _updateDebugInfo(
          "No results from model - this suggests a model compatibility issue",
        );

        // Try alternative parameters
        _updateDebugInfo("Trying alternative parameters...");
        final altRecognitions = await Tflite.runModelOnImage(
          path: imagePath,
          imageMean: 127.5,
          imageStd: 127.5,
          numResults: 5,
          threshold: 0.0,
          asynch: false, // Try synchronous
        );

        if (altRecognitions != null && altRecognitions.isNotEmpty) {
          _updateDebugInfo("Alternative params worked: $altRecognitions");
          if (mounted) {
            setState(() {
              _results =
                  altRecognitions
                      .map(
                        (r) => {
                          'label': _formatLabel(
                            r['label']?.toString() ?? 'Unknown',
                          ),
                          'confidence':
                              (r['confidence'] as num?)?.toDouble() ?? 0.0,
                        },
                      )
                      .toList();
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _results = [
                {
                  'label': 'No detection results - check model compatibility',
                  'confidence': 0.0,
                },
              ];
            });
          }
        }
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
                          '${((result['confidence'] as num?) ?? 0 * 100).toStringAsFixed(1)}%',
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
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isModelLoaded = true; // Force skip model for testing
                    _updateDebugInfo('⚠️ Model loading bypassed for testing');
                  });
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Skip Model (Test Camera Only)'),
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
            icon: const Icon(Icons.photo_library),
            onPressed: _testWithSampleImage,
            tooltip: 'Test with sample image',
          ),
          IconButton(
            icon: Icon(
              _currentFlashMode == FlashMode.off
                  ? Icons.flash_off
                  : Icons.flash_on,
            ),
            onPressed: _toggleFlash,
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
    Tflite.close();
    super.dispose();
  }
}
