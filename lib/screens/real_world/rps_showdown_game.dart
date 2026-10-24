import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/common_widgets.dart';

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

  _RpsChoice? _playerChoice;
  _RpsChoice? _aiChoice;
  String _outcomeText = 'Select your move to throw!';
  _RpsPhase _phase = _RpsPhase.choose;
  int _countdownValue = 3;

  final Random _random = Random();
  final List<_RpsChoice> _playerHistory = [];

  void _onPlayerSelected(_RpsChoice choice) {
    if (_phase != _RpsPhase.choose) return;

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
      _aiChoice = null;
      _phase = _RpsPhase.choose;
      _outcomeText = 'Select your move to throw!';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Rock Paper Scissors Showdown', style: AppTypography.heading4),
        actions: [
          IconButton(
            icon: const Icon(Icons.replay_rounded, color: AppColors.primaryAccent),
            onPressed: _resetMatch,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
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
                        color: isSel ? AppColors.primaryAccent.withOpacity(0.2) : AppColors.cardBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isSel ? AppColors.primaryAccent : AppColors.divider),
                      ),
                      child: Text(
                        'First to $target',
                        style: AppTypography.labelSmall.copyWith(
                          color: isSel ? AppColors.primaryAccent : AppColors.secondaryText,
                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Scoreboard
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildScorePill('You', _playerScore, AppColors.primaryAccent),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('Draws: $_draws', style: AppTypography.bodySmall),
                  ),
                  _buildScorePill('AI Bot', _aiScore, AppColors.secondaryAccent),
                ],
              ),

              const SizedBox(height: 20),

              // Status message
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.elevatedCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Text(
                  _outcomeText,
                  style: AppTypography.labelMedium.copyWith(color: AppColors.primaryText),
                  textAlign: TextAlign.center,
                ),
              ),

              const Spacer(),

              // Arena Duel Reveal Area
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.divider, width: 2),
                ),
                child: _phase == _RpsPhase.countdown
                    ? Center(
                        child: Text(
                          '$_countdownValue',
                          style: AppTypography.monoLarge.copyWith(fontSize: 72, color: AppColors.primaryAccent),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Player Choice
                          Column(
                            children: [
                              Text(
                                _playerChoice != null ? _getEmoji(_playerChoice!) : '❓',
                                style: const TextStyle(fontSize: 64),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _playerChoice != null ? _getLabel(_playerChoice!) : 'You',
                                style: AppTypography.labelMedium.copyWith(color: AppColors.primaryAccent),
                              ),
                            ],
                          ),

                          Text('VS', style: AppTypography.heading3.copyWith(color: AppColors.secondaryText)),

                          // AI Choice
                          Column(
                            children: [
                              Text(
                                _aiChoice != null ? _getEmoji(_aiChoice!) : '🤖',
                                style: const TextStyle(fontSize: 64),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _aiChoice != null ? _getLabel(_aiChoice!) : 'AI Bot',
                                style: AppTypography.labelMedium.copyWith(color: AppColors.secondaryAccent),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),

              const Spacer(),

              // 3 Move Selection Cards
              if (_phase == _RpsPhase.choose) ...[
                Row(
                  children: _RpsChoice.values.map((choice) {
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _onPlayerSelected(choice),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: AppColors.elevatedCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.primaryAccent.withOpacity(0.4)),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryAccent.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(_getEmoji(choice), style: const TextStyle(fontSize: 40)),
                              const SizedBox(height: 6),
                              Text(_getLabel(choice), style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w700)),
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
                    color: _playerScore >= _targetWins ? AppColors.success.withOpacity(0.2) : AppColors.error.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _playerScore >= _targetWins ? AppColors.success : AppColors.error),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _playerScore >= _targetWins ? '🏆 MATCH VICTORY!' : '⚡ MATCH DEFEAT',
                        style: AppTypography.heading3.copyWith(
                          color: _playerScore >= _targetWins ? AppColors.success : AppColors.error,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Final Score: You $_playerScore - $_aiScore AI', style: AppTypography.monoMedium),
                      const SizedBox(height: 14),
                      MindRushButton(
                        label: 'Play Again',
                        icon: Icons.replay_rounded,
                        onPressed: _resetMatch,
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScorePill(String label, int score, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Text(label, style: AppTypography.bodySmall.copyWith(fontSize: 11)),
          Text('$score', style: AppTypography.monoMedium.copyWith(fontSize: 22, color: color)),
        ],
      ),
    );
  }
}
