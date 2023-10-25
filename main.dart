import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:charts_flutter/flutter.dart' as charts;

class StockPrice {
  final DateTime timestamp;
  final double low;  // Mengganti 'price' menjadi 'terendah'

  StockPrice(this.timestamp, this.low); // Menggunakan atribut "low" (harga terendah)

  factory StockPrice.fromJson(Map<String, dynamic> json) {
    return StockPrice(
      DateTime.fromMillisecondsSinceEpoch(json['t'] * 1000),
      json['i'].toDouble(),  // Menggunakan atribut "i" (harga terendah) dan nama panggilan saya icang jadi memakai atribut "i"
    );
  }
}



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Pergerakan Harga Saham'),
        ),
        body: StockPriceChart(),
      ),
    );
  }
}

class StockPriceChart extends StatefulWidget {
  @override
  _StockPriceChartState createState() => _StockPriceChartState();
}

class _StockPriceChartState extends State<StockPriceChart> {
  List<StockPrice> stockPrices = [];

  @override
  void initState() {
    super.initState();
    loadStockPrices();
  }

  Future<void> loadStockPrices() async {
    final response = await http.get(
        Uri.parse(
            'https://api.polygon.io/v2/aggs/ticker/i/range/1/day/2023-01-09/2023-02-09?adjusted=true&sort=asc&limit=120&apiKey=nFmniBLIeZO8K4ec4MQO6WBC17lQsb7t'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body)['results'];
      List<StockPrice> prices = jsonList.map((e) => StockPrice.fromJson(e)).toList();

      setState(() {
        stockPrices = prices;
      });
    } else {
      throw Exception('Gagal memuat data harga saham');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Kode Saham: i', style: TextStyle(fontSize: 18)),
        ElevatedButton(
          onPressed: () {
            loadStockPrices();
          },
          child: Text('Refresh Data'),
        ),
        Expanded(
          child: charts.TimeSeriesChart(
            [
              charts.Series<StockPrice, DateTime>(
                id: 'Harga Terendah',
                domainFn: (StockPrice price, _) => price.timestamp,
                measureFn: (StockPrice price, _) => price.low, // Menggunakan atribut "i" (harga terendah)
                data: stockPrices,
              ),
            ],
            animate: true,
          ),
        ),
      ],
    );
  }
}