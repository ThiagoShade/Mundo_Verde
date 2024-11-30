import 'package:flutter/material.dart';
import 'package:mundo_verde/telas/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_gemini/flutter_gemini.dart'; 

const apiKey = 'API-KEY-GEMINI'; // Chave de API Gemini

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Garante a inicialização de plugins antes do runApp

  Gemini.init(apiKey: apiKey);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Configurações do Firebase
  );
  
  runApp(const MundoVerdeApp());
}

class MundoVerdeApp extends StatelessWidget {
  const MundoVerdeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
