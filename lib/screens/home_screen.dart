import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../helpers/location_helper.dart';
import '../helpers/maps_launcher_helper.dart';
import '../widgets/lixo_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> locais = [];
  Position? _posicaoAtual;
  String? _localizacaoAtual;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    final carregados = await LocationHelper.carregarLocais();
    final posicao = await LocationHelper.obterLocalizacaoAtual((erro) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro)));
    });

    if (mounted) {
      setState(() {
        locais = carregados;
        _posicaoAtual = posicao;
        if (posicao != null) {
          _localizacaoAtual = 'Lat: ${posicao.latitude}, Lng: ${posicao.longitude}';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_posicaoAtual == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final locaisProximos = locais.where((local) {
      final distancia = LocationHelper.calcularDistancia(
        _posicaoAtual!.latitude,
        _posicaoAtual!.longitude,
        local['lat'].toDouble(),
        local['lng'].toDouble(),
      );
      return distancia <= 20;
    }).toList()
      ..sort((a, b) {
        final distanciaA = LocationHelper.calcularDistancia(
          _posicaoAtual!.latitude,
          _posicaoAtual!.longitude,
          a['lat'].toDouble(),
          a['lng'].toDouble(),
        );
        final distanciaB = LocationHelper.calcularDistancia(
          _posicaoAtual!.latitude,
          _posicaoAtual!.longitude,
          b['lat'].toDouble(),
          b['lng'].toDouble(),
        );
        return distanciaA.compareTo(distanciaB);
      });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Locais de Descarte'),
        backgroundColor: Colors.greenAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_localizacaoAtual != null)
              Text(
                'Sua localização: $_localizacaoAtual',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            const SizedBox(height: 24),
            const Text(
              'Locais de descarte encontrados (até 20km):',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: locaisProximos.length,
                itemBuilder: (context, index) {
                  final local = locaisProximos[index];
                  final distancia = LocationHelper.calcularDistancia(
                    _posicaoAtual!.latitude,
                    _posicaoAtual!.longitude,
                    local['lat'].toDouble(),
                    local['lng'].toDouble(),
                  );

                  return LixoCard(
                    local: local,
                    distancia: distancia,
                    onTap: () {
                      MapsLauncherHelper.abrirNoGoogleMaps(
                        context: context,
                        lat: local['lat'].toDouble(),
                        lng: local['lng'].toDouble(),
                        nome: local['name'],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
