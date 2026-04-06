import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RemoteConfigService {
  final _rc = FirebaseRemoteConfig.instance;

  Future<void> initialise() async {
    await _rc.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 15),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );

    // Default value in case fetch fails
    await _rc.setDefaults({
      'gemini_api_key': '',
    });

    try {
      await _rc.fetchAndActivate();
    } catch (e) {
      // Use cached/default values if fetch fails
      debugPrint('Remote Config fetch failed: $e');
    }
  }

  // Returns the Gemini API key
  String get geminiApiKey => _rc.getString('gemini_api_key');
}

final remoteConfigServiceProvider = Provider<RemoteConfigService>(
  (ref) => RemoteConfigService(),
);