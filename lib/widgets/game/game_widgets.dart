import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Custom numeric keypad for answer input
class NumericKeypad extends StatelessWidget {
  final Function(int) onNumberTap;
  final VoidCallback onDelete;
  final VoidCallback onSubmit;
  final String currentInput;

  const NumericKeypad({
    super.key,
    required this.onNumberTap,
    required this.onDelete,
    required this.onSubmit,
    required this.currentInput,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Display current input
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.elevatedCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryAccent.withOpacity(0.3)),
          ),
          child: Text(
            currentInput.isEmpty ? '—' : currentInput,
            style: AppTypography.monoMedium.copyWith(
              color: currentInput.isEmpty ? AppColors.secondaryText : AppColors.primaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        // Keypad grid
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.8,
          children: [
            for (int i = 1; i <= 9; i++)
              _KeyButton(label: '$i', onTap: () => onNumberTap(i)),
            _KeyButton(
              label: '⌫',
              onTap: onDelete,
              color: AppColors.error.withOpacity(0.2),
              textColor: AppColors.error,
            ),
            _KeyButton(label: '0', onTap: () => onNumberTap(0)),
            _KeyButton(
              label: '✓',
              onTap: onSubmit,
              color: AppColors.primaryAccent.withOpacity(0.2),
              textColor: AppColors.primaryAccent,
            ),
          ],
        ),
      ],
    );
  }
}

class _KeyButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final Color? textColor;

  const _KeyButton({
    required this.label,
    required this.onTap,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? AppColors.elevatedCard,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider, width: 0.5),
          ),
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
      ),
    );
  }
}

/// Multiple choice answer option button
class AnswerOptionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isSelected;
  final bool? isCorrect; // null = not yet answered
  final bool showResult;

  const AnswerOptionButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isSelected = false,
    this.isCorrect,
    this.showResult = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = AppColors.elevatedCard;
    Color borderColor = AppColors.divider;
    Color textColor = AppColors.primaryText;

    if (showResult && isCorrect == true) {
      bgColor = AppColors.success.withOpacity(0.15);
      borderColor = AppColors.success;
      textColor = AppColors.success;
    } else if (showResult && isSelected && isCorrect == false) {
      bgColor = AppColors.error.withOpacity(0.15);
      borderColor = AppColors.error;
      textColor = AppColors.error;
    } else if (isSelected) {
      bgColor = AppColors.primaryAccent.withOpacity(0.15);
      borderColor = AppColors.primaryAccent;
      textColor = AppColors.primaryAccent;
    }

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: showResult ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.monoSmall.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Game timer display
class GameTimer extends StatelessWidget {
  final int seconds;
  final int? maxSeconds;
  final Color? color;

  const GameTimer({
    super.key,
    required this.seconds,
    this.maxSeconds,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    final isLow = maxSeconds != null && seconds <= (maxSeconds! * 0.2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (isLow ? AppColors.error : (color ?? AppColors.primaryAccent)).withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (isLow ? AppColors.error : (color ?? AppColors.primaryAccent)).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_rounded,
            size: 16,
            color: isLow ? AppColors.error : (color ?? AppColors.primaryAccent),
          ),
          const SizedBox(width: 4),
          Text(
            '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
            style: AppTypography.monoBody.copyWith(
              color: isLow ? AppColors.error : (color ?? AppColors.primaryAccent),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Score display for duel mode
class DuelScoreBar extends StatelessWidget {
  final String playerName;
  final int playerScore;
  final String opponentName;
  final int opponentScore;
  final String playerEmoji;

  const DuelScoreBar({
    super.key,
    required this.playerName,
    required this.playerScore,
    required this.opponentName,
    required this.opponentScore,
    this.playerEmoji = '🧠',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.elevatedCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          // Player
          Expanded(
            child: Row(
              children: [
                Text(playerEmoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playerName,
                      style: AppTypography.labelSmall.copyWith(color: AppColors.primaryAccent),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$playerScore',
                      style: AppTypography.monoBody.copyWith(
                        color: AppColors.primaryAccent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // VS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'VS',
              style: AppTypography.labelSmall.copyWith(color: AppColors.secondaryText),
            ),
          ),
          // Opponent
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      opponentName,
                      style: AppTypography.labelSmall.copyWith(color: AppColors.secondaryAccent),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$opponentScore',
                      style: AppTypography.monoBody.copyWith(
                        color: AppColors.secondaryAccent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                const Text('🤖', style: TextStyle(fontSize: 20)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Question progress indicator
class QuestionProgress extends StatelessWidget {
  final int current;
  final int total;

  const QuestionProgress({
    super.key,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Q${current + 1}',
          style: AppTypography.labelMedium.copyWith(color: AppColors.primaryAccent),
        ),
        Text(
          ' / $total',
          style: AppTypography.labelMedium.copyWith(color: AppColors.secondaryText),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (current + 1) / total,
              backgroundColor: AppColors.divider,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryAccent),
              minHeight: 4,
            ),
          ),
        ),
      ],
    );
  }
}
