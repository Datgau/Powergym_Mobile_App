import 'package:flutter/material.dart';
import '../ai_chat.dart';

/// Demo screen để test AI Chat feature
class AiChatDemo extends StatelessWidget {
  const AiChatDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60), // Space for app bar
                const Text(
                  'AI Chat Feature Demo',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'The AI Chat feature has been integrated into PowerGym Mobile App. '
                  'You can use the AI assistant to:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                const _FeatureItem(
                  icon: Icons.fitness_center,
                  title: 'Find membership packages',
                  description: 'AI will suggest membership packages that fit your needs',
                ),
                const _FeatureItem(
                  icon: Icons.sports_gymnastics,
                  title: 'Find gym services',
                  description: 'Discover services like PT, Yoga, Boxing, etc.',
                ),
                const _FeatureItem(
                  icon: Icons.person,
                  title: 'Find trainers',
                  description: 'Find trainers by specialty and experience',
                ),
                const _FeatureItem(
                  icon: Icons.calendar_today,
                  title: 'Schedule workouts',
                  description: 'Get help booking sessions with your favorite trainer',
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AiChatScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.smart_toy),
                    label: const Text('Open AI Chat (Full Screen)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF045668),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Or use the AI Chat button in the bottom right corner (Beautiful Popup).',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // App Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0999B8), Color(0xFF00B4FF), Color(0xFF1366BA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'AI Chat Demo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // AI Chat Popup
          const AiChatPopup(),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF045668).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF045668),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
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