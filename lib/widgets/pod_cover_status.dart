import 'package:flutter/material.dart';

class PanelState {
  final String label;
  final Color color;
  final IconData icon;

  PanelState(this.label, this.color, this.icon);
}

class PodCoverStatus extends StatelessWidget {
  final int leftAngle;
  final int rightAngle;
  final int backAngle;

  const PodCoverStatus({
    Key? key,
    required this.leftAngle,
    required this.rightAngle,
    required this.backAngle,
  }) : super(key: key);

  PanelState _getPanelState(int angle) {
    if (angle >= 75) {
      return PanelState('Open', Colors.orange.shade400, Icons.unfold_more);
    } else {
      return PanelState('Closed', Colors.lightBlue.shade300, Icons.check_circle_outline);
    }
  }

  @override
  Widget build(BuildContext context) {
    final leftState = _getPanelState(leftAngle);
    final rightState = _getPanelState(rightAngle);
    final backState = _getPanelState(backAngle);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: const Color(0x32397144).withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24, width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cover Panel Status',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _PanelStatusRow(label: "Back", state: leftState),
          const Divider(color: Colors.white24, height: 14, thickness: 0.5),
          _PanelStatusRow(label: "Left", state: backState),
          const Divider(color: Colors.white24, height: 14, thickness: 0.5),
          _PanelStatusRow(label: "Right", state: rightState),
        ],
      ),
    );
  }
}

class _PanelStatusRow extends StatelessWidget {
  const _PanelStatusRow({required this.label, required this.state});

  final String label;
  final PanelState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Row(
          children: [
            Icon(state.icon, color: state.color, size: 22),
            const SizedBox(width: 8),
            Text(
              state.label,
              style: TextStyle(
                color: state.color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
