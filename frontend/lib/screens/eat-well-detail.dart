import 'package:flutter/material.dart';

class EatWellDetailScreen extends StatelessWidget {
  const EatWellDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF0F7),
      appBar: AppBar(
        title: Text(
          'Hydrate & Eat Well',
          style: TextStyle(
            color: Colors.pink[300],
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.pink[300]),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.pink[300]),
            onPressed: () {
              // Notification functionality
            },
          ),
          IconButton(
            icon: Icon(Icons.person_outline, color: Colors.pink[300]),
            onPressed: () {
              // Profile functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Container(
              width: double.infinity,
              height: 200,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: AssetImage('assets/hydrate-and-eat-well.png'),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            
            // Title section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Nutrition Matters',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            
            // Main content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Staying hydrated and maintaining a balanced diet can significantly impact period pain. Dehydration can make cramps worse, as it causes the body to retain water, leading to bloating and discomfort. Drinking warm water or herbal teas can help reduce bloating and relax muscles.\nEating anti-inflammatory foods can also help manage period pain. Magnesium-rich foods (such as spinach, almonds, and bananas) help relax muscles and reduce cramps. Omega-3 fatty acids found in fish and flaxseeds help reduce inflammation, while foods high in iron (like leafy greens and red meat) help replenish lost blood and combat fatigue. ',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.grey[800],
                ),
              ),
            ),
            
            // Expert insight section
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.pink.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Expert Insight:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '"A healthy diet rich in omega-3s, magnesium, and iron can help reduce period cramps by decreasing inflammation and muscle tension." – Dr. Lara Briden, Naturopathic Doctor',
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            
            // Suggested exercises section (optional addition)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Foods to Eat for Period Pain Relief:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildExerciseTile('Good', 'Bananas, nuts, spinach, fish, dark chocolate, ginger, turmeric, and yogurt.'),
                  _buildExerciseTile('Avoid', 'Processed foods, caffeine, excess salt, alcohol, and sugary snacks, which can trigger inflammation and worsen pain.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseTile(String name, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: Colors.pink[300],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}