import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'pages/main_page.dart';
import 'pages/hello_world_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Get initial link before app starts to prevent Safari fallback
  final appLinks = AppLinks();
  final initialLink = await appLinks.getInitialLink();

  runApp(MyApp(initialLink: initialLink));
}

class MyApp extends StatelessWidget {
  final Uri? initialLink;

  const MyApp({super.key, this.initialLink});

  @override
  Widget build(BuildContext context) {
    // Determine initial route based on deeplink
    String initialRoute = '/';
    if (initialLink != null &&
        (initialLink!.path == '/app' || initialLink!.host == 'app')) {
      initialRoute = '/app';
    }

    return MaterialApp(
      title: 'CardeirApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: initialRoute,
      routes: {
        '/': (context) => const MainPage(),
        '/app': (context) => HelloWorldPage(initialLink: initialLink),
      },
    );
  }
}
