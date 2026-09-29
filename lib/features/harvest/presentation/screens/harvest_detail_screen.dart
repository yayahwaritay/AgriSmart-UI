import 'package:flutter/material.dart';

import '../../domain/entities/harvest_prediction.dart';
import '../widgets/harvest_result_card.dart';

/// Read-only reopen of a saved `GET /harvest/history` entry.
class HarvestDetailScreen extends StatelessWidget {
  const HarvestDetailScreen({super.key, required this.prediction});

  final HarvestPrediction prediction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: const Text('Prediction')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [HarvestResultCard(prediction: prediction)],
        ),
      ),
    );
  }
}
