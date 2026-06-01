import 'package:flutter/material.dart';
import 'bgm_toggle_button.dart';
import 'bgm_controller.dart';

class Chapter1Story2Screen extends StatefulWidget {
  const Chapter1Story2Screen({super.key});

  @override
  State<Chapter1Story2Screen> createState() => _Chapter1Story2ScreenState();
}

class _Chapter1Story2ScreenState extends State<Chapter1Story2Screen> {
  int _sceneIndex = 0;

  static const List<_Chapter2Scene> _scenes = [
    _Chapter2Scene(
      speaker: '하우',
      line: '문이 열렸다! 바닥을 채운 문양들 위로 은은한 길이 반짝이며 번져나가고 있어!',
      characterAsset: 'assets/images/chr_how_heart.png',
    ),
    _Chapter2Scene(
      speaker: '플레이',
      line: '와... 이 빛나는 길이 복도 너머 어두운 곳까지 뻗어 있어. 우리 저 빛을 따라가 볼까?',
      characterAsset: 'assets/images/chr_play_lefthand2.png',
    ),
    _Chapter2Scene(
      speaker: '하우',
      line: '길 끝에 이르니까 크기가 다른 원판 블록들이 차례대로 예쁘게 꽂혀 있어!',
      characterAsset: 'assets/images/chr_how_right.png',
    ),
    _Chapter2Scene(
      speaker: '플레이',
      line: '이 원판 블록들을 알맞게 움직여서 원래 자리를 찾아주면, 첫 번째 별 조각을 얻을 수 있을 것 같아!',
      characterAsset: 'assets/images/chr_play_explaining.png',
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
    precacheImage(const AssetImage('assets/images/chapter1_bg_1.png'), context);
    for (var scene in _scenes) {
      precacheImage(AssetImage(scene.characterAsset), context);
    }
  }

  void _goNext() {
    if (_sceneIndex < _scenes.length - 1) {
      setState(() => _sceneIndex++);
      return;
    }
    Navigator.pushReplacementNamed(context, '/mission_ch1_q2');
  }

  @override
  Widget build(BuildContext context) {
    final scene = _scenes[_sceneIndex];
    final isLast = _sceneIndex == _scenes.length - 1;
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    final isMobile = width < 600;
    final charHeight = isMobile 
        ? (screenSize.height * 0.42).clamp(180.0, 320.0)
        : (width < 1100 ? width * 0.46 : 460.0);
    
    final dialogFontSize = isMobile ? (width * 0.055).clamp(18.0, 24.0) : 28.0;
    final buttonFontSize = isMobile ? 22.0 : 26.0;

    Color getSpeakerColor(String name) {
      if (name == '하우') return const Color(0xFFFF6B80);
      if (name == '플레이') return const Color(0xFF3B82F6);
      return const Color(0xFF133E97);
    }
    final speakerColor = getSpeakerColor(scene.speaker);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        backgroundColor: const Color(0xFFF4F7FC),
        foregroundColor: const Color(0xFF163988),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 32),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
          ),
        ),
        centerTitle: true,
        title: const Text(
          '미션! 수학체험센터의 반짝별을 찾아서',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
        ),
        actions: [
          const BgmToggleButton(iconSize: 32),
          IconButton(
            icon: const Icon(Icons.home_rounded, size: 32),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/chapter1_bg_1.png',
              fit: BoxFit.cover,
              cacheWidth: 800,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: const Color(0xFFDFE6F7)),
            ),
          ),
          Positioned.fill(child: Container(color: const Color(0x33000000))),
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                SizedBox(
                  height: charHeight,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Image.asset(
                      scene.characterAsset,
                      key: ValueKey(scene.characterAsset),
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomCenter,
                      cacheHeight: 600,
                      gaplessPlayback: false,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
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
                        border: Border.all(
                          color: speakerColor,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: speakerColor.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: speakerColor,
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x33000000),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                scene.speaker,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              scene.line,
                              style: TextStyle(
                                fontSize: dialogFontSize,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1E1E1E),
                                height: 1.25,
                                fontFamily: 'GangwonEduAll',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _goNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF133E97),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isLast ? '문제 해결하기' : '다음',
                        style: TextStyle(
                          fontSize: buttonFontSize,
                          fontWeight: FontWeight.w800,
                        ),
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
