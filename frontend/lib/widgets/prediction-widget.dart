import 'package:flutter/material.dart';
import 'package:frontend/services/period-prediction-service.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PredictionWidget extends StatefulWidget {
  const PredictionWidget({Key? key}) : super(key: key);

  @override
  _PredictionWidgetState createState() => _PredictionWidgetState();
}

class _PredictionWidgetState extends State<PredictionWidget> {
  final PeriodPredictionService _predictionService = PeriodPredictionService();
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _prediction;

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
      
      setState(() {
        _prediction = prediction;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading prediction: $e");
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load prediction: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
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
      return const Center(
        child: Text('No prediction data available'),
      );
    }

    // Format the next period date
    String nextPeriodDate = 'Unknown';
    if (_prediction!.containsKey('nextPeriodStartDate')) {
      try {
        final dateTime = DateTime.parse(_prediction!['nextPeriodStartDate']);
        nextPeriodDate = DateFormat('MMM dd, yyyy').format(dateTime);
      } catch (e) {
        print("Error parsing date: $e");
        nextPeriodDate = 'Date unavailable';
      }
    }

    bool isUsingAIModel = _prediction!.containsKey('usedActualModel') && 
                          _prediction!['usedActualModel'] == true;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_today, 
              color: Color.fromARGB(255, 240, 99, 153), 
              size: 24),
            const SizedBox(width: 8),
            const Text(
              'Your Next Period',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (_prediction!.containsKey('isFallback') && _prediction!['isFallback'] == true)
              Tooltip(
                message: 'Using estimated prediction (server unavailable)',
                child: const Icon(Icons.sync_problem, size: 16, color: Colors.orange),
              )
            else if (isUsingAIModel)
              Tooltip(
                message: 'Using AI prediction model',
                child: const Icon(Icons.psychology, size: 16, color: Colors.green),
              )
            else if (_prediction!.containsKey('fromCache') && _prediction!['fromCache'])
              Tooltip(
                message: 'Using cached prediction',
                child: const Icon(Icons.info_outline, size: 16, color: Colors.grey),
              ),
          ],
        ),
        const Divider(),
        
        // AI Model Badge - show only when using the actual Random Forest model
        if (isUsingAIModel)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.psychology, color: Colors.green, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'AI Prediction',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
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
          value: '${_prediction!['predictedCycleLength']} days',
        ),
        
        // Show model type information
        if (_prediction!.containsKey('modelType'))
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: _buildInfoRow(
              icon: Icons.model_training,
              label: 'Prediction Method:',
              value: _prediction!['modelType'],
              valueColor: isUsingAIModel ? Colors.green : Colors.grey[600],
            ),
          ),
          
        const SizedBox(height: 16),
        Center(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh Prediction'),
            onPressed: _loadPrediction,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color.fromARGB(255, 240, 99, 153),
            ),
          ),
        ),
      ],
    );
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
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
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