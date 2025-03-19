import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/period-prediction-service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PredictionWidget extends StatefulWidget {
  const PredictionWidget({super.key});

  @override
  _PredictionWidgetState createState() => _PredictionWidgetState();
}

class _PredictionWidgetState extends State<PredictionWidget> {
  final PeriodPredictionService _predictionService = PeriodPredictionService();
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;
  Map<String, dynamic>? _prediction;
  int _retryCount = 0;
  static const int MAX_RETRIES = 2;

  @override
  void initState() {
    super.initState();
    _loadPrediction();
  }

  Future<void> _loadPrediction() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'You need to be logged in to see predictions';
        });
        return;
      }

      print("Getting prediction for user: $userId");
      final prediction = await _predictionService.getPredictionsForUser(userId);
      print("Prediction received: $prediction");

      // Validate that prediction has required fields
      if (!prediction.containsKey('predictedCycleLength') ||
          !prediction.containsKey('nextPeriodStartDate')) {
        throw Exception('Invalid prediction data received');
      }

      setState(() {
        _prediction = prediction;
        _isLoading = false;
        _retryCount = 0; // Reset retry count on success
      });
    } catch (e) {
      print("Error loading prediction: $e");

      // If we haven't reached max retries, try again
      if (_retryCount < MAX_RETRIES) {
        _retryCount++;
        print(
          "Retrying prediction load (attempt $_retryCount of $MAX_RETRIES)",
        );
        await Future.delayed(
          Duration(seconds: 1),
        ); // Wait a second before retry
        return _loadPrediction();
      }

      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load prediction: ${e.toString()}';
      });
    }
  }

  Future<void> _refreshPrediction() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need to be logged in to refresh predictions'),
        ),
      );
      return;
    }

    setState(() {
      _isRefreshing = true;
      _errorMessage = null;
    });

    try {
      // Force a refresh by clearing cached predictions from Firestore first
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'lastPredictionDate': null,
      });

      // Now get a fresh prediction
      final prediction = await _predictionService.getPredictionsForUser(userId);

      if (!prediction.containsKey('predictedCycleLength') ||
          !prediction.containsKey('nextPeriodStartDate')) {
        throw Exception('Invalid prediction data received');
      }

      setState(() {
        _prediction = prediction;
        _isRefreshing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prediction refreshed successfully')),
      );
    } catch (e) {
      print("Error refreshing prediction: $e");
      setState(() {
        _isRefreshing = false;
        _errorMessage = 'Failed to refresh prediction: ${e.toString()}';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to refresh prediction: ${e.toString()}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'My cycle',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildContent(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadPrediction,
            child: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 240, 99, 153),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      );
    }

    if (_prediction == null) {
      return const Center(child: Text('No prediction data available'));
    }

    // Format the next period date with null safety
    String nextPeriodDate = 'Unknown';
    if (_prediction!.containsKey('nextPeriodStartDate') &&
        _prediction!['nextPeriodStartDate'] != null) {
      try {
        final dateTime = DateTime.parse(_prediction!['nextPeriodStartDate']);
        nextPeriodDate = DateFormat('MMM dd, yyyy').format(dateTime);
      } catch (e) {
        print("Error parsing date: $e");
        nextPeriodDate = 'Date unavailable';
      }
    }

    // Get cycle length with null safety
    String cycleLength = 'Unknown';
    if (_prediction!.containsKey('predictedCycleLength') &&
        _prediction!['predictedCycleLength'] != null) {
      try {
        int cycleDays = _prediction!['predictedCycleLength'];
        cycleLength = '$cycleDays days';
      } catch (e) {
        print("Error getting cycle length: $e");
      }
    }

    bool isUsingAIModel =
        _prediction!.containsKey('usedActualModel') &&
        _prediction!['usedActualModel'] == true;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.calendar_today,
              color: Color.fromARGB(255, 240, 99, 153),
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'Your Next Period',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            if (_prediction!.containsKey('isFallback') &&
                _prediction!['isFallback'] == true)
              Tooltip(
                message: 'Using estimated prediction (server unavailable)',
                child: const Icon(
                  Icons.sync_problem,
                  size: 16,
                  color: Colors.orange,
                ),
              )
            else if (isUsingAIModel)
              Tooltip(
                message: 'Using AI prediction model',
                child: const Icon(
                  Icons.psychology,
                  size: 16,
                  color: Colors.green,
                ),
              )
            else if (_prediction!.containsKey('fromCache') &&
                _prediction!['fromCache'] == true)
              Tooltip(
                message: 'Using cached prediction',
                child: const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
        const Divider(),

        const SizedBox(height: 8),
        _buildInfoRow(
          icon: Icons.event,
          label: 'Expected Start Date:',
          value: nextPeriodDate,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          icon: Icons.loop,
          label: 'Predicted Cycle Length:',
          value: cycleLength,
        ),

        // Show date prediction was last updated
        if (_prediction!.containsKey('lastPredictionDate') &&
            _prediction!['lastPredictionDate'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: _buildInfoRow(
              icon: Icons.update,
              label: 'Last Updated:',
              value: _formatDate(_prediction!['lastPredictionDate']),
              valueColor: Colors.grey[600],
            ),
          ),

        const SizedBox(height: 16),
        Center(
          child:
              _isRefreshing
                  ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color.fromARGB(255, 240, 99, 153),
                    ),
                  )
                  : OutlinedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Prediction'),
                    onPressed: _refreshPrediction,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 240, 99, 153),
                    ),
                  ),
        ),
      ],
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';

    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(dateTime);
    } catch (e) {
      print("Error formatting date: $e");
      return 'Unknown date';
    }
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor ?? const Color.fromARGB(255, 240, 99, 153),
          ),
        ),
      ],
    );
  }
}