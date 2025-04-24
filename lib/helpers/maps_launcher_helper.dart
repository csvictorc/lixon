// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MapsLauncherHelper {
  static Future<void> abrirNoGoogleMaps({
    required BuildContext context,
    required double lat,
    required double lng,
    required String nome,
  }) async {
    final nomeFormatado = Uri.encodeComponent(nome);
    final url = 'https://www.google.com/maps/search/?api=1&query=$nomeFormatado@$lat,$lng';
    final uri = Uri.parse(url);

    try {
      final sucesso = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!sucesso) throw Exception();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o mapa.')),
      );
    }
  }
}
