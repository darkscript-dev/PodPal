import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:podpal/providers/pod_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class AskAIPage extends StatefulWidget {
  const AskAIPage({super.key});

  @override
  State<AskAIPage> createState() => _AskAIPageState();
}

class _AskAIPageState extends State<AskAIPage> {
  @override
  void initState() {
    super.initState();
    // Trigger the report generation as soon as the screen loads
    // Use a post-frame callback to ensure the context is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PodDataProvider>(context, listen: false).generateAiReport();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use a Consumer to rebuild the UI when the provider's state changes
    return Consumer<PodDataProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('AI Analytical Report'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: buildBody(provider),
          floatingActionButton: provider.aiReport != null
              ? FloatingActionButton.extended(
            onPressed: () {
              final plantName = provider.plantProfile?.name ?? "Your Plant";
              final subject =
                  "PodPal Health Report for $plantName - ${DateFormat('yyyy-MM-dd').format(DateTime.now())}";
              Share.share(provider.aiReport!, subject: subject);
            },
            label: const Text('Export Report'),
            icon: const Icon(Icons.share),
            backgroundColor: Colors.amber,
          )
              : null,
        );
      },
    );
  }

  Widget buildBody(PodDataProvider provider) {
    if (provider.isGeneratingReport) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Analyzing data and generating report...',
                style: TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    if (provider.reportError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Failed to generate report:\n${provider.reportError}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      );
    }

    if (provider.aiReport != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          provider.aiReport!,
          style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
        ),
      );
    }

    // Default initial state
    return const SizedBox.shrink();
  }
}