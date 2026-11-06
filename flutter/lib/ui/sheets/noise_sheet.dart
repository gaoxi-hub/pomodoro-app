import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/noise_sound.dart';
import '../../core/models/settings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/settings_provider.dart';
import '../../providers/storage_providers.dart';
import '../../services/audio_service.dart';
import '../widgets/app_switch.dart';
import '../widgets/bottom_sheet_base.dart';

/// 白噪音选择弹层（单一音轨开启）。
/// 切换即时试听：打开音轨立即播放，关闭或退出弹层停止。
class NoiseSheet extends ConsumerStatefulWidget {
  const NoiseSheet({super.key});

  @override
  ConsumerState<NoiseSheet> createState() => _NoiseSheetState();
}

class _NoiseSheetState extends ConsumerState<NoiseSheet> {
  late final AudioService _audio;

  @override
  void initState() {
    super.initState();
    _audio = ref.read(audioServiceProvider);
  }

  @override
  void dispose() {
    // 关闭面板时停止预览播放（ref 在 dispose 中已失效，故使用 initState 缓存的实例）。
    _audio.stopNoise();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider).valueOrNull;
    final noise = settings?.noise ?? NoiseConfig.defaults();

    return BottomSheetBase(
      title: '白噪音',
      child: SingleChildScrollView(
        child: Column(
          children: [
            for (final s in noiseSounds)
              _NoiseRow(
                sound: s,
                on: noise.layers[s]?.on ?? false,
                onToggle: () => _toggle(ref, s),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('总音量', style: AppTextStyles.body),
                const SizedBox(width: 12),
                Expanded(
                  child: Slider(
                    value: noise.master,
                    activeColor: AppColors.accent,
                    onChanged: (v) {
                      ref
                          .read(settingsProvider.notifier)
                          .patch(noise: noise.copyWith(master: v));
                      _audio.setNoiseVolume(v);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _toggle(WidgetRef ref, NoiseSound s) {
    final cur = ref.read(settingsProvider).valueOrNull;
    final noise = cur?.noise ?? NoiseConfig.defaults();
    final willOn = !(noise.layers[s]?.on ?? false);
    final layers = {
      for (final k in NoiseSound.values)
        k: (noise.layers[k] ?? const NoiseLayer())
            .copyWith(on: k == s ? willOn : false),
    };
    ref
        .read(settingsProvider.notifier)
        .patch(noise: noise.copyWith(layers: layers));
    if (willOn) {
      _audio.playNoise(s, volume: noise.master.clamp(0.0, 1.0));
    } else {
      _audio.stopNoise();
    }
  }
}

class _NoiseRow extends StatelessWidget {
  final NoiseSound sound;
  final bool on;
  final VoidCallback onToggle;

  const _NoiseRow({
    required this.sound,
    required this.on,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Text(sound.icon, style: const TextStyle(fontSize: 24)),
        title: Text(sound.label, style: AppTextStyles.body),
        trailing: AppSwitch(value: on, onChanged: (_) => onToggle()),
      ),
    );
  }
}
