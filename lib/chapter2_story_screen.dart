import 'package:flutter/material.dart';

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
      line: '첫 번째 조각을 찾았어!',
      characterAsset: 'assets/images/chr_together_1.png',
    ),
    _Chapter2Scene(
      speaker: '플레이',
      line: '다음은 수학체험센터야!',
      characterAsset: 'assets/images/chr_howplay.png',
    ),
    _Chapter2Scene(
      speaker: '하우',
      line: '와! 여기가 수학체험센터구나!',
      characterAsset: 'assets/images/chr_how_surprised.png',
    ),
    _Chapter2Scene(
      speaker: '플레이',
      line: '저기 반짝이는 체험판이 보여!',
      characterAsset: 'assets/images/chr_play_lefthand.png',
    ),
    _Chapter2Scene(
      speaker: '하우',
      line: '이번 문제는 뭘까?',
      characterAsset: 'assets/images/chr_how_lefttalk.png',
    ),
    _Chapter2Scene(
      speaker: '플레이',
      line: '같이 도전해 보자!',
      characterAsset: 'assets/images/chr_play_left.png',
    ),
  ];

  void _goNext() {
    if (_sceneIndex < _scenes.length - 1) {
      setState(() => _sceneIndex++);
      return;
    }
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final scene = _scenes[_sceneIndex];
    final isLast = _sceneIndex == _scenes.length - 1;
    final width = MediaQuery.of(context).size.width;
    final charHeight = width < 1100 ? width * 0.46 : 460.0;
    final sceneCharHeight = _sceneIndex == 0 ? charHeight * 1.22 : charHeight;
    final backgroundAsset = _sceneIndex <= 1 ? 'assets/images/chapter1_bg_1.png' : 'assets/images/chapter2_bg_1.png';

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
          '미션! 수학체험센터를 찾아라!',
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
              backgroundAsset,
              fit: BoxFit.cover,
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
                  child: Image.asset(
                    scene.characterAsset,
                    key: ValueKey(scene.characterAsset),
                    fit: BoxFit.fitHeight,
                    gaplessPlayback: false,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Text(
                        '캐릭터 이미지를 불러오지 못했어요',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Container(
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
                        isLast ? '홈으로' : '다음',
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
