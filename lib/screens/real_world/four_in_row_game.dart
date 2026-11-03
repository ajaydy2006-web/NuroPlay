import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/common_widgets.dart';

class FourInRowGame extends StatefulWidget {
  const FourInRowGame({super.key});

  @override
  State<FourInRowGame> createState() => _FourInRowGameState();
}

class _FourInRowGameState extends State<FourInRowGame> {
  static const int _rows = 6;
  static const int _cols = 7;

  // 0 = empty, 1 = Player 1 (Cyan), 2 = Player 2 / AI (Purple)
  late List<List<int>> _board;
  int _currentPlayer = 1;
  bool _isVsAi = true;
  bool _isGameOver = false;
  int? _winner;
  List<Point<int>>? _winningCoords;

  int _p1Wins = 0;
  int _p2Wins = 0;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      _board = List.generate(_rows, (_) => List.generate(_cols, (_) => 0));
      _currentPlayer = 1;
      _isGameOver = false;
      _winner = null;
      _winningCoords = null;
    });
  }

  void _onColumnTap(int col) {
    if (_isGameOver) return;
    if (_isVsAi && _currentPlayer == 2) return;

    _dropDisc(col);
  }

  void _dropDisc(int col) {
    // Find lowest empty row in this column
    int targetRow = -1;
    for (int r = _rows - 1; r >= 0; r--) {
      if (_board[r][col] == 0) {
        targetRow = r;
        break;
      }
    }

    if (targetRow == -1) return; // Column full

    setState(() {
      _board[targetRow][col] = _currentPlayer;
    });

    final winLine = _checkWinner(targetRow, col, _currentPlayer);
    if (winLine != null) {
      setState(() {
        _isGameOver = true;
        _winner = _currentPlayer;
        _winningCoords = winLine;
        if (_winner == 1) _p1Wins++;
        if (_winner == 2) _p2Wins++;
      });
      return;
    }

    // Check draw
    bool isFull = true;
    for (int c = 0; c < _cols; c++) {
      if (_board[0][c] == 0) isFull = false;
    }
    if (isFull) {
      setState(() {
        _isGameOver = true;
        _winner = 0; // Draw
      });
      return;
    }

    // Next turn
    setState(() {
      _currentPlayer = _currentPlayer == 1 ? 2 : 1;
    });

    if (_isVsAi && _currentPlayer == 2 && !_isGameOver) {
      _executeAiMove();
    }
  }

  void _executeAiMove() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted || _isGameOver) return;

      int bestCol = _findBestAiCol();
      _dropDisc(bestCol);
    });
  }

  int _findBestAiCol() {
    final validCols = <int>[];
    for (int c = 0; c < _cols; c++) {
      if (_board[0][c] == 0) validCols.add(c);
    }
    if (validCols.isEmpty) return 0;

    // 1. Can AI win on this move?
    for (final c in validCols) {
      int r = _getLowestEmptyRow(c);
      _board[r][c] = 2;
      if (_checkWinner(r, c, 2) != null) {
        _board[r][c] = 0;
        return c;
      }
      _board[r][c] = 0;
    }

    // 2. Can player win on their next move? Block them!
    for (final c in validCols) {
      int r = _getLowestEmptyRow(c);
      _board[r][c] = 1;
      if (_checkWinner(r, c, 1) != null) {
        _board[r][c] = 0;
        return c;
      }
      _board[r][c] = 0;
    }

    // 3. Prefer center columns (3, 2, 4)
    if (validCols.contains(3)) return 3;
    if (validCols.contains(2) && Random().nextBool()) return 2;
    if (validCols.contains(4)) return 4;

    return validCols[Random().nextInt(validCols.length)];
  }

  int _getLowestEmptyRow(int col) {
    for (int r = _rows - 1; r >= 0; r--) {
      if (_board[r][col] == 0) return r;
    }
    return 0;
  }

  List<Point<int>>? _checkWinner(int r, int c, int p) {
    // 4 directions: Horizontal, Vertical, Diagonal /, Diagonal \
    const directions = [
      [Point(0, 1), Point(0, -1)], // Horizontal
      [Point(1, 0), Point(-1, 0)], // Vertical
      [Point(1, 1), Point(-1, -1)], // Diagonal \
      [Point(1, -1), Point(-1, 1)], // Diagonal /
    ];

    for (final dir in directions) {
      final line = <Point<int>>[Point(r, c)];

      for (final d in dir) {
        int nr = r + d.x;
        int nc = c + d.y;
        while (nr >= 0 && nr < _rows && nc >= 0 && nc < _cols && _board[nr][nc] == p) {
          line.add(Point(nr, nc));
          nr += d.x;
          nc += d.y;
        }
      }

      if (line.length >= 4) return line;
    }
    return null;
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
                      child: Text('Four in a Row', style: AppTypography.heading3, textAlign: TextAlign.center),
                    ),
                    IconButton(
                      icon: const Icon(Icons.replay_rounded, color: AppColors.primaryAccent),
                      tooltip: 'Restart Game',
                      onPressed: _resetGame,
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Mode switcher (vs AI / Pass & Play)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _isVsAi = true);
                            _resetGame();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _isVsAi ? AppColors.elevatedCard : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: _isVsAi ? Border.all(color: AppColors.primaryAccent) : null,
                            ),
                            child: Center(
                              child: Text('vs AI Bot 🤖', style: AppTypography.labelSmall),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _isVsAi = false);
                            _resetGame();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: !_isVsAi ? AppColors.elevatedCard : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: !_isVsAi ? Border.all(color: AppColors.secondaryAccent) : null,
                            ),
                            child: Center(
                              child: Text('Pass & Play 👥', style: AppTypography.labelSmall),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Scoreboard
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPlayerCard('Player 1', _p1Wins, AppColors.primaryAccent, _currentPlayer == 1 && !_isGameOver),
                    _buildPlayerCard(
                      _isVsAi ? 'AI Bot' : 'Player 2',
                      _p2Wins,
                      AppColors.secondaryAccent,
                      _currentPlayer == 2 && !_isGameOver,
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                if (_isGameOver)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _winner == 0 ? AppColors.warning.withOpacity(0.2) : AppColors.success.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _winner == 0 ? AppColors.warning : AppColors.success),
                    ),
                    child: Text(
                      _winner == 0
                          ? '🤝 DRAW GAME!'
                          : '🎉 WINNER: ${_winner == 1 ? "PLAYER 1" : (_isVsAi ? "AI BOT" : "PLAYER 2")}!',
                      style: AppTypography.heading4.copyWith(color: _winner == 0 ? AppColors.warning : AppColors.success),
                    ),
                  )
                else
                  Text(
                    'Tap a column to drop your disc (Player $_currentPlayer)',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.secondaryText),
                  ),

                const SizedBox(height: 8),

                // Responsive Connect 4 Vertical Board (scaled for phone screens)
                Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F1E36), // Deep cyber blue frame
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.primaryAccent.withOpacity(0.5), width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryAccent.withOpacity(0.18),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(_rows, (r) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(_cols, (c) {
                                final val = _board[r][c];
                                final isWinning = _winningCoords?.any((p) => p.x == r && p.y == c) ?? false;

                                Color discColor = const Color(0xFF070B14); // Empty slot hole
                                if (val == 1) discColor = AppColors.primaryAccent;
                                if (val == 2) discColor = AppColors.secondaryAccent;

                                return GestureDetector(
                                  onTap: () => _onColumnTap(c),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 36,
                                    height: 36,
                                    margin: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: discColor,
                                      border: isWinning
                                          ? Border.all(color: Colors.white, width: 3)
                                          : Border.all(color: Colors.black.withOpacity(0.4), width: 1.5),
                                      boxShadow: [
                                        if (val != 0)
                                          BoxShadow(
                                            color: discColor.withOpacity(0.5),
                                            blurRadius: isWinning ? 12 : 4,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                if (_isGameOver)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: MindRushButton(
                      label: 'Play Again',
                      icon: Icons.replay_rounded,
                      onPressed: _resetGame,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerCard(String name, int wins, Color color, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.18) : AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isActive ? color : AppColors.divider, width: isActive ? 2 : 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
              const SizedBox(width: 6),
              Text(name, style: AppTypography.labelSmall.copyWith(color: isActive ? color : AppColors.secondaryText)),
            ],
          ),
          const SizedBox(height: 2),
          Text('$wins Wins', style: AppTypography.monoMedium.copyWith(fontSize: 16, color: color)),
        ],
      ),
    );
  }
}
