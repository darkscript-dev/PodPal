import 'dart:ui';
import 'package:flutter/material.dart';

class HomeStatusCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color cardColor;

  const HomeStatusCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.cardColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          width: 125,
          padding: const EdgeInsets.symmetric(vertical: 7.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: cardColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title == "Temp" ? "Temp (c)" : title,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  Icon(icon, color: Colors.white.withOpacity(0.8), size: 24),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
