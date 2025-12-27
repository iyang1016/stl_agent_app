import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../models/bet.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StorageService>(
      builder: (context, storage, child) {
        final allBets = storage.allBets;
        
        final grouped = <String, List<Bet>>{};
        for (final bet in allBets) {
          final dateKey = DateFormat('yyyy-MM-dd').format(bet.createdAt);
          grouped.putIfAbsent(dateKey, () => []).add(bet);
        }

        final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

        return Scaffold(
          appBar: AppBar(
            title: const Text('History'),
          ),
          body: allBets.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No bet history yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedDates.length,
                  itemBuilder: (context, index) {
                    final dateKey = sortedDates[index];
                    final bets = grouped[dateKey]!;
                    final total = bets.fold(0.0, (sum, bet) => sum + bet.amount);
                    final commission = total * 0.42;
                    final date = DateTime.parse(dateKey);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            '${bets.length}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          DateFormat('EEEE, MMM d, yyyy').format(date),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Total: ₱${total.toStringAsFixed(2)} | Commission: ₱${commission.toStringAsFixed(2)}',
                        ),
                        children: bets.map((bet) => ListTile(
                          dense: true,
                          leading: Icon(
                            bet.isWinner ? Icons.emoji_events : Icons.receipt,
                            color: bet.isWinner ? Colors.amber : Colors.grey,
                          ),
                          title: Text(
                            '${bet.gameTypeLabel}: ${bet.numbers} ${bet.betTypeLabel}',
                          ),
                          subtitle: Text('${bet.drawTime} - ₱${bet.amount.toStringAsFixed(2)}'),
                        )).toList(),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
