import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_screen.dart'; // We'll create this next

const String supabaseUrl = 'https://xuueajbiwueqeiijshrv.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh1dWVhamJpd3VlcWVpaWpzaHJ2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk0ODI2NjcsImV4cCI6MjA4NTA1ODY2N30.CbmalUTAM1fFnwJqSwsHTb3v8AyZp3RO7WChBjpaPLE';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timeblocking App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AuthScreen(), // Starts with auth
    );
  }
}
