import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../screens/chatbot/chatbot_screen.dart';

/// Edukkit AI Assistant Floating Mascot Widget (Home Screen Only)
/// Animates the official Edukkit AI Assistant PNG peeking from behind the right screen edge wall.
/// 
/// Step 1: Hidden completely outside right edge (right: -240.0)
/// Step 2: After 2 seconds, slides horizontally (700ms, Curves.easeOutBack)
/// Step 3: Final position keeps ~40-45% of mascot visible peeking from screen edge (right: -128.0)
/// Step 4: PNG contains speech bubble, waving hand, & wall grip; no extra elements added
/// Step 5: Idle breathing animation (Scale 1.00 -> 1.03 -> 1.00 every 2 seconds)
/// Step 6: Tapping fades out mascot and opens AI Chat Screen (ChatbotScreen)
class AiFloatingMascot extends StatefulWidget {
  final bool isHidden;

  const AiFloatingMascot({
    super.key,
    this.isHidden = false,
  });

  @override
  State<AiFloatingMascot> createState() => _AiFloatingMascotState();
}

class _AiFloatingMascotState extends State<AiFloatingMascot> with SingleTickerProviderStateMixin {
  // Session Flag: Intro animation plays once per app session
  static bool hasSeenAiIntro = false;

  bool _isVisible = false;
  bool _isFadingOut = false;

  late AnimationController _idleController;
  late Animation<double> _idleScaleAnimation;

  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();

    // Breathing Idle Scale Controller (1.00 -> 1.03 -> 1.00 every 2s)
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _idleScaleAnimation = Tween<double>(begin: 1.00, end: 1.03).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
    );

    if (hasSeenAiIntro) {
      // Session persistence: Show peeking mascot immediately without 2s delay
      _isVisible = true;
      _idleController.repeat(reverse: true);
    } else {
      // Step 1 & Step 2: Start hidden outside right edge, slide in after 2 seconds
      _startIntroSequence();
    }
  }

  void _startIntroSequence() {
    _delayTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isVisible = true;
      });

      // Step 5: Enter subtle breathing idle animation after slide-in completes
      Future.delayed(const Duration(milliseconds: 750), () {
        if (!mounted) return;
        _idleController.repeat(reverse: true);
        hasSeenAiIntro = true;
      });
    });
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _idleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (_isFadingOut) return;

    hasSeenAiIntro = true;

    setState(() {
      _isFadingOut = true;
    });

    // Chat Open Animation: Fade out mascot -> Open AI Assistant Chat
    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ChatbotScreen()),
      ).then((_) {
        if (!mounted) return;
        // On return to Home Screen, keep mascot visible peeking from right edge
        setState(() {
          _isFadingOut = false;
          _isVisible = true;
        });
        if (!_idleController.isAnimating) {
          _idleController.repeat(reverse: true);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // --------------------------------------------------------------------------
    // ⚙️ MASCOT POSITION CONFIGURATION (നിങ്ങൾക്ക് വേണമെങ്കിൽ ഇവിടെ മാറ്റങ്ങൾ വരുത്താം)
    // --------------------------------------------------------------------------
    // 1. Visible Peeking Position (-128.0 = 40-45% visible on screen)
    //    - കൂട്ടുമ്പോൾ (eg: -100.0) mascot കൂടുതൽ ഉള്ളിലേക്ക് വരും.
    //    - കുറയ്ക്കുമ്പോൾ (eg: -150.0) mascot കൂടുതൽ പുറത്തേക്ക് പോകും.
    const double peekingPositionOnScreen = -33.0;

    // 2. Offscreen Hidden Position (-240.0 = completely hidden outside right edge)
    const double hiddenPositionOffscreen = -240.0;

    // 3. Current Right Offset
    final rightOffset = _isVisible ? peekingPositionOnScreen : hiddenPositionOffscreen;

    return AnimatedPositioned(
      // ⏱️ Slide Animation Duration (എത്ര വേഗത്തിൽ വരണം)
      duration: const Duration(milliseconds: 700),
      // 📈 Slide Animation Curve (Bounce effect)
      curve: Curves.easeOutBack,
      right: rightOffset,
      // 📏 Bottom Floating Height (Footer/Bottom space height)
      bottom: 120.0,
      child: AnimatedOpacity(
        opacity: (_isFadingOut || widget.isHidden) ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: IgnorePointer(
          ignoring: _isFadingOut || widget.isHidden,
          child: GestureDetector(
            onTap: _handleTap,
            behavior: HitTestBehavior.opaque,
            child: ScaleTransition(
              scale: _idleScaleAnimation,
              child: SizedBox(
                // 📐 Mascot Image Size (Mascot-ന്റെ വലിപ്പം)
                width: 190,
                height: 190,
                child: Image.asset(
                  'assets/mascot/ai_assistant_peek.png',
                  width: 190,
                  height: 190,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/mascot/ai_assistant_peeking.png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
