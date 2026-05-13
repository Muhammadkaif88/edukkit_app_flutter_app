import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {

  final List<Map<String, String>> _faqs = [
    {
      'q': 'How do I enrol in a course?',
      'a': 'Browse our courses from the home screen, tap a course and press "Enrol Now". You will be guided through the payment or free enrolment process.',
    },
    {
      'q': 'Can I download course content offline?',
      'a': 'Offline downloads are available for premium subscribers. Go to the course page and tap the download icon next to each lesson.',
    },
    {
      'q': 'How do I get my completion certificate?',
      'a': 'Complete all lessons and pass the final assessment. Your certificate will be automatically generated and available in My Profile.',
    },
    {
      'q': 'What payment methods are accepted?',
      'a': 'We accept UPI, credit/debit cards, net banking, and wallets via Razorpay. All transactions are secured and encrypted.',
    },
    {
      'q': 'How do I reset my password?',
      'a': 'Go to Settings → Change Password, or use the "Forgot Password" option on the login screen. A reset link will be sent to your email.',
    },
  ];

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open link. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A40DF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Help & Support',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hero banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5B52F0), Color(0xFF3B30C8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('How can we help you?',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Our support team is available\nMon–Sat, 9 AM – 6 PM',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13,
                              height: 1.5)),
                    ],
                  ),
                ),
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.support_agent,
                      color: Colors.white, size: 36),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Support Options ──────────────────────────────────────────
          _sectionHeader(Icons.headset_mic_outlined, 'Support Options'),
          const SizedBox(height: 10),
          _buildCard(children: [
            _tile(
              icon: Icons.quiz_outlined,
              iconBg: const Color(0xFF4527A0),
              title: 'FAQ',
              subtitle: 'Browse frequently asked questions',
              onTap: () => _showFaqSheet(),
            ),
            _divider(),
            _tile(
              icon: Icons.support_agent_outlined,
              iconBg: const Color(0xFF00695C),
              title: 'Contact Support',
              subtitle: 'Talk to our support team',
              onTap: () => _launch('mailto:support@edukkit.com?subject=Support Request'),
            ),
            _divider(),
            _tile(
              icon: Icons.bug_report_outlined,
              iconBg: const Color(0xFFC62828),
              title: 'Report a Bug',
              subtitle: 'Help us improve the app',
              onTap: () => _showBugReportSheet(),
            ),
            _divider(),
            _tile(
              icon: Icons.chat_bubble_outline,
              iconBg: const Color(0xFF0277BD),
              title: 'Chat Support',
              subtitle: 'Live chat with our team',
              badge: 'LIVE',
              onTap: () => _launch('https://t.me/edukkitsupport'),
            ),
          ]),

          const SizedBox(height: 24),

          // ── Contact Options ──────────────────────────────────────────
          _sectionHeader(Icons.contact_phone_outlined, 'Contact Options'),
          const SizedBox(height: 10),
          _buildCard(children: [
            _tile(
              icon: Icons.chat_outlined,
              iconBg: const Color(0xFF2E7D32),
              title: 'WhatsApp Support',
              subtitle: '+91 98765 43210',
              onTap: () => _launch('https://wa.me/919876543210?text=Hi, I need help with Edukkit app.'),
            ),
            _divider(),
            _tile(
              icon: Icons.email_outlined,
              iconBg: const Color(0xFFB71C1C),
              title: 'Email Support',
              subtitle: 'support@edukkit.com',
              onTap: () => _launch('mailto:support@edukkit.com'),
            ),
            _divider(),
            _tile(
              icon: Icons.send_outlined,
              iconBg: const Color(0xFF0288D1),
              title: 'Telegram Support',
              subtitle: '@edukkitsupport',
              onTap: () => _launch('https://t.me/edukkitsupport'),
            ),
          ]),

          const SizedBox(height: 24),

          // Response time card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEEEBFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: const Color(0xFF4A40DF).withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined,
                    color: Color(0xFF4A40DF), size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Average Response Time',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D2D2D),
                              fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(
                          'WhatsApp/Telegram: < 1 hour\nEmail: within 24 hours',
                          style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                              height: 1.5)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── FAQ Bottom Sheet ─────────────────────────────────────────────
  void _showFaqSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        builder: (_, controller) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Frequently Asked Questions',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                controller: controller,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                itemCount: _faqs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (_, i) => Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F7FB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      childrenPadding: const EdgeInsets.fromLTRB(
                          16, 0, 16, 16),
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFFEEEBFF),
                        child: Text('${i + 1}',
                            style: const TextStyle(
                                color: Color(0xFF4A40DF),
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                      title: Text(_faqs[i]['q']!,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Color(0xFF2D2D2D))),
                      children: [
                        Text(_faqs[i]['a']!,
                            style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                                height: 1.6))
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bug Report Sheet ─────────────────────────────────────────────
  void _showBugReportSheet() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String selectedCategory = 'UI Issue';
    final categories = ['UI Issue', 'Crash', 'Login Problem', 'Payment Issue', 'Other'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSS) => Padding(
          padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Report a Bug',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  filled: true,
                  fillColor: const Color(0xFFF6F7FB),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setSS(() => selectedCategory = v!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: 'Bug Title',
                  filled: true,
                  fillColor: const Color(0xFFF6F7FB),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xFF4A40DF), width: 1.5)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Describe the issue',
                  filled: true,
                  fillColor: const Color(0xFFF6F7FB),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xFF4A40DF), width: 1.5)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Bug report submitted. Thank you!'),
                        backgroundColor: Color(0xFF4A40DF),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.send_outlined,
                      color: Colors.white, size: 18),
                  label: const Text('Submit Report',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A40DF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────
  Widget _sectionHeader(IconData icon, String title) => Row(
        children: [
          Icon(icon, color: const Color(0xFF4A40DF), size: 18),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A40DF),
                  letterSpacing: 0.4)),
        ],
      );

  Widget _buildCard({required List<Widget> children}) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(children: children),
      );

  Widget _tile({
    required IconData icon,
    required Color iconBg,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    String? badge,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(title,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D2D2D))),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: Colors.green.shade300),
                            ),
                            child: Text(badge,
                                style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: Colors.grey.shade400, size: 22),
            ],
          ),
        ),
      );

  Widget _divider() =>
      const Divider(height: 1, indent: 72, endIndent: 16);
}
