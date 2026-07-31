import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const OrderManagementApp());
}

class OrderManagementApp extends StatelessWidget {
  const OrderManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Order Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}