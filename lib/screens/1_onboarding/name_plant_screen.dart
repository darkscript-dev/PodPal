import 'package:flutter/material.dart';
import 'package:podpal/providers/pod_data_provider.dart';
import 'package:podpal/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class PodPalSetupScreen extends StatefulWidget {
  const PodPalSetupScreen({Key? key}) : super(key: key);

  @override
  _PodPalSetupScreenState createState() => _PodPalSetupScreenState();
}

class _PodPalSetupScreenState extends State<PodPalSetupScreen> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _finishSetup() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please give your new friend a name!')),
      );
      return;
    }

    final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    final plantType = args['plantType']!;
    final plantStage = args['plantStage']!;

    final provider = Provider.of<PodDataProvider>(context, listen: false);

    final success = await provider.generateAndSetPlantProfile(
      plantType,
      plantStage,
      _nameController.text.trim(),
    );

    if (success) {
      // Clear the onboarding screens and go to home
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } else {
      // Show an error if Gemini failed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.profileError ?? 'Could not generate profile.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use a consumer to listen for loading state changes
    return Consumer<PodDataProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF0B1611),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: const BackButton(color: Colors.white),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                const Text(
                  'Give your new friend a\nname!',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter a name...',
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
                const Spacer(),
                // Show a loading spinner or the button
                provider.isGeneratingProfile
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButton(
                  text: 'Finish Setup',
                  onPressed: _finishSetup,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}