import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

class LocationHelper {
  static Future<List<dynamic>> carregarLocais() async {
    final String resposta = await rootBundle.loadString('lib/assets/locais_descarte.json');
    final data = json.decode(resposta);
    return data['msg'];
  }

  static Future<Position?> obterLocalizacaoAtual(Function(String) onError) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      onError('Por favor, habilite os serviços de localização');
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        onError('Permissão de localização negada');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      onError('Permissão de localização negada permanentemente');
      return null;
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  static double calcularDistancia(
      double lat1,
      double lon1,
      double lat2,
      double lon2,
      ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }
}
