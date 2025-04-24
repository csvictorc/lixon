import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int _currentStep = 0;

  final List<_StepData> _steps = [
    _StepData(
      title: "Olá",
      content:
      "Este aplicativo foi desenvolvido como parte de um projeto de extensão universitária para promover práticas sustentáveis e o descarte responsável de resíduos eletrônicos e pilhas.",
    ),
    _StepData(
      title: "Pontos de Coleta",
      content:
      "Sabia que várias lojas, principalmente as que vendem eletrônicos, também recolhem pilhas, baterias e outros lixos eletrônicos?",
    ),
    _StepData(
      title: "Faça parte da mudança",
      content:
      "Contribua com o meio ambiente e encontre locais de descarte próximos a você com apenas um toque.",
    ),
  ];

  Future<void> _finalizarIntroducao(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenWelcomeScreen', true);
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  void _proximoPasso() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      _finalizarIntroducao(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final corPrimaria = Colors.green.shade700;
    final step = _steps[_currentStep];

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'lib/assets/images/bg_welcome.jpg',
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.recycling, size: 72, color: corPrimaria),
                      const SizedBox(height: 24),
                      Text(
                        step.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        step.content,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: corPrimaria,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: _proximoPasso,
                          child: Text(
                            _currentStep < _steps.length - 1
                                ? "Próximo"
                                : "Buscar estabelecimentos",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepData {
  final String title;
  final String content;

  const _StepData({required this.title, required this.content});
}
