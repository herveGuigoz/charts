import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PieChart Demo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          toolbarTextStyle: TextStyle(color: Colors.black),
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 18),
          elevation: 0,
        ),
      ),
      home: const CirularChart(),
    );
  }
}

class CirularChart extends StatelessWidget {
  const CirularChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PieChart Demo'),
      ),
      body: const Center(
        child: PieChart(
          textStyle: TextStyle(color: Colors.black, fontSize: 12),
          data: [
            PieChartData(value: 21, label: 'Resting 21%', color: Color.fromRGBO(75, 135, 185, 1)),
            PieChartData(value: 18, label: 'Speading 18%', color: Color.fromRGBO(192, 108, 132, 1)),
            PieChartData(value: 16, label: 'Cornering 16%', color: Color.fromRGBO(246, 114, 128, 1)),
            PieChartData(value: 16, label: 'Complying 16%', color: Color.fromRGBO(248, 177, 149, 1)),
            PieChartData(value: 12, label: 'Accelerating 12%', color: Color.fromRGBO(116, 180, 155, 1)),
            PieChartData(value: 17, label: 'Braking 17%', color: Color.fromRGBO(0, 168, 181, 1)),
          ],
        ),
      ),
    );
  }
}
