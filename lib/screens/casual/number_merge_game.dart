import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/common_widgets.dart';

class NumberMergeGame extends StatefulWidget {
  const NumberMergeGame({super.key});

  @override
  State<NumberMergeGame> createState() => _NumberMergeGameState();
}

class _NumberMergeGameState extends State<NumberMergeGame> {
  static const int _gridSize = 4;
  late List<List<int>> _grid;
  List<List<int>>? _previousGrid;
  int _score = 0;
  int _previousScore = 0;
  int _bestScore = 0;
  final Random _random = Random();
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    _grid = List.generate(_gridSize, (_) => List.generate(_gridSize, (_) => 0));
    _score = 0;
    _previousGrid = null;
    _isGameOver = false;
    _addRandomTile();
    _addRandomTile();
    setState(() {});
  }

  void _addRandomTile() {
    final emptyCells = <Point<int>>[];
    for (int r = 0; r < _gridSize; r++) {
      for (int c = 0; c < _gridSize; c++) {
        if (_grid[r][c] == 0) emptyCells.add(Point(r, c));
      }
    }

    if (emptyCells.isNotEmpty) {
      final cell = emptyCells[_random.nextInt(emptyCells.length)];
      _grid[cell.x][cell.y] = _random.nextDouble() < 0.9 ? 2 : 4;
    }
  }

  void _savePreviousState() {
    _previousGrid = List.generate(_gridSize, (r) => List<int>.from(_grid[r]));
    _previousScore = _score;
  }

  void _undo() {
    if (_previousGrid != null) {
      setState(() {
        _grid = _previousGrid!;
        _score = _previousScore;
        _previousGrid = null;
        _isGameOver = false;
      });
    }
  }

  bool _slide(List<int> row) {
    final original = List<int>.from(row);
    // Filter non-zero
    final filtered = row.where((n) => n != 0).toList();
    final result = <int>[];

    int i = 0;
    while (i < filtered.length) {
      if (i + 1 < filtered.length && filtered[i] == filtered[i + 1]) {
        final merged = filtered[i] * 2;
        result.add(merged);
        _score += merged;
        if (_score > _bestScore) _bestScore = _score;
        i += 2;
      } else {
        result.add(filtered[i]);
        i++;
      }
    }

    while (result.length < _gridSize) {
      result.add(0);
    }

    for (int j = 0; j < _gridSize; j++) {
      row[j] = result[j];
    }

    for (int j = 0; j < _gridSize; j++) {
      if (original[j] != row[j]) return true;
    }
    return false;
  }

  void _move(int dx, int dy) {
    if (_isGameOver) return;
    _savePreviousState();
    bool moved = false;

    if (dx != 0) {
      // Horizontal move
      for (int r = 0; r < _gridSize; r++) {
        final row = _grid[r];
        if (dx < 0) {
          // Left
          if (_slide(row)) moved = true;
        } else {
          // Right
          final rev = row.reversed.toList();
          if (_slide(rev)) moved = true;
          for (int c = 0; c < _gridSize; c++) {
            _grid[r][c] = rev[_gridSize - 1 - c];
          }
        }
      }
    } else if (dy != 0) {
      // Vertical move
      for (int c = 0; c < _gridSize; c++) {
        final col = List.generate(_gridSize, (r) => _grid[r][c]);
        if (dy < 0) {
          // Up
          if (_slide(col)) moved = true;
          for (int r = 0; r < _gridSize; r++) {
            _grid[r][c] = col[r];
          }
        } else {
          // Down
          final rev = col.reversed.toList();
          if (_slide(rev)) moved = true;
          for (int r = 0; r < _gridSize; r++) {
            _grid[r][c] = rev[_gridSize - 1 - r];
          }
        }
      }
    }

    if (moved) {
      _addRandomTile();
      _checkGameOver();
      setState(() {});
    }
  }

  void _checkGameOver() {
    for (int r = 0; r < _gridSize; r++) {
      for (int c = 0; c < _gridSize; c++) {
        if (_grid[r][c] == 0) return;
        if (c + 1 < _gridSize && _grid[r][c] == _grid[r][c + 1]) return;
        if (r + 1 < _gridSize && _grid[r][c] == _grid[r + 1][c]) return;
      }
    }
    _isGameOver = true;
  }

  Color _getTileColor(int value) {
    switch (value) {
      case 2: return const Color(0xFF1E293B);
      case 4: return const Color(0xFF334155);
      case 8: return const Color(0xFF0284C7);
      case 16: return const Color(0xFF2563EB);
      case 32: return const Color(0xFF7C3AED);
      case 64: return const Color(0xFF9333EA);
      case 128: return const Color(0xFFD97706);
      case 256: return const Color(0xFFEA580C);
      case 512: return const Color(0xFFDC2626);
      case 1024: return const Color(0xFF059669);
      case 2048: return AppColors.primaryAccent;
      default: return AppColors.cardBg;
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
        title: Text('Number Merge 2048', style: AppTypography.heading4),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo_rounded, color: AppColors.primaryAccent),
            tooltip: 'Undo Move',
            onPressed: _previousGrid != null ? _undo : null,
          ),
          IconButton(
            icon: const Icon(Icons.replay_rounded, color: AppColors.secondaryText),
            tooltip: 'New Game',
            onPressed: _initGame,
          ),
        ],
      ),
      body: NeonRiseBackground(
        child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              // Score & Best Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SCORE', style: AppTypography.bodySmall.copyWith(fontSize: 10, letterSpacing: 1)),
                        Text('$_score', style: AppTypography.monoMedium.copyWith(fontSize: 22, color: AppColors.primaryAccent)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BEST', style: AppTypography.bodySmall.copyWith(fontSize: 10, letterSpacing: 1)),
                        Text('$_bestScore', style: AppTypography.monoMedium.copyWith(fontSize: 22, color: AppColors.warning)),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Text('Swipe in any direction to slide & merge matching tiles', style: AppTypography.bodySmall),
              const SizedBox(height: 20),

              // Game 4x4 Grid with Gesture Detector
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: GestureDetector(
                      onHorizontalDragEnd: (details) {
                        if (details.primaryVelocity! > 200) {
                          _move(1, 0); // Right
                        } else if (details.primaryVelocity! < -200) {
                          _move(-1, 0); // Left
                        }
                      },
                      onVerticalDragEnd: (details) {
                        if (details.primaryVelocity! > 200) {
                          _move(0, 1); // Down
                        } else if (details.primaryVelocity! < -200) {
                          _move(0, -1); // Up
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.elevatedCard,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.divider, width: 2),
                        ),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _gridSize,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: _gridSize * _gridSize,
                          itemBuilder: (context, idx) {
                            final r = idx ~/ _gridSize;
                            final c = idx % _gridSize;
                            final val = _grid[r][c];

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                color: _getTileColor(val),
                                borderRadius: BorderRadius.circular(12),
                                border: val > 0 ? Border.all(color: Colors.white.withOpacity(0.1)) : null,
                              ),
                              child: Center(
                                child: val > 0
                                    ? Text(
                                        '$val',
                                        style: AppTypography.monoMedium.copyWith(
                                          fontSize: val > 512 ? 20 : val > 64 ? 24 : 28,
                                          fontWeight: FontWeight.w700,
                                          color: val == 2048 ? AppColors.primaryBg : AppColors.primaryText,
                                        ),
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              if (_isGameOver) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No moves left! Game Over! 🛑', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _initGame,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
      ),
    );
  }
}
