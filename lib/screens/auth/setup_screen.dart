import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/common_widgets.dart';
import '../../providers/game_provider.dart';
import '../../models/game_models.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _usernameController = TextEditingController();
  String _selectedAvatar = '🧠';
  Difficulty _selectedDifficulty = Difficulty.medium;
  int _step = 0;

  final List<String> _avatars = [
    '🧠', '⚡', '🔥', '🎯', '🚀', '💎',
    '🦊', '🐺', '🦁', '🐲', '🦅', '🐙',
    '👾', '🤖', '🎮', '🏆', '⭐', '🌟',
  ];

  @override
  void initState() {
    super.initState();
    _usernameController.text = context.read<GameProvider>().profile.username;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < 2) {
      setState(() => _step++);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final provider = context.read<GameProvider>();
    if (_usernameController.text.trim().isNotEmpty) {
      await provider.updateUsername(_usernameController.text.trim());
    }
    await provider.updateAvatar(_selectedAvatar);
    await provider.setPreferredDifficulty(_selectedDifficulty);

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Progress
              Row(
                children: List.generate(3, (index) => Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: index <= _step
                          ? AppColors.primaryAccent
                          : AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                )),
              ),

              const SizedBox(height: 8),

              // Skip
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _finish,
                  child: Text(
                    'Skip',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _step == 0
                      ? _buildUsernameStep()
                      : _step == 1
                          ? _buildAvatarStep()
                          : _buildDifficultyStep(),
                ),
              ),

              MindRushButton(
                label: _step < 2 ? 'Continue' : 'Start Playing',
                onPressed: _next,
                width: double.infinity,
                icon: _step < 2
                    ? Icons.arrow_forward_rounded
                    : Icons.rocket_launch_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameStep() {
    return Column(
      key: const ValueKey('username'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('👤', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 24),
        Text('Choose your username', style: AppTypography.heading2),
        const SizedBox(height: 8),
        Text(
          'This is how other players will see you',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.secondaryText),
        ),
        const SizedBox(height: 32),
        TextFormField(
          controller: _usernameController,
          style: AppTypography.bodyLarge,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: 'Enter username',
            counterText: '${_usernameController.text.length}/20',
          ),
          maxLength: 20,
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildAvatarStep() {
    return Column(
      key: const ValueKey('avatar'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(_selectedAvatar, style: const TextStyle(fontSize: 64)),
        const SizedBox(height: 24),
        Text('Pick your avatar', style: AppTypography.heading2),
        const SizedBox(height: 8),
        Text(
          'Express yourself with an emoji avatar',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.secondaryText),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: _avatars.map((emoji) {
            final isSelected = emoji == _selectedAvatar;
            return GestureDetector(
              onTap: () => setState(() => _selectedAvatar = emoji),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryAccent.withOpacity(0.2)
                      : AppColors.elevatedCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryAccent
                        : AppColors.divider,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 28)),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDifficultyStep() {
    return Column(
      key: const ValueKey('difficulty'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🎚️', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 24),
        Text('Set your difficulty', style: AppTypography.heading2),
        const SizedBox(height: 8),
        Text(
          'You can change this anytime in settings',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.secondaryText),
        ),
        const SizedBox(height: 32),
        ...Difficulty.values.map((d) {
          final isSelected = d == _selectedDifficulty;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => setState(() => _selectedDifficulty = d),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? d.color.withOpacity(0.15)
                      : AppColors.cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? d.color : AppColors.divider,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(d.icon, color: d.color, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.label, style: AppTypography.labelLarge),
                          Text(
                            d == Difficulty.easy ? 'Numbers 1-20, basic operations'
                                : d == Difficulty.medium ? 'Numbers 1-50, all operations'
                                : d == Difficulty.hard ? 'Numbers 1-100, complex problems'
                                : 'Numbers 1-500, expert challenges',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle_rounded, color: d.color),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
