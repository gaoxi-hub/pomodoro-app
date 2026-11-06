import 'noise_sound.dart';

/// 白噪音单层配置。
class NoiseLayer {
  final bool on;
  final double volume; // 0..1

  const NoiseLayer({this.on = false, this.volume = 0.5});

  factory NoiseLayer.fromJson(Map<String, dynamic> json) => NoiseLayer(
        on: (json['on'] as bool?) ?? false,
        volume: (json['volume'] as num?)?.toDouble() ?? 0.5,
      );

  Map<String, dynamic> toJson() => {'on': on, 'volume': volume};

  NoiseLayer copyWith({bool? on, double? volume}) =>
      NoiseLayer(on: on ?? this.on, volume: volume ?? this.volume);
}

/// 白噪音配置（多层叠加，在 Flutter 端按"首个开启层"单轨播放）。
class NoiseConfig {
  final double master; // 0..1 总音量
  final Map<NoiseSound, NoiseLayer> layers;

  const NoiseConfig({this.master = 0.6, this.layers = const {}});

  factory NoiseConfig.defaults() => NoiseConfig(
        master: 0.6,
        layers: {
          for (final s in NoiseSound.values) s: const NoiseLayer(),
        },
      );

  factory NoiseConfig.fromJson(Map<String, dynamic> json) {
    final raw = (json['layers'] as Map?)?.cast<String, dynamic>() ?? {};
    final layers = <NoiseSound, NoiseLayer>{
      for (final s in NoiseSound.values)
        s: NoiseLayer.fromJson(
          raw[s.name] as Map<String, dynamic>? ?? {},
        ),
    };
    return NoiseConfig(
      master: (json['master'] as num?)?.toDouble() ?? 0.6,
      layers: layers,
    );
  }

  Map<String, dynamic> toJson() => {
        'master': master,
        'layers': {
          for (final e in layers.entries) e.key.name: e.value.toJson(),
        },
      };

  NoiseConfig copyWith({
    double? master,
    Map<NoiseSound, NoiseLayer>? layers,
  }) =>
      NoiseConfig(master: master ?? this.master, layers: layers ?? this.layers);

  /// 当前启用的音轨（取第一个开启的）。
  NoiseSound? get activeSound {
    for (final e in layers.entries) {
      if (e.value.on) return e.key;
    }
    return null;
  }

  double get activeVolume {
    final a = activeSound;
    if (a == null) return 0.0;
    return layers[a]!.volume * master;
  }
}

/// 设置模型 —— 对照 H5 types/index.ts 的 Settings。
class Settings {
  final int workMin;
  final int shortMin;
  final int longMin;
  final int longBreakInterval;
  final bool autoStartNext;
  final bool breakEndNotify;
  final bool celebrate;
  final bool soundOn;
  final NoiseConfig noise;

  const Settings({
    this.workMin = 25,
    this.shortMin = 5,
    this.longMin = 15,
    this.longBreakInterval = 4,
    this.autoStartNext = true,
    this.breakEndNotify = true,
    this.celebrate = true,
    this.soundOn = true,
    this.noise = const NoiseConfig(),
  });

  factory Settings.defaults() => const Settings();

  factory Settings.fromJson(Map<String, dynamic> json) => Settings(
        workMin: (json['workMin'] as int?) ?? 25,
        shortMin: (json['shortMin'] as int?) ?? 5,
        longMin: (json['longMin'] as int?) ?? 15,
        longBreakInterval: (json['longBreakInterval'] as int?) ?? 4,
        autoStartNext: (json['autoStartNext'] as bool?) ?? true,
        breakEndNotify: (json['breakEndNotify'] as bool?) ?? true,
        celebrate: (json['celebrate'] as bool?) ?? true,
        soundOn: (json['soundOn'] as bool?) ?? true,
        noise: json['noise'] is Map
            ? NoiseConfig.fromJson(json['noise'] as Map<String, dynamic>)
            : NoiseConfig.defaults(),
      );

  Map<String, dynamic> toJson() => {
        'workMin': workMin,
        'shortMin': shortMin,
        'longMin': longMin,
        'longBreakInterval': longBreakInterval,
        'autoStartNext': autoStartNext,
        'breakEndNotify': breakEndNotify,
        'celebrate': celebrate,
        'soundOn': soundOn,
        'noise': noise.toJson(),
      };

  Settings copyWith({
    int? workMin,
    int? shortMin,
    int? longMin,
    int? longBreakInterval,
    bool? autoStartNext,
    bool? breakEndNotify,
    bool? celebrate,
    bool? soundOn,
    NoiseConfig? noise,
  }) =>
      Settings(
        workMin: workMin ?? this.workMin,
        shortMin: shortMin ?? this.shortMin,
        longMin: longMin ?? this.longMin,
        longBreakInterval: longBreakInterval ?? this.longBreakInterval,
        autoStartNext: autoStartNext ?? this.autoStartNext,
        breakEndNotify: breakEndNotify ?? this.breakEndNotify,
        celebrate: celebrate ?? this.celebrate,
        soundOn: soundOn ?? this.soundOn,
        noise: noise ?? this.noise,
      );
}
