import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../services/pcso_api_service.dart';
import '../models/bet.dart';

class AddBetScreen extends StatefulWidget {
  final String drawTime;

  const AddBetScreen({super.key, required this.drawTime});

  @override
  State<AddBetScreen> createState() => _AddBetScreenState();
}

class _AddBetScreenState extends State<AddBetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numbersController = TextEditingController();
  final _amountController = TextEditingController();

  GameType _selectedGameType = GameType.threeD;
  BetType _selectedBetType = BetType.ramble;

  @override
  void dispose() {
    _numbersController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String _getNumberHint() {
    switch (_selectedGameType) {
      case GameType.twoD:
        return 'e.g., 12-34';
      case GameType.threeD:
        return 'e.g., 1-2-3';
      case GameType.pick3:
        return 'e.g., 12-23-34';
    }
  }

  String _getGameLabel(GameType type) {
    switch (type) {
      case GameType.twoD:
        return '2D';
      case GameType.threeD:
        return '3D';
      case GameType.pick3:
        return 'Pick 3 (${PcsoApiService().getPick3GameLabel()})';
    }
  }

  void _saveBet() {
    if (_formKey.currentState!.validate()) {
      final storage = Provider.of<StorageService>(context, listen: false);
      
      final bet = Bet(
        bettorName: storage.agentName,
        gameType: _selectedGameType,
        betType: _selectedBetType,
        numbers: _numbersController.text.trim(),
        amount: double.parse(_amountController.text),
        drawTime: widget.drawTime,
        createdAt: DateTime.now(),
      );

      storage.addBet(bet);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Bet - ${widget.drawTime}'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Game Type',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SegmentedButton<GameType>(
              segments: GameType.values.map((type) => ButtonSegment(
                value: type,
                label: Text(_getGameLabel(type)),
              )).toList(),
              selected: {_selectedGameType},
              onSelectionChanged: (selected) {
                setState(() {
                  _selectedGameType = selected.first;
                  if (_selectedGameType == GameType.pick3) {
                    _selectedBetType = BetType.ramble;
                  }
                });
              },
            ),
            const SizedBox(height: 24),
            if (_selectedGameType != GameType.pick3) ...[
              const Text(
                'Bet Type',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SegmentedButton<BetType>(
                segments: const [
                  ButtonSegment(
                    value: BetType.straight,
                    label: Text('Straight (S)'),
                  ),
                  ButtonSegment(
                    value: BetType.ramble,
                    label: Text('Ramble (R)'),
                  ),
                ],
                selected: {_selectedBetType},
                onSelectionChanged: (selected) {
                  setState(() => _selectedBetType = selected.first);
                },
              ),
              const SizedBox(height: 24),
            ],
            TextFormField(
              controller: _numbersController,
              decoration: InputDecoration(
                labelText: 'Numbers',
                hintText: _getNumberHint(),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.numbers),
              ),
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter numbers';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount (₱)',
                hintText: 'e.g., 50',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _saveBet,
              icon: const Icon(Icons.save),
              label: const Text('Save Bet'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
