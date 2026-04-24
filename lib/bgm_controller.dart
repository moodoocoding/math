import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

enum AppBgmTrack { main, problem, story }

class AppBgmController {
  AppBgmController._();

  static final AudioPlayer _player = AudioPlayer();
  static bool _configured = false;
  static String? _currentAsset;
  static AppBgmTrack? _currentTrack;
  static StreamSubscription<Duration>? _positionSub;
  static final Map<String, Duration> _savedPositions = <String, Duration>{};
  static final ValueNotifier<bool> isMuted = ValueNotifier<bool>(false);

  static const String _mainAsset = 'audio/bgm_main.mp3';
  static const String _problemAsset = 'audio/bgm_problem.mp3';
  static const String _storyAsset = 'audio/bgm_bg.mp3';
  static const double _defaultVolume = 0.35;
  static const double _problemVolume = _defaultVolume * 0.7;

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
    final volume = _effectiveVolume(track);

    if (_currentAsset == asset) {
      try {
        await _player.setVolume(volume);
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
    _currentTrack = track;
    await _player.play(AssetSource(asset), volume: volume, position: resumePosition);
  }

  static double _effectiveVolume(AppBgmTrack track) {
    if (isMuted.value) return 0;
    return track == AppBgmTrack.problem ? _problemVolume : _defaultVolume;
  }

  static Future<void> toggleMuted() async {
    await setMuted(!isMuted.value);
  }

  static Future<void> setMuted(bool muted) async {
    await _ensureConfigured();
    if (isMuted.value != muted) {
      isMuted.value = muted;
    }
    final track = _currentTrack;
    await _player.setVolume(track == null ? 0 : _effectiveVolume(track));
  }

  static Future<void> stop({bool resetPositions = false}) async {
    await _ensureConfigured();
    _currentAsset = null;
    _currentTrack = null;
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
    _currentTrack = null;
    isMuted.value = false;
    _savedPositions.clear();
  }
}
