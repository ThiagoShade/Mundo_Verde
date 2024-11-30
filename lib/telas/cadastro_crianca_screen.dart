import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> registerKid({
  required String fName,
  required int age,
  required String phone,
  required Position? address,
}) async {
  try {
    String uid = FirebaseAuth.instance.currentUser!.uid; // Obter o UID do usuário autenticado

    // Gerar UID aleatório para o documento da criança
    String kidUid = FirebaseFirestore.instance.collection('kids').doc().id;

    // Criar entrada no Firestore na coleção `kids` com o UID aleatório como ID do documento
    await FirebaseFirestore.instance.collection('kids').doc(kidUid).set({
      'f_name': fName,
      'age': age,
      'phone': phone,
      'address': address != null
          ? GeoPoint(address.latitude, address.longitude)
          : null, // Salva a localização como GeoPoint
      'id_user': uid, // Associar o UID do usuário autenticado
    });

    // Atualizar o campo 'kids' no documento do usuário logado
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'kids': FieldValue.arrayUnion([kidUid]), // Adiciona o UID da criança ao array 'kids'
    });

    print('Dados da criança adicionados ao Firestore e criança registrada no usuário.');
  } catch (e) {
    print('Erro ao salvar no Firestore: $e');
  }
}

class CadastroCriancaScreen extends StatefulWidget {
  const CadastroCriancaScreen({Key? key}) : super(key: key);

  @override
  _CadastroCriancaScreenState createState() => _CadastroCriancaScreenState();
}

class _CadastroCriancaScreenState extends State<CadastroCriancaScreen> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController idadeController = TextEditingController();
  final TextEditingController celularController = TextEditingController();
  
  Position? _currentPosition; // Para armazenar a localização da criança

  // Função para obter a localização
  Future<void> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica se os serviços de localização estão habilitados
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    // Verifica a permissão de localização
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    // Obtém a posição atual
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });
  }

  @override
  void initState() {
    super.initState();
    _getLocation(); // Chama a função para obter a localização ao iniciar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Criança'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Cadastre a Criança',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Entrada para o nome
              TextField(
                controller: nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome da Criança',
                  labelStyle: const TextStyle(color: Color(0xFF4CAF50), fontSize: 16, fontWeight: FontWeight.normal),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Color(0xFF4CAF50)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              // Entrada para a idade
              TextField(
                controller: idadeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Idade da Criança',
                  labelStyle: const TextStyle(color: Color(0xFF4CAF50), fontSize: 16, fontWeight: FontWeight.normal),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Color(0xFF4CAF50)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              // Entrada para o número de celular
              TextField(
                controller: celularController,
                decoration: InputDecoration(
                  labelText: 'Telefone para contato',
                  labelStyle: const TextStyle(color: Color(0xFF4CAF50), fontSize: 16, fontWeight: FontWeight.normal),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Color(0xFF4CAF50)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (nomeController.text.trim().isEmpty ||
                      idadeController.text.trim().isEmpty ||
                      celularController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Por favor, preencha todos os campos.')),
                    );
                    return;
                  }

                  if (_currentPosition == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Não foi possível obter a localização.')),
                    );
                    return;
                  }

                  try {
                    await registerKid(
                      fName: nomeController.text.trim(),
                      age: int.parse(idadeController.text.trim()),
                      phone: celularController.text.trim(),
                      address: _currentPosition,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cadastro realizado com sucesso!')),
                    );

                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao cadastrar criança: $e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'CADASTRAR CRIANÇA',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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
