import 'package:flutter/material.dart';
import 'package:podpal/providers/pod_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({Key? key}) : super(key: key);

  @override
  _ChartsScreenState createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  bool _isLoading = true;
  List<FlSpot> _temperatureData = [];
  List<FlSpot> _humidityData = [];
  List<FlSpot> _moistureData = [];
  List<FlSpot> _waterLevelData = [];
  List<FlSpot> _nutrientLevelData = [];

  @override
  void initState() {
    super.initState();
    _fetchChartData();
  }

  double _levelStringToDouble(String? level) {
    if (level == null) return 0.0;
    switch (level.toUpperCase()) {
      case 'LOW': return 1.0;
      case 'OK': return 2.0;
      case 'HIGH': return 3.0;
      default: return 0.0;
    }
  }

  Future<void> _fetchChartData() async {
    final provider = Provider.of<PodDataProvider>(context, listen: false);
    final historicalData = await provider.getHistoricalData();

    if (mounted && historicalData.isNotEmpty) {
      List<FlSpot> tempSpots = [];
      List<FlSpot> humiditySpots = [];
      List<FlSpot> moistureSpots = [];
      List<FlSpot> waterSpots = [];
      List<FlSpot> nutrientSpots = [];

      for (var record in historicalData) {
        final timestamp = DateTime.parse(record['timestamp']);
        final xValue = timestamp.millisecondsSinceEpoch.toDouble();

        tempSpots.add(FlSpot(xValue, record['temperature']));
        humiditySpots.add(FlSpot(xValue, record['humidity']));
        moistureSpots.add(FlSpot(xValue, (record['moisture'] as int).toDouble()));
        waterSpots.add(FlSpot(xValue, _levelStringToDouble(record['water_level'])));
        nutrientSpots.add(FlSpot(xValue, _levelStringToDouble(record['nutrient_level'])));
      }

      setState(() {
        _temperatureData = tempSpots;
        _humidityData = humiditySpots;
        _moistureData = moistureSpots;
        _waterLevelData = waterSpots;
        _nutrientLevelData = nutrientSpots;
      });
    }
    if (mounted) setState(() { _isLoading = false; });
  }

  Widget _buildSensorChart(String title, List<FlSpot> data, Color lineColor) {
    if (data.isEmpty) return const SizedBox.shrink();

    final double minY = data.map((spot) => spot.y).reduce(min);
    final double maxY = data.map((spot) => spot.y).reduce(max);
    final double yBuffer = (maxY - minY).abs() < 1.0 ? 1.0 : ((maxY - minY) * 0.2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        AspectRatio(
          aspectRatio: 1.8,
          child: LineChart(
            LineChartData(
              minY: minY - yBuffer,
              maxY: maxY + yBuffer,
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 44, getTitlesWidget: (value, meta) {
                  if (value == meta.max || value == meta.min) return const SizedBox.shrink();
                  return Text(value.toStringAsFixed(1), style: const TextStyle(color: Colors.white70, fontSize: 12));
                })),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: true, border: Border.all(color: Colors.white24, width: 1)),
              lineBarsData: [
                LineChartBarData(
                  spots: data,
                  isCurved: true,
                  color: lineColor,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: true, color: lineColor.withOpacity(0.3)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLevelChart(String title, List<FlSpot> data, Color lineColor) {
    if (data.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        AspectRatio(
          aspectRatio: 1.8,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: 4,
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 44, getTitlesWidget: (value, meta) {
                  String text;
                  switch (value.toInt()) {
                    case 1: text = 'LOW'; break;
                    case 2: text = 'OK'; break;
                    case 3: text = 'HIGH'; break;
                    default: return const SizedBox.shrink();
                  }
                  return Padding(padding: const EdgeInsets.only(right: 8.0), child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)));
                })),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: true, border: Border.all(color: Colors.white24, width: 1)),
              lineBarsData: [
                LineChartBarData(
                  spots: data,
                  // --- THIS IS THE FIX ---
                  // Replaced `isStepped: true` with the correct `lineChartStepData` property.
                  lineChartStepData: const LineChartStepData(stepDirection: LineChartStepData.stepDirectionMiddle),
                  color: lineColor,
                  barWidth: 4,
                  dotData: const FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Advance Insight'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _temperatureData.isEmpty
          ? const Center(
        child: Text(
          'No historical data available yet.\nData is saved every 5 minutes.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSensorChart('Temperature (°C)', _temperatureData, Colors.amber),
            const SizedBox(height: 32),
            _buildSensorChart('Humidity (%)', _humidityData, Colors.lightBlueAccent),
            const SizedBox(height: 32),
            _buildSensorChart('Soil Moisture', _moistureData, Colors.purple.shade300),
            const SizedBox(height: 32),
            _buildLevelChart('Water Level', _waterLevelData, Colors.cyan),
            const SizedBox(height: 32),
            _buildLevelChart('Nutrient Level', _nutrientLevelData, Colors.deepOrangeAccent),
          ],
        ),
      ),
    );
  }
}