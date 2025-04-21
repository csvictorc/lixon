import 'package:flutter/material.dart';

class LixoCard extends StatelessWidget {
  final Map<String, dynamic> local;
  final double distancia;
  final VoidCallback onTap;

  const LixoCard({
    super.key,
    required this.local,
    required this.distancia,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.place),
        title: Text(local['name']),
        subtitle: Text('Distância: ${distancia.toStringAsFixed(2)} km'),
        onTap: onTap,
      ),
    );
  }
}
