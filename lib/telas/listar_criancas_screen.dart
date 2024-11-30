import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ListarCriancasScreen extends StatefulWidget {
  const ListarCriancasScreen({Key? key}) : super(key: key);

  @override
  _ListarCriancasScreenState createState() => _ListarCriancasScreenState();
}

class _ListarCriancasScreenState extends State<ListarCriancasScreen> {
  late String uid;
  List<Map<String, dynamic>> kids = [];

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid; // Obtém o UID do usuário logado
    _loadKidsData(); // Carrega os dados das crianças
  }

  Future<void> _loadKidsData() async {
    try {
      // Obtém o campo 'kids' do documento do usuário logado
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      List<dynamic> kidsUids = userDoc['kids'] ?? []; // Lista de UIDs das crianças

      if (kidsUids.isEmpty) {
        setState(() {
          kids = [];
        });
        return;
      }

      // Recupera as informações das crianças usando seus UIDs
      List<Map<String, dynamic>> kidsList = [];
      for (String kidUid in kidsUids) {
        DocumentSnapshot kidDoc = await FirebaseFirestore.instance.collection('kids').doc(kidUid).get();
        if (kidDoc.exists) {
          var kidData = kidDoc.data() as Map<String, dynamic>;
          kidData['id'] = kidUid; // Adiciona o UID como campo 'id'
          kidsList.add(kidData);
        }
      }

      setState(() {
        kids = kidsList; // Atualiza a lista de crianças
      });
    } catch (e) {
      print('Erro ao carregar dados das crianças: $e');
    }
  }

  // Função para excluir uma criança
  Future<void> _deleteKid(String kidUid) async {
    try {
      // Deleta o documento da criança na coleção 'kids'
      await FirebaseFirestore.instance.collection('kids').doc(kidUid).delete();

      // Remove o UID da criança do array 'kids' do documento do usuário
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'kids': FieldValue.arrayRemove([kidUid]),
      });

      // Atualiza a lista de crianças
      setState(() {
        kids.removeWhere((kid) => kid['id'] == kidUid);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Criança excluída com sucesso!')),
      );
    } catch (e) {
      print('Erro ao excluir criança: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao excluir criança')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Crianças'),
        backgroundColor: Color(0xFFF9F9F9), 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: kids.isEmpty
            ? const Center(child: Text('Nenhuma criança cadastrada.'))
            : ListView.builder(
                itemCount: kids.length,
                itemBuilder: (context, index) {
                  var kid = kids[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Color(0xFF4CAF50), width: 2), // Borda verde
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      title: Text(kid['f_name'] ?? 'Nome não disponível', style: const TextStyle(color: Color(0xFF4CAF50), fontSize: 16, fontWeight: FontWeight.normal)),
                      subtitle: Text('Idade: ${kid['age'] ?? 'Desconhecida'}\nTelefone: ${kid['phone'] ?? 'Desconhecido'}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Color(0xFF4CAF50)),
                        onPressed: () {
                          _deleteKid(kid['id']); // Chama a função de exclusão
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
