import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/common_widgets.dart';
import '../../providers/game_provider.dart';

class RoomDuelScreen extends StatefulWidget {
  const RoomDuelScreen({super.key});

  @override
  State<RoomDuelScreen> createState() => _RoomDuelScreenState();
}

class _RoomDuelScreenState extends State<RoomDuelScreen> {
  final TextEditingController _codeController = TextEditingController();
  String? _createdRoomCode;
  bool _isWaitingForFriend = false;

  void _createRoom() {
    final code = 'MIND-${1000 + Random().nextInt(9000)}';
    setState(() {
      _createdRoomCode = code;
      _isWaitingForFriend = true;
    });

    // Simulate friend connecting after 2.5s
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      final provider = context.read<GameProvider>();
      provider.startDuel(questionCount: 10);
      Navigator.of(context).pushReplacementNamed('/duel-game');
    });
  }

  void _joinRoom() {
    if (_codeController.text.trim().isEmpty) return;

    final provider = context.read<GameProvider>();
    provider.startDuel(questionCount: 10);
    Navigator.of(context).pushReplacementNamed('/duel-game');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, _) {
        final profile = provider.profile;

        return Scaffold(
          backgroundColor: AppColors.primaryBg,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primaryText),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text('Friend Match Room', style: AppTypography.heading4),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Challenge a friend directly using a private match code', style: AppTypography.bodySmall),
                  const SizedBox(height: 24),

                  // Option A: Create Room
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primaryAccent.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('⚔️', style: TextStyle(fontSize: 24)),
                            const SizedBox(width: 10),
                            Text('Host Private Duel Room', style: AppTypography.labelLarge),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Generate a private room PIN and share it with your friend.', style: AppTypography.bodySmall),
                        const SizedBox(height: 16),

                        if (_createdRoomCode == null)
                          MindRushButton(
                            label: 'Create Room Code',
                            icon: Icons.add_circle_outline_rounded,
                            onPressed: _createRoom,
                          )
                        else ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.primaryAccent),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_createdRoomCode!, style: AppTypography.monoMedium.copyWith(color: AppColors.primaryAccent, fontSize: 24)),
                                IconButton(
                                  icon: const Icon(Icons.copy_rounded, color: AppColors.primaryAccent),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Room code copied to clipboard!')),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryAccent),
                              ),
                              const SizedBox(width: 10),
                              Text('Waiting for friend to join...', style: AppTypography.bodySmall.copyWith(color: AppColors.primaryAccent)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Option B: Join Room
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.secondaryAccent.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('🔑', style: TextStyle(fontSize: 24)),
                            const SizedBox(width: 10),
                            Text('Join Room with Code', style: AppTypography.labelLarge),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Enter the 6-digit PIN code shared by your friend.', style: AppTypography.bodySmall),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _codeController,
                          textCapitalization: TextCapitalization.characters,
                          style: AppTypography.monoMedium.copyWith(color: AppColors.secondaryAccent),
                          decoration: InputDecoration(
                            hintText: 'e.g. MIND-7482',
                            prefixIcon: const Icon(Icons.tag_rounded, color: AppColors.secondaryAccent),
                          ),
                        ),
                        const SizedBox(height: 16),
                        MindRushButton(
                          label: 'Join Duel',
                          icon: Icons.login_rounded,
                          isOutlined: true,
                          onPressed: _joinRoom,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
