import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/common_widgets.dart';

class TicTacToeGame extends StatefulWidget {
  const TicTacToeGame({super.key});

  @override
  State<TicTacToeGame> createState() => _TicTacToeGameState();
}

enum _TttMode { vsAi, passAndPlay }
enum _AiDifficulty { easy, medium, hard }

class _TicTacToeGameState extends State<TicTacToeGame> {
  static const int _size = 3;
  late List<String> _board;
  String _currentPlayer = 'X';
  _TttMode _mode = _TttMode.vsAi;
  _AiDifficulty _difficulty = _AiDifficulty.hard;
  bool _isGameOver = false;
  String? _winner;
  List<int>? _winningLine;

  int _xWins = 0;
  int _oWins = 0;
  int _draws = 0;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      _board = List.generate(_size * _size, (_) => '');
      _currentPlayer = 'X';
      _isGameOver = false;
      _winner = null;
      _winningLine = null;
    });
  }

  void _onCellTap(int index) {
    if (_board[index].isNotEmpty || _isGameOver) return;

    setState(() {
      _board[index] = _currentPlayer;
    });

    _checkGameState();

    if (!_isGameOver) {
      _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
      if (_mode == _TttMode.vsAi && _currentPlayer == 'O') {
        _executeAiMove();
      }
    }
  }

  void _executeAiMove() {
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted || _isGameOver) return;

      int bestMove;
      if (_difficulty == _AiDifficulty.easy) {
        bestMove = _getRandomMove();
      } else if (_difficulty == _AiDifficulty.medium) {
        bestMove = Random().nextBool() ? _getBestMove() : _getRandomMove();
      } else {
        bestMove = _getBestMove();
      }

      if (bestMove != -1) {
        setState(() {
          _board[bestMove] = 'O';
        });
        _checkGameState();
        if (!_isGameOver) {
          _currentPlayer = 'X';
        }
      }
    });
  }

  int _getRandomMove() {
    final available = <int>[];
    for (int i = 0; i < _board.length; i++) {
      if (_board[i].isEmpty) available.add(i);
    }
    return available.isNotEmpty ? available[Random().nextInt(available.length)] : -1;
  }

  int _getBestMove() {
    // 1. Can AI win immediately?
    for (int i = 0; i < 9; i++) {
      if (_board[i].isEmpty) {
        _board[i] = 'O';
        if (_evaluateWinner(_board) == 'O') {
          _board[i] = '';
          return i;
        }
        _board[i] = '';
      }
    }
    // 2. Can player win? Block player!
    for (int i = 0; i < 9; i++) {
      if (_board[i].isEmpty) {
        _board[i] = 'X';
        if (_evaluateWinner(_board) == 'X') {
          _board[i] = '';
          return i;
        }
        _board[i] = '';
      }
    }
    // 3. Take center
    if (_board[4].isEmpty) return 4;
    // 4. Take corners
    final corners = [0, 2, 6, 8].where((c) => _board[c].isEmpty).toList();
    if (corners.isNotEmpty) return corners[Random().nextInt(corners.length)];

    return _getRandomMove();
  }

  String? _evaluateWinner(List<String> b) {
    const lines = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Cols
      [0, 4, 8], [2, 4, 6], // Diagonals
    ];
    for (final line in lines) {
      if (b[line[0]].isNotEmpty && b[line[0]] == b[line[1]] && b[line[1]] == b[line[2]]) {
        return b[line[0]];
      }
    }
    return null;
  }

  void _checkGameState() {
    const lines = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6],
    ];

    for (final line in lines) {
      if (_board[line[0]].isNotEmpty &&
          _board[line[0]] == _board[line[1]] &&
          _board[line[1]] == _board[line[2]]) {
        setState(() {
          _isGameOver = true;
          _winner = _board[line[0]];
          _winningLine = line;
          if (_winner == 'X') _xWins++;
          if (_winner == 'O') _oWins++;
        });
        return;
      }
    }

    if (!_board.contains('')) {
      setState(() {
        _isGameOver = true;
        _winner = 'Draw';
        _draws++;
      });
    }
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
        title: Text('Tic-Tac-Toe Arena', style: AppTypography.heading4),
        actions: [
          IconButton(
            icon: const Icon(Icons.replay_rounded, color: AppColors.primaryAccent),
            tooltip: 'Reset Board',
            onPressed: _resetGame,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              // Mode Toggle (vs AI / 2 Player)
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
                          setState(() => _mode = _TttMode.vsAi);
                          _resetGame();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _mode == _TttMode.vsAi ? AppColors.elevatedCard : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: _mode == _TttMode.vsAi ? Border.all(color: AppColors.primaryAccent) : null,
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
                          setState(() => _mode = _TttMode.passAndPlay);
                          _resetGame();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _mode == _TttMode.passAndPlay ? AppColors.elevatedCard : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: _mode == _TttMode.passAndPlay ? Border.all(color: AppColors.secondaryAccent) : null,
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

              const SizedBox(height: 16),

              // Scoreboard
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildScoreCard('Player X', _xWins, AppColors.primaryAccent, _currentPlayer == 'X' && !_isGameOver),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('Draws: $_draws', style: AppTypography.bodySmall),
                  ),
                  _buildScoreCard(
                    _mode == _TttMode.vsAi ? 'AI (O)' : 'Player O',
                    _oWins,
                    AppColors.secondaryAccent,
                    _currentPlayer == 'O' && !_isGameOver,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Status message
              if (_isGameOver)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _winner == 'Draw' ? AppColors.warning.withOpacity(0.2) : AppColors.success.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _winner == 'Draw' ? AppColors.warning : AppColors.success),
                  ),
                  child: Text(
                    _winner == 'Draw' ? '🤝 MATCH TIED!' : '🏆 WINNER: PLAYER $_winner!',
                    style: AppTypography.heading4.copyWith(
                      color: _winner == 'Draw' ? AppColors.warning : AppColors.success,
                    ),
                  ),
                )
              else
                Text(
                  'Turn: Player $_currentPlayer (${_currentPlayer == "X" ? "You" : (_mode == _TttMode.vsAi ? "AI" : "Opponent")})',
                  style: AppTypography.labelMedium,
                ),

              const Spacer(),

              // 3x3 Grid
              Center(
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.divider, width: 2),
                    ),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _size,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: 9,
                      itemBuilder: (context, idx) {
                        final val = _board[idx];
                        final isWinning = _winningLine?.contains(idx) ?? false;

                        return GestureDetector(
                          onTap: () => _onCellTap(idx),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isWinning
                                  ? (val == 'X' ? AppColors.primaryAccent : AppColors.secondaryAccent).withOpacity(0.25)
                                  : AppColors.elevatedCard,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isWinning
                                    ? (val == 'X' ? AppColors.primaryAccent : AppColors.secondaryAccent)
                                    : AppColors.divider,
                                width: isWinning ? 2.5 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                val,
                                style: AppTypography.monoLarge.copyWith(
                                  fontSize: 48,
                                  color: val == 'X' ? AppColors.primaryAccent : AppColors.secondaryAccent,
                                  fontWeight: FontWeight.w700,
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

              if (_isGameOver)
                MindRushButton(
                  label: 'Play Another Round',
                  icon: Icons.replay_rounded,
                  onPressed: _resetGame,
                ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(String name, int wins, Color color, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.18) : AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isActive ? color : AppColors.divider, width: isActive ? 2 : 1),
      ),
      child: Column(
        children: [
          Text(name, style: AppTypography.labelSmall.copyWith(color: isActive ? color : AppColors.secondaryText)),
          Text('$wins W', style: AppTypography.monoMedium.copyWith(fontSize: 18, color: color)),
        ],
      ),
    );
  }
}
