import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HelloWorldPage extends StatefulWidget {
  final Uri? initialLink;

  const HelloWorldPage({super.key, this.initialLink});

  @override
  State<HelloWorldPage> createState() => _HelloWorldPageState();
}

class _HelloWorldPageState extends State<HelloWorldPage> {
  String? _userName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();

    // If we have an initial link with a name parameter, save it
    if (widget.initialLink != null) {
      final name = widget.initialLink!.queryParameters['name'];
      if (name != null && name.isNotEmpty) {
        await prefs.setString('user_name', name);
        setState(() {
          _userName = name;
          _isLoading = false;
        });
        return;
      }
    }

    // Otherwise load from storage
    setState(() {
      _userName = prefs.getString('user_name');
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Hello World'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _isLoading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.deepPurple.shade300,
                            Colors.deepPurple.shade600,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.waving_hand,
                            size: 60,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _userName != null
                                ? 'Hello, $_userName!'
                                : 'Hello, World!',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _userName != null
                                ? 'Your info was loaded from local storage'
                                : 'No user info found. Try opening a deeplink with a name parameter.',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'How to test:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            '1. Use a deeplink like:',
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 5),
                          SelectableText(
                            'cardeirapp://hello?name=John',
                            style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'monospace',
                              color: Colors.deepPurple[700],
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'or',
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 5),
                          SelectableText(
                            'https://cardeira.org/app/hello?name=John',
                            style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'monospace',
                              color: Colors.deepPurple[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}