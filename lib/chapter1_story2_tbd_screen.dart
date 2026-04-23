import 'package:flutter/material.dart';

class Chapter1Story2TbdScreen extends StatefulWidget {
  const Chapter1Story2TbdScreen({super.key});

  @override
  State<Chapter1Story2TbdScreen> createState() => _Chapter1Story2TbdScreenState();
}

class _Chapter1Story2TbdScreenState extends State<Chapter1Story2TbdScreen> {
  int _sceneIndex = 0;

  static const List<_Chapter2Scene> _scenes = [
    _Chapter2Scene(
      speaker: '하우',
      line: '와! 첫 번째 문제를 풀었더니 바닥에 반짝이는 빛이 나타났어!',
      characterAsset: 'assets/images/chr_how_happy.png',
    ),
    _Chapter2Scene(
      speaker: '플레이',
      line: '저 빛을 따라가 보면 다음 단서를 찾을 수 있을 것 같아!',
      characterAsset: 'assets/images/chr_play_lefthand2.png',
    ),
    _Chapter2Scene(
      speaker: '하우',
      line: '앗! 이번에는 여러 모양이 차례대로 놓여 있어!',
      characterAsset: 'assets/images/chr_how_surprised.png',
    ),
    _Chapter2Scene(
      speaker: '플레이',
      line: '모양이 어떤 순서로 반복되는지 잘 보면 두 번째 문제를 풀 수 있대!',
      characterAsset: 'assets/images/chr_play_thinking.png',
    ),
  ];

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
    final width = MediaQuery.of(context).size.width;
    final charHeight = width < 1100 ? width * 0.46 : 460.0;

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
              'assets/images/chapter1_bg_1.png',
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
                      gaplessPlayback: false,
                      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
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
                              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Color(0xFF1E1E1E), height: 1.25),
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        isLast ? '문제 풀이 시작' : '다음',
                        style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
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
