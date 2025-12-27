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

  void _shareToMessenger(String content) {
    Share.share(content);
  }

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).colorScheme.secondary;
    final blue = Theme.of(context).colorScheme.primary;

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
                icon: const Icon(Icons.settings_outlined),
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [blue.withOpacity(0.3), blue.withOpacity(0.1)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('📋 BETS - ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          DropdownButton<String>(
                            value: _selectedDrawTime,
                            dropdownColor: const Color(0xFF2C2C2C),
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: gold),
                            items: _drawTimes.map((time) => DropdownMenuItem(
                              value: time,
                              child: Text(time),
                            )).toList(),
                            onChanged: (value) {
                              if (value != null) setState(() => _selectedDrawTime = value);
                            },
                            underline: const SizedBox(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [const Color(0xFF1E1E1E), const Color(0xFF2C2C2C)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: gold.withOpacity(0.3), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: gold.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildSummaryRow('💵 Total Bets', '₱${totalAmount.toStringAsFixed(2)}', gold),
                          const Divider(height: 24, color: Colors.white24),
                          _buildSummaryRow('📌 Commission (42%)', '₱${commission.toStringAsFixed(2)}', Colors.greenAccent),
                          const SizedBox(height: 8),
                          _buildSummaryRow('📤 Remit to STL', '₱${remit.toStringAsFixed(2)}', Colors.white, isBold: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: bets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade700),
                            const SizedBox(height: 16),
                            Text(
                              'No bets for $_selectedDrawTime\nTap + to add a bet',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: bets.length,
                        itemBuilder: (context, index) => _buildBetCard(bets[index], storage, gold, blue),
                      ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, -2))],
                ),
                child: SafeArea(
                  child: ElevatedButton.icon(
                    onPressed: bets.isEmpty
                        ? null
                        : () {
                            final content = storage.generateFormattedBetList(_selectedDrawTime);
                            _shareToMessenger(content);
                          },
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Share to Messenger', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gold,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddBetScreen(drawTime: _selectedDrawTime)),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Bet'),
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value, Color valueColor, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: isBold ? 22 : 16,
          ),
        ),
      ],
    );
  }

  Widget _buildBetCard(Bet bet, StorageService storage, Color gold, Color blue) {
    return Dismissible(
      key: Key(bet.key.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade700,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => storage.deleteBet(bet),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF1E1E1E), const Color(0xFF252525)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: bet.isWinner ? gold : blue.withOpacity(0.3),
            width: bet.isWinner ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: bet.isWinner ? gold.withOpacity(0.2) : blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: bet.isWinner
                    ? Icon(Icons.emoji_events, color: gold, size: 28)
                    : Text(
                        bet.gameTypeLabel.length > 2 
                            ? bet.gameTypeLabel.substring(0, 2) 
                            : bet.gameTypeLabel,
                        style: TextStyle(
                          color: blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${bet.gameTypeLabel}: ${bet.numbers} ${bet.betTypeLabel}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₱${bet.amount.toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  ),
                ],
              ),
            ),
            if (bet.isWinner)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: gold,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '🏆 WIN',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
