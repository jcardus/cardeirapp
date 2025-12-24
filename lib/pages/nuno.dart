import 'package:cardeirapp/pages/take_photo.dart';
import 'package:flutter/material.dart';

class NunoPage extends StatefulWidget {
  const NunoPage({super.key});

  @override
  State<NunoPage> createState() => _NunoPageState();
}

class _NunoPageState extends State<NunoPage> {
  int _currentQuestion = 0;
  bool _showGift = false;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Gostas de tirar fotografias?',
      'answers': ['Sim', 'Não', 'Às vezes'],
    },
    {
      'question': 'Já tiraste uma selfie num sítio estranho?',
      'answers': ['Sim', 'Não', 'Talvez'],
    },
    {
      'question': 'O que achas de ter mais estabilidade nas tuas fotos?',
      'answers': ['Ótimo!', 'Interessante', 'Porquê?'],
    },
  ];

  void _answerQuestion(int answerIndex) {
    setState(() {
      if (_currentQuestion < _questions.length - 1) {
        _currentQuestion++;
      } else {
        _showGift = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Nuno'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _showGift ? _buildGiftReveal() : _buildQuestion(),
        ),
      ),
    );
  }

  Widget _buildQuestion() {
    final question = _questions[_currentQuestion];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade300,
                Colors.blue.shade600,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(
            Icons.card_giftcard,
            size: 80,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 40),
        Text(
          'Pergunta ${_currentQuestion + 1} de ${_questions.length}',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          question['question'],
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        ...List.generate(
          (question['answers'] as List<String>).length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _answerQuestion(index),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 20,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: Text((question['answers'] as List<String>)[index]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGiftReveal() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.celebration,
          size: 100,
          color: Colors.amber,
        ),
        const SizedBox(height: 30),
        const Text(
          'Parabéns!',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'A tua prenda é:',
          style: TextStyle(
            fontSize: 20,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue.shade200, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              const Icon(
                Icons.camera_alt,
                size: 60,
                color: Colors.blue,
              ),
              const SizedBox(height: 20),
              const Text(
                'Amazon Basics\nTrípode Flexible',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Text(
                'Perfeito para as tuas fotografias!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
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
          label: const Text('Tirar Selfie'),
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
            setState(() {
              _currentQuestion = 0;
              _showGift = false;
            });
          },
          icon: const Icon(Icons.replay),
          label: const Text('Recomeçar'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 15,
            ),
            textStyle: const TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }
}
