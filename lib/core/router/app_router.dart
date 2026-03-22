import 'package:go_router/go_router.dart';
import '../../ui/screens/title/title_screen.dart';
import '../../ui/screens/party_select/party_select_screen.dart';
import '../../ui/screens/map/map_screen.dart';
import '../../ui/screens/combat/combat_screen.dart';
import '../../ui/screens/shop/shop_screen.dart';
import '../../ui/screens/rest/rest_screen.dart';
import '../../ui/screens/treasure/treasure_screen.dart';
import '../../ui/screens/event/event_screen.dart';
import '../../ui/screens/recruit/recruit_screen.dart';
import '../../ui/screens/help/help_screen.dart';
import '../../ui/screens/legacy_hall/legacy_hall_screen.dart';
import '../../ui/screens/game_over/game_over_screen.dart';
import '../../ui/screens/codex/codex_screen.dart';
import '../../ui/screens/victory/victory_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const TitleScreen()),
    GoRoute(path: '/party-select', builder: (context, state) => PartySelectScreen(testMode: state.uri.queryParameters['testMode'] == 'true')),
    GoRoute(path: '/map', builder: (context, state) => const MapScreen()),
    GoRoute(path: '/combat', builder: (context, state) => const CombatScreen()),
    GoRoute(path: '/shop', builder: (context, state) => const ShopScreen()),
    GoRoute(path: '/rest', builder: (context, state) => const RestScreen()),
    GoRoute(path: '/treasure', builder: (context, state) => const TreasureScreen()),
    GoRoute(path: '/event', builder: (context, state) => const EventScreen()),
    GoRoute(path: '/recruit', builder: (context, state) => const RecruitScreen()),
    GoRoute(path: '/help', builder: (context, state) => const HelpScreen()),
    GoRoute(path: '/legacy-hall', builder: (context, state) => const LegacyHallScreen()),
    GoRoute(path: '/game-over', builder: (context, state) => const GameOverScreen()),
    GoRoute(path: '/codex', builder: (context, state) => const CodexScreen()),
    GoRoute(path: '/victory', builder: (context, state) => const VictoryScreen()),
  ],
);
