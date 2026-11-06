import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../core/models/noise_sound.dart';

/// 音频服务 —— 提示音（完成"叮"）+ 白噪音播放。
/// 提示音用 assets/audio/ding.wav；白噪音用 assets/audio/<file> 循环播放。
class AudioService {
  final AudioPlayer _ding = AudioPlayer();
  final AudioPlayer _noise = AudioPlayer();

  AudioService() {
    _ding.setReleaseMode(ReleaseMode.stop);
    _noise.setReleaseMode(ReleaseMode.loop);
    _wire(_ding, 'ding');
    _wire(_noise, 'noise');
  }

  void _wire(AudioPlayer p, String tag) {
    p.onLog.listen((msg) => log('[$tag] $msg', name: 'AudioService'));
    p.onPlayerStateChanged
        .listen((s) => log('[$tag] state=$s', name: 'AudioService'));
  }

  /// 完成提示音。
  ///
  /// 注意：audioplayers 的 [AssetSource] 会自动拼接 `AudioCache.prefix`（默认
  /// `'assets/'`），所以这里必须传**相对 assets 目录**的路径，即 `audio/xxx`，
  /// 不能再带开头的 `assets/`，否则会加载 `assets/assets/audio/xxx` 而失败。
  Future<void> playDing() async {
    try {
      await _ding.setVolume(1.0);
      await _ding.play(AssetSource('audio/ding.wav'));
      log('playDing 触发', name: 'AudioService');
    } catch (e, st) {
      log('playDing 失败: $e\n$st', name: 'AudioService');
      debugPrint('[AudioService] playDing 失败: $e');
    }
  }

  /// 开始白噪音循环（单轨）。
  Future<void> playNoise(NoiseSound sound, {double volume = 0.6}) async {
    try {
      await _noise.setVolume(volume.clamp(0.0, 1.0));
      // 同上：路径相对 assets 目录，prefix 由 AudioCache 自动补 `assets/`。
      await _noise.play(AssetSource('audio/${sound.file}'));
      log('playNoise 触发: ${sound.file} vol=$volume', name: 'AudioService');
    } catch (e, st) {
      log('playNoise 失败: $e\n$st', name: 'AudioService');
      debugPrint('[AudioService] playNoise 失败: $e');
    }
  }

  Future<void> setNoiseVolume(double volume) async {
    try {
      await _noise.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      log('setNoiseVolume 失败: $e', name: 'AudioService');
    }
  }

  Future<void> stopNoise() async {
    try {
      await _noise.stop();
    } catch (e) {
      log('stopNoise 失败: $e', name: 'AudioService');
    }
  }

  void dispose() {
    _ding.dispose();
    _noise.dispose();
  }
}
