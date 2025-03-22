import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F7),
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFF6B8B),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6B8B).withOpacity(0.1),
                blurRadius: 15,
                spreadRadius: 1,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Privacy Policy',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Last updated: March 20, 2025',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF666666),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildPolicySection(
                'Introduction',
                'AuraBloom ("we," "our," or "us") respects your privacy and is committed to protecting your personal data. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.',
              ),
              _buildPolicySection(
                'Information We Collect',
                'We may collect information that you provide directly to us, such as when you create an account, update your profile, use the interactive features of our app, participate in surveys, contests, or promotions, request customer support, or otherwise communicate with us.\n\n'
                    'This information may include:\n'
                    '• Personal identifiers (name, email address)\n'
                    '• Health information (menstrual cycle data, symptoms, mood tracking)\n'
                    '• Usage data (how you interact with our app)\n',
              ),
              _buildPolicySection(
                'How We Use Your Information',
                'We use the information we collect to:\n'
                    '• Provide, maintain, and improve our services\n'
                    '• Personalize your experience\n'
                    '• Communicate with you about updates, offers, and promotions\n'
                    '• Monitor and analyze usage patterns\n'
                    '• Ensure the security of our services\n',
              ),
              _buildPolicySection(
                'Information Sharing',
                'We do not sell your personal information. We may share your information in the following situations:\n'
                    '• With your consent\n'
                    '• With service providers who perform services on our behalf\n'
                    '• To comply with legal obligations\n'
                    '• In connection with a merger, sale, or acquisition\n',
              ),
              _buildPolicySection(
                'Data Security',
                'We implement appropriate technical and organizational measures to protect the security of your personal information. However, please note that no method of transmission over the internet or electronic storage is completely secure.',
              ),
              _buildPolicySection(
                'Your Choices',
                'You can update your account information and preferences at any time by accessing your account settings within the AuraBloom app. You may also opt-out of receiving promotional communications from us by following the instructions in those messages.',
              ),
              _buildPolicySection(
                'Children\'s Privacy',
                'Our service is not directed to children under the age of 13, and we do not knowingly collect personal information from children under 13.',
              ),
              _buildPolicySection(
                'Changes to This Policy',
                'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last Updated" date.',
              ),
              _buildPolicySection(
                'Contact Us',
                'If you have any questions about this Privacy Policy, please contact us at:\n'
                    'Email: aurabloom28@gmail.com\n',
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolicySection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
            color: Color(0xFF666666),
          ),
        ),
      ],
    );
  }
}
