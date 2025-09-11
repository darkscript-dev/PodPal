import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:podpal/providers/pod_data_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _developerModeEnabled = false;

  // State variables for all manual thresholds
  List<double> _lightThresholdOpen = [400, 400, 400];
  double _wateringThreshold = 500;
  double _wateringDurationMs = 3000;
  double _lowHumidityWateringThreshold = 40;
  double _lightOnHour = 8;
  double _lightOffHour = 22;
  double _fanOnHumidity = 75;
  double _fanOnTemperature = 29;
  double _nutrientOnHour = 12;
  double _nutrientDurationMs = 1500;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncStateWithProvider();
    });
  }

  void _syncStateWithProvider() {
    final provider = Provider.of<PodDataProvider>(context, listen: false);
    final lastPlan = provider.lastAiPlan;
    if (lastPlan != null) {
      setState(() {
        _lightThresholdOpen = (lastPlan['light_threshold_open'] as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList() ?? _lightThresholdOpen;
        // REMOVED: Sync logic for the unused light_threshold_close.
        _fanOnHumidity = (lastPlan['fan_on_humidity'] as num?)?.toDouble() ?? _fanOnHumidity;
        _fanOnTemperature = (lastPlan['fan_on_temperature'] as num?)?.toDouble() ?? _fanOnTemperature;
        _wateringThreshold = (lastPlan['watering_threshold'] as num?)?.toDouble() ?? _wateringThreshold;
        _wateringDurationMs = (lastPlan['watering_duration_ms'] as num?)?.toDouble() ?? _wateringDurationMs;
        _lowHumidityWateringThreshold = (lastPlan['low_humidity_watering_threshold'] as num?)?.toDouble() ?? _lowHumidityWateringThreshold;
        _lightOnHour = (lastPlan['light_on_hour'] as num?)?.toDouble() ?? _lightOnHour;
        _lightOffHour = (lastPlan['light_off_hour'] as num?)?.toDouble() ?? _lightOffHour;
        _nutrientOnHour = (lastPlan['nutrient_on_hour'] as num?)?.toDouble() ?? _nutrientOnHour;
        _nutrientDurationMs = (lastPlan['nutrient_duration_ms'] as num?)?.toDouble() ?? _nutrientDurationMs;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.redAccent : Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 24.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        ),
      );
    }
  }

  Future<void> _resetApp() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1C1C1E),
          title: const Text('Confirm Reset'),
          content: const Text('Are you sure you want to reset the app? All your plant profiles and settings will be deleted.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Reset', style: TextStyle(color: Colors.redAccent)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      final provider = Provider.of<PodDataProvider>(context, listen: false);
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      provider.resetState();
      Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
    }
  }

  Widget _buildSlider({
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$title: ${value.round()}', style: const TextStyle(color: Colors.white)),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: value.round().toString(),
          onChanged: onChanged,
          activeColor: Colors.amber,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PodDataProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: const Text('Developer Mode', style: TextStyle(color: Colors.white, fontSize: 18)),
            subtitle: const Text('Manually control Pod thresholds', style: TextStyle(color: Colors.white70)),
            value: _developerModeEnabled,
            onChanged: (bool value) => setState(() => _developerModeEnabled = value),
            activeColor: Colors.amber,
          ),
          const Divider(color: Colors.white24),

          if (_developerModeEnabled) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Manual Thresholds', style: TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold)),
            ),

            // Light Threshold Sliders
            const Text("Light Threshold Open (LDR)", style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic)),
            _buildSlider(title: 'Left Panel [1]', value: _lightThresholdOpen[0], min: 0, max: 1023, divisions: 50, onChanged: (v) => setState(() => _lightThresholdOpen[0] = v)),
            _buildSlider(title: 'Right Panel [2]', value: _lightThresholdOpen[1], min: 0, max: 1023, divisions: 50, onChanged: (v) => setState(() => _lightThresholdOpen[1] = v)),
            _buildSlider(title: 'Back Panel [3]', value: _lightThresholdOpen[2], min: 0, max: 1023, divisions: 50, onChanged: (v) => setState(() => _lightThresholdOpen[2] = v)),
            const Divider(color: Colors.white24, height: 32),


            // Climate & Watering Sliders
            _buildSlider(title: 'Fan On Humidity (%)', value: _fanOnHumidity, min: 50, max: 90, divisions: 40, onChanged: (v) => setState(() => _fanOnHumidity = v)),
            _buildSlider(title: 'Fan On Temperature (°C)', value: _fanOnTemperature, min: 20, max: 35, divisions: 15, onChanged: (v) => setState(() => _fanOnTemperature = v)),
            _buildSlider(title: 'Watering Threshold (Soil)', value: _wateringThreshold, min: 300, max: 800, divisions: 50, onChanged: (v) => setState(() => _wateringThreshold = v)),
            _buildSlider(title: 'Watering Duration (ms)', value: _wateringDurationMs, min: 1000, max: 10000, divisions: 90, onChanged: (v) => setState(() => _wateringDurationMs = v)),
            _buildSlider(title: 'Low Humidity Water Threshold (%)', value: _lowHumidityWateringThreshold, min: 20, max: 60, divisions: 40, onChanged: (v) => setState(() => _lowHumidityWateringThreshold = v)),
            const Divider(color: Colors.white24, height: 32),

            // Light Schedule Sliders
            _buildSlider(title: 'Light On Hour (0-23)', value: _lightOnHour, min: 0, max: 23, divisions: 23, onChanged: (v) => setState(() => _lightOnHour = v)),
            _buildSlider(title: 'Light Off Hour (0-23)', value: _lightOffHour, min: 0, max: 23, divisions: 23, onChanged: (v) => setState(() => _lightOffHour = v)),
            const Divider(color: Colors.white24, height: 32),

            // Nutrient Schedule Sliders
            _buildSlider(title: 'Nutrient Dosing Hour (0-23)', value: _nutrientOnHour, min: 0, max: 23, divisions: 23, onChanged: (v) => setState(() => _nutrientOnHour = v)),
            _buildSlider(title: 'Nutrient Dosing Duration (ms)', value: _nutrientDurationMs, min: 500, max: 5000, divisions: 45, onChanged: (v) => setState(() => _nutrientDurationMs = v)),

            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                onPressed: () {
                  final manualPlan = {
                    "light_threshold_open": _lightThresholdOpen.map((d) => d.round()).toList(),
                    "fan_on_humidity": _fanOnHumidity.round(),
                    "fan_on_temperature": _fanOnTemperature.round(),
                    "watering_threshold": _wateringThreshold.round(),
                    "watering_duration_ms": _wateringDurationMs.round(),
                    "low_humidity_watering_threshold": _lowHumidityWateringThreshold.round(),
                    "light_on_hour": _lightOnHour.round(),
                    "light_off_hour": _lightOffHour.round(),
                    "nutrient_on_hour": _nutrientOnHour.round(),
                    "nutrient_duration_ms": _nutrientDurationMs.round()
                  };
                  provider.sendManualPlan(manualPlan)
                      .then((_) => _showSnackBar('Manual plan sent successfully!'))
                      .catchError((e) => _showSnackBar('Failed to send plan: $e', isError: true));
                },
                child: const Text('Send Manual Plan to Pod', style: TextStyle(color: Colors.black)),
              ),
            ),
          ],
          const SizedBox(height: 24),
          const Divider(color: Colors.white24),

          // Last AI Plan Display
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('Last Received AI Plan', style: TextStyle(color: Colors.cyan, fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          if (provider.lastAiPlan == null)
            const Text('No AI plan has been received yet.', style: TextStyle(color: Colors.white70))
          else
            ...provider.lastAiPlan!.entries.map((entry) {
              return ListTile(
                title: Text(entry.key, style: const TextStyle(color: Colors.white)),
                trailing: Text(entry.value.toString(), style: const TextStyle(color: Colors.cyan, fontSize: 16)),
              );
            }).toList(),

          // Danger Zone & Reset Button
          const Divider(color: Colors.white24, height: 40),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('Danger Zone', style: TextStyle(color: Colors.redAccent, fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            title: const Text('Reset App', style: TextStyle(color: Colors.white)),
            subtitle: const Text('This will delete all data and restart the setup process.', style: TextStyle(color: Colors.white70)),
            onTap: _resetApp,
          ),
        ],
      ),
    );
  }
}