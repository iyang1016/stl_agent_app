import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/storage_service.dart';
import '../models/bet.dart';
import 'add_bet_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedDrawTime = '2PM';
  final List<String> _drawTimes = ['2PM', '5PM', '9PM'];

  Future<void> _openMessenger() async {
    final uri = Uri.parse('fb-messenger://');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _shareToMessenger(String content) {
    Share.share(content);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StorageService>(
      builder: (context, storage, child) {
        final bets = storage.getBetsByDrawTime(_selectedDrawTime);
        final totalAmount = bets.fold(0.0, (sum, bet) => sum + bet.amount);
        final commission = totalAmount * 0.42;
        final remit = totalAmount - commission;

        return Scaffold(
          appBar: AppBar(
            title: Text(storage.agentName),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text(
                          '📋 BETS - ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        DropdownButton<String>(
                          value: _selectedDrawTime,
                          items: _drawTimes.map((time) => DropdownMenuItem(
                            value: time,
                            child: Text(
                              time,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedDrawTime = value);
                            }
                          },
                          underline: const SizedBox(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildSummaryRow('Total Bets', '₱${totalAmount.toStringAsFixed(2)}'),
                            _buildSummaryRow('Commission (42%)', '₱${commission.toStringAsFixed(2)}'),
                            const Divider(),
                            _buildSummaryRow('Remit to STL', '₱${remit.toStringAsFixed(2)}', isBold: true),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: bets.isEmpty
                    ? const Center(
                        child: Text(
                          'No bets yet.\nTap + to add a bet.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: bets.length,
                        itemBuilder: (context, index) {
                          final bet = bets[index];
                          return _buildBetCard(bet, storage);
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: bets.isEmpty
                            ? null
                            : () {
                                final content = storage.generateFormattedBetList(_selectedDrawTime);
                                _shareToMessenger(content);
                              },
                        icon: const Icon(Icons.send),
                        label: const Text('Share to Messenger'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddBetScreen(drawTime: _selectedDrawTime),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBetCard(Bet bet, StorageService storage) {
    return Dismissible(
      key: Key(bet.key.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => storage.deleteBet(bet),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: bet.isWinner ? Colors.amber : Colors.blue.shade100,
            child: bet.isWinner
                ? const Icon(Icons.emoji_events, color: Colors.white)
                : Text(
                    bet.gameTypeLabel.substring(0, 2),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
          title: Text(
            '${bet.gameTypeLabel}: ${bet.numbers} ${bet.betTypeLabel}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('₱${bet.amount.toStringAsFixed(2)}'),
          trailing: bet.isWinner
              ? const Icon(Icons.emoji_events, color: Colors.amber, size: 28)
              : null,
        ),
      ),
    );
  }
}
