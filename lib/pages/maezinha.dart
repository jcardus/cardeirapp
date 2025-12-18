import 'package:cardeirapp/pages/take_photo.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;

class MaezinhaPage extends StatefulWidget {
  const MaezinhaPage({super.key});

  @override
  State<MaezinhaPage> createState() => _MaezinhaPageState();
}

class _MaezinhaPageState extends State<MaezinhaPage> {
  bool _isSending = false;

  Future<void> _sendPushoverNotification(message) async {
    setState(() {
      _isSending = true;
    });

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

      if (mounted) {
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notification sent successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to send: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      dev.log('Error sending notification: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Vizcolas'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.shade300,
                      Colors.orange.shade600,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.star,
                  size: 80,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _isSending ? null : () => _sendPushoverNotification('manda a prenda ao Viczolas'),
                icon: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.notifications),
                label: Text(_isSending ? '...' : 'Carrega aqui'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _isSending ? null : () => _sendPushoverNotification('manda o guito ao Viczolas'),
                icon: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.notifications),
                label: Text(_isSending ? 'Sending...' : 'Depois carrega aqui'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
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
