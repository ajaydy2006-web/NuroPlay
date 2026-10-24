import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/common/common_widgets.dart';

class FlashAnzanScreen extends StatefulWidget {
  const FlashAnzanScreen({super.key});

  @override
  State<FlashAnzanScreen> createState() => _FlashAnzanScreenState();
}

enum _AnzanState { setup, readyCountdown, flashing, answerInput, result }

class _FlashAnzanScreenState extends State<FlashAnzanScreen> {
  _AnzanState _state = _AnzanState.setup;

  int _numberCount = 5; // How many numbers
  int _digits = 2; // 1, 2, or 3 digits
  int _intervalMs = 800; // ms per number

  final List<int> _numbers = [];
  int _currentIndex = 0;
  int _correctSum = 0;
  String _userAnswer = '';
  int _readyCountdown = 3;
  Timer? _flashTimer;

  final Random _random = Random();

  void _startFlashing() {
    _numbers.clear();
    final minVal = _digits == 1 ? 1 : _digits == 2 ? 10 : 100;
    final maxVal = _digits == 1 ? 9 : _digits == 2 ? 99 : 999;

    int sum = 0;
    for (int i = 0; i < _numberCount; i++) {
      final val = minVal + _random.nextInt(maxVal - minVal + 1);
      _numbers.add(val);
      sum += val;
    }
    _correctSum = sum;
    _currentIndex = 0;
    _userAnswer = '';

    setState(() {
      _state = _AnzanState.readyCountdown;
      _readyCountdown = 3;
    });

    // 3.. 2.. 1.. GO
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_readyCountdown > 1) {
        setState(() => _readyCountdown--);
      } else {
        timer.cancel();
        _runFlashingLoop();
      }
    });
  }

  void _runFlashingLoop() {
    setState(() {
      _state = _AnzanState.flashing;
      _currentIndex = 0;
    });

    _flashTimer?.cancel();
    _flashTimer = Timer.periodic(Duration(milliseconds: _intervalMs), (timer) {
      if (_currentIndex + 1 < _numbers.length) {
        setState(() => _currentIndex++);
      } else {
        timer.cancel();
        setState(() {
          _state = _AnzanState.answerInput;
        });
      }
    });
  }

  void _onDigitTap(int d) {
    if (_userAnswer.length < 6) {
      setState(() => _userAnswer += '$d');
    }
  }

  void _onBackspace() {
    if (_userAnswer.isNotEmpty) {
      setState(() => _userAnswer = _userAnswer.substring(0, _userAnswer.length - 1));
    }
  }

  void _submitAnswer() {
    if (_userAnswer.isEmpty) return;
    setState(() {
      _state = _AnzanState.result;
    });
  }

  @override
  void dispose() {
    _flashTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isCorrect = int.tryParse(_userAnswer) == _correctSum;

    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Flash Anzan (Mental Math)', style: AppTypography.heading4),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              if (_state == _AnzanState.setup) ...[
                Text('Rapid Soroban mental arithmetic: add numbers flashed one by one', style: AppTypography.bodySmall, textAlign: TextAlign.center),
                const SizedBox(height: 24),

                // Settings Cards
                _buildSettingCard('Numbers to Add', '$_numberCount numbers', [
                  3, 5, 7, 10
                ], (val) => setState(() => _numberCount = val), _numberCount),
                const SizedBox(height: 14),

                _buildSettingCard('Digits', '$_digits digit numbers', [
                  1, 2, 3
                ], (val) => setState(() => _digits = val), _digits),
                const SizedBox(height: 14),

                _buildSettingCard('Flash Speed', '${_intervalMs / 1000}s per number', [
                  1200, 800, 500, 350
                ], (val) => setState(() => _intervalMs = val), _intervalMs, formatLabel: (ms) => '${ms / 1000}s'),

                const Spacer(),

                MindRushButton(
                  label: 'Start Flash Challenge',
                  icon: Icons.flash_on_rounded,
                  onPressed: _startFlashing,
                ),
                const SizedBox(height: 20),
              ] else if (_state == _AnzanState.readyCountdown) ...[
                const Spacer(),
                Text('GET READY', style: AppTypography.labelLarge.copyWith(letterSpacing: 2)),
                const SizedBox(height: 20),
                Text('$_readyCountdown', style: AppTypography.monoLarge.copyWith(fontSize: 80, color: AppColors.primaryAccent)),
                const Spacer(),
              ] else if (_state == _AnzanState.flashing) ...[
                // Flashing state
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Number ${_currentIndex + 1} of ${_numbers.length}', style: AppTypography.labelSmall),
                    Text('${_intervalMs}ms', style: AppTypography.bodySmall),
                  ],
                ),
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.primaryAccent, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryAccent.withOpacity(0.3),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${_numbers[_currentIndex]}',
                      style: AppTypography.monoLarge.copyWith(fontSize: 72, color: AppColors.primaryAccent),
                    ),
                  ),
                ),
                const Spacer(),
              ] else if (_state == _AnzanState.answerInput) ...[
                Text('What was the total sum?', style: AppTypography.heading3),
                const SizedBox(height: 8),
                Text('${_numbers.length} numbers added together', style: AppTypography.bodySmall),
                const SizedBox(height: 16),

                // Display user answer
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primaryAccent.withOpacity(0.5)),
                  ),
                  child: Center(
                    child: Text(
                      _userAnswer.isEmpty ? '—' : _userAnswer,
                      style: AppTypography.monoLarge.copyWith(fontSize: 36, color: AppColors.primaryAccent),
                    ),
                  ),
                ),

                const Spacer(),

                // Keypad
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.8,
                  children: [
                    for (int i = 1; i <= 9; i++)
                      _buildKey('$i', () => _onDigitTap(i)),
                    _buildKey('⌫', _onBackspace, color: AppColors.error.withOpacity(0.2), textColor: AppColors.error),
                    _buildKey('0', () => _onDigitTap(0)),
                    _buildKey('✓', _submitAnswer, color: AppColors.primaryAccent.withOpacity(0.2), textColor: AppColors.primaryAccent),
                  ],
                ),
                const SizedBox(height: 16),
              ] else if (_state == _AnzanState.result) ...[
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isCorrect ? AppColors.success.withOpacity(0.15) : AppColors.error.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: isCorrect ? AppColors.success : AppColors.error, width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(isCorrect ? '🎯 EXCELLENT CALCULATION!' : '❌ INCORRECT SUM', style: AppTypography.heading3.copyWith(color: isCorrect ? AppColors.success : AppColors.error)),
                      const SizedBox(height: 16),
                      Text('Correct Sum: $_correctSum', style: AppTypography.monoLarge.copyWith(fontSize: 36)),
                      if (!isCorrect)
                        Text('Your Answer: ${_userAnswer.isEmpty ? "None" : _userAnswer}', style: AppTypography.monoBody.copyWith(color: AppColors.error)),
                      const SizedBox(height: 12),
                      Text('Equation: ${_numbers.join(" + ")} = $_correctSum', style: AppTypography.bodySmall, textAlign: TextAlign.center),
                    ],
                  ),
                ),
                const Spacer(),

                Row(
                  children: [
                    Expanded(
                      child: MindRushButton(
                        label: 'Try Again',
                        icon: Icons.replay_rounded,
                        onPressed: _startFlashing,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MindRushButton(
                        label: 'Settings',
                        icon: Icons.tune_rounded,
                        isOutlined: true,
                        onPressed: () => setState(() => _state = _AnzanState.setup),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard<T>(
    String title,
    String subtitle,
    List<T> options,
    Function(T) onSelect,
    T current, {
    String Function(T)? formatLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTypography.labelMedium),
              Text(subtitle, style: AppTypography.bodySmall.copyWith(color: AppColors.primaryAccent)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: options.map((opt) {
              final isSel = opt == current;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onSelect(opt),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSel ? AppColors.primaryAccent.withOpacity(0.2) : AppColors.elevatedCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSel ? AppColors.primaryAccent : AppColors.divider),
                    ),
                    child: Center(
                      child: Text(
                        formatLabel != null ? formatLabel(opt) : '$opt',
                        style: AppTypography.labelSmall.copyWith(
                          color: isSel ? AppColors.primaryAccent : AppColors.secondaryText,
                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String label, VoidCallback onTap, {Color? color, Color? textColor}) {
    return Material(
      color: color ?? AppColors.elevatedCard,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Text(
            label,
            style: AppTypography.monoSmall.copyWith(
              color: textColor ?? AppColors.primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
