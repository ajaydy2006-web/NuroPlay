import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/common_widgets.dart';

class ReactionTapGame extends StatefulWidget {
  const ReactionTapGame({super.key});

  @override
  State<ReactionTapGame> createState() => _ReactionTapGameState();
}

enum _ReactionState { waitingToStart, waitingForGreen, tapNow, tooEarly, result }

class _ReactionTapGameState extends State<ReactionTapGame> {
  _ReactionState _state = _ReactionState.waitingToStart;
  Timer? _delayTimer;
  DateTime? _greenStartTime;
  int _reactionTimeMs = 0;
  final List<int> _attempts = [];
  final Random _random = Random();

  void _startRound() {
    _delayTimer?.cancel();
    setState(() {
      _state = _ReactionState.waitingForGreen;
    });

    // Random delay between 1.5s and 4.0s
    final delayMs = 1500 + _random.nextInt(2500);
    _delayTimer = Timer(Duration(milliseconds: delayMs), () {
      if (mounted && _state == _ReactionState.waitingForGreen) {
        setState(() {
          _state = _ReactionState.tapNow;
          _greenStartTime = DateTime.now();
        });
      }
    });
  }

  void _onScreenTapped() {
    if (_state == _ReactionState.waitingToStart) {
      _startRound();
    } else if (_state == _ReactionState.waitingForGreen) {
      _delayTimer?.cancel();
      setState(() {
        _state = _ReactionState.tooEarly;
      });
    } else if (_state == _ReactionState.tapNow && _greenStartTime != null) {
      final elapsed = DateTime.now().difference(_greenStartTime!).inMilliseconds;
      setState(() {
        _reactionTimeMs = elapsed;
        _attempts.add(elapsed);
        _state = _ReactionState.result;
      });
    } else if (_state == _ReactionState.tooEarly || _state == _ReactionState.result) {
      _startRound();
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    super.dispose();
  }

  Color _getBgColor() {
    switch (_state) {
      case _ReactionState.waitingToStart:
        return AppColors.cardBg;
      case _ReactionState.waitingForGreen:
        return const Color(0xFFDC2626); // Bright Red
      case _ReactionState.tapNow:
        return const Color(0xFF16A34A); // Bright Green
      case _ReactionState.tooEarly:
        return const Color(0xFFD97706); // Orange Warning
      case _ReactionState.result:
        return AppColors.cardBg;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bestAttempt = _attempts.isNotEmpty ? _attempts.reduce(min) : 0;
    final avgAttempt = _attempts.isNotEmpty ? (_attempts.reduce((a, b) => a + b) ~/ _attempts.length) : 0;

    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Reaction Tap', style: AppTypography.heading4),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Stats bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('Attempts: ${_attempts.length}', style: AppTypography.bodySmall),
                  if (bestAttempt > 0)
                    Text('Best: ${bestAttempt}ms', style: AppTypography.labelSmall.copyWith(color: AppColors.warning)),
                  if (avgAttempt > 0)
                    Text('Avg: ${avgAttempt}ms', style: AppTypography.labelSmall.copyWith(color: AppColors.primaryAccent)),
                ],
              ),
            ),

            // Tap Area
            Expanded(
              child: GestureDetector(
                onTap: _onScreenTapped,
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _getBgColor(),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.divider, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: _getBgColor().withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildContent(),
                        ],
                      ),
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

  Widget _buildContent() {
    switch (_state) {
      case _ReactionState.waitingToStart:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.touch_app_rounded, size: 72, color: AppColors.primaryAccent),
            const SizedBox(height: 16),
            Text('Tap to Begin', style: AppTypography.heading2),
            const SizedBox(height: 8),
            Text(
              'When the screen turns RED, wait...\nWhen it turns GREEN, TAP AS FAST AS YOU CAN!',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium,
            ),
          ],
        );
      case _ReactionState.waitingForGreen:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.hourglass_top_rounded, size: 72, color: Colors.white),
            const SizedBox(height: 16),
            Text('WAIT FOR GREEN...', style: AppTypography.heading2.copyWith(color: Colors.white)),
            const SizedBox(height: 8),
            Text('Do not tap yet!', style: AppTypography.bodyMedium.copyWith(color: Colors.white70)),
          ],
        );
      case _ReactionState.tapNow:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.flash_on_rounded, size: 90, color: Colors.white),
            const SizedBox(height: 16),
            Text('TAP NOW!', style: AppTypography.heading1.copyWith(color: Colors.white, fontSize: 44)),
          ],
        );
      case _ReactionState.tooEarly:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 72, color: Colors.white),
            const SizedBox(height: 16),
            Text('Too Early! ⚠️', style: AppTypography.heading2.copyWith(color: Colors.white)),
            const SizedBox(height: 8),
            Text('You tapped before it turned green. Tap to retry.', style: AppTypography.bodyMedium.copyWith(color: Colors.white70), textAlign: TextAlign.center),
          ],
        );
      case _ReactionState.result:
        final rating = _reactionTimeMs < 200
            ? '⚡ GODLIKE REFLEXES!'
            : _reactionTimeMs < 250
                ? '🔥 PRO GAMER SPEED!'
                : _reactionTimeMs < 350
                    ? '🎯 SHARP REFLEXES'
                    : '🌱 KEEP PRACTICING';

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$_reactionTimeMs', style: AppTypography.monoLarge.copyWith(fontSize: 64, color: AppColors.primaryAccent)),
            Text('MILLISECONDS', style: AppTypography.labelMedium.copyWith(color: AppColors.secondaryText, letterSpacing: 2)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryAccent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(rating, style: AppTypography.labelLarge.copyWith(color: AppColors.primaryAccent)),
            ),
            const SizedBox(height: 24),
            Text('Tap anywhere to try again', style: AppTypography.bodySmall),
          ],
        );
    }
  }
}
