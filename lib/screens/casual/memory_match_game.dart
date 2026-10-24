import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/common_widgets.dart';

class MemoryMatchGame extends StatefulWidget {
  const MemoryMatchGame({super.key});

  @override
  State<MemoryMatchGame> createState() => _MemoryMatchGameState();
}

class _MemoryCard {
  final int id;
  final String emoji;
  bool isFlipped;
  bool isMatched;

  _MemoryCard({
    required this.id,
    required this.emoji,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

class _MemoryMatchGameState extends State<MemoryMatchGame> {
  late List<_MemoryCard> _cards;
  int _moves = 0;
  int _matchedPairs = 0;
  static const int _totalPairs = 6;
  _MemoryCard? _firstSelected;
  bool _isLocked = false;
  Timer? _stopwatch;
  int _seconds = 0;
  bool _gameWon = false;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    _stopwatch?.cancel();
    final emojis = ['🧠', '⚡', '💎', '🚀', '👑', '🎯'];
    final list = <_MemoryCard>[];

    int id = 0;
    for (final em in emojis) {
      list.add(_MemoryCard(id: id++, emoji: em));
      list.add(_MemoryCard(id: id++, emoji: em));
    }
    list.shuffle();

    setState(() {
      _cards = list;
      _moves = 0;
      _matchedPairs = 0;
      _firstSelected = null;
      _isLocked = false;
      _seconds = 0;
      _gameWon = false;
    });

    _stopwatch = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && !_gameWon) {
        setState(() => _seconds++);
      }
    });
  }

  void _onCardTapped(_MemoryCard card) {
    if (_isLocked || card.isFlipped || card.isMatched) return;

    setState(() {
      card.isFlipped = true;
    });

    if (_firstSelected == null) {
      _firstSelected = card;
    } else {
      _moves++;
      final first = _firstSelected!;
      _firstSelected = null;

      if (first.emoji == card.emoji) {
        // MATCH!
        setState(() {
          first.isMatched = true;
          card.isMatched = true;
          _matchedPairs++;
          if (_matchedPairs == _totalPairs) {
            _gameWon = true;
            _stopwatch?.cancel();
          }
        });
      } else {
        // MISMATCH
        _isLocked = true;
        Future.delayed(const Duration(milliseconds: 700), () {
          if (!mounted) return;
          setState(() {
            first.isFlipped = false;
            card.isFlipped = false;
            _isLocked = false;
          });
        });
      }
    }
  }

  @override
  void dispose() {
    _stopwatch?.cancel();
    super.dispose();
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
        title: Text('Memory Match Pairs', style: AppTypography.heading4),
        actions: [
          IconButton(
            icon: const Icon(Icons.replay_rounded, color: AppColors.primaryAccent),
            onPressed: _startNewGame,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Text('Moves: $_moves', style: AppTypography.labelSmall),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Text('Time: ${_seconds}s', style: AppTypography.monoBody.copyWith(color: AppColors.primaryAccent)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Text('Pairs: $_matchedPairs/$_totalPairs', style: AppTypography.labelSmall.copyWith(color: AppColors.success)),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Game Victory Notice
              if (_gameWon) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text('🎉 COMPLETED IN $_moves MOVES!', style: AppTypography.heading3.copyWith(color: AppColors.primaryBg)),
                      const SizedBox(height: 4),
                      Text('Total Time: ${_seconds}s', style: AppTypography.bodySmall.copyWith(color: AppColors.primaryBg.withOpacity(0.8))),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Card Grid (4 rows x 3 columns)
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: _cards.length,
                  itemBuilder: (context, index) {
                    final card = _cards[index];
                    final isOpen = card.isFlipped || card.isMatched;

                    return GestureDetector(
                      onTap: () => _onCardTapped(card),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        decoration: BoxDecoration(
                          color: card.isMatched
                              ? AppColors.success.withOpacity(0.25)
                              : isOpen
                                  ? AppColors.elevatedCard
                                  : AppColors.cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: card.isMatched
                                ? AppColors.success
                                : isOpen
                                    ? AppColors.primaryAccent
                                    : AppColors.divider,
                            width: isOpen ? 2 : 1,
                          ),
                          boxShadow: [
                            if (isOpen)
                              BoxShadow(
                                color: (card.isMatched ? AppColors.success : AppColors.primaryAccent).withOpacity(0.2),
                                blurRadius: 10,
                              ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            isOpen ? card.emoji : '❓',
                            style: TextStyle(fontSize: isOpen ? 36 : 28),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              if (_gameWon)
                MindRushButton(
                  label: 'Play Again',
                  icon: Icons.replay_rounded,
                  onPressed: _startNewGame,
                ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
