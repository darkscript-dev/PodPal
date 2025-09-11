import 'package:flutter/material.dart';
import 'package:podpal/providers/pod_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Package for formatting dates

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  // Helper widget for displaying a profile detail
  Widget buildProfileDetail(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the data from the provider
    final profile = Provider.of<PodDataProvider>(context).plantProfile;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      // Check if the profile data exists yet
      body: profile == null
          ? const Center(
        child: Text(
          'Plant profile not yet created.',
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildProfileDetail('Name', profile.name),
            const SizedBox(height: 24),
            // Format the birthday to be readable
            buildProfileDetail('Birthday', DateFormat('MMMM d, yyyy').format(profile.birthday)),
            const SizedBox(height: 24),
            buildProfileDetail('Personality', profile.personality),
            const SizedBox(height: 24),
            buildProfileDetail('Interests', profile.interests),
          ],
        ),
      ),
    );
  }
}