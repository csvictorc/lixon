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
      final lat = (local['lat'] is String) ? double.tryParse(local['lat']) : local['lat'];
      final lng = (local['lng'] is String) ? double.tryParse(local['lng']) : local['lng'];

      if (lat == null || lng == null) return false;

      final distancia = LocationHelper.calcularDistancia(
        _posicaoAtual!.latitude,
        _posicaoAtual!.longitude,
        lat.toDouble(),
        lng.toDouble(),
      );
      return distancia <= _distanciaMaxima;
    }).toList()
      ..sort((a, b) {
        final latA = (a['lat'] is String) ? double.tryParse(a['lat']) : a['lat'];
        final lngA = (a['lng'] is String) ? double.tryParse(a['lng']) : a['lng'];
        final latB = (b['lat'] is String) ? double.tryParse(b['lat']) : b['lat'];
        final lngB = (b['lng'] is String) ? double.tryParse(b['lng']) : b['lng'];

        if (latA == null || lngA == null) return 1;
        if (latB == null || lngB == null) return -1;

        final distanciaA = LocationHelper.calcularDistancia(
          _posicaoAtual!.latitude,
          _posicaoAtual!.longitude,
          latA.toDouble(),
          lngA.toDouble(),
        );
        final distanciaB = LocationHelper.calcularDistancia(
          _posicaoAtual!.latitude,
          _posicaoAtual!.longitude,
          latB.toDouble(),
          lngB.toDouble(),
        );
        return distanciaA.compareTo(distanciaB);
      });

    setState(() {
      _locaisFiltrados = locaisProximos.take(_numeroResultadosMaximos).toList();
    });
  }


  @override
  Widget build(BuildContext context) {

    final Color corPrimaria = Colors.green;
    final Color corTextoPrimario = Colors.white;

    if (_posicaoAtual == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: corPrimaria)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: corPrimaria,
        surfaceTintColor: corPrimaria,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Sobre os resultados'),
                  content: const Text(
                    'Este projeto foi desenvolvido por uma pessoa e pode apresentar resultados imprecisos. '
                        'Recomenda-se sempre confirmar as informações com o estabelecimento por telefone ou email antes de se deslocar até o local.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Entendi'),
                    ),
                  ],
                );
              },
            );
          },
          tooltip: 'Ajuda',
          color: corTextoPrimario,
        ),
        title: Text(
          'Locais próximos:',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: corTextoPrimario,
          ),
        ),
        iconTheme: IconThemeData(
          color: corTextoPrimario,
        ),
        actionsIconTheme: IconThemeData(
          color: corTextoPrimario,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _mostrarMenuFiltros(context, corPrimaria, corTextoPrimario);
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
              child: _locaisFiltrados.isEmpty
                  ? const Center(child: Text("Nenhum local encontrado com os filtros atuais."))
                  : ListView.builder(
                itemCount: _locaisFiltrados.length,
                itemBuilder: (context, index) {
                  final local = _locaisFiltrados[index];

                  final lat = (local['lat'] is String) ? double.tryParse(local['lat']) : local['lat'];
                  final lng = (local['lng'] is String) ? double.tryParse(local['lng']) : local['lng'];

                  if (lat == null || lng == null) {

                    return const SizedBox.shrink();
                  }

                  final distancia = LocationHelper.calcularDistancia(
                    _posicaoAtual!.latitude,
                    _posicaoAtual!.longitude,
                    lat.toDouble(),
                    lng.toDouble(),
                  );

                  return LixoCard(
                    local: local,
                    distancia: distancia,
                    onTap: () {
                      MapsLauncherHelper.abrirNoGoogleMaps(
                        context: context,
                        lat: lat.toDouble(),
                        lng: lng.toDouble(),
                        nome: local['name'] ?? 'Local sem nome',
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

  void _mostrarMenuFiltros(BuildContext context, Color corPrimaria, Color corTextoBotao) {
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
                  Slider(
                    value: tempDistancia,
                    min: 1,
                    max: 50,
                    divisions: 49,
                    label: tempDistancia.toStringAsFixed(1),
                    activeColor: corPrimaria,
                    inactiveColor: corPrimaria.withOpacity(0.3),
                    onChanged: (value) {
                      setStateBottomSheet(() {
                        tempDistancia = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Text('Mostrar no máximo: $tempResultados resultados'),
                  Slider(
                    value: tempResultados.toDouble(),
                    min: 1,
                    max: 20,
                    divisions: 19,
                    label: tempResultados.toString(),
                    activeColor: corPrimaria,
                    inactiveColor: corPrimaria.withOpacity(0.3),
                    onChanged: (value) {
                      setStateBottomSheet(() {
                        tempResultados = value.toInt();
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: corPrimaria,
                      foregroundColor: corTextoBotao,
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