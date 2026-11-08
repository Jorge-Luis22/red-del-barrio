import 'package:go_router/go_router.dart';

import '../features/community/presentation/community_screen.dart';

import '../features/bids/domain/bid.dart';
import '../features/bids/presentation/bid_board_screen.dart';
import '../features/deals_chat/presentation/chat_screen.dart';
import '../features/deals_chat/presentation/mensajes_screen.dart';
import '../features/emergency/presentation/emergencia_screen.dart';
import '../features/explore/presentation/explore_section.dart';
import '../features/assistant/presentation/tablero_screen.dart';
import '../features/needs/presentation/home_screen.dart';
import '../features/profile/presentation/welcome_screen.dart';
import '../features/needs/presentation/my_needs_screen.dart';
import '../features/proposals/presentation/need_detail_screen.dart';
import '../features/settings/presentation/perfil_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/solidarity/presentation/vecinos_screen.dart';
import 'shell_scaffold.dart';

/// Rutas declarativas: las cinco pestañas del PWA (Inicio, Vecinos, Mensajes, Emergencia, Perfil)
/// y sus pantallas internas (pedidos, explorar, detalle de un pedido y chat de un trato).
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/bienvenida', builder: (_, _) => const WelcomeScreen()),
    GoRoute(
      path: '/oferta/:kind/:id',
      builder: (_, state) => BidBoardScreen(
        kind: state.pathParameters['kind'] == 'request'
            ? BidKind.request
            : BidKind.sale,
        id: state.pathParameters['id']!,
      ),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => ShellScaffold(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'need/:id',
                  builder: (_, state) =>
                      NeedDetailScreen(needId: state.pathParameters['id']!),
                ),
                GoRoute(
                  path: 'pedidos',
                  builder: (_, _) => const MyNeedsScreen(),
                ),
                GoRoute(
                  path: 'barrio',
                  builder: (_, _) => const CommunityScreen(),
                ),
                GoRoute(
                  path: 'explorar',
                  builder: (_, _) => const ExploreScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/vecinos', builder: (_, _) => const VecinosScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/mensajes',
              builder: (_, _) => const MensajesScreen(),
              routes: [
                GoRoute(
                  path: ':dealId',
                  builder: (_, state) =>
                      ChatScreen(dealId: state.pathParameters['dealId']!),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/emergencia',
              builder: (_, _) => const EmergenciaScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/perfil',
              builder: (_, _) => const PerfilScreen(),
              routes: [
                GoRoute(
                  path: 'ajustes',
                  builder: (_, _) => const SettingsScreen(),
                ),
                GoRoute(
                  path: 'tablero',
                  builder: (_, _) => const TableroScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
