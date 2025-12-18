import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  String _latestLink = 'No deep link received yet';

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      setState(() {
        _latestLink = 'Opened via: $uri';
      });
      _handleDeepLink(uri);
    });

    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        setState(() {
          _latestLink = 'App opened via: $uri';
        });
        // Handle the initial link immediately to prevent Safari fallback
        await _handleDeepLink(uri);
      }
    } catch (e) {
      setState(() {
        _latestLink = 'Error: $e';
      });
    }
  }

  Future<void> _handleDeepLink(Uri uri) async {
    if (uri.path == '/app' || uri.host == 'app') {
      final name = uri.queryParameters['name'];
      if (name != null && name.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', name);
        if (mounted) {
          dev.log('push /$name');
          Navigator.pushNamed(context, '/$name');
        }
      }
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('CardeirApp'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Please open the app with a deep link',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Text(
                  _latestLink,
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/tio_carlitos');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Tio Carlitos'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/vizcolas');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Vizcolas'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
