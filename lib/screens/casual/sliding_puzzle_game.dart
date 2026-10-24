import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/common_widgets.dart';

class SlidingPuzzleGame extends StatefulWidget {
  const SlidingPuzzleGame({super.key});

  @override
  State<SlidingPuzzleGame> createState() => _SlidingPuzzleGameState();
}

class _SlidingPuzzleGameState extends State<SlidingPuzzleGame> {
  static const int _size = 3;
  late List<int> _board; // 0 represents the blank tile
  int _moves = 0;
  Timer? _timer;
  int _seconds = 0;
  bool _isSolved = false;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    _timer?.cancel();
    // Start with solved state and shuffle with valid moves to guarantee solvability!
    final b = List.generate(_size * _size, (i) => (i + 1) % (_size * _size));
    final random = Random();

    int emptyPos = b.indexOf(0);
    for (int i = 0; i < 80; i++) {
      final neighbors = _getValidMoves(emptyPos);
      final move = neighbors[random.nextInt(neighbors.length)];
      b[emptyPos] = b[move];
      b[move] = 0;
      emptyPos = move;
    }

    setState(() {
      _board = b;
      _moves = 0;
      _seconds = 0;
      _isSolved = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && !_isSolved) {
        setState(() => _seconds++);
      }
    });
  }

  List<int> _getValidMoves(int index) {
    final moves = <int>[];
    final r = index ~/ _size;
    final c = index % _size;

    if (r > 0) moves.add(index - _size); // Up
    if (r < _size - 1) moves.add(index + _size); // Down
    if (c > 0) moves.add(index - 1); // Left
    if (c < _size - 1) moves.add(index + 1); // Right

    return moves;
  }

  void _onTileTap(int index) {
    if (_isSolved || _board[index] == 0) return;

    final emptyPos = _board.indexOf(0);
    final validMoves = _getValidMoves(emptyPos);

    if (validMoves.contains(index)) {
      setState(() {
        _board[emptyPos] = _board[index];
        _board[index] = 0;
        _moves++;
        _checkVictory();
      });
    }
  }

  void _checkVictory() {
    for (int i = 0; i < _board.length - 1; i++) {
      if (_board[i] != i + 1) return;
    }
    _isSolved = true;
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
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
        title: Text('Sliding Number Puzzle', style: AppTypography.heading4),
        actions: [
          IconButton(
            icon: const Icon(Icons.replay_rounded, color: AppColors.primaryAccent),
            tooltip: 'Shuffle',
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
                ],
              ),

              const SizedBox(height: 12),
              Text('Slide numbered tiles into order from 1 to 8', style: AppTypography.bodySmall),

              if (_isSolved) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      '🏆 SOLVED IN $_moves MOVES & ${_seconds}s!',
                      style: AppTypography.heading3.copyWith(color: AppColors.primaryBg),
                    ),
                  ),
                ),
              ],

              const Spacer(),

              // Board
              Center(
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.divider, width: 2),
                    ),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _size,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _size * _size,
                      itemBuilder: (context, idx) {
                        final val = _board[idx];
                        if (val == 0) {
                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.primaryBg.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(14),
                            ),
                          );
                        }

                        final isCorrectPosition = val == idx + 1;

                        return GestureDetector(
                          onTap: () => _onTileTap(idx),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            decoration: BoxDecoration(
                              gradient: isCorrectPosition ? AppColors.accentGradient : AppColors.cardGradient,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isCorrectPosition ? AppColors.primaryAccent : AppColors.divider,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '$val',
                                style: AppTypography.monoLarge.copyWith(
                                  fontSize: 32,
                                  color: isCorrectPosition ? AppColors.primaryBg : AppColors.primaryText,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              const Spacer(),

              MindRushButton(
                label: 'Shuffle & New Game',
                icon: Icons.shuffle_rounded,
                isOutlined: true,
                onPressed: _startNewGame,
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
