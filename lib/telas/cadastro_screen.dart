import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mundo_verde/telas/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> registerUser({
  required String email,
  required String password,
  required String fName,
  required String phone,
  required Position? address,
}) async {
  try {
    // Registrar o usuário no Firebase Authentication
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    
    String uid = userCredential.user!.uid; // Obter o UID do usuário registrado

    print('Usuário registrado: $uid');

    // Criar entrada no Firestore na coleção `users`
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'f_name': fName,
      'email': email,
      'phone': phone,
      'address': address != null
          ? GeoPoint(address.latitude, address.longitude)
          : null, // Salva a localização como GeoPoint
    });

    print('Dados do usuário adicionados ao Firestore.');
  } on FirebaseAuthException catch (e) {
    throw Exception('Erro no Firebase Authentication: ${e.message}');
  } catch (e) {
    throw Exception('Erro ao salvar no Firestore: $e');
  }
}

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({Key? key}) : super(key: key);

  @override
  _CadastroScreenState createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController celularController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  
  Position? _currentPosition; // Para armazenar a localização do usuário

  // Função para obter a localização do usuário
  Future<void> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica se os serviços de localização estão habilitados
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Se os serviços de localização não estiverem habilitados, pede para o usuário ativar
      return;
    }

    // Verifica a permissão de localização
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Se a permissão for negada, solicita a permissão
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Se a permissão ainda for negada, não pode continuar
        return;
      }
    }

    // Obtém a posição atual do usuário
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });
  }

  @override
  void initState() {
    super.initState();
    _getLocation(); // Chama a função para obter a localização do usuário ao iniciar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Bem-vindo ao Mundo Verde!',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Cadastre-se para começar sua jornada sustentável',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 18,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Image.asset(
                'lib/assets/logo.png',
                height: 150,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: nomeController,
                decoration: InputDecoration(
                  labelText: 'Primeiro Nome',
                  labelStyle: const TextStyle(color: Color(0xFF4CAF50)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                      color: Color(0xFF4CAF50),
                      width: 2.0,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: celularController,
                decoration: InputDecoration(
                  labelText: 'Número de Celular',
                  labelStyle: const TextStyle(color: Color(0xFF4CAF50)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                      color: Color(0xFF4CAF50),
                      width: 2.0,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: Color(0xFF4CAF50)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                      color: Color(0xFF4CAF50),
                      width: 2.0,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: senhaController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  labelStyle: const TextStyle(color: Color(0xFF4CAF50)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                      color: Color(0xFF4CAF50),
                      width: 2.0,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  // Validação
                  if (nomeController.text.trim().isEmpty ||
                      celularController.text.trim().isEmpty ||
                      emailController.text.trim().isEmpty ||
                      senhaController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Por favor, preencha todos os campos.')),
                    );
                    return;
                  }

                  // Validar se a localização foi obtida
                  if (_currentPosition == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Não foi possível obter a localização.')),
                    );
                    return;
                  }

                  try {
                    await registerUser(
                      email: emailController.text.trim(),
                      password: senhaController.text.trim(),
                      fName: nomeController.text.trim(),
                      phone: celularController.text.trim(),
                      address: _currentPosition,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cadastro realizado com sucesso!')),
                    );

                    // Redireciona para a tela HomeScreen apenas se o cadastro for bem-sucedido
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                    );
                  } catch (e) {
                    // Tratar erros e exibir mensagem ao usuário
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro no cadastro: $e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Cadastrar',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
