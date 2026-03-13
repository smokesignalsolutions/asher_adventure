import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/audio_provider.dart';
import 'services/audio_service.dart';

const _routeMusic = <String, MusicTrack>{
  '/': MusicTrack.title,
  '/party-select': MusicTrack.title,
  '/map': MusicTrack.exploration,
  '/combat': MusicTrack.battle,
  '/shop': MusicTrack.shop,
  '/rest': MusicTrack.rest,
  '/treasure': MusicTrack.treasure,
  '/event': MusicTrack.event,
  '/game-over': MusicTrack.gameOver,
  '/victory': MusicTrack.victory,
};

class AsherAdventureApp extends ConsumerStatefulWidget {
  const AsherAdventureApp({super.key});

  @override
  ConsumerState<AsherAdventureApp> createState() => _AsherAdventureAppState();
}

class _AsherAdventureAppState extends ConsumerState<AsherAdventureApp> {
  @override
  void initState() {
    super.initState();
    appRouter.routerDelegate.addListener(_onRouteChanged);
  }

  @override
  void dispose() {
    appRouter.routerDelegate.removeListener(_onRouteChanged);
    super.dispose();
  }

  void _onRouteChanged() {
    final location = appRouter.routerDelegate.currentConfiguration.uri.path;
    final track = _routeMusic[location];
    if (track != null) {
      ref.read(audioProvider.notifier).playMusic(track);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Asher's Adventure",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
