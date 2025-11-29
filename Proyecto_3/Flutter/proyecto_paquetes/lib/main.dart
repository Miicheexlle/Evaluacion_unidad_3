import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/package_list_screen.dart';

void main() {
  runApp(const PaquexpressApp());
}

class PaquexpressApp extends StatelessWidget {
  const PaquexpressApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Paquexpress',
        theme: ThemeData(primarySwatch: Colors.teal),
        home: const LoginScreen(),
        routes: { PackageListScreen.routeName: (_) => const PackageListScreen() },
      ),
    );
  }
}
