import 'package:flutter/material.dart';

import 'bgm_controller.dart';

class BgmToggleButton extends StatelessWidget {
  const BgmToggleButton({
    super.key,
    this.iconSize = 38,
    this.color = const Color(0xFF163988),
  });

  final double iconSize;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppBgmController.isMuted,
      builder: (context, muted, child) {
        return IconButton(
          tooltip: muted ? '소리 켜기' : '소리 끄기',
          padding: EdgeInsets.zero,
          constraints: BoxConstraints.tightFor(
            width: iconSize + 20,
            height: iconSize + 20,
          ),
          icon: Icon(
            muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
            size: iconSize,
            color: color,
          ),
          onPressed: () {
            AppBgmController.toggleMuted();
          },
        );
      },
    );
  }
}
