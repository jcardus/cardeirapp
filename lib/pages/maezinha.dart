import 'package:cardeirapp/pages/take_photo.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;
import 'package:audioplayers/audioplayers.dart';

class MaezinhaPage extends StatefulWidget {
  const MaezinhaPage({super.key});

  @override
  State<MaezinhaPage> createState() => _MaezinhaPageState();
}

class _MaezinhaPageState extends State<MaezinhaPage> with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  AnimationController? _animationController;
  Animation<double>? _scaleAnimation;
  Animation<double>? _rotationAnimation;
  Animation<double>? _opacityAnimation;
  bool _showCelebration = false;
  bool _showError = false;
  bool _flashRed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.95), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.1), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 20),
    ]).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.05).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 80),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 10),
    ]).animate(_animationController!);
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startFlashing() {
    int flashCount = 0;
    const maxFlashes = 5;

    void flash() {
      if (flashCount < maxFlashes && mounted) {
        setState(() {
          _flashRed = !_flashRed;
        });
        flashCount++;
        Future.delayed(const Duration(milliseconds: 250), flash);
      } else {
        if (mounted) {
          setState(() {
            _flashRed = false;
            _showError = false;
          });
        }
      }
    }

    flash();
  }

  Future<void> _playSuccessSound() async {
    try {
      // Play the first sound
      await _audioPlayer.play(AssetSource('orchestral-win-331233.mp3'));

      // Wait 10 seconds, then play the second sound
      Future.delayed(const Duration(seconds: 10), () {
        _audioPlayer.play(AssetSource('good-luck-babe.mp3'));
      });
    } catch (e) {
      dev.log('Error playing sound: $e');
    }
  }

  Future<void> _playErrorSound() async {
    try {
      await _audioPlayer.play(AssetSource('error-170796.mp3'));
    } catch (e) {
      dev.log('Error playing sound: $e');
    }
  }

  void _showPhotoQuestionDialog() {
    void handleAnswer(String answer, bool isCorrect) {
      Navigator.of(context).pop();

      if (isCorrect) {
        _playSuccessSound();
        setState(() {
          _showCelebration = true;
        });

        _animationController?.forward().then((_) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() {
                _showCelebration = false;
              });
              _animationController?.reset();
            }
          });
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.celebration, color: Colors.white),
                  SizedBox(width: 10),
                  Expanded(child: Text('Resposta correta! 🎉')),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        _playErrorSound();
        setState(() {
          _showError = true;
        });

        _startFlashing();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Resposta errada!'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Onde e em que mês / ano foi tirada esta foto?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.photo_camera,
                size: 60,
                color: Colors.orange,
              ),
              const SizedBox(height: 20),
              const Text(
                'Escolhe uma opção:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.maxFinite,
                child: ElevatedButton(
                  onPressed: () => handleAnswer('Portugalia, Janeiro de 2013', false),
                  child: const Text('Portugalia, Janeiro de 2013'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.maxFinite,
                child: ElevatedButton(
                  onPressed: () => handleAnswer('Café de São Bento, Fevereiro de 2013', false),
                  child: const Text('Café de São Bento, Fevereiro de 2013'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.maxFinite,
                child: ElevatedButton(
                  onPressed: () => handleAnswer('Pabe, Janeiro de 2013', true),
                  child: const Text('Pabe, Janeiro de 2013'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.maxFinite,
                child: ElevatedButton(
                  onPressed: () => handleAnswer('Café de São Bento, Março de 2014', false),
                  child: const Text('Café de São Bento, Março de 2014'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Maezinha'),
      ),
      backgroundColor: _showError && _flashRed
          ? Colors.red.shade400
          : Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  // Celebration overlay
                  if (_showCelebration)
                    FadeTransition(
                      opacity: _opacityAnimation!,
                      child: Container(
                        width: double.infinity,
                        height: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: RadialGradient(
                            colors: [
                              Colors.yellow.withValues(alpha: 0.6),
                              Colors.orange.withValues(alpha: 0.4),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.celebration,
                            size: 100,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  // Animated image
                  AnimatedBuilder(
                    animation: _animationController!,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation!.value,
                        child: Transform.rotate(
                          angle: _rotationAnimation!.value * 3.14159,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: _showCelebration
                                      ? Colors.green.withValues(alpha: 0.5)
                                      : Colors.orange.withValues(alpha: 0.3),
                                  blurRadius: _showCelebration ? 20 : 10,
                                  offset: const Offset(0, 5),
                                  spreadRadius: _showCelebration ? 5 : 0,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                'assets/IMG_1139.JPG',
                                height: 300,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _showPhotoQuestionDialog,
                icon: const Icon(Icons.photo_camera),
                label: const Text('Onde e em que mês / ano?'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TakePhoto(),
                    ),
                  );
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Terminar'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
