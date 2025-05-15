
import 'package:flutter/material.dart';
import '../../../core/constants/theme.dart';
import '../../../core/widgets/ghana_widgets.dart';

class SupportItem {
  final String title;
  final String description;
  final IconData icon;

  SupportItem({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  _SupportScreenState createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final List<SupportItem> _supportItems = [
    SupportItem(
      title: 'Contact Customer Support',
      description: 'Speak with our customer service team',
      icon: Icons.headset_mic_outlined,
    ),
    SupportItem(
      title: 'Report a Safety Issue',
      description: 'Had a safety concern during your ride?',
      icon: Icons.warning_amber_outlined,
    ),
    SupportItem(
      title: 'Report Lost Item',
      description: 'Lost something during your ride?',
      icon: Icons.search_outlined,
    ),
    SupportItem(
      title: 'Billing and Payments',
      description: 'Questions about your payments or refunds',
      icon: Icons.payment_outlined,
    ),
    SupportItem(
      title: 'Account Issues',
      description: 'Need help with your account?',
      icon: Icons.person_outline,
    ),
    SupportItem(
      title: 'App Feedback',
      description: 'Share your thoughts about our app',
      icon: Icons.feedback_outlined,
    ),
  ];

  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I book a ride?',
      'answer': 'To book a ride, open the app and enter your destination on the home screen. Choose your preferred motorcycle taxi and tap "Book Now" to confirm your ride.'
    },
    {
      'question': 'How do payments work?',
      'answer': 'You can pay for your ride using cash, mobile money, or saved payment cards. To add a payment method, go to Profile > Payment Methods.'
    },
    {
      'question': 'How do I cancel a ride?',
      'answer': 'To cancel a ride, go to your Active Trips, select the trip you want to cancel, and tap the "Cancel Trip" button. Note that cancellation fees may apply depending on when you cancel.'
    },
    {
      'question': 'What safety features does Okada have?',
      'answer': 'Okada has several safety features including driver verification, trip sharing, and an emergency SOS button that can be accessed during your trip.'
    },
    {
      'question': 'How do I report an issue with my driver?',
      'answer': 'You can report an issue by going to your Trip History, selecting the trip, and tapping "Report an Issue". Alternatively, you can contact our support team directly from the Support screen.'
    },
  ];

  void _showContactDialog() {
    final reasonController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contact Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GhanaTextField(
              label: 'Reason',
              controller: reasonController,
              hint: 'What is your inquiry about?',
              prefixIcon: Icons.help_outline,
            ),
            SizedBox(height: 16),
            GhanaTextField(
              label: 'Message',
              controller: messageController,
              hint: 'Please describe your issue',
              prefixIcon: Icons.message_outlined,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ghanaGreen,
            ),
            onPressed: () {
              if (messageController.text.isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Your message has been sent. We\'ll get back to you soon.'),
                    backgroundColor: ghanaGreen,
                  ),
                );
              }
            },
            child: Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Support'),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(text: 'Help Topics'),
                Tab(text: 'FAQs'),
              ],
              labelColor: ghanaGreen,
              unselectedLabelColor: textSecondary,
              indicatorColor: ghanaGreen,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildHelpTopicsTab(),
                  _buildFaqsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ghanaGreen,
        onPressed: _showContactDialog,
        tooltip: 'Contact Support',
        child: Icon(Icons.chat_outlined),
      ),
    );
  }

  Widget _buildHelpTopicsTab() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _supportItems.length,
      itemBuilder: (context, index) {
        final item = _supportItems[index];
        return GhanaCard(
          padding: EdgeInsets.all(16),
          elevation: 1,
          onTap: () {
            if (index == 0) {
              _showContactDialog();
            } else {
              // Navigate to specific support page based on index
            }
          },
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: ghanaGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.icon,
                  color: ghanaGreen,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      item.description,
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: textSecondary,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFaqsTab() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _faqs.length,
      itemBuilder: (context, index) {
        final faq = _faqs[index];
        return KenteBorderContainer(
          borderWidth: 1,
          padding: EdgeInsets.all(16),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(
              faq['question']!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 16,
                  left: 16,
                  right: 16,
                ),
                child: Text(
                  faq['answer']!,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
