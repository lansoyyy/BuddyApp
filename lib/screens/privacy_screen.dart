import 'package:flutter/material.dart';
import 'package:buddyapp/widgets/custom_button.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Privacy Policy',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Last Updated
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Last Updated: November 18, 2024',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withOpacity(0.7),
                      ),
                ),
              ),
              const SizedBox(height: 24),

              // Introduction
              _buildSection(
                context,
                '1. Introduction',
                'BuddyApp ("we," "us," or "our") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile camera application for workflow management.',
              ),

              // Information We Collect
              _buildSection(
                context,
                '2. Information We Collect',
                'We may collect several types of information from and about users of our application, including:\n\n'
                    'Personal Information: Name, email address, phone number, and other contact information you provide when creating an account.\n\n'
                    'Account Information: Username, password, and authentication credentials.\n\n'
                    'Usage Data: Information about how you use the application, including features accessed, time spent, and interactions.\n\n'
                    'Device Information: Device type, operating system, unique device identifiers, and mobile network information.\n\n'
                    'Location Data: Approximate location based on IP address and, with your permission, precise location data.\n\n'
                    'Photos and Metadata: Images you capture and associated metadata including timestamps, job information, and tags.',
              ),

              // How We Use Your Information
              _buildSection(
                context,
                '3. How We Use Your Information',
                'We use the information we collect to:\n\n'
                    'Provide, maintain, and improve our services\n\n'
                    'Process transactions and manage your account\n\n'
                    'Authenticate users and ensure security\n\n'
                    'Communicate with you about your account and our services\n\n'
                    'Analyze usage patterns to optimize user experience\n\n'
                    'Comply with legal obligations and protect our rights\n\n'
                    'Develop new features and services',
              ),

              // Information Sharing
              _buildSection(
                context,
                '4. Information Sharing',
                'We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except as described in this policy:\n\n'
                    'Service Providers: We may share information with trusted service providers who assist us in operating our application.\n\n'
                    'Business Transfers: In the event of a merger, acquisition, or sale of assets, user information may be transferred.\n\n'
                    'Legal Requirements: We may disclose information when required by law or to protect our rights, property, or safety.\n\n'
                    'Job-Related Sharing: Photos and metadata may be shared with authorized parties involved in your work orders and projects.',
              ),

              // Data Security
              _buildSection(
                context,
                '5. Data Security',
                'We implement appropriate technical and organizational measures to protect your information against unauthorized access, alteration, disclosure, or destruction. However, no method of transmission over the internet is 100% secure, and we cannot guarantee absolute security.',
              ),

              // Data Retention
              _buildSection(
                context,
                '6. Data Retention',
                'We retain your personal information for as long as necessary to provide our services and fulfill the purposes outlined in this policy, unless a longer retention period is required or permitted by law.',
              ),

              // Your Rights
              _buildSection(
                context,
                '7. Your Rights',
                'Depending on your location, you may have the following rights regarding your personal information:\n\n'
                    'Access: Request access to your personal information\n\n'
                    'Correction: Request correction of inaccurate information\n\n'
                    'Deletion: Request deletion of your personal information\n\n'
                    'Portability: Request a copy of your data in a structured format\n\n'
                    'Objection: Object to processing of your information\n\n'
                    'Restriction: Request restriction of processing your information',
              ),

              // Cookies and Tracking
              _buildSection(
                context,
                '8. Cookies and Tracking',
                'We may use cookies and similar tracking technologies to enhance your experience, analyze usage patterns, and personalize content. You can control cookie settings through your device preferences.',
              ),

              // Third-Party Services
              _buildSection(
                context,
                '9. Third-Party Services',
                'Our application may integrate with third-party services, including:\n\n'
                    'Firebase for authentication and data storage\n\n'
                    'Cloud storage services for photo storage\n\n'
                    'Analytics services for usage analysis\n\n'
                    'These services have their own privacy policies, and we are not responsible for their practices.',
              ),

              // Children\'s Privacy
              _buildSection(
                context,
                '10. Children\'s Privacy',
                'Our application is not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13. If you become aware that a child has provided us with personal information, please contact us immediately.',
              ),

              // International Data Transfers
              _buildSection(
                context,
                '11. International Data Transfers',
                'Your information may be transferred to and processed in countries other than your own. We ensure appropriate safeguards are in place to protect your information in accordance with applicable data protection laws.',
              ),

              // Changes to This Policy
              _buildSection(
                context,
                '12. Changes to This Policy',
                'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new policy in the application and, where required by law, obtaining your consent.',
              ),

              // Contact Information
              _buildSection(
                context,
                '13. Contact Information',
                'If you have any questions about this Privacy Policy or want to exercise your rights, please contact us at:\n\n'
                    'Email: privacy@buddyapp.com\n'
                    'Phone: +1 (555) 123-4567\n'
                    'Address: 123 Workflow Street, Industrial City, IC 12345',
              ),

              const SizedBox(height: 32),

              // Close Button
              CustomButton(
                text: 'I Understand',
                onPressed: () => Navigator.of(context).pop(),
                isFullWidth: true,
                type: ButtonType.primary,
                size: ButtonSize.large,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.7),
                height: 1.6,
              ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
