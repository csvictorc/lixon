import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/location_helper.dart';
import '../helpers/maps_launcher_helper.dart';
import '../widgets/lixo_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _locais = [];
  Position? _posicaoAtual;

  double _distanciaMaxima = 10.0;
  int _numeroResultadosMaximos = 10;

  List<dynamic> _locaisFiltrados = [];

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _carregarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _distanciaMaxima = prefs.getDouble('distanciaMaxima') ?? 10.0;
      _numeroResultadosMaximos = prefs.getInt('numeroResultadosMaximos') ?? 10;
    });
  }

  Future<void> _salvarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('distanciaMaxima', _distanciaMaxima);
    await prefs.setInt('numeroResultadosMaximos', _numeroResultadosMaximos);
  }

  Future<void> _inicializar() async {
    await _carregarPreferencias();

    final carregados = await LocationHelper.carregarLocais();
    final posicao = await LocationHelper.obterLocalizacaoAtual((erro) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro)));
      }
    });

    if (mounted) {
      setState(() {
        _locais = carregados;
        _posicaoAtual = posicao;
        _filtrarLocais();
      });
    }
  }

  void _filtrarLocais() {
    if (_posicaoAtual == null) {
      setState(() {
        _locaisFiltrados = [];
      });
      return;
    }

    final locaisProximos = _locais.where((local) {
      final distancia = LocationHelper.calcularDistancia(
        _posicaoAtual!.latitude,
        _posicaoAtual!.longitude,
        local['lat'].toDouble(),
        local['lng'].toDouble(),
      );
      return distancia <= _distanciaMaxima;
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

    setState(() {
      _locaisFiltrados = locaisProximos.take(_numeroResultadosMaximos).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_posicaoAtual == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green,
        surfaceTintColor: Colors.green,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
        ),
        centerTitle: true,
        //--------------------
        title: Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: 'Locais próximos',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          style: TextStyle(
            fontSize: 20,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        actionsIconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _mostrarMenuFiltros(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _locaisFiltrados.length,
                itemBuilder: (context, index) {
                  final local = _locaisFiltrados[index];
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

  void _mostrarMenuFiltros(BuildContext context) {
    double tempDistancia = _distanciaMaxima;
    int tempResultados = _numeroResultadosMaximos;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateBottomSheet) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 16.0,
                  right: 16.0,
                  top: 16.0
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Filtros',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text('Distância máxima: ${tempDistancia.toStringAsFixed(1)} km'),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.green,
                      inactiveTrackColor: Colors.green.shade100,
                      thumbColor: Colors.green,
                      overlayColor: Colors.green.withAlpha(32),
                      valueIndicatorColor: Colors.green,
                    ),
                    child: Slider(
                      value: tempDistancia,
                      min: 1,
                      max: 50,
                      divisions: 49,
                      label: tempDistancia.toStringAsFixed(1),
                      onChanged: (value) {
                        setStateBottomSheet(() {
                          tempDistancia = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Mostrar no máximo: $tempResultados resultados'),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.green,
                      inactiveTrackColor: Colors.green.shade100,
                      thumbColor: Colors.green,
                      overlayColor: Colors.green.withAlpha(32),
                      valueIndicatorColor: Colors.green,
                    ),
                    child: Slider(
                      value: tempResultados.toDouble(),
                      min: 1,
                      max: 20,
                      divisions: 19,
                      label: tempResultados.toString(),
                      onChanged: (value) {
                        setStateBottomSheet(() {
                          tempResultados = value.toInt();
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Salvar'),
                    onPressed: () {
                      setState(() {
                        _distanciaMaxima = tempDistancia;
                        _numeroResultadosMaximos = tempResultados;
                        _filtrarLocais();
                        _salvarPreferencias();
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Preferências salvas!'), duration: Duration(seconds: 2),)
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
}