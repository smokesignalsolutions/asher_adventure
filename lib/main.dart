import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'services/audio_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AudioService().init();
  runApp(
    const ProviderScope(
      child: AsherAdventureApp(),
    ),
  );
}
