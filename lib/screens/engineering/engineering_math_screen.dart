import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/common_widgets.dart';

class EngineeringMathScreen extends StatefulWidget {
  const EngineeringMathScreen({super.key});

  @override
  State<EngineeringMathScreen> createState() => _EngineeringMathScreenState();
}

class _EngineeringMathScreenState extends State<EngineeringMathScreen> {
  String _selectedSyllabus = 'JNTUA (R23/R20)';
  String _selectedBranch = 'CSE & IT';
  int _selectedSubjectIndex = 0;

  final List<Map<String, dynamic>> _subjects = [
    {
      'title': 'Engineering Mathematics I',
      'code': '23BS101',
      'sem': 'Year 1 • Semester 1',
      'units': [
        'Unit I: Matrices & System of Linear Equations',
        'Unit II: Eigenvalues & Eigenvectors (Cayley-Hamilton)',
        'Unit III: Mean Value Theorems & Calculus',
        'Unit IV: Functions of Several Variables & Jacobians',
        'Unit V: Multiple Integrals (Double & Triple)',
      ],
      'formulas': [
        'Cayley-Hamilton Theorem: Every square matrix satisfies its own characteristic equation |A - λI| = 0',
        'Taylor\'s Theorem: f(x) = f(a) + f\'(a)(x-a) + f\'\'(a)(x-a)²/2! + ...',
        'Jacobian J = ∂(u,v)/∂(x,y)',
      ],
      'quiz': [
        {
          'q': 'If λ₁, λ₂, λ₃ are eigenvalues of a 3×3 matrix A, what is the trace of A?',
          'options': ['λ₁ × λ₂ × λ₃', 'λ₁ + λ₂ + λ₃', '|A|', '0'],
          'answer': 1,
          'explanation': 'The trace of any square matrix is equal to the sum of its eigenvalues: Trace(A) = ∑ λᵢ.',
        },
        {
          'q': 'What is the condition for matrix A to be orthogonal?',
          'options': ['A² = I', 'Aᵀ = A⁻¹', 'det(A) = 0', 'A = -Aᵀ'],
          'answer': 1,
          'explanation': 'A matrix is orthogonal if A × Aᵀ = I, which implies that Aᵀ = A⁻¹ and det(A) = ±1.',
        },
        {
          'q': 'Evaluate the Rank of an identity matrix I₄:',
          'options': ['1', '2', '3', '4'],
          'answer': 3,
          'explanation': 'The rank of an n×n identity matrix is always n. For I₄, the rank is 4.',
        },
      ],
    },
    {
      'title': 'Engineering Mathematics II',
      'code': '23BS201',
      'sem': 'Year 1 • Semester 2',
      'units': [
        'Unit I: First Order Ordinary Differential Equations',
        'Unit II: Higher Order Linear ODEs with Constant Coefficients',
        'Unit III: Laplace Transforms & Applications',
        'Unit IV: Vector Differentiation & Gradient/Divergence/Curl',
        'Unit V: Vector Integration (Green\'s, Stokes\', Gauss Divergence)',
      ],
      'formulas': [
        'Laplace Transform: L{e^(at)} = 1 / (s - a)',
        'Gauss Divergence: ∯ F · n dS = ∭ (div F) dV',
        'Stokes\' Theorem: ∮ F · dr = ∬ (curl F) · n dS',
      ],
      'quiz': [
        {
          'q': 'What is the Laplace transform of L{sin(at)}?',
          'options': ['s / (s² + a²)', 'a / (s² + a²)', 'a / (s² - a²)', '1 / (s + a)'],
          'answer': 1,
          'explanation': 'L{sin(at)} = a / (s² + a²), while L{cos(at)} = s / (s² + a²).',
        },
        {
          'q': 'If a vector field F satisfies curl(F) = 0, the field is said to be:',
          'options': ['Solenoidal', 'Irrotational / Conservative', 'Harmonic', 'Rotational'],
          'answer': 1,
          'explanation': 'A vector field with zero curl everywhere is irrotational (conservative), meaning F = ∇φ.',
        },
      ],
    },
    {
      'title': 'Engineering Mathematics III',
      'code': '23BS301',
      'sem': 'Year 2 • Semester 1',
      'units': [
        'Unit I: Complex Variables & Cauchy-Riemann Equations',
        'Unit II: Complex Integration & Residue Theorem',
        'Unit III: Probability Distributions (Binomial, Poisson, Normal)',
        'Unit IV: Numerical Solutions of Algebraic Equations',
        'Unit V: Curve Fitting & Correlation/Regression',
      ],
      'formulas': [
        'Cauchy-Riemann Equations: ∂u/∂x = ∂v/∂y and ∂u/∂y = -∂v/∂x',
        'Residue Theorem: ∮ f(z) dz = 2πi ∑ Res(f, zₖ)',
        'Poisson Distribution: P(X = k) = (λᵏ e⁻λ) / k!',
      ],
      'quiz': [
        {
          'q': 'What is the mean of a Poisson distribution with parameter λ?',
          'options': ['λ²', 'λ', '√λ', '1/λ'],
          'answer': 1,
          'explanation': 'For a Poisson distribution, both the Mean and the Variance are equal to parameter λ.',
        },
      ],
    },
  ];

  void _startPracticeQuiz(Map<String, dynamic> subject) {
    final quiz = subject['quiz'] as List<Map<String, dynamic>>;
    int score = 0;
    int currentQ = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.secondaryBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final q = quiz[currentQ];
            final options = q['options'] as List<String>;
            final correctIdx = q['answer'] as int;

            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Question ${currentQ + 1}/${quiz.length}', style: AppTypography.labelMedium.copyWith(color: AppColors.primaryAccent)),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.secondaryText),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(q['q'], style: AppTypography.heading3),
                  const SizedBox(height: 24),
                  ...List.generate(options.length, (optIdx) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          side: const BorderSide(color: AppColors.divider),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          final isCorrect = optIdx == correctIdx;
                          if (isCorrect) score++;

                          showDialog(
                            context: context,
                            builder: (dCtx) => AlertDialog(
                              backgroundColor: AppColors.cardBg,
                              title: Text(isCorrect ? '✅ Correct Answer!' : '❌ Incorrect', style: AppTypography.heading4),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Correct: ${options[correctIdx]}', style: AppTypography.labelMedium.copyWith(color: AppColors.success)),
                                  const SizedBox(height: 10),
                                  Text(q['explanation'], style: AppTypography.bodySmall),
                                ],
                              ),
                              actions: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(dCtx).pop();
                                    if (currentQ + 1 < quiz.length) {
                                      setModalState(() => currentQ++);
                                    } else {
                                      Navigator.of(ctx).pop();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Quiz Completed! Score: $score/${quiz.length} points')),
                                      );
                                    }
                                  },
                                  child: const Text('Next'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(options[optIdx], style: AppTypography.bodyMedium),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeSubject = _subjects[_selectedSubjectIndex];

    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('B.Tech Engineering Math', style: AppTypography.heading4),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Syllabus & Regulation Selector Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.school_rounded, color: AppColors.primaryAccent, size: 20),
                        const SizedBox(width: 8),
                        Text('Syllabus & Branch', style: AppTypography.labelMedium),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.elevatedCard,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedSyllabus,
                                dropdownColor: AppColors.elevatedCard,
                                isDense: true,
                                style: AppTypography.labelSmall,
                                items: ['JNTUA (R23/R20)', 'JNTUH (R22)', 'Autonomous Colleges', 'AICTE Model']
                                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedSyllabus = val);
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.elevatedCard,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedBranch,
                                dropdownColor: AppColors.elevatedCard,
                                isDense: true,
                                style: AppTypography.labelSmall,
                                items: ['CSE & IT', 'ECE & EEE', 'Mechanical', 'Civil Engineering', 'AI & Data Science']
                                    .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedBranch = val);
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Subject Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_subjects.length, (idx) {
                    final sub = _subjects[idx];
                    final isSel = _selectedSubjectIndex == idx;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedSubjectIndex = idx),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.secondaryAccent.withOpacity(0.2) : AppColors.cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSel ? AppColors.secondaryAccent : AppColors.divider,
                            width: isSel ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sub['title'].split(' ')[1] + ' ' + sub['title'].split(' ')[2],
                              style: AppTypography.labelMedium.copyWith(
                                color: isSel ? AppColors.secondaryAccent : AppColors.primaryText,
                                fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                            Text(sub['sem'], style: AppTypography.bodySmall.copyWith(fontSize: 10)),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 20),

              // Subject Units Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(activeSubject['title'], style: AppTypography.heading3),
                              Text('Code: ${activeSubject["code"]} • ${_selectedSyllabus}', style: AppTypography.bodySmall),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryAccent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('VERIFIED', style: AppTypography.labelSmall.copyWith(color: AppColors.primaryAccent, fontSize: 9)),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Text('Units & Topics', style: AppTypography.labelMedium),
                    const SizedBox(height: 8),
                    ...(activeSubject['units'] as List<String>).map((unit) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.bookmark_outline_rounded, size: 16, color: AppColors.primaryAccent),
                            const SizedBox(width: 8),
                            Expanded(child: Text(unit, style: AppTypography.bodySmall)),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    MindRushButton(
                      label: 'Start Practice Questions',
                      icon: Icons.quiz_rounded,
                      onPressed: () => _startPracticeQuiz(activeSubject),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Formulas Reference Sheet
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.elevatedCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.functions_rounded, size: 20, color: AppColors.warning),
                        const SizedBox(width: 8),
                        Text('Essential Formula Sheet', style: AppTypography.labelMedium),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...(activeSubject['formulas'] as List<String>).map((formula) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.divider, width: 0.5),
                        ),
                        child: Text(formula, style: AppTypography.monoBody.copyWith(fontSize: 12, color: AppColors.primaryText)),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
