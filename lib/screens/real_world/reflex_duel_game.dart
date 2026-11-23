import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'realistic_game_components.dart';

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
      backgroundColor: const Color(0xFF18100C),
      body: RealisticWoodTableSurface(
        isDarkWood: true,
        child: SafeArea(
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
                      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: const RadialGradient(
                          colors: [
                            Color(0xFF2C241E),
                            Color(0xFF19120E),
                            Color(0xFF0F0B08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: _state == _DuelState.activeGreen
                              ? const Color(0xFF22C55E)
                              : _state == _DuelState.waitingForGreen
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF5D4037),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_state == _DuelState.activeGreen
                                    ? const Color(0xFF22C55E)
                                    : _state == _DuelState.waitingForGreen
                                        ? const Color(0xFFEF4444)
                                        : Colors.black)
                                .withOpacity(0.45),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isTwoPlayer ? 'PLAYER 2' : 'AI OPPONENT 🤖',
                              style: AppTypography.labelLarge.copyWith(
                                color: _state == _DuelState.activeGreen ? const Color(0xFF4ADE80) : const Color(0xFFFFD54F),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // 3D Physical Dome Buzzer
                            _buildTactileArcadeBuzzer(
                              score: _p2Score,
                              isActiveGreen: _state == _DuelState.activeGreen,
                              isWaitingRed: _state == _DuelState.waitingForGreen,
                              colorAccent: const Color(0xFFF97316),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _state == _DuelState.activeGreen
                                  ? 'TAP INSTANTLY!'
                                  : _state == _DuelState.waitingForGreen
                                      ? 'DO NOT TAP!'
                                      : 'Tap on Green',
                              style: AppTypography.bodySmall.copyWith(
                                color: _state == _DuelState.activeGreen
                                    ? const Color(0xFF4ADE80)
                                    : Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

              // Middle Control & Status Divider (Polished mahogany / gold strip)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3E2723), Color(0xFF2B1810), Color(0xFF1E100B)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: const Border.symmetric(
                    horizontal: BorderSide(color: Color(0xFFC5A059), width: 1.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2C2416), size: 16),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _roundWinnerMessage,
                            style: AppTypography.labelSmall.copyWith(
                              color: _state == _DuelState.activeGreen
                                  ? const Color(0xFF4ADE80)
                                  : _state == _DuelState.waitingForGreen
                                      ? const Color(0xFFF87171)
                                      : Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                          Text('First to $_targetScore points wins', style: AppTypography.captionSmall.copyWith(fontSize: 10, color: const Color(0xFFFFD54F))),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_state == _DuelState.ready || _state == _DuelState.roundResult)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7E52FF),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _startRound,
                        child: const Text('Start', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      )
                    else if (_state == _DuelState.matchOver)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF22C55E),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _resetMatch,
                        child: const Text('Rematch', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
                    margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const RadialGradient(
                        colors: [
                          Color(0xFF2C241E),
                          Color(0xFF19120E),
                          Color(0xFF0F0B08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: _state == _DuelState.activeGreen
                            ? const Color(0xFF22C55E)
                            : _state == _DuelState.waitingForGreen
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF5D4037),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_state == _DuelState.activeGreen
                                  ? const Color(0xFF22C55E)
                                  : _state == _DuelState.waitingForGreen
                                      ? const Color(0xFFEF4444)
                                      : Colors.black)
                              .withOpacity(0.45),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'PLAYER 1',
                            style: AppTypography.labelLarge.copyWith(
                              color: _state == _DuelState.activeGreen ? const Color(0xFF4ADE80) : const Color(0xFF7E52FF),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // 3D Physical Dome Buzzer
                          _buildTactileArcadeBuzzer(
                            score: _p1Score,
                            isActiveGreen: _state == _DuelState.activeGreen,
                            isWaitingRed: _state == _DuelState.waitingForGreen,
                            colorAccent: const Color(0xFF7E52FF),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _state == _DuelState.activeGreen
                                ? 'TAP INSTANTLY!'
                                : _state == _DuelState.waitingForGreen
                                    ? 'DO NOT TAP!'
                                    : 'Tap on Green',
                            style: AppTypography.bodySmall.copyWith(
                              color: _state == _DuelState.activeGreen
                                  ? const Color(0xFF4ADE80)
                                  : Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
      ),
    );
  }

  Widget _buildTactileArcadeBuzzer({
    required int score,
    required bool isActiveGreen,
    required bool isWaitingRed,
    required Color colorAccent,
  }) {
    final domeColors = isActiveGreen
        ? [const Color(0xFF86EFAC), const Color(0xFF22C55E), const Color(0xFF15803D)]
        : isWaitingRed
            ? [const Color(0xFFFCA5A5), const Color(0xFFEF4444), const Color(0xFF991B1B)]
            : [const Color(0xFF64748B), const Color(0xFF334155), const Color(0xFF1E293B)];

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        width: 140,
        height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFE2E8F0), Color(0xFF94A3B8), Color(0xFF475569)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 116,
          height: 116,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: domeColors,
              center: const Alignment(-0.3, -0.3),
              radius: 0.85,
            ),
            boxShadow: [
              BoxShadow(
                color: (isActiveGreen ? const Color(0xFF22C55E) : isWaitingRed ? const Color(0xFFEF4444) : Colors.black).withOpacity(0.5),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              '$score',
              style: AppTypography.monoLarge.copyWith(
                fontSize: 52,
                color: Colors.white,
                fontWeight: FontWeight.w900,
                shadows: const [
                  Shadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 2)),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
