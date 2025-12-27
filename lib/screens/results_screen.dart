import 'package:flutter/material.dart';
import '../services/pcso_api_service.dart';
import '../models/lotto_result.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final PcsoApiService _apiService = PcsoApiService();
  List<LottoResult> _results = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchResults();
  }

  Future<void> _fetchResults() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await _apiService.getLiveResults();
      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PCSO Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchResults,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading results'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _fetchResults,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_results.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('No results available'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchResults,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline),
                      const SizedBox(width: 8),
                      Text(
                        "Today's Pick 3 Source",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_apiService.getPick3GameLabel()} (9PM Draw)',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Latest Results',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._results.map((result) => _buildResultCard(result)),
        ],
      ),
    );
  }

  Widget _buildResultCard(LottoResult result) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getGameColor(result.game),
          child: Text(
            _getGameAbbrev(result.game),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          result.game,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(result.draw),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            result.formattedNumbers,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Color _getGameColor(String game) {
    if (game.contains('2D')) return Colors.orange;
    if (game.contains('3D')) return Colors.purple;
    if (game.contains('6/45')) return Colors.green;
    if (game.contains('6/49')) return Colors.blue;
    if (game.contains('6/55')) return Colors.red;
    if (game.contains('6/58')) return Colors.teal;
    return Colors.grey;
  }

  String _getGameAbbrev(String game) {
    if (game.contains('2D')) return '2D';
    if (game.contains('3D')) return '3D';
    if (game.contains('6/45')) return '45';
    if (game.contains('6/49')) return '49';
    if (game.contains('6/55')) return '55';
    if (game.contains('6/58')) return '58';
    return '??';
  }
}
