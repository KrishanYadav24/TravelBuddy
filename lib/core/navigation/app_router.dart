import 'package:go_router/go_router.dart';
import '../../features/activity_selector/activity_selector_screen.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/browse_by_state/browse_by_state_screen.dart';
import '../../features/community/community_screen.dart';
import '../../features/destination_detail/destination_detail_screen.dart';
import '../../features/emergency/emergency_screen.dart';
import '../../features/itinerary/itinerary_screen.dart';
import '../../features/map/map_screen.dart';
import '../../features/offline/offline_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/wishlist/wishlist_screen.dart';

/// Central Router configuration utilizing GoRouter.
final GoRouter appRouter = GoRouter(
  initialLocation: '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/activity-selector',
      builder: (context, state) => const ActivitySelectorScreen(),
    ),
    GoRoute(
      path: '/browse-by-state',
      builder: (context, state) => const BrowseByStateScreen(),
    ),
    GoRoute(
      path: '/map',
      builder: (context, state) => const MapScreen(),
    ),
    GoRoute(
      path: '/destination/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? 'unknown';
        return DestinationDetailScreen(destinationId: id);
      },
    ),
    GoRoute(
      path: '/wishlist',
      builder: (context, state) => const WishlistScreen(),
    ),
    GoRoute(
      path: '/itinerary',
      builder: (context, state) => const ItineraryScreen(),
    ),
    GoRoute(
      path: '/offline',
      builder: (context, state) => const OfflineScreen(),
    ),
    GoRoute(
      path: '/community',
      builder: (context, state) => const CommunityScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/emergency',
      builder: (context, state) => const EmergencyScreen(),
    ),
  ],
);
