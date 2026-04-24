import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

enum AppBgmTrack { main, problem, story }

class AppBgmController {
  AppBgmController._();

  static final AudioPlayer _player = AudioPlayer();
  static bool _configured = false;
  static String? _currentAsset;
  static StreamSubscription<Duration>? _positionSub;
  static final Map<String, Duration> _savedPositions = <String, Duration>{};

  static const String _mainAsset = 'audio/bgm_main.mp3';
  static const String _problemAsset = 'audio/bgm_problem.mp3';
  static const String _storyAsset = 'audio/bgm_bg.mp3';

  static Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _player.setReleaseMode(ReleaseMode.loop);
    _positionSub = _player.onPositionChanged.listen((position) {
      final asset = _currentAsset;
      if (asset != null) {
        _savedPositions[asset] = position;
      }
    });
    _configured = true;
  }

  static String _assetFor(AppBgmTrack track) {
    switch (track) {
      case AppBgmTrack.main:
        return _mainAsset;
      case AppBgmTrack.problem:
        return _problemAsset;
      case AppBgmTrack.story:
        return _storyAsset;
    }
  }

  static Future<void> playMain() => playTrack(AppBgmTrack.main);
  static Future<void> playProblem() => playTrack(AppBgmTrack.problem);
  static Future<void> playStory() => playTrack(AppBgmTrack.story);

  static Future<void> playTrack(AppBgmTrack track) async {
    await _ensureConfigured();
    final asset = _assetFor(track);

    if (_currentAsset == asset) {
      try {
        await _player.resume();
      } catch (_) {
        // Ignore if already playing.
      }
      return;
    }

    final previousAsset = _currentAsset;
    if (previousAsset != null) {
      try {
        final pos = await _player.getCurrentPosition();
        if (pos != null) {
          _savedPositions[previousAsset] = pos;
        }
      } catch (_) {
        // Ignore position read errors.
      }
    }

    final resumePosition = _savedPositions[asset];
    _currentAsset = asset;
    await _player.play(AssetSource(asset), volume: 0.35, position: resumePosition);
  }

  static Future<void> stop({bool resetPositions = false}) async {
    await _ensureConfigured();
    _currentAsset = null;
    await _player.stop();
    if (resetPositions) {
      _savedPositions.clear();
    }
  }

  static Future<void> dispose() async {
    await _positionSub?.cancel();
    await _player.dispose();
    _positionSub = null;
    _configured = false;
    _currentAsset = null;
    _savedPositions.clear();
  }
}
