import 'package:flutter/material.dart';
import '../screens/ai_chat_screen.dart';

class AiChatFab extends StatelessWidget {
  const AiChatFab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0999B8), Color(0xFF00B4FF), Color(0xFF1366BA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0999B8).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AiChatScreen(),
            ),
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Stack(
          children: [
            const Icon(
              Icons.smart_toy,
              color: Colors.white,
              size: 28,
            ),
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: const Text(
                  'PowerGym',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}