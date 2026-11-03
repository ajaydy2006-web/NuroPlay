import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class ReflexDuelGame extends StatefulWidget {
  const ReflexDuelGame({super.key});

  @override
  State<ReflexDuelGame> createState() => _ReflexDuelGameState();
}

enum _DuelState { ready, waitingForGreen, activeGreen, roundResult, matchOver }

class _ReflexDuelGameState extends State<ReflexDuelGame> {
  bool _isTwoPlayer = true; // true = 2-player split screen, false = vs AI
  _DuelState _state = _DuelState.ready;

  int _p1Score = 0; // Bottom player
  int _p2Score = 0; // Top player / AI
  static const int _targetScore = 5;

  Timer? _delayTimer;
  DateTime? _greenTime;
  String _roundWinnerMessage = 'Tap "Start Round" to begin';
  final Random _random = Random();

  void _startRound() {
    _delayTimer?.cancel();
    setState(() {
      _state = _DuelState.waitingForGreen;
      _roundWinnerMessage = 'WAIT FOR GREEN...';
    });

    final delay = 2000 + _random.nextInt(3000); // 2.0s to 5.0s
    _delayTimer = Timer(Duration(milliseconds: delay), () {
      if (!mounted || _state != _DuelState.waitingForGreen) return;
      setState(() {
        _state = _DuelState.activeGreen;
        _greenTime = DateTime.now();
        _roundWinnerMessage = 'TAP NOW!';
      });

      // If playing vs AI, simulate AI reaction time
      if (!_isTwoPlayer) {
        final aiReactionMs = 240 + _random.nextInt(180); // 240ms - 420ms
        Future.delayed(Duration(milliseconds: aiReactionMs), () {
          if (mounted && _state == _DuelState.activeGreen) {
            _onP2Tapped(isAi: true);
          }
        });
      }
    });
  }

  void _onP1Tapped() {
    if (_state == _DuelState.waitingForGreen) {
      // False start! P1 tapped prematurely, point goes to P2
      _delayTimer?.cancel();
      _awardPoint(2, 'Player 1 False Start! Point to Player 2.');
    } else if (_state == _DuelState.activeGreen && _greenTime != null) {
      final ms = DateTime.now().difference(_greenTime!).inMilliseconds;
      _awardPoint(1, 'Player 1 wins round in ${ms}ms! ⚡');
    }
  }

  void _onP2Tapped({bool isAi = false}) {
    if (_state == _DuelState.waitingForGreen) {
      // False start! P2 tapped prematurely, point goes to P1
      _delayTimer?.cancel();
      _awardPoint(1, '${isAi ? "AI" : "Player 2"} False Start! Point to Player 1.');
    } else if (_state == _DuelState.activeGreen && _greenTime != null) {
      final ms = DateTime.now().difference(_greenTime!).inMilliseconds;
      _awardPoint(2, '${isAi ? "AI" : "Player 2"} wins round in ${ms}ms! ⚡');
    }
  }

  void _awardPoint(int player, String msg) {
    setState(() {
      if (player == 1) _p1Score++;
      if (player == 2) _p2Score++;
      _roundWinnerMessage = msg;
      _state = (_p1Score >= _targetScore || _p2Score >= _targetScore)
          ? _DuelState.matchOver
          : _DuelState.roundResult;
    });
  }

  void _resetMatch() {
    _delayTimer?.cancel();
    setState(() {
      _p1Score = 0;
      _p2Score = 0;
      _state = _DuelState.ready;
      _roundWinnerMessage = 'Tap "Start Round" to begin';
    });
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Half (Player 2 / AI) - inverted 180 degrees if 2-player for face-to-face play!
            Expanded(
              child: RotatedBox(
                quarterTurns: _isTwoPlayer ? 2 : 0,
                child: GestureDetector(
                  onTap: () => _onP2Tapped(),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _state == _DuelState.activeGreen
                          ? AppColors.success.withOpacity(0.3)
                          : _state == _DuelState.waitingForGreen
                              ? AppColors.error.withOpacity(0.25)
                              : AppColors.cardBg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _state == _DuelState.activeGreen ? AppColors.success : AppColors.secondaryAccent,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_state == _DuelState.activeGreen ? AppColors.success : AppColors.secondaryAccent).withOpacity(0.15),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isTwoPlayer ? 'PLAYER 2' : 'AI OPPONENT 🤖',
                            style: AppTypography.labelLarge.copyWith(color: AppColors.secondaryAccent),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$_p2Score',
                            style: AppTypography.monoLarge.copyWith(fontSize: 60, color: AppColors.secondaryAccent),
                          ),
                          const SizedBox(height: 6),
                          Text('Tap this half on Green', style: AppTypography.bodySmall.copyWith(color: AppColors.secondaryText)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Middle Control & Status Divider (Electrifying neon bar)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.elevatedCard,
                border: const Border.symmetric(horizontal: BorderSide(color: AppColors.divider)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryAccent.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.secondaryText, size: 18),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _roundWinnerMessage,
                          style: AppTypography.labelSmall.copyWith(
                            color: _state == _DuelState.activeGreen ? AppColors.success : AppColors.primaryText,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        Text('First to $_targetScore points wins', style: AppTypography.captionSmall.copyWith(fontSize: 10, color: AppColors.secondaryText)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (_state == _DuelState.ready || _state == _DuelState.roundResult)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      onPressed: _startRound,
                      child: const Text('Start'),
                    )
                  else if (_state == _DuelState.matchOver)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      onPressed: _resetMatch,
                      child: const Text('Rematch'),
                    )
                  else
                    const SizedBox(width: 44),
                ],
              ),
            ),

            // Bottom Half (Player 1)
            Expanded(
              child: GestureDetector(
                onTap: _onP1Tapped,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _state == _DuelState.activeGreen
                        ? AppColors.success.withOpacity(0.3)
                        : _state == _DuelState.waitingForGreen
                            ? AppColors.error.withOpacity(0.25)
                            : AppColors.cardBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _state == _DuelState.activeGreen ? AppColors.success : AppColors.primaryAccent,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (_state == _DuelState.activeGreen ? AppColors.success : AppColors.primaryAccent).withOpacity(0.15),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('PLAYER 1', style: AppTypography.labelLarge.copyWith(color: AppColors.primaryAccent)),
                        const SizedBox(height: 8),
                        Text(
                          '$_p1Score',
                          style: AppTypography.monoLarge.copyWith(fontSize: 60, color: AppColors.primaryAccent),
                        ),
                        const SizedBox(height: 6),
                        Text('Tap this half on Green', style: AppTypography.bodySmall.copyWith(color: AppColors.secondaryText)),
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
}
