import 'package:flutter/material.dart';
import 'package:frontend/screens/cycle-history-page.dart';
import 'package:intl/intl.dart';

class PreviousCycleBox extends StatelessWidget {
  final DateTime? lastCycleStartDate;
  final int cycleDuration;
  final int periodDuration;
  final VoidCallback? onReviewTap;

  const PreviousCycleBox({
    super.key,
    this.lastCycleStartDate,
    this.cycleDuration = 28,
    this.periodDuration = 5,
    this.onReviewTap,
  });

  @override
  Widget build(BuildContext context) {
    // Format the date if available
    String formattedDate = "No previous data";
    if (lastCycleStartDate != null) {
      formattedDate = DateFormat('MMM d, yyyy').format(lastCycleStartDate!);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Previous Cycle",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color.fromARGB(255, 240, 99, 153),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (onReviewTap != null) {
                    onReviewTap!();
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CycleHistoryPage(),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 240, 99, 153),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Text(
                    "View All",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Row with cycle information icons and text - fixed to prevent overflow
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCycleInfoItem(
                  icon: Icons.calendar_today,
                  title: "Last Period",
                  value: formattedDate,
                ),
                _buildCycleInfoItem(
                  icon: Icons.loop,
                  title: "Cycle Length",
                  value: "$cycleDuration days",
                ),
                _buildCycleInfoItem(
                  icon: Icons.water_drop,
                  title: "Period Length",
                  value: "$periodDuration days",
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.grey, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "View all your cycle history to track patterns over time",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCycleInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color.fromARGB(255, 240, 99, 153),
                size: 16,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
