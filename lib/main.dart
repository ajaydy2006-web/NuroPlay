import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'widgets/common/phone_interface_wrapper.dart';
import 'providers/game_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/auth/setup_screen.dart';
import 'screens/main_screen.dart';
import 'screens/games/duel/duel_setup_screen.dart';
import 'screens/games/duel/duel_game_screen.dart';
import 'screens/games/duel/solo_math_screen.dart';
import 'screens/games/memory/memory_game_screen.dart';
import 'screens/games/mind_snap/mind_snap_screen.dart';
import 'screens/games/logic/logic_puzzles_screen.dart';
import 'screens/games/daily_challenge/daily_challenge_screen.dart';
import 'screens/games/workout/workout_screen.dart';
import 'screens/results/game_results_screen.dart';
import 'screens/premium/premium_screen.dart';

// New features from Master Prompt
import 'screens/casual/casual_feed_screen.dart';
import 'screens/casual/reaction_tap_game.dart';
import 'screens/casual/memory_match_game.dart';
import 'screens/casual/color_switch_game.dart';
import 'screens/casual/number_merge_game.dart';
import 'screens/casual/sliding_puzzle_game.dart';
import 'screens/casual/pattern_recall_game.dart';
import 'screens/puzzles/puzzle_hub_screen.dart';
import 'screens/puzzles/cross_math_screen.dart';
import 'screens/puzzles/mini_sudoku_screen.dart';
import 'screens/games/flash_anzan/flash_anzan_screen.dart';
import 'screens/engineering/engineering_math_screen.dart';
import 'screens/multiplayer/room_duel_screen.dart';

// Real-World Games Collection
import 'screens/real_world/real_world_arcade_screen.dart';
import 'screens/real_world/paper_football_game.dart';
import 'screens/real_world/paper_plane_game.dart';
import 'screens/real_world/mini_carrom_game.dart';
import 'screens/real_world/cup_pong_game.dart';
import 'screens/real_world/marble_knockout_game.dart';
import 'screens/real_world/jenga_tower_game.dart';
import 'screens/real_world/tic_tac_toe_game.dart';
import 'screens/real_world/rps_showdown_game.dart';
import 'screens/real_world/four_in_row_game.dart';
import 'screens/real_world/reflex_duel_game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final gameProvider = GameProvider();
  await gameProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<GameProvider>.value(value: gameProvider),
      ],
      child: const NuroPlayApp(),
    ),
  );
}

class NuroPlayApp extends StatelessWidget {
  const NuroPlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NuroPlay',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/splash',
      builder: (context, child) => PhoneInterfaceWrapper(child: child ?? const SizedBox()),
      routes: {
        '/': (context) => const SplashScreen(),
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/auth': (context) => const AuthScreen(),
        '/setup': (context) => const SetupScreen(),
        '/main': (context) => const MainScreen(),
        '/duel-setup': (context) => const DuelSetupScreen(),
        '/duel-game': (context) => const DuelGameScreen(),
        '/solo-math': (context) => const SoloMathScreen(),
        '/memory-game': (context) => const MemoryGameScreen(),
        '/mind-snap': (context) => const MindSnapScreen(),
        '/logic-puzzles': (context) => const LogicPuzzlesScreen(),
        '/daily-challenge': (context) => const DailyChallengeScreen(),
        '/workout': (context) => const WorkoutScreen(),
        '/results': (context) => const GameResultsScreen(),
        '/premium': (context) => const PremiumScreen(),

        // Master prompt new feature routes
        '/casual-games': (context) => const CasualFeedScreen(),
        '/casual-reaction-tap': (context) => const ReactionTapGame(),
        '/casual-memory-match': (context) => const MemoryMatchGame(),
        '/casual-color-switch': (context) => const ColorSwitchGame(),
        '/casual-number-merge': (context) => const NumberMergeGame(),
        '/casual-sliding-puzzle': (context) => const SlidingPuzzleGame(),
        '/casual-pattern-recall': (context) => const PatternRecallGame(),
        '/puzzles': (context) => const PuzzleHubScreen(),
        '/puzzle-crossmath': (context) => const CrossMathScreen(),
        '/puzzle-sudoku': (context) => const MiniSudokuScreen(),
        '/flash-anzan': (context) => const FlashAnzanScreen(),
        '/engineering-math': (context) => const EngineeringMathScreen(),
        '/room-duel': (context) => const RoomDuelScreen(),

        // Real-World Games Collection Routes
        '/arcade': (context) => const RealWorldArcadeScreen(),
        '/real-world-arcade': (context) => const RealWorldArcadeScreen(),
        '/game-paper-football': (context) => const PaperFootballGame(),
        '/game-paper-plane': (context) => const PaperPlaneGame(),
        '/game-mini-carrom': (context) => const MiniCarromGame(),
        '/game-cup-pong': (context) => const CupPongGame(),
        '/game-marble-knockout': (context) => const MarbleKnockoutGame(),
        '/game-jenga': (context) => const JengaTowerGame(),
        '/game-tictactoe': (context) => const TicTacToeGame(),
        '/game-rps': (context) => const RpsShowdownGame(),
        '/game-four-in-row': (context) => const FourInRowGame(),
        '/game-reflex-duel': (context) => const ReflexDuelGame(),
      },
    );
  }
}
