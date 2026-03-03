import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Audio service for ambient sounds and session alerts.
class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  final Map<String, AudioPlayer> _players = {};
  final Map<String, double> _volumes = {};
  static const int maxConcurrent = 3;

  /// Play an ambient sound with optional looping
  Future<void> play(String soundId,
      {String? assetPath, bool loop = true, double volume = 0.7}) async {
    if (_players.length >= maxConcurrent && !_players.containsKey(soundId)) {
      debugPrint('🎵 Max concurrent sounds reached ($maxConcurrent)');
      return;
    }

    try {
      _players[soundId]?.dispose();
      final player = AudioPlayer();
      _players[soundId] = player;
      _volumes[soundId] = volume;

      if (loop) {
        await player.setReleaseMode(ReleaseMode.loop);
      }
      await player.setVolume(volume);

      if (assetPath != null) {
        await player.play(AssetSource(assetPath));
      }
      debugPrint('🎵 Playing: $soundId (vol: $volume)');
    } catch (e) {
      debugPrint('🎵 Error playing $soundId: $e');
    }
  }

  /// Stop a specific sound
  Future<void> stop(String soundId) async {
    await _players[soundId]?.stop();
    await _players[soundId]?.dispose();
    _players.remove(soundId);
    _volumes.remove(soundId);
  }

  /// Stop all sounds
  Future<void> stopAll() async {
    for (final player in _players.values) {
      await player.stop();
      await player.dispose();
    }
    _players.clear();
    _volumes.clear();
  }

  /// Set volume for a specific sound
  Future<void> setVolume(String soundId, double volume) async {
    _volumes[soundId] = volume;
    await _players[soundId]?.setVolume(volume);
  }

  /// Check if a specific sound is playing
  bool isPlaying(String soundId) => _players.containsKey(soundId);

  /// Get all currently playing sounds
  Set<String> get activeSounds => _players.keys.toSet();

  /// Get volume for a sound
  double getVolume(String soundId) => _volumes[soundId] ?? 0.7;

  /// Dispose all players
  void dispose() {
    for (final player in _players.values) {
      player.dispose();
    }
    _players.clear();
    _volumes.clear();
  }
}
