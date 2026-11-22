import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/common_widgets.dart';
import 'realistic_game_components.dart';

class RpsShowdownGame extends StatefulWidget {
  const RpsShowdownGame({super.key});

  @override
  State<RpsShowdownGame> createState() => _RpsShowdownGameState();
}

enum _RpsChoice { rock, paper, scissors }
enum _RpsPhase { choose, countdown, reveal, matchOver }

class _RpsShowdownGameState extends State<RpsShowdownGame> {
  int _targetWins = 3; // Best of 5 (first to 3)
  int _playerScore = 0;
  int _aiScore = 0;
  int _draws = 0;
  int _streak = 0;
  bool _isTwoPlayer = false;

  _RpsChoice? _playerChoice;
  _RpsChoice? _p2SecretChoice;
  _RpsChoice? _aiChoice;
  String _outcomeText = 'Select your move to throw!';
  _RpsPhase _phase = _RpsPhase.choose;
  int _countdownValue = 3;

  final Random _random = Random();
  final List<_RpsChoice> _playerHistory = [];

  void _onPlayerSelected(_RpsChoice choice) {
    if (_phase != _RpsPhase.choose) return;

    if (_isTwoPlayer) {
      if (_playerChoice == null) {
        // Player 1 picked, wait for Player 2
        setState(() {
          _playerChoice = choice;
          _outcomeText = 'Player 1 locked in! 🔒 Pass to Player 2.';
        });
      } else {
        // Player 2 picked!
        _p2SecretChoice = choice;
        setState(() {
          _phase = _RpsPhase.countdown;
          _countdownValue = 3;
        });

        Timer.periodic(const Duration(milliseconds: 300), (timer) {
          if (_countdownValue > 1) {
            setState(() => _countdownValue--);
          } else {
            timer.cancel();
            _evaluateTwoPlayerRound();
          }
        });
      }
      return;
    }

    setState(() {
      _playerChoice = choice;
      _playerHistory.add(choice);
      _phase = _RpsPhase.countdown;
      _countdownValue = 3;
    });

    // 3.. 2.. 1.. SHOOT!
    Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (_countdownValue > 1) {
        setState(() => _countdownValue--);
      } else {
        timer.cancel();
        _evaluateRound(choice);
      }
    });
  }

  void _evaluateTwoPlayerRound() {
    final p1 = _playerChoice!;
    final p2 = _p2SecretChoice!;

    String result;
    if (p1 == p2) {
      result = 'Draw!';
      _draws++;
    } else if ((p1 == _RpsChoice.rock && p2 == _RpsChoice.scissors) ||
        (p1 == _RpsChoice.paper && p2 == _RpsChoice.rock) ||
        (p1 == _RpsChoice.scissors && p2 == _RpsChoice.paper)) {
      result = 'Player 1 Wins Round! 🎉';
      _playerScore++;
    } else {
      result = 'Player 2 Wins Round! ⚡';
      _aiScore++;
    }

    setState(() {
      _aiChoice = p2;
      _outcomeText = result;
      _phase = _RpsPhase.reveal;
    });

    if (_playerScore >= _targetWins || _aiScore >= _targetWins) {
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (!mounted) return;
        setState(() {
          _phase = _RpsPhase.matchOver;
        });
      });
    } else {
      Future.delayed(const Duration(milliseconds: 1800), () {
        if (!mounted) return;
        setState(() {
          _phase = _RpsPhase.choose;
          _playerChoice = null;
          _p2SecretChoice = null;
          _aiChoice = null;
          _outcomeText = 'Player 1: Select your move!';
        });
      });
    }
  }

  void _evaluateRound(_RpsChoice pChoice) {
    // AI move with pattern counter
    final aiChoice = _getAiMove();

    String result;
    if (pChoice == aiChoice) {
      result = 'Draw!';
      _draws++;
    } else if ((pChoice == _RpsChoice.rock && aiChoice == _RpsChoice.scissors) ||
        (pChoice == _RpsChoice.paper && aiChoice == _RpsChoice.rock) ||
        (pChoice == _RpsChoice.scissors && aiChoice == _RpsChoice.paper)) {
      result = 'You Win This Round! 🎉';
      _playerScore++;
      _streak++;
    } else {
      result = 'AI Wins This Round! 🤖';
      _aiScore++;
      _streak = 0;
    }

    setState(() {
      _aiChoice = aiChoice;
      _outcomeText = result;
      _phase = _RpsPhase.reveal;
    });

    if (_playerScore >= _targetWins || _aiScore >= _targetWins) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        setState(() {
          _phase = _RpsPhase.matchOver;
        });
      });
    } else {
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (!mounted) return;
        setState(() {
          _phase = _RpsPhase.choose;
          _playerChoice = null;
          _aiChoice = null;
          _outcomeText = 'Make your next move!';
        });
      });
    }
  }

  _RpsChoice _getAiMove() {
    // 70% random, 30% counters player's most frequent move
    if (_playerHistory.length > 3 && _random.nextDouble() < 0.35) {
      final rockCount = _playerHistory.where((c) => c == _RpsChoice.rock).length;
      final paperCount = _playerHistory.where((c) => c == _RpsChoice.paper).length;
      final scissorsCount = _playerHistory.where((c) => c == _RpsChoice.scissors).length;

      if (rockCount >= paperCount && rockCount >= scissorsCount) {
        return _RpsChoice.paper; // Counter rock
      } else if (paperCount >= scissorsCount) {
        return _RpsChoice.scissors; // Counter paper
      } else {
        return _RpsChoice.rock; // Counter scissors
      }
    }
    return _RpsChoice.values[_random.nextInt(3)];
  }

  String _getEmoji(_RpsChoice choice) {
    switch (choice) {
      case _RpsChoice.rock: return '✊';
      case _RpsChoice.paper: return '✋';
      case _RpsChoice.scissors: return '✌️';
    }
  }

  String _getLabel(_RpsChoice choice) {
    switch (choice) {
      case _RpsChoice.rock: return 'Rock';
      case _RpsChoice.paper: return 'Paper';
      case _RpsChoice.scissors: return 'Scissors';
    }
  }

  void _resetMatch() {
    setState(() {
      _playerScore = 0;
      _aiScore = 0;
      _draws = 0;
      _streak = 0;
      _playerChoice = null;
      _p2SecretChoice = null;
      _aiChoice = null;
      _phase = _RpsPhase.choose;
      _outcomeText = _isTwoPlayer ? 'Player 1: Select your move!' : 'Select your move to throw!';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C1E14),
      body: RealisticWoodTableSurface(
        isDarkWood: false,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                // Top App Bar
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2C2416), size: 18),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Rock Paper Scissors', style: AppTypography.heading3.copyWith(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                          Text(
                            _isTwoPlayer ? '2P Secret Pass & Play' : 'vs AI Opponent',
                            style: AppTypography.captionSmall.copyWith(
                              color: const Color(0xFFFFD54F),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Mode Toggle (AI / 2P)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (_isTwoPlayer) {
                                setState(() {
                                  _isTwoPlayer = false;
                                  _resetMatch();
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: !_isTwoPlayer ? const Color(0xFF7E52FF) : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'AI',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: !_isTwoPlayer ? Colors.white : const Color(0xFF5D4037),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (!_isTwoPlayer) {
                                setState(() {
                                  _isTwoPlayer = true;
                                  _resetMatch();
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: _isTwoPlayer ? const Color(0xFF7E52FF) : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '2P',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _isTwoPlayer ? Colors.white : const Color(0xFF5D4037),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.replay_rounded, color: Color(0xFF7E52FF), size: 18),
                        onPressed: _resetMatch,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Target Wins Selector (First to 3, 5, 7)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [3, 5, 7].map((target) {
                    final isSel = _targetWins == target;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _targetWins = target);
                        _resetMatch();
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFF7E52FF) : Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'First to $target',
                          style: AppTypography.labelSmall.copyWith(
                            color: isSel ? Colors.white : const Color(0xFF2C2416),
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 8),

                // Scoreboard
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildScorePill(_isTwoPlayer ? 'Player 1' : 'You', _playerScore, const Color(0xFF7E52FF)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text('Draws: $_draws', style: AppTypography.bodySmall.copyWith(color: const Color(0xFF5D4037), fontWeight: FontWeight.bold)),
                    ),
                    _buildScorePill(_isTwoPlayer ? 'Player 2' : 'AI Bot', _aiScore, const Color(0xFFF97316)),
                  ],
                ),

                const SizedBox(height: 8),

                // Status message
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    _outcomeText,
                    style: AppTypography.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 8),

                // Responsive Realistic Felt Tabletop Playmat Arena
                Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Container(
                        width: 320,
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        decoration: BoxDecoration(
                          gradient: const RadialGradient(
                            colors: [
                              Color(0xFF1B4D3E),
                              Color(0xFF0F2E25),
                              Color(0xFF091C16),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFC5A059), width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: _phase == _RpsPhase.countdown
                            ? Center(
                                child: Text(
                                  '$_countdownValue',
                                  style: AppTypography.monoLarge.copyWith(fontSize: 64, color: const Color(0xFFFFD54F)),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  // Player 1 Realistic Card
                                  _buildPhysicalPlayCard(
                                    emoji: _phase == _RpsPhase.choose && _isTwoPlayer && _playerChoice != null
                                        ? '🔒'
                                        : _playerChoice != null
                                            ? _getEmoji(_playerChoice!)
                                            : '❓',
                                    label: _phase == _RpsPhase.choose && _isTwoPlayer && _playerChoice != null
                                        ? 'Locked In'
                                        : _playerChoice != null
                                            ? _getLabel(_playerChoice!)
                                            : (_isTwoPlayer ? 'Player 1' : 'You'),
                                    accentColor: const Color(0xFF7E52FF),
                                  ),

                                  // Center VS Medallion
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFFFE082), Color(0xFFFFB300), Color(0xFFC5A059)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.4),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: const Text('VS', style: TextStyle(color: Color(0xFF3E2723), fontWeight: FontWeight.w900, fontSize: 13)),
                                  ),

                                  // Player 2 / AI Realistic Card
                                  _buildPhysicalPlayCard(
                                    emoji: _aiChoice != null ? _getEmoji(_aiChoice!) : (_isTwoPlayer ? '👥' : '🤖'),
                                    label: _aiChoice != null
                                        ? _getLabel(_aiChoice!)
                                        : (_isTwoPlayer ? 'Player 2' : 'AI Bot'),
                                    accentColor: const Color(0xFFF97316),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // 3 Move Selection Cards (Tactile 3D Buttons)
                if (_phase == _RpsPhase.choose) ...[
                  Row(
                    children: _RpsChoice.values.map((choice) {
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => _onPlayerSelected(choice),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.white, Color(0xFFF4F0FF)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFD6C8FF), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_getEmoji(choice), style: const TextStyle(fontSize: 34)),
                                const SizedBox(height: 4),
                                Text(_getLabel(choice), style: AppTypography.labelSmall.copyWith(color: const Color(0xFF2C2416), fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ] else if (_phase == _RpsPhase.matchOver) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _playerScore >= _targetWins ? '🏆 MATCH VICTORY!' : '⚡ MATCH DEFEAT',
                          style: AppTypography.heading3.copyWith(
                            color: _playerScore >= _targetWins ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('Final Score: You $_playerScore - $_aiScore AI', style: AppTypography.monoMedium.copyWith(color: const Color(0xFF2C2416))),
                        const SizedBox(height: 10),
                        MindRushButton(
                          label: 'Play Again',
                          icon: Icons.replay_rounded,
                          onPressed: _resetMatch,
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhysicalPlayCard({required String emoji, required String label, required Color accentColor}) {
    return Container(
      width: 95,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5D5B8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(color: const Color(0xFF2C2416), fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScorePill(String label, int score, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(label, style: AppTypography.bodySmall.copyWith(fontSize: 11, color: const Color(0xFF5D4037), fontWeight: FontWeight.bold)),
          Text('$score', style: AppTypography.monoMedium.copyWith(fontSize: 22, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
