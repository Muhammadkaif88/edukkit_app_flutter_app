import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../screens/chatbot/chatbot_screen.dart';

/// Edukkit AI Assistant Floating Mascot Widget (Home Screen Only)
/// ---------------------------------------------------------------
/// 1. Only visible when user is at top screen section (not scrolled down).
/// 2. Hides smoothly offscreen when scrolling down.
/// 3. Continuously cycles: Visible on screen for 60 seconds -> Hidden for 30 seconds -> Repeat.
/// 4. Breathing idle scale animation while visible.
/// 5. Tapping opens ChatbotScreen.
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
  bool _isCycleVisible = true; // True for 60s show phase, False for 30s hide phase
  bool _isFadingOut = false;

  late AnimationController _idleController;
  late Animation<double> _idleScaleAnimation;

  Timer? _cycleTimer;

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

    _idleController.repeat(reverse: true);

    // Start 60s visible -> 30s hidden repeating cycle
    _startCycleTimer();
  }

  void _startCycleTimer() {
    _cycleTimer?.cancel();
    _isCycleVisible = true;
    // 5 seconds visible phase, then switch to hidden (false)
    _scheduleNextCyclePhase(const Duration(seconds: 5), false);
  }

  void _scheduleNextCyclePhase(Duration duration, bool nextVisibleState) {
    _cycleTimer = Timer(duration, () {
      if (!mounted) return;
      setState(() {
        _isCycleVisible = nextVisibleState;
      });

      if (nextVisibleState) {
        // Visible phase for 5 seconds -> Next phase hidden (false)
        _scheduleNextCyclePhase(const Duration(seconds: 5), false);
      } else {
        // Hidden phase for 5 seconds -> Next phase visible (true)
        _scheduleNextCyclePhase(const Duration(seconds: 5), true);
      }
    });
  }

  @override
  void dispose() {
    _cycleTimer?.cancel();
    _idleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (_isFadingOut) return;

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
        setState(() {
          _isFadingOut = false;
        });
        // Reset 60s visible cycle when returning from chat screen
        _startCycleTimer();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // --------------------------------------------------------------------------
    // ⚙️ MASCOT POSITION CONFIGURATION
    // --------------------------------------------------------------------------
    // 1. Visible Peeking Position (-33.0)
    const double peekingPositionOnScreen = -32.0;

    // 2. Offscreen Hidden Position (-240.0)
    const double hiddenPositionOffscreen = -240.0;

    // Mascot is visible ONLY if 60s cycle is active AND user is at top screen (!widget.isHidden)
    final bool shouldBeVisible = _isCycleVisible && !widget.isHidden && !_isFadingOut;
    final rightOffset = shouldBeVisible ? peekingPositionOnScreen : hiddenPositionOffscreen;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutBack,
      right: rightOffset,
      bottom: 120,
      child: AnimatedOpacity(
        opacity: shouldBeVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: IgnorePointer(
          ignoring: !shouldBeVisible,
          child: GestureDetector(
            onTap: _handleTap,
            behavior: HitTestBehavior.opaque,
            child: ScaleTransition(
              scale: _idleScaleAnimation,
              child: SizedBox(
                width: 190,
                height: 190,
                child: Image.asset(
                  'assets/mascot/ai_assistant_peek.png',
                  width: 185,
                  height: 185,
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

