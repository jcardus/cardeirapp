import 'dart:developer' as dev;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image/image.dart' as img;
import '../config/cloudflare_config.dart';

class TakePhoto extends StatefulWidget {
  const TakePhoto({super.key});

  @override
  State<TakePhoto> createState() => _TakePhotoState();
}

class _TakePhotoState extends State<TakePhoto> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  XFile? _capturedImage;
  bool _isCameraInitialized = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      // Find the front camera (selfie camera)
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
      );

      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();

      setState(() {
        _capturedImage = image;
        _isUploading = true;
      });

      // Automatically upload and send SMS
      await _uploadPhoto();

      // Reset for next photo
      setState(() {
        _capturedImage = null;
      });
    } catch (e) {
      debugPrint('Error taking picture: $e');
      setState(() {
        _capturedImage = null;
        _isUploading = false;
      });
    }
  }


  Future<String> _shortenUrl(String longUrl) async {
    try {
      // Use is.gd for URL shortening (free, no API key needed)
      final response = await http.get(
        Uri.parse('https://is.gd/create.php?format=simple&url=${Uri.encodeComponent(longUrl)}'),
      );

      if (response.statusCode == 200) {
        final shortUrl = response.body.trim();
        // is.gd returns error messages starting with "Error:"
        if (!shortUrl.startsWith('Error:')) {
          return shortUrl;
        } else {
          dev.log('is.gd error: $shortUrl');
        }
      }

      dev.log('Failed to shorten URL: ${response.statusCode}');
      return longUrl;
    } catch (e) {
      dev.log('Error shortening URL: $e');
      return longUrl;
    }
  }

  Future<void> _sendSms(String message) async {
    final gwUrl = CloudflareConfig.gwUrl;
    final gwToken = CloudflareConfig.gwToken;
    final phoneNumber = CloudflareConfig.phoneNumber;
    dev.log(gwToken);
    if (gwUrl.isEmpty || gwToken.isEmpty || phoneNumber.isEmpty) {
      throw Exception('SMS gateway not configured. Please set SMS_GATEWAY_URL, SMS_GATEWAY_TOKEN, and PHONE_NUMBER in --dart-define');
    }

    final smsUrl = '$gwUrl?gateway=sns&token=$gwToken&msisdn=${Uri.encodeComponent(phoneNumber)}&message=${Uri.encodeComponent(message)}';

    dev.log('$smsUrl');

    final response = await http.get(Uri.parse(smsUrl));

    if (response.statusCode != 200) {
      throw Exception('Failed to send SMS: ${response.statusCode} - ${response.body}');
    }

    dev.log('SMS sent successfully');
  }

  Future<File> _addTextToImage(File imageFile, String text) async {
    // Read the image file
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Position text at top center
    final textY = 40;
    final textX = (image.width - (text.length * 28)) ~/ 2; // Center horizontally (rough estimate)

    // Draw text with outline effect for visibility
    // First draw black outline (shadow effect)
    for (int dx = -2; dx <= 2; dx++) {
      for (int dy = -2; dy <= 2; dy++) {
        if (dx != 0 || dy != 0) {
          img.drawString(
            image,
            text,
            font: img.arial48,
            x: textX + dx,
            y: textY + dy,
            color: img.ColorRgb8(0, 0, 0), // Black outline
          );
        }
      }
    }

    // Then draw white text on top
    img.drawString(
      image,
      text,
      font: img.arial48,
      x: textX,
      y: textY,
      color: img.ColorRgb8(255, 255, 255), // White text
    );

    // Save the modified image
    final modifiedBytes = img.encodeJpg(image, quality: 95);
    final modifiedFile = File('${imageFile.path}_modified.jpg');
    await modifiedFile.writeAsBytes(modifiedBytes);

    return modifiedFile;
  }

  Future<void> _uploadPhoto() async {
    if (_capturedImage == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final file = File(_capturedImage!.path);

      // Add text overlay to the image
      final modifiedFile = await _addTextToImage(file, 'Natal 2026');
      final bytes = await modifiedFile.readAsBytes();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(CloudflareConfig.uploadEndpoint),
      );

      dev.log('${CloudflareConfig.uploadEndpoint} ${CloudflareConfig.apiToken}');
      request.headers['Authorization'] = 'Bearer ${CloudflareConfig.apiToken}';

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: 'selfie_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        // Parse the Cloudflare Images API response
        final jsonResponse = json.decode(responseBody);

        String? imageUrl;
        if (jsonResponse['success'] == true && jsonResponse['result'] != null) {
          // Extract the image URL from the variants
          final result = jsonResponse['result'];
          if (result['variants'] != null && result['variants'].isNotEmpty) {
            imageUrl = result['variants'][0];
          }
        }

        final longUrl = imageUrl ?? 'Upload successful';

        // Shorten the URL
        final shortUrl = await _shortenUrl(longUrl);

        // Send SMS with the short URL
        await _sendSms('Recordação do Natal 2026: $shortUrl');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto enviada e SMS enviado com sucesso!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        throw Exception('Upload failed: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('Error uploading photo: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Take Selfie'),
      ),
      body: Stack(
        children: [
          _buildCameraPreview(),
          if (_isUploading)
            Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.white,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Enviando foto...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
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

  Widget _buildCameraPreview() {
    if (!_isCameraInitialized || _controller == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      children: [
        Expanded(
          child: CameraPreview(_controller!),
        ),
        Container(
          color: Colors.black,
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                onPressed: _isUploading ? null : _takePicture,
                backgroundColor: _isUploading ? Colors.grey : null,
                child: const Icon(Icons.camera),
              ),
            ],
          ),
        ),
      ],
    );
  }

}
