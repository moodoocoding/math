import 'package:flutter/material.dart';
import 'bgm_toggle_button.dart';
import 'bgm_controller.dart';

class Chapter2Story2Screen extends StatefulWidget {
  const Chapter2Story2Screen({super.key});

  @override
  State<Chapter2Story2Screen> createState() => _Chapter2Story2ScreenState();
}

class _Chapter2Story2ScreenState extends State<Chapter2Story2Screen> {
  int _sceneIndex = 0;

  static const List<_Chapter2Scene> _scenes = [
    _Chapter2Scene(
      speaker: '플레이',
      line: '열렸어! 저울 아래에서 반짝이는 무늬판이 나타났어!',
      characterAsset: 'assets/images/chr_play_happy.png',
    ),
    _Chapter2Scene(
      speaker: '하우',
      line: '앗, 무늬판이 길을 막고 있어! 조각을 맞춰 같은 무늬를 만들어야 지나갈 수 있대!',
      characterAsset: 'assets/images/chr_how_surprised.png',
    ),
    _Chapter2Scene(
      speaker: '플레이',
      line: '봐! 여기 조각 6개가 있어! 이 조각으로 목표 무늬를 완성하면 될 것 같아!',
      characterAsset: 'assets/images/chr_play_lefthand2.png',
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
    precacheImage(const AssetImage('assets/images/chapter2_bg_1.png'), context);
    for (var scene in _scenes) {
      precacheImage(AssetImage(scene.characterAsset), context);
    }
  }

  void _goNext() {
    if (_sceneIndex < _scenes.length - 1) {
      setState(() => _sceneIndex++);
      return;
    }
    Navigator.pushReplacementNamed(context, '/mission_chapter2_q2');
  }

  @override
  Widget build(BuildContext context) {
    final scene = _scenes[_sceneIndex];
    final isLast = _sceneIndex == _scenes.length - 1;
    final width = MediaQuery.of(context).size.width;
    final charHeight = width < 1100 ? width * 0.44 : 430.0;

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
              'assets/images/chapter2_bg_1.png',
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
                  height: charHeight,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Image.asset(
                      scene.characterAsset,
                      key: ValueKey(scene.characterAsset),
                      fit: BoxFit.fitHeight,
                      cacheHeight: 600,
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
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF1E1E1E), height: 1.25),
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
