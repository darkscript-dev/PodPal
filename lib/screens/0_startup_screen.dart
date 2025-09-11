import 'package:flutter/material.dart';

class PodPalIntroScreen extends StatelessWidget {
  const PodPalIntroScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Layer 1: The Background Image
          Image.asset(
            'assets/images/pod_plant.png',
            fit: BoxFit.cover,
          ),

          // Layer 2: The Dark Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),

          // Layer 3: The Content (Text, Button, and Developer Name)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // This first Spacer pushes everything down from the top.
                  const Spacer(),

                  // Title
                  const Text(
                    'Pod Pal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // This Spacer creates the gap between the title and the subtitle.
                  const Spacer(),

                  // Subtitle
                  Text(
                    'Your Robotic\nGardening Companion',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 18,
                      height: 1.4,
                    ),
                  ),

                  // This Spacer pushes the button to the bottom.
                  const Spacer(),

                  // Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF569E36),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 48),
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/connect');
                    },
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Text(
                    'by Darkscript',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4), // Low opacity for subtlety
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
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