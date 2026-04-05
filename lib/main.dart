import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_screen.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://zuvtmjevpdkcmqhjgapi.supabase.co",
    anonKey: "sb_publishable_mPonKRdjVJJoloDh_q4-og_W9sSv3c9", 
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gem Store',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: supabase.auth.currentSession == null 
          ? const AuthScreen() 
          : const HomeScreen(),
    );
  }
}