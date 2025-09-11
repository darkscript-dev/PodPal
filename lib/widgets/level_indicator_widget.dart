import 'package:flutter/material.dart';

class LevelInfo {
  final double value;
  final Color color;

  LevelInfo({required this.value, required this.color});
}

class LevelIndicator extends StatelessWidget {
  final String title;
  final String level;

  const LevelIndicator({
    Key? key,
    required this.title,
    required this.level,
  }) : super(key:key);

  LevelInfo _getLevelData(String level) {
    switch (level.toUpperCase()) {
      case "OK":
        return LevelInfo(value: 1.0, color: Colors.greenAccent.shade400);
      case "LOW":
        return LevelInfo(value: 0.25, color: Colors.orange.shade400);
      case "EMPTY":
        return LevelInfo(value: 0.05, color: Colors.red.shade400);
      default:
        return LevelInfo(value: 0.0, color: Colors.grey.shade600);
    }
  }

  @override
  Widget build(BuildContext context) {
    final levelData = _getLevelData(level);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: levelData.value,
            backgroundColor: Colors.white.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(levelData.color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}