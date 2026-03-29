import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _rc = FirebaseRemoteConfig.instance;

  Future<void> initialise() async {
    await _rc.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 15),
        minimumFetchInterval: Duration.zero, // no caching (dev)
      ),
    );

    // ✅ Default values
    await _rc.setDefaults({
      'gemini_api_key': '',
      'huggingface_api_key': '',
    });

    // ✅ Fetch from Firebase
    await _rc.fetchAndActivate();

    // ✅ Debug logs
    debugPrint("HF RAW VALUE: ${_rc.getString('huggingface_api_key')}");
    debugPrint(
      "HF STATUS: ${huggingFaceApiKey.isEmpty ? "MISSING" : "OK"}",
    );
  }

  // ✅ Getters
  String get geminiApiKey => _rc.getString('gemini_api_key');

  String get huggingFaceApiKey => _rc.getString('huggingface_api_key');
}

// ✅ Riverpod provider
final remoteConfigServiceProvider =
    Provider<RemoteConfigService>((ref) => RemoteConfigService());
