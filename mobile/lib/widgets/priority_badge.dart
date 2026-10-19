import 'package:flutter/material.dart';

class PriorityBadge extends StatelessWidget {
  final String priority;
  final String display;
  final Color color;

  const PriorityBadge({
    super.key,
    required this.priority,
    required this.display,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Ưu tiên: $display',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
