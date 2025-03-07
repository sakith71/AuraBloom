import 'package:flutter/material.dart';
import './stay-active-detail.dart'; // Import the detail screen
import './eat-well-detail.dart';// Import the detail screen
import './apply-heat.dart'; //Import the detail screen
import './get-rest.dart'; //Import the detail screen

class HealthTipsScreen extends StatelessWidget {
  const HealthTipsScreen({super.key});

  Widget _buildTipCard({
    required IconData icon, 
    required String title,
    required Color cardColor,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        height: 110,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon, 
              color: iconColor, 
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteCard({
    required String quote,
    required String doctor,
    required String specialty,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.format_quote,
                color: Colors.pink[300],
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  quote,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "$doctor, $specialty",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF0F7),
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              color: Colors.pink[300],
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Health Tips',
              style: TextStyle(
                color: Colors.pink[300],
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.pink[300],),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.pink[300],),
            onPressed: () {
              // Notification functionality
            },
          ),
          IconButton(
            icon: Icon(Icons.person_outline, color: Colors.pink[300],),
            onPressed: () {
              // Profile functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Horizontal row of tip cards
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTipCard(
                      icon: Icons.bolt,
                      title: 'Stay\nActive',
                      cardColor: const Color(0xFFFFE6F1),
                      iconColor: Colors.orange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StayActiveDetailScreen(),
                          ),
                        );
                      },
                    ),
                    _buildTipCard(
                      icon: Icons.restaurant,
                      title: 'Hydrate &\nEat Well',
                      cardColor: const Color(0xFFE6EEFF),
                      iconColor: Colors.blue[700]!,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EatWellDetailScreen(),
                          ),
                        );
                      },
                    ),
                    
                    _buildTipCard(
                      icon: Icons.hot_tub,
                      title: 'Apply\nHeat',
                      cardColor: const Color(0xFFE5F8FF),
                      iconColor: Colors.red,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ApplyHeatDetailScreen(),
                          ),
                        );
                      },
                    ),
                    _buildTipCard(
                      icon: Icons.hotel,
                      title: 'Get\nRest',
                      cardColor: const Color(0xFFE6FFE6),
                      iconColor: Colors.purple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GetRestDetailScreen(),
                          ),
                        );
                      },
                    ),
                    _buildTipCard(
                      icon: Icons.spa,
                      title: 'Practice\nMindfulness',
                      cardColor: const Color(0xFFFFF0E6),
                      iconColor: Colors.green,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Quote cards
              _buildQuoteCard(
                quote: "Menstrual cramps are not just 'part of being a woman.' Severe pain should be taken seriously and evaluated by a doctor.",
                doctor: "Dr. Tamer Seckin",
                specialty: "Endometriosis Specialist",
              ),
              
              _buildQuoteCard(
                quote: "Pain is not a normal part of the menstrual cycle when it disrupts your daily life. If that happens, it's time to seek medical advice.",
                doctor: "Dr. Jessica Shepherd",
                specialty: "OB-GYN",
              ),
              
              _buildQuoteCard(
                quote: "Heat therapy can be as effective as ibuprofen in reducing menstrual pain. A heating pad or warm water bottle can work wonders.",
                doctor: "Dr. Penelope Law",
                specialty: "Consultant Gynecologist",
              ),
              
              _buildQuoteCard(
                quote: "Regular exercise, even simple stretching or yoga, helps improve circulation and reduce cramping.",
                doctor: "Dr. Lisa Masterson",
                specialty: "OB-GYN",
              ),
              
              _buildQuoteCard(
                quote: "Your period is a vital sign, like your pulse or blood pressure. If something feels wrong, listen to your body.",
                doctor: "Dr. Lara Briden",
                specialty: "Naturopathic Doctor",
              ),
            ],
          ),
        ),
      ),
    );
  }
}