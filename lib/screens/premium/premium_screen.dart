import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/common_widgets.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  int _selectedPlan = 1; // 0 = monthly, 1 = yearly

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            children: [
              // ─── Pro Badge & Header ───
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8A7CFF), Color(0xFF52E0C0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondaryAccent.withOpacity(0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('👑', style: TextStyle(fontSize: 36)),
                ),
              ),
              const SizedBox(height: 16),
              Text('NuroPlay PRO', style: AppTypography.heading1),
              const SizedBox(height: 6),
              Text(
                'Unlock your full mental potential with elite brain training tools',
                style: AppTypography.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // ─── Features List ───
              _buildFeatureRow('⚡', 'Unlimited Workouts', 'No daily workout cooldowns or limits'),
              _buildFeatureRow('📊', 'Advanced Analytics', 'Track reaction times, accuracy by operation & cognitive trends'),
              _buildFeatureRow('🤖', 'Adaptive AI Bots', 'Play against AI tuned to your exact skill level'),
              _buildFeatureRow('🎨', 'Exclusive Avatars & Themes', 'Unlock gold badges, neon frames and custom UI styles'),
              _buildFeatureRow('🚫', 'Zero Distractions', '100% ad-free, pure competitive focus'),

              const SizedBox(height: 24),

              // ─── Plans Selector ───
              _buildPlanCard(
                index: 1,
                title: 'Annual Plan',
                price: '\$29.99 / year',
                periodSubtitle: '\$2.49 / month • Billed annually',
                badgeText: 'BEST VALUE (SAVE 50%)',
              ),
              const SizedBox(height: 12),
              _buildPlanCard(
                index: 0,
                title: 'Monthly Plan',
                price: '\$4.99 / month',
                periodSubtitle: 'Billed monthly • Cancel anytime',
              ),

              const SizedBox(height: 24),

              // ─── CTA Button ───
              MindRushButton(
                label: 'Start 7-Day Free Trial',
                icon: Icons.bolt_rounded,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('NuroPlay PRO activated! Welcome to the elite club! 🎉')),
                  );
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 12),
              Text(
                'Free for 7 days, then \$${_selectedPlan == 1 ? "29.99/yr" : "4.99/mo"}. Cancel anytime in store.',
                style: AppTypography.bodySmall.copyWith(fontSize: 11),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Text('Restore', style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                  ),
                  const Text('•', style: TextStyle(color: AppColors.secondaryText)),
                  TextButton(
                    onPressed: () {},
                    child: Text('Terms', style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                  ),
                  const Text('•', style: TextStyle(color: AppColors.secondaryText)),
                  TextButton(
                    onPressed: () {},
                    child: Text('Privacy', style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.elevatedCard,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.labelMedium),
                const SizedBox(height: 1),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required int index,
    required String title,
    required String price,
    required String periodSubtitle,
    String? badgeText,
  }) {
    final isSelected = _selectedPlan == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = index),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryAccent.withOpacity(0.12)
              : AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryAccent : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (badgeText != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primaryBg,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.labelLarge),
                    const SizedBox(height: 2),
                    Text(
                      periodSubtitle,
                      style: AppTypography.bodySmall.copyWith(fontSize: 11),
                    ),
                  ],
                ),
                Text(
                  price,
                  style: AppTypography.monoBody.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isSelected ? AppColors.primaryAccent : AppColors.primaryText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
