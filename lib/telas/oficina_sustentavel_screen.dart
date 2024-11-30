import 'package:flutter/material.dart';
import 'perfil_screen.dart';
import 'carinho_de_caixa_de_leite_screen.dart';

class OficinaSustentavelScreen extends StatelessWidget {
  const OficinaSustentavelScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Oficina Sustentável',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.green),
                    const SizedBox(width: 4),
                    const Text(
                      '1',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.person, color: Colors.black),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PerfilScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 400,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Card centralizado
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'lib/assets/logo.png',
                            height: 80,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Fase 1',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '1/40',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Categorias organizadas em linhas alternadas
                  Column(
                    children: [
                      _buildAlignedCategoryItem(
                        context,
                        'lib/assets/carinhodeleite.png',
                        'Carinho de Caixa de Leite',
                        Colors.green,
                        alignment: Alignment.centerLeft,
                      ),
                      const SizedBox(height: 16),
                      _buildAlignedCategoryItem(
                        context,
                        'lib/assets/portalapis.png',
                        'Porta Lápis',
                        Colors.blue,
                        alignment: Alignment.centerRight,
                      ),
                      const SizedBox(height: 16),
                      _buildAlignedCategoryItem(
                        context,
                        'lib/assets/elefante.png',
                        'Elefante',
                       Colors.orange,
                        alignment: Alignment.centerLeft,
                      ),
                      const SizedBox(height: 16),
                      _buildAlignedCategoryItem(
                        context,
                        'lib/assets/campinho.png',
                        'Campo de Futebool',
                         Colors.grey,
                         alignment: Alignment.centerRight,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget para uma categoria alinhada
  Widget _buildAlignedCategoryItem(BuildContext context, String asset, String title, Color color, {required Alignment alignment}) {
    return Align(
      alignment: alignment,
      child: GestureDetector(
        onTap: () {
          if (title == 'Carinho de Caixa de Leite') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CarinhoDeCaixaDeLeiteScreen(),
              ),
            );
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  asset,
                  height: 40,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
