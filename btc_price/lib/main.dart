import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BTC Price',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const BtcPricePage(),
    );
  }
}

class BtcPricePage extends StatefulWidget {
  const BtcPricePage({super.key});

  @override
  State<BtcPricePage> createState() => _BtcPricePageState();
}

class _BtcPricePageState extends State<BtcPricePage> {
  String? _price;
  bool _loading = false;
  String? _error;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchPrice();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchPrice());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchPrice() async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      final response = await http.get(
        Uri.parse('https://api.binance.com/api/v3/ticker/price?symbol=BTCUSDT'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final price = double.parse(data['price']);
        setState(() {
          _price = price.toStringAsFixed(2);
          _error = null;
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'HTTP ${response.statusCode}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BTC Price')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.currency_bitcoin, size: 64, color: Colors.orange),
            const SizedBox(height: 24),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.redAccent))
            else if (_price != null)
              Text(
                '\$$_price',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              const CircularProgressIndicator(),
            const SizedBox(height: 8),
            const Text('BTCUSDT · Binance', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _loading ? null : _fetchPrice,
              icon: _loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              label: const Text('새로고침'),
            ),
          ],
        ),
      ),
    );
  }
}
