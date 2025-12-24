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
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
