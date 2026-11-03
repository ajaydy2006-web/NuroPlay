import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/common_widgets.dart';
import '../../services/storage_service.dart';

class PaperFootballGame extends StatefulWidget {
  const PaperFootballGame({super.key});

  @override
  State<PaperFootballGame> createState() => _PaperFootballGameState();
}

enum _FootballPhase { sliding, fieldGoal, roundOver }

class _PaperFootballGameState extends State<PaperFootballGame> with SingleTickerProviderStateMixin {
  late AnimationController _ticker;

  // Fixed virtual desk dimensions for consistent physics on all phone screens
  static const double tableWidth = 340.0;
  static const double tableHeight = 520.0;

  // Table dimensions & ball state
  Offset _ballPos = const Offset(tableWidth / 2, 440);
  Offset _ballVel = Offset.zero;
  double _ballAngle = 0.0;
  bool _isMoving = false;
  Offset? _dragStart;
  Offset? _dragCurrent;

  int _playerScore = 0;
  int _opponentScore = 0;
  int _round = 1;
  static const int _maxRounds = 5;
  bool _isPlayerTurn = true;
  _FootballPhase _phase = _FootballPhase.sliding;
  String _statusMessage = 'Flick the paper triangle toward the table edge!';

  final double _ballRadius = 20.0;

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..addListener(_updatePhysics)
      ..repeat();

    _resetBall();
  }

  void _resetBall() {
    setState(() {
      _ballPos = _isPlayerTurn ? const Offset(tableWidth / 2, 440) : const Offset(tableWidth / 2, 80);
      _ballVel = Offset.zero;
      _ballAngle = 0.0;
      _isMoving = false;
      _dragStart = null;
      _dragCurrent = null;
      _phase = _FootballPhase.sliding;
      _statusMessage = _isPlayerTurn
          ? 'Your turn! Flick gently to stop near the top edge.'
          : 'AI is taking their flick...';
    });

    if (!_isPlayerTurn) {
      _executeAiTurn();
    }
  }

  void _executeAiTurn() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted || _isPlayerTurn) return;
      // AI flick with slight random variation
      final targetVelY = 11.5 + Random().nextDouble() * 3.0;
      final targetVelX = (Random().nextDouble() - 0.5) * 3.5;
      setState(() {
        _ballVel = Offset(targetVelX, targetVelY);
        _isMoving = true;
      });
    });
  }

  void _updatePhysics() {
    if (!_isMoving) return;

    setState(() {
      _ballPos += _ballVel;
      _ballAngle += _ballVel.distance * 0.05;
      // Friction deceleration
      _ballVel = _ballVel * 0.955;

      // Left / Right cushion bounce
      if (_ballPos.dx < _ballRadius) {
        _ballPos = Offset(_ballRadius, _ballPos.dy);
        _ballVel = Offset(-_ballVel.dx * 0.7, _ballVel.dy);
      } else if (_ballPos.dx > tableWidth - _ballRadius) {
        _ballPos = Offset(tableWidth - _ballRadius, _ballPos.dy);
        _ballVel = Offset(-_ballVel.dx * 0.7, _ballVel.dy);
      }

      // Check if velocity is nearly zero
      if (_ballVel.distance < 0.25) {
        _ballVel = Offset.zero;
        _isMoving = false;
        _evaluateSlideOutcome(tableHeight);
      }
    });
  }

  void _evaluateSlideOutcome(double height) {
    if (_phase != _FootballPhase.sliding) return;

    if (_isPlayerTurn) {
      // Player target is top edge (y near 0)
      if (_ballPos.dy < 0) {
        // Flew off edge
        _statusMessage = 'Flew off the table! Turnover! ❌';
        _endTurn(false, 0);
      } else if (_ballPos.dy <= 45) {
        // Touchdown! Hanging over the edge!
        _statusMessage = 'TOUCHDOWN! +6 POINTS! 🎉 Kick field goal!';
        _playerScore += 6;
        _phase = _FootballPhase.fieldGoal;
        _ballPos = const Offset(tableWidth / 2, 440);
      } else {
        _statusMessage = 'Short of the edge! No touchdown.';
        _endTurn(false, 0);
      }
    } else {
      // AI target is bottom edge (y near height)
      if (_ballPos.dy > height) {
        _statusMessage = 'AI flew off the edge! Your turn.';
        _endTurn(true, 0);
      } else if (_ballPos.dy >= height - 45) {
        _statusMessage = 'AI scored a Touchdown! +6 points.';
        _opponentScore += 6;
        _endTurn(true, 0);
      } else {
        _statusMessage = 'AI came up short.';
        _endTurn(true, 0);
      }
    }
  }

  void _endTurn(bool nextIsPlayer, int points) {
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      if (_round >= _maxRounds && !_isPlayerTurn) {
        _phase = _FootballPhase.roundOver;
        StorageService.setPersonalBest('paper_football', _playerScore);
        setState(() {});
      } else {
        if (!_isPlayerTurn) _round++;
        _isPlayerTurn = nextIsPlayer;
        _resetBall();
      }
    });
  }

  void _onPanStart(DragStartDetails details) {
    if (_isMoving || !_isPlayerTurn || _phase == _FootballPhase.roundOver) return;
    _dragStart = details.localPosition;
    _dragCurrent = details.localPosition;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_dragStart == null) return;
    setState(() {
      _dragCurrent = details.localPosition;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_dragStart == null || _dragCurrent == null) return;

    final diff = _dragStart! - _dragCurrent!;
    final speed = diff.distance.clamp(10.0, 180.0) * 0.16;
    final angle = atan2(diff.dy, diff.dx);

    setState(() {
      _ballVel = Offset(cos(angle) * speed, sin(angle) * speed);
      _isMoving = true;
      _dragStart = null;
      _dragCurrent = null;
    });

    if (_phase == _FootballPhase.fieldGoal) {
      // Evaluate field goal: must pass between top uprights
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        if (_ballPos.dx >= 70 && _ballPos.dx <= 270 && _ballPos.dy < 100) {
          _statusMessage = 'FIELD GOAL IS GOOD! +1 EXTRA POINT! 🏈';
          _playerScore += 1;
        } else {
          _statusMessage = 'Field Goal missed wide!';
        }
        _endTurn(false, 0);
      });
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: NeonRiseBackground(
        showMiddleBeam: true,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                // Top App Bar
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryText, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text('Paper Football Tabletop', style: AppTypography.heading3, textAlign: TextAlign.center),
                    ),
                    IconButton(
                      icon: const Icon(Icons.replay_rounded, color: AppColors.primaryAccent),
                      onPressed: () {
                        setState(() {
                          _playerScore = 0;
                          _opponentScore = 0;
                          _round = 1;
                          _isPlayerTurn = true;
                        });
                        _resetBall();
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Scoreboard
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildScorePill('You', _playerScore, AppColors.primaryAccent),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Text('Round $_round/$_maxRounds', style: AppTypography.labelSmall),
                    ),
                    _buildScorePill('AI Opponent', _opponentScore, AppColors.secondaryAccent),
                  ],
                ),

                const SizedBox(height: 6),

                // Instruction Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.elevatedCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryAccent.withOpacity(0.3)),
                  ),
                  child: Text(
                    _statusMessage,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.primaryText),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 8),

                // Responsive Desk Surface scaled to any phone screen
                Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        width: tableWidth,
                        height: tableHeight,
                        child: GestureDetector(
                          onPanStart: _onPanStart,
                          onPanUpdate: _onPanUpdate,
                          onPanEnd: _onPanEnd,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.primaryAccent.withOpacity(0.4), width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryAccent.withOpacity(0.12),
                                  blurRadius: 18,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Endzone lines
                                Positioned(
                                  top: 40,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 2,
                                    color: AppColors.primaryAccent.withOpacity(0.4),
                                  ),
                                ),
                                Positioned(
                                  top: 10,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: Text(
                                      'OPPONENT ENDZONE (TOUCHDOWN EDGE)',
                                      style: AppTypography.labelSmall.copyWith(
                                        fontSize: 9,
                                        color: AppColors.primaryAccent.withOpacity(0.6),
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ),

                                Positioned(
                                  bottom: 40,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 2,
                                    color: AppColors.secondaryAccent.withOpacity(0.4),
                                  ),
                                ),
                                Positioned(
                                  bottom: 12,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: Text(
                                      'YOUR LAUNCH ZONE',
                                      style: AppTypography.labelSmall.copyWith(
                                        fontSize: 9,
                                        color: AppColors.secondaryAccent.withOpacity(0.6),
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ),

                                // Goalposts if in Field Goal phase
                                if (_phase == _FootballPhase.fieldGoal)
                                  Positioned(
                                    top: 2,
                                    left: 70,
                                    right: 70,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(width: 8, height: 35, color: AppColors.warning),
                                        Text('GOAL POST', style: AppTypography.labelSmall.copyWith(color: AppColors.warning, fontSize: 10)),
                                        Container(width: 8, height: 35, color: AppColors.warning),
                                      ],
                                    ),
                                  ),

                                // Drag trajectory aiming line
                                if (_dragStart != null && _dragCurrent != null)
                                  CustomPaint(
                                    size: const Size(tableWidth, tableHeight),
                                    painter: _AimPainter(start: _dragStart!, current: _dragCurrent!),
                                  ),

                                // The Paper Triangle Football
                                Positioned(
                                  left: _ballPos.dx - _ballRadius,
                                  top: _ballPos.dy - _ballRadius,
                                  child: Transform.rotate(
                                    angle: _ballAngle,
                                    child: CustomPaint(
                                      size: Size(_ballRadius * 2, _ballRadius * 2),
                                      painter: _PaperTrianglePainter(),
                                    ),
                                  ),
                                ),

                                // Round Over Overlay
                                if (_phase == _FootballPhase.roundOver)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.85),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text('🏆', style: TextStyle(fontSize: 48)),
                                          const SizedBox(height: 12),
                                          Text(
                                            _playerScore > _opponentScore
                                                ? 'VICTORY!'
                                                : _playerScore == _opponentScore
                                                    ? 'TIED MATCH!'
                                                    : 'DEFEAT!',
                                            style: AppTypography.heading1.copyWith(
                                              color: _playerScore >= _opponentScore ? AppColors.primaryAccent : AppColors.error,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Final: You $_playerScore — $_opponentScore AI',
                                            style: AppTypography.monoMedium,
                                          ),
                                          const SizedBox(height: 20),
                                          MindRushButton(
                                            label: 'Play Again',
                                            onPressed: () {
                                              setState(() {
                                                _playerScore = 0;
                                                _opponentScore = 0;
                                                _round = 1;
                                                _isPlayerTurn = true;
                                              });
                                              _resetBall();
                                            },
                                          ),
                                        ],
                                      ),
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

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScorePill(String label, int score, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Text(label, style: AppTypography.captionSmall.copyWith(color: AppColors.secondaryText)),
          const SizedBox(height: 2),
          Text('$score', style: AppTypography.monoLarge.copyWith(fontSize: 20, color: color)),
        ],
      ),
    );
  }
}

class _PaperTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(size.width / 2, 0); // Top tip
    path.lineTo(size.width, size.height); // Bottom right
    path.lineTo(0, size.height); // Bottom left
    path.close();

    // Paper white fill
    final paint = Paint()
      ..color = const Color(0xFFF8FAFC)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);

    // Subtle paper fold shading
    final foldPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), foldPaint);
    canvas.drawPath(path, foldPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AimPainter extends CustomPainter {
  final Offset start;
  final Offset current;

  _AimPainter({required this.start, required this.current});

  @override
  void paint(Canvas canvas, Size size) {
    final diff = start - current;
    final target = start + Offset(diff.dx * 1.6, diff.dy * 1.6);

    final paint = Paint()
      ..color = AppColors.primaryAccent
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(start, target, paint);
    canvas.drawCircle(target, 5, Paint()..color = AppColors.primaryAccent);
  }

  @override
  bool shouldRepaint(covariant _AimPainter old) => old.start != start || old.current != current;
}
