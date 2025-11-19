import 'package:flutter/material.dart';
import 'package:buddyapp/utils/app_colors.dart';
import 'package:buddyapp/utils/app_text_styles.dart';
import 'package:buddyapp/widgets/custom_button.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Terms & Conditions',
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
                'Welcome to BuddyApp, a mobile camera application designed for workflow management in industrial and field service settings. By accessing or using our application, you agree to be bound by these Terms & Conditions.',
              ),

              // Acceptance of Terms
              _buildSection(
                context,
                '2. Acceptance of Terms',
                'By creating an account and using BuddyApp, you acknowledge that you have read, understood, and agree to be bound by these Terms & Conditions, our Privacy Policy, and any additional terms and conditions referenced herein.',
              ),

              // User Accounts
              _buildSection(
                context,
                '3. User Accounts',
                'To use BuddyApp, you must create an account and provide accurate, complete, and current information. You are responsible for safeguarding your account credentials and for all activities that occur under your account. You must notify us immediately of any unauthorized use of your account.',
              ),

              // Permitted Use
              _buildSection(
                context,
                '4. Permitted Use',
                'BuddyApp is intended for legitimate business purposes related to workflow management, inspections, repairs, and quality control in industrial settings. You agree to use the application only for lawful purposes and in accordance with these Terms & Conditions.',
              ),

              // Data and Privacy
              _buildSection(
                context,
                '5. Data and Privacy',
                'Your privacy is important to us. Our collection, use, and protection of your personal data is governed by our Privacy Policy, which is incorporated into these Terms & Conditions by reference. By using BuddyApp, you consent to the collection and use of your information as described in our Privacy Policy.',
              ),

              // Intellectual Property
              _buildSection(
                context,
                '6. Intellectual Property',
                'BuddyApp and its original content, features, and functionality are and will remain the exclusive property of BuddyApp and its licensors. The application is protected by copyright, trademark, and other laws.',
              ),

              // User Content
              _buildSection(
                context,
                '7. User Content',
                'You retain ownership of any content you upload, including photos and related metadata. By uploading content to BuddyApp, you grant us a worldwide, non-exclusive, royalty-free license to use, store, and process your content solely for the purpose of providing the service to you.',
              ),

              // Prohibited Activities
              _buildSection(
                context,
                '8. Prohibited Activities',
                'You agree not to: (a) use the application for any illegal or unauthorized purpose; (b) upload malicious code or harmful content; (c) interfere with or disrupt the application or servers; (d) attempt to gain unauthorized access to our systems; (e) reverse engineer or attempt to extract the source code of the application.',
              ),

              // Service Availability
              _buildSection(
                context,
                '9. Service Availability',
                'We strive to maintain high availability of BuddyApp, but we do not guarantee that the service will be uninterrupted or error-free. We may update, modify, or discontinue the application at any time without prior notice.',
              ),

              // Limitation of Liability
              _buildSection(
                context,
                '10. Limitation of Liability',
                'To the maximum extent permitted by law, BuddyApp shall not be liable for any indirect, incidental, special, consequential, or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses, resulting from your use of the application.',
              ),

              // Indemnification
              _buildSection(
                context,
                '11. Indemnification',
                'You agree to defend, indemnify, and hold harmless BuddyApp and its affiliates from and against any claims, damages, obligations, losses, liabilities, costs or debt, and expenses (including but not limited to attorney\'s fees).',
              ),

              // Termination
              _buildSection(
                context,
                '12. Termination',
                'We may terminate or suspend your account and bar access to the service immediately, without prior notice or liability, under our sole discretion, for any reason whatsoever and without limitation.',
              ),

              // Governing Law
              _buildSection(
                context,
                '13. Governing Law',
                'These Terms & Conditions shall be interpreted and governed by the laws of the jurisdiction in which BuddyApp operates, without regard to its conflict of law provisions.',
              ),

              // Changes to Terms
              _buildSection(
                context,
                '14. Changes to Terms',
                'We reserve the right to modify these Terms & Conditions at any time. If we make material changes, we will notify you by email or by posting a notice in the application prior to the effective date of the changes.',
              ),

              // Contact Information
              _buildSection(
                context,
                '15. Contact Information',
                'If you have any questions about these Terms & Conditions, please contact us at:\n\nEmail: support@buddyapp.com\nPhone: +1 (555) 123-4567',
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
