/// 环境音轨元数据 —— 单一来源（key → 文件 / 图标 / 名称）。
/// 音频文件存放于 assets/audio/，与原 H5 的 public/audio/ 同名复用。
enum NoiseSound {
  cat,
  crickets,
  seagulls,
  campfire,
  lake,
  river,
  wind,
  piano,
  rainwind,
  drizzle,
  thunder,
  bowl,
  train,
  airplane,
}

extension NoiseSoundMeta on NoiseSound {
  String get file => const {
        NoiseSound.cat: 'cat-purring.mp3',
        NoiseSound.crickets: 'crickets.mp3',
        NoiseSound.seagulls: 'seagulls.mp3',
        NoiseSound.campfire: 'campfire.mp3',
        NoiseSound.lake: 'lake.mp3',
        NoiseSound.river: 'river.mp3',
        NoiseSound.wind: 'wind.mp3',
        NoiseSound.piano: 'piano.mp3',
        NoiseSound.rainwind: '小雨加风.mp3',
        NoiseSound.drizzle: 'drizzle.mp3',
        NoiseSound.thunder: 'thunderstorm.mp3',
        NoiseSound.bowl: 'singing-bowl.mp3',
        NoiseSound.train: 'inside-a-train.mp3',
        NoiseSound.airplane: 'airplane.mp3',
      }[this]!;

  String get label => const {
        NoiseSound.cat: '猫咪呼噜',
        NoiseSound.crickets: '虫鸣',
        NoiseSound.seagulls: '海鸥',
        NoiseSound.campfire: '篝火',
        NoiseSound.lake: '湖泊',
        NoiseSound.river: '河流',
        NoiseSound.wind: '风声',
        NoiseSound.piano: '钢琴',
        NoiseSound.rainwind: '小雨加风',
        NoiseSound.drizzle: '细雨',
        NoiseSound.thunder: '雷暴',
        NoiseSound.bowl: '颂钵',
        NoiseSound.train: '火车内',
        NoiseSound.airplane: '飞机',
      }[this]!;

  String get icon => const {
        NoiseSound.cat: '🐱',
        NoiseSound.crickets: '🦗',
        NoiseSound.seagulls: '🕊️',
        NoiseSound.campfire: '🔥',
        NoiseSound.lake: '🏞️',
        NoiseSound.river: '💧',
        NoiseSound.wind: '🍃',
        NoiseSound.piano: '🎹',
        NoiseSound.rainwind: '🌧️',
        NoiseSound.drizzle: '🌦️',
        NoiseSound.thunder: '⛈️',
        NoiseSound.bowl: '🔔',
        NoiseSound.train: '🚂',
        NoiseSound.airplane: '✈️',
      }[this]!;
}

const List<NoiseSound> noiseSounds = NoiseSound.values;

/// 兼容旧字段 'off' 的解析（设置页白噪音选项含 关闭）
const String noiseOffKey = 'off';
