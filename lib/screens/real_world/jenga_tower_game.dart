import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/common_widgets.dart';
import '../../services/storage_service.dart';

enum JengaGameMode { solo, vsAi, passAndPlay }

enum JengaAiDifficulty { easy, medium, hard }

class _JengaBlock {
  final int floor;
  final int slot; // 0: left, 1: center, 2: right
  bool isExtracted;
  double slideOffset; // -1.0 to 1.0 (how far pulled)
  bool isBeingPulled;

  _JengaBlock({
    required this.floor,
    required this.slot,
    this.isExtracted = false,
    this.slideOffset = 0.0,
    this.isBeingPulled = false,
  });
}

class JengaTowerGame extends StatefulWidget {
  const JengaTowerGame({super.key});

  @override
  State<JengaTowerGame> createState() => _JengaTowerGameState();
}

class _JengaTowerGameState extends State<JengaTowerGame>
    with SingleTickerProviderStateMixin {
  late AnimationController _ticker;

  JengaGameMode _mode = JengaGameMode.solo;
  JengaAiDifficulty _aiDifficulty = JengaAiDifficulty.medium;

  // Game state
  late List<List<_JengaBlock>> _floors; // floor 0 is bottom
  int _activeFloorCount = 9;
  double _towerInstability = 0.0; // 0.0 to 1.0 (1.0 = collapse)
  double _swayAngle = 0.0; // radians
  double _timeElapsed = 0.0;

  bool _isGameOver = false;
  String _gameOverReason = '';
  int _score = 0;
  int _blocksPulled = 0;
  int _currentPlayer = 1; // 1 or 2 (or AI)
  bool _isAiTurn = false;

  _JengaBlock? _selectedBlock;
  double _pullProgress = 0.0; // 0.0 to 1.0

  // Collapsed physics animation pieces
  final List<_FallingWoodPiece> _fallingPieces = [];

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_onTick)..repeat();

    _initTower();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initTower() {
    _activeFloorCount = 8;
    _floors = List.generate(
      _activeFloorCount,
      (f) => List.generate(
        3,
        (s) => _JengaBlock(floor: f, slot: s),
      ),
    );
    _towerInstability = 0.05;
    _isGameOver = false;
    _gameOverReason = '';
    _score = 0;
    _blocksPulled = 0;
    _currentPlayer = 1;
    _isAiTurn = false;
    _selectedBlock = null;
    _pullProgress = 0.0;
    _fallingPieces.clear();
  }

  void _onTick() {
    if (!mounted) return;
    setState(() {
      _timeElapsed += 0.03;
      // Tower sway amplitude depends on instability
      final swayMag = (_towerInstability * 0.12);
      _swayAngle = sin(_timeElapsed * (1.8 + _towerInstability * 3.0)) * swayMag;

      // Update falling pieces if game over
      if (_isGameOver && _fallingPieces.isNotEmpty) {
        for (final p in _fallingPieces) {
          p.x += p.vx;
          p.y += p.vy;
          p.vy += 0.5; // gravity
          p.rot += p.vRot;
        }
      }
    });
  }

  void _calculateInstability() {
    double totalInstability = 0.05 + (_floors.length * 0.02);

    for (int f = 0; f < _floors.length - 2; f++) {
      final floorBlocks = _floors[f].where((b) => !b.isExtracted).toList();
      if (floorBlocks.isEmpty) {
        // Floor has no support at all! Collapse!
        _triggerCollapse('Floor ${f + 1} completely collapsed!');
        return;
      } else if (floorBlocks.length == 1) {
        final slot = floorBlocks.first.slot;
        if (slot == 0) {
          // Only left block! Severe tilt to left
          totalInstability += 0.22;
        } else if (slot == 2) {
          // Only right block! Severe tilt to right
          totalInstability += 0.22;
        } else {
          // Center block: balanced but very narrow pivot
          totalInstability += 0.12;
        }
      } else if (floorBlocks.length == 2) {
        // Missing center vs missing edge
        final hasCenter = floorBlocks.any((b) => b.slot == 1);
        if (!hasCenter) {
          // Missing center (bridge style): relatively stable
          totalInstability += 0.04;
        } else {
          // Missing one outer edge: slight tilt
          totalInstability += 0.07;
        }
      }
    }

    // Add extra wobble factor if pulling
    _towerInstability = totalInstability.clamp(0.0, 1.0);

    if (_towerInstability >= 0.98) {
      _triggerCollapse('The tower swayed too violently and toppled!');
    }
  }

  void _triggerCollapse(String reason) {
    if (_isGameOver) return;
    _isGameOver = true;
    _gameOverReason = reason;

    // Generate falling physics pieces
    _fallingPieces.clear();
    final rand = Random();
    for (int f = 0; f < _floors.length; f++) {
      for (int s = 0; s < 3; s++) {
        if (!_floors[f][s].isExtracted) {
          _fallingPieces.add(
            _FallingWoodPiece(
              x: (s - 1) * 45.0 + rand.nextDouble() * 20 - 10,
              y: (_floors.length - 1 - f) * 28.0,
              vx: (rand.nextDouble() - 0.5) * 8,
              vy: -rand.nextDouble() * 6,
              rot: rand.nextDouble() * pi,
              vRot: (rand.nextDouble() - 0.5) * 0.2,
            ),
          );
        }
      }
    }

    if (_mode == JengaGameMode.solo) {
      StorageService.setPersonalBest('jenga_tower', _score);
    }
  }

  void _selectBlock(_JengaBlock block) {
    if (_isGameOver || _isAiTurn) return;
    if (block.isExtracted) return;

    // Rule: Cannot pull from top 2 active floors
    if (block.floor >= _floors.length - 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot pull from the top 2 floors!'),
          duration: Duration(milliseconds: 900),
          backgroundColor: AppColors.surfaceBorder,
        ),
      );
      return;
    }

    setState(() {
      _selectedBlock = block;
      _pullProgress = 0.0;
    });
  }

  void _updatePullProgress(double progress) {
    if (_selectedBlock == null || _isGameOver) return;
    setState(() {
      _pullProgress = progress.clamp(0.0, 1.0);
      _selectedBlock!.slideOffset = _pullProgress;

      // Dynamic instability spike during pull
      _calculateInstability();
      _towerInstability = (_towerInstability + (_pullProgress * 0.15)).clamp(0.0, 1.0);
    });

    if (_towerInstability >= 0.98) {
      _triggerCollapse('Tension broke! The tower toppled during extraction!');
    }
  }

  void _completeBlockPull() {
    if (_selectedBlock == null || _isGameOver) return;

    final block = _selectedBlock!;
    setState(() {
      block.isExtracted = true;
      block.slideOffset = 0.0;
      _selectedBlock = null;
      _pullProgress = 0.0;
      _blocksPulled++;
      _score += (100 + (_floors.length * 20));

      // Place block on top floor
      final topFloor = _floors.last;
      final emptySlot = topFloor.indexWhere((b) => b.isExtracted);

      if (emptySlot != -1) {
        topFloor[emptySlot].isExtracted = false;
      } else {
        // Top floor is full, start a brand new floor!
        _floors.add([
          _JengaBlock(floor: _floors.length, slot: 0, isExtracted: false),
          _JengaBlock(floor: _floors.length, slot: 1, isExtracted: true),
          _JengaBlock(floor: _floors.length, slot: 2, isExtracted: true),
        ]);
      }

      _calculateInstability();

      // Switch turn
      if (_mode == JengaGameMode.passAndPlay) {
        _currentPlayer = _currentPlayer == 1 ? 2 : 1;
      } else if (_mode == JengaGameMode.vsAi) {
        _currentPlayer = 2;
        _isAiTurn = true;
        _scheduleAiTurn();
      }
    });
  }

  void _scheduleAiTurn() {
    Timer(const Duration(milliseconds: 1400), () {
      if (!mounted || _isGameOver) return;

      // AI block selection logic based on difficulty
      final eligibleBlocks = <_JengaBlock>[];
      for (int f = 0; f < _floors.length - 2; f++) {
        for (int s = 0; s < 3; s++) {
          if (!_floors[f][s].isExtracted) {
            eligibleBlocks.add(_floors[f][s]);
          }
        }
      }

      if (eligibleBlocks.isEmpty) return;

      _JengaBlock chosen;
      if (_aiDifficulty == JengaAiDifficulty.easy) {
        // Easy AI picks completely random (even risky outer blocks)
        chosen = eligibleBlocks[Random().nextInt(eligibleBlocks.length)];
      } else if (_aiDifficulty == JengaAiDifficulty.medium) {
        // Medium AI prefers center blocks or floors with 3 blocks
        final safeBlocks = eligibleBlocks.where((b) {
          final floorCount = _floors[b.floor].where((x) => !x.isExtracted).length;
          return floorCount == 3;
        }).toList();
        chosen = safeBlocks.isNotEmpty
            ? safeBlocks[Random().nextInt(safeBlocks.length)]
            : eligibleBlocks[Random().nextInt(eligibleBlocks.length)];
      } else {
        // Hard AI: analyzes risk, avoids leaving single edge block, pulls smoothly
        final bestBlocks = eligibleBlocks.where((b) {
          final remaining = _floors[b.floor].where((x) => !x.isExtracted).length;
          return remaining >= 2 && b.slot == 1; // Center blocks are safest
        }).toList();
        chosen = bestBlocks.isNotEmpty
            ? bestBlocks[Random().nextInt(bestBlocks.length)]
            : eligibleBlocks[Random().nextInt(eligibleBlocks.length)];
      }

      setState(() {
        _selectedBlock = chosen;
      });

      // Animate AI pulling
      Timer(const Duration(milliseconds: 800), () {
        if (!mounted || _isGameOver) return;
        _completeBlockPull();
        setState(() {
          _isAiTurn = false;
          _currentPlayer = 1;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text('Jenga Tower', style: AppTypography.headingMedium),
            Text(
              _mode == JengaGameMode.solo
                  ? 'Solo Tower Builder'
                  : _mode == JengaGameMode.passAndPlay
                      ? 'Pass & Play: Player $_currentPlayer'
                      : _isAiTurn
                          ? 'WoodBot is thinking...'
                          : 'Your Turn',
              style: AppTypography.captionSmall.copyWith(
                color: _currentPlayer == 1 ? AppColors.primaryAccent : AppColors.warning,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary),
            onPressed: _showRulesDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
            onPressed: () => setState(_initTower),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Mode & Instability Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Mode Selector
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<JengaGameMode>(
                        value: _mode,
                        dropdownColor: AppColors.surfaceDark,
                        icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryAccent),
                        items: const [
                          DropdownMenuItem(
                            value: JengaGameMode.solo,
                            child: Text('Solo Tower', style: TextStyle(color: Colors.white, fontSize: 13)),
                          ),
                          DropdownMenuItem(
                            value: JengaGameMode.vsAi,
                            child: Text('vs WoodBot AI', style: TextStyle(color: Colors.white, fontSize: 13)),
                          ),
                          DropdownMenuItem(
                            value: JengaGameMode.passAndPlay,
                            child: Text('2P Pass & Play', style: TextStyle(color: Colors.white, fontSize: 13)),
                          ),
                        ],
                        onChanged: (m) {
                          if (m != null) {
                            setState(() {
                              _mode = m;
                              _initTower();
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Height & Score
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Height: ${_floors.length} Floors',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Score: $_score',
                        style: AppTypography.captionSmall.copyWith(color: AppColors.primaryAccent),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Instability Meter Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TOWER STABILITY',
                        style: AppTypography.captionSmall.copyWith(
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        '${((1.0 - _towerInstability) * 100).toInt()}% Stable',
                        style: AppTypography.captionSmall.copyWith(
                          color: _towerInstability > 0.7
                              ? AppColors.error
                              : _towerInstability > 0.4
                                  ? AppColors.warning
                                  : AppColors.primaryAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _towerInstability.clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: AppColors.surfaceBorder,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _towerInstability > 0.75
                            ? AppColors.error
                            : _towerInstability > 0.45
                                ? AppColors.warning
                                : AppColors.primaryAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Interactive Tower Stage
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Wooden Table Surface
                  Positioned(
                    bottom: 0,
                    left: 20,
                    right: 20,
                    height: 24,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5D4037), Color(0xFF3E2723)],
                        ),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // The Swaying Tower Stack
                  if (!_isGameOver)
                    Transform.rotate(
                      angle: _swayAngle,
                      alignment: Alignment.bottomCenter,
                      child: SingleChildScrollView(
                        reverse: true, // Floor 0 at bottom
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 24, top: 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(_floors.length, (floorIdx) {
                            // Reverse so index 0 is at bottom
                            final f = _floors.length - 1 - floorIdx;
                            final isTopTwo = f >= _floors.length - 2;
                            final isEvenFloor = f % 2 == 0;

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              height: 28,
                              width: 180,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(3, (s) {
                                  final block = _floors[f][s];
                                  final isSelected = _selectedBlock == block;

                                  if (block.isExtracted) {
                                    return const Expanded(
                                      child: SizedBox(),
                                    );
                                  }

                                  return Expanded(
                                    child: GestureDetector(
                                      onTap: () => _selectBlock(block),
                                      child: Transform.translate(
                                        offset: Offset(
                                          isSelected ? _pullProgress * 40.0 : 0.0,
                                          0,
                                        ),
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 2),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: isSelected
                                                  ? [const Color(0xFFFFD54F), const Color(0xFFFFB300)]
                                                  : isTopTwo
                                                      ? [const Color(0xFF8D6E63), const Color(0xFF6D4C41)]
                                                      : isEvenFloor
                                                          ? [const Color(0xFFD7CCC8), const Color(0xFFA1887F)]
                                                          : [const Color(0xFFBCAAA4), const Color(0xFF8D6E63)],
                                            ),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(
                                              color: isSelected
                                                  ? AppColors.primaryAccent
                                                  : const Color(0xFF4E342E),
                                              width: isSelected ? 2 : 1,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.3),
                                                blurRadius: 4,
                                                offset: const Offset(1, 2),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: isTopTwo
                                                ? const Icon(Icons.lock_rounded, size: 12, color: Colors.white38)
                                                : isSelected
                                                    ? const Icon(Icons.drag_indicator_rounded, size: 14, color: Colors.black87)
                                                    : null,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            );
                          }),
                        ),
                      ),
                    )
                  else
                    // Collapsed falling blocks visualization
                    CustomPaint(
                      size: const Size(300, 350),
                      painter: _JengaCollapsePainter(pieces: _fallingPieces),
                    ),
                ],
              ),
            ),

            // Pull Extraction Control Panel (When a block is selected)
            if (_selectedBlock != null && !_isGameOver && !_isAiTurn)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryAccent.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryAccent.withOpacity(0.15),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Floor ${_selectedBlock!.floor + 1} • ${_selectedBlock!.slot == 0 ? "Left" : _selectedBlock!.slot == 1 ? "Center" : "Right"} Block',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primaryAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${(_pullProgress * 100).toInt()}% Pulled',
                          style: AppTypography.captionSmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.primaryAccent,
                        inactiveTrackColor: AppColors.surfaceBorder,
                        thumbColor: Colors.white,
                        trackHeight: 6,
                      ),
                      child: Slider(
                        value: _pullProgress,
                        onChanged: _updatePullProgress,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.surfaceBorder),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => setState(() {
                              _selectedBlock = null;
                              _pullProgress = 0.0;
                              _calculateInstability();
                            }),
                            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _pullProgress >= 0.85
                                  ? AppColors.primaryAccent
                                  : AppColors.surfaceBorder,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: _pullProgress >= 0.85 ? _completeBlockPull : null,
                            child: Text(
                              'Stack on Top',
                              style: TextStyle(
                                color: _pullProgress >= 0.85 ? Colors.black : AppColors.textTertiary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // Game Over Banner
            if (_isGameOver)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.error),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 36),
                    const SizedBox(height: 6),
                    Text(
                      'TOWER TOPPLED!',
                      style: AppTypography.headingMedium.copyWith(color: AppColors.error),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _gameOverReason,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    if (_mode == JengaGameMode.passAndPlay)
                      Text(
                        'Player ${_currentPlayer == 1 ? 2 : 1} Wins!',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.primaryAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else if (_mode == JengaGameMode.vsAi)
                      Text(
                        _currentPlayer == 1 ? 'WoodBot Wins!' : 'You Won against WoodBot!',
                        style: AppTypography.bodyMedium.copyWith(
                          color: _currentPlayer == 1 ? AppColors.error : AppColors.primaryAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else
                      Text(
                        'Blocks Successfully Extracted: $_blocksPulled',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.primaryAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 14),
                    MindRushButton(
                      label: 'Rebuild Tower',
                      icon: Icons.refresh_rounded,
                      onPressed: () => setState(_initTower),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showRulesDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.domain_rounded, color: AppColors.primaryAccent),
            const SizedBox(width: 8),
            Text('Jenga Tower Rules', style: AppTypography.headingMedium),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRuleItem('1. Tap any wooden block on floors below the top 2.'),
            _buildRuleItem('2. Use the extraction slider to slide the block out steadily.'),
            _buildRuleItem('3. If you slide too fast or remove key load-bearing blocks, the tower will tilt and collapse!'),
            _buildRuleItem('4. Complete extraction and tap "Stack on Top" to place it on the pinnacle.'),
            _buildRuleItem('5. In 2P or vs AI: The player who causes the tower to topple loses!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it', style: TextStyle(color: AppColors.primaryAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(text, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
    );
  }
}

class _FallingWoodPiece {
  double x;
  double y;
  double vx;
  double vy;
  double rot;
  double vRot;

  _FallingWoodPiece({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.rot,
    required this.vRot,
  });
}

class _JengaCollapsePainter extends CustomPainter {
  final List<_FallingWoodPiece> pieces;

  _JengaCollapsePainter({required this.pieces});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (final p in pieces) {
      canvas.save();
      canvas.translate(center.dx + p.x, p.y.clamp(0.0, size.height - 10));
      canvas.rotate(p.rot);

      final rect = Rect.fromCenter(center: Offset.zero, width: 44, height: 18);
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(3));

      final paint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFD7CCC8), Color(0xFF8D6E63)],
        ).createShader(rect);

      canvas.drawRRect(rrect, paint);
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = const Color(0xFF4E342E)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _JengaCollapsePainter oldDelegate) => true;
}
