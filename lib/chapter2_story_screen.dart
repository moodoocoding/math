import 'package:flutter/material.dart';
import 'bgm_toggle_button.dart';
import 'bgm_controller.dart';

class Chapter2StoryScreen extends StatefulWidget {
  const Chapter2StoryScreen({super.key});

  @override
  State<Chapter2StoryScreen> createState() => _Chapter2StoryScreenState();
}

class _Chapter2StoryScreenState extends State<Chapter2StoryScreen> {
  int _sceneIndex = 0;

  static const List<_Chapter2Scene> _scenes = [
    _Chapter2Scene(
      speaker: '하우',
      line: '첫 번째 별 조각을 찾았어! 다음 조각을 찾으러 서둘러 가자!',
      characterAsset: 'assets/images/chr_together.png',
    ),
    _Chapter2Scene(
      speaker: '플레이',
      line: '어? 체험센터 불빛이 또 하나 꺼졌어! 더 늦기 전에 두 번째 별 조각을 찾아야 해!',
      characterAsset: 'assets/images/chr_play_worry.png',
    ),
    _Chapter2Scene(
      speaker: '하우',
      line: '첫 번째 조각 뒤에 다음 단서가 있어! 두 번째 별 조각은 수학놀이실에 있대!',
      characterAsset: 'assets/images/chr_how_lefttalk.png',
    ),
    _Chapter2Scene(
      speaker: '플레이',
      line: '와! 여기가 수학놀이실이구나! 그런데 저기 반짝이는 저울이 보여!',
      characterAsset: 'assets/images/chr_play_surprised.png',
    ),
    _Chapter2Scene(
      speaker: '하우',
      line: '찾았다! 그런데 저울 아래 서랍이 꼭 닫혀 있어! 더 무거운 쪽을 맞혀야 열 수 있대!',
      characterAsset: 'assets/images/chr_how_thinking.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    AppBgmController.playStory();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (var scene in _scenes) {
      precacheImage(AssetImage(scene.characterAsset), context);
    }
  }

  void _goNext() {
    if (_sceneIndex < _scenes.length - 1) {
      setState(() => _sceneIndex++);
      return;
    }
    Navigator.pushReplacementNamed(context, '/mission_chapter2_q1');
  }

  @override
  Widget build(BuildContext context) {
    final scene = _scenes[_sceneIndex];
    final isLast = _sceneIndex == _scenes.length - 1;
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final availableHeight = media.size.height - media.padding.top - kToolbarHeight;
    final desiredCharacterHeight = _sceneIndex == 0 ? width * 0.40 : width * 0.34;
    final maxCharacterHeight = availableHeight * 0.46;
    final sceneCharHeight = desiredCharacterHeight.clamp(220.0, maxCharacterHeight).toDouble();
    final dialogFontSize = width < 1100 ? 26.0 : 28.0;
    final buttonBottomPadding = (media.padding.bottom > 0 ? media.padding.bottom : 12.0) + 10.0;
    final backgroundAsset = _sceneIndex <= 2 ? 'assets/images/chapter1_bg_1.png' : 'assets/images/chapter2_bg_1.png';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF163988),
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 32),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false),
        ),
        centerTitle: true,
        title: const Text(
          '미션! 수학체험센터의 반짝별을 찾아서',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24),
        ),
        actions: [
          const BgmToggleButton(iconSize: 34),
          IconButton(
            icon: const Icon(Icons.home_rounded, size: 38),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              backgroundAsset,
              fit: BoxFit.cover,
              cacheWidth: 800,
              errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFFDFE6F7)),
            ),
          ),
          Positioned.fill(
            child: Container(color: const Color(0x66000000)),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                SizedBox(
                  height: sceneCharHeight,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Image.asset(
                      scene.characterAsset,
                      key: ValueKey(scene.characterAsset),
                      fit: BoxFit.fitHeight,
                      cacheHeight: 600,
                      gaplessPlayback: false,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Text(
                          '캐릭터 이미지를 불러오지 못했어요',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      key: ValueKey(scene.line),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFF133E97), width: 3),
                        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 10, offset: Offset(0, 4))],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF133E97),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                scene.speaker,
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              scene.line,
                              style: TextStyle(fontSize: dialogFontSize, fontWeight: FontWeight.w800, color: const Color(0xFF1E1E1E), height: 1.25),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: EdgeInsets.fromLTRB(18, 0, 18, buttonBottomPadding),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _goNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF133E97),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        isLast ? '문제 풀이 시작' : '다음',
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chapter2Scene {
  const _Chapter2Scene({
    required this.speaker,
    required this.line,
    required this.characterAsset,
  });

  final String speaker;
  final String line;
  final String characterAsset;
}
