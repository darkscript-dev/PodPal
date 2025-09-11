import 'package:flutter/material.dart';
import 'package:podpal/providers/pod_data_provider.dart';
import 'package:podpal/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConnectToPodScreen extends StatefulWidget {
  const ConnectToPodScreen({Key? key}) : super(key: key);

  @override
  _ConnectToPodScreenState createState() => _ConnectToPodScreenState();
}

class _ConnectToPodScreenState extends State<ConnectToPodScreen> {
  final _urlController = TextEditingController();
  bool _isConnecting = false;
  bool _isMockEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSavedUrl();
  }

  Future<void> _loadSavedUrl() async {
    final prefs = await SharedPreferences.getInstance();
    _urlController.text = prefs.getString('ngrok_url') ?? '';
  }

  Future<void> _connectToPod() async {
    final url = _urlController.text.trim();
    if (!_isMockEnabled && url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the ngrok URL.')),
      );
      return;
    }
    setState(() {
      _isConnecting = true;
    });
    if (!_isMockEnabled) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ngrok_url', url);
    }
    final provider = Provider.of<PodDataProvider>(context, listen: false);
    await provider.updatePodData(newUrl: url, useMockData: _isMockEnabled);
    setState(() {
      _isConnecting = false;
    });
    if (!provider.hasError && provider.podStatus?.ledStatus == "ON") {
      if (provider.plantProfile != null) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        Navigator.pushNamed(context, '/plant_list');
      }
    } else {
      String errorMessage =
          provider.errorMessage ?? 'An unknown error occurred.';
      if (!provider.hasError) {
        errorMessage = 'Device responded, but LED confirmation failed.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(errorMessage),
        ),
      );
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF011001),
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Make AppBar invisible
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        // Add a secret switch to the AppBar's actions
        actions: [
          Switch(
            value: _isMockEnabled,
            onChanged: (value) {
              setState(() {
                _isMockEnabled = value;
              });
            },
            activeColor: Colors.purple.shade200,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- TOP IMAGE SECTION (takes up about 40% of the screen) ---
          /*Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              // Use a ClipRRect to give the image rounded corners if needed
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Image.asset(
                  'assets/images/pot_image.png', // The image name you provided
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),---*/
          Expanded(
            flex: 6,
            child: Container(
              // The dark background for the content area
              color: const Color(0xFF011001),
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 24.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // Distributes space evenly
                children: [
                  // --- Text content at the top ---
                  Column(
                    children: [
                      const Text(
                        'Connect to Your Pod',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Please ensure your PodPal is powered on.\nNow\'add your ip below to connect it to your Wi-Fi network.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                          height: 1.5, // Improves readability
                        ),
                      ),
                    ],
                  ),
                  // --- The URL input field ---
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E291E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _urlController,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        hintText: 'Enter ngrok URL here',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.white38),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  // --- The connection button at the bottom ---
                  _isConnecting
                      ? const CircularProgressIndicator()
                      : CustomButton(
                        text: 'Find My Pod',
                        onPressed: _connectToPod,
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
