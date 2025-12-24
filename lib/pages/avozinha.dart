import 'package:cardeirapp/pages/take_photo.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;

class AvozinhaPage extends StatefulWidget {
  const AvozinhaPage({super.key});

  @override
  State<AvozinhaPage> createState() => _AvozinhaPageState();
}

class _AvozinhaPageState extends State<AvozinhaPage> {
  int _currentQuestion = 0;
  bool _showGift = false;
  final List<String> _userAnswers = [];

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Gostas de ouvir música ou rádio?',
      'answers': ['Sim, muito!', 'De vez em quando', 'Raramente'],
    },
    {
      'question': 'Costumas fazer chamadas telefónicas?',
      'answers': ['Sim, frequentemente', 'Às vezes', 'Não muito'],
    },
    {
      'question': 'O que achas de ter melhor qualidade de som?',
      'answers': ['Adorava!', 'Seria bom', 'Interessante'],
    },
  ];

  Future<void> _sendPushoverNotification(String message) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.pushover.net/1/messages.json'),
        body: {
          'token': 'a2hfgtzk5sffdqz4zqxr8rbacqgev6',
          'user': 'u9wcnq1jaz5sn3j26vkwoipq5g1dus',
          'message': message
        },
      );

      dev.log('Pushover response: ${response.statusCode} - ${response.body}');
    } catch (e) {
      dev.log('Error sending notification: $e');
    }
  }

  void _answerQuestion(int answerIndex) {
    final answer = (_questions[_currentQuestion]['answers'] as List<String>)[answerIndex];
    _userAnswers.add(answer);

    setState(() {
      if (_currentQuestion < _questions.length - 1) {
        _currentQuestion++;
      } else {
        _showGift = true;
        // Send all answers via push notification
        _sendAnswersToPush();
      }
    });
  }

  void _sendAnswersToPush() {
    final message = '''Avozinha respondeu:
Q1: ${_questions[0]['question']}
A: ${_userAnswers[0]}

Q2: ${_questions[1]['question']}
A: ${_userAnswers[1]}

Q3: ${_questions[2]['question']}
A: ${_userAnswers[2]}''';

    _sendPushoverNotification(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Avozinha'),
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
                Colors.pink.shade300,
                Colors.pink.shade600,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withValues(alpha: 0.3),
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
            color: Colors.pink,
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
            color: Colors.pink.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.pink.shade200, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              const Icon(
                Icons.headphones,
                size: 60,
                color: Colors.pink,
              ),
              const SizedBox(height: 20),
              const Text(
                'Earbuds',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Text(
                'Para ouvires tudo com clareza!',
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
              _userAnswers.clear();
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