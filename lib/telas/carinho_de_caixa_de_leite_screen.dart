import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class CarinhoDeCaixaDeLeiteScreen extends StatefulWidget {
  const CarinhoDeCaixaDeLeiteScreen({Key? key}) : super(key: key);

  @override
  State<CarinhoDeCaixaDeLeiteScreen> createState() =>
      _CarinhoDeCaixaDeLeiteScreenState();
}

class _CarinhoDeCaixaDeLeiteScreenState
    extends State<CarinhoDeCaixaDeLeiteScreen> {
  // Links do vídeo e passo a passo
  final String youtubeLink =
      "https://www.youtube.com/watch?v=5JUCwjvGGak&list=PLooqzTcqqZvmqNkoxBojvXcqHB9jeJhxV&index=4";
  final String passoAPassoUrl =
      "https://www.artesanatopassoapassoja.com.br/carrinho-de-caixa-de-leite-passo-passo/";

  late YoutubePlayerController _controller;
  String _iaResponse = ''; // Resposta da IA

  @override
  void initState() {
    super.initState();
    // Inicializa o controlador do YouTube
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(youtubeLink)!,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Função para abrir URL
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw "Não foi possível abrir o link: $url";
    }
  }

  // Função para chamar o gemini
  Future<void> _generateTips(String age) async {
    try {
      final response = await Gemini.instance.prompt(parts: [
        Part.text(
            "Você é um assistente social para crianças de diversas idades. O seu objetivo é explicar como fazer um projeto de reciclagem de carrinho de caixa de leite. Sua primeira resposta já aparecerá para uma criança de $age anos, então ensine de forma personalizada para uma criança dessa idade"),
      ]);
      setState(() {
        _iaResponse = response?.output ??
            'Não foi possível gerar dicas no momento. Tente novamente mais tarde.';
      });
    } catch (e) {
      setState(() {
        _iaResponse = 'Erro ao gerar dicas: $e';
      });
    }
  }

  // Mostra o diálogo para inserir a idade
  void _showAgeDialog() {
    final TextEditingController ageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Insira a idade da criança"),
          content: TextField(
            controller: ageController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "Digite a idade em anos",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                final age = ageController.text.trim();
                if (age.isNotEmpty) {
                  Navigator.pop(context);
                  _generateTips(age);
                }
              },
              child: const Text("Confirmar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const double screenHeight = 800;
    const double screenWidth = 500;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Carinho de Caixa de Leite",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SizedBox(
        width: screenWidth,
        height: screenHeight,
        child: Column(
          children: [
            // Área superior com o vídeo
            SizedBox(
              width: screenWidth,
              height: screenHeight * 0.25,
              child: YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.red,
              ),
            ),
            const Divider(),
            // Menu inferior com opções
            Expanded(
              child: ListView(
                children: [
                  _buildListTile(
                    icon: Icons.info,
                    title: "Passo a Passo",
                    onTap: () => _launchUrl(passoAPassoUrl),
                  ),
                  _buildListTile(
                    icon: Icons.lightbulb,
                    title: "Passo a Passo com IA",
                    onTap: _showAgeDialog,
                  ),
                  _buildListTile(
                    icon: Icons.school,
                    title: "Materiais Necessários",
                    onTap: () {},
                  ),
                  _buildListTile(
                    icon: Icons.share,
                    title: "Compartilhar este projeto",
                    onTap: () {},
                  ),
                  _buildListTile(
                    icon: Icons.note,
                    title: "Doe este projeto para o bazar solidário Mundo Verde",
                    onTap: () {},
                  ),
                  _buildListTile(
                    icon: Icons.star_border,
                    title: "Adicionar projeto aos favoritos",
                    onTap: () {},
                  ),
                  const Divider(),
                  if (_iaResponse.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _iaResponse,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 30),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16),
      ),
      onTap: onTap,
    );
  }
}
