import 'package:flutter/material.dart';
import 'bgm_toggle_button.dart';
import 'bgm_controller.dart';

class StoryDummyScreen extends StatefulWidget {
  const StoryDummyScreen({super.key});

  @override
  State<StoryDummyScreen> createState() => _StoryDummyScreenState();
}

class _StoryDummyScreenState extends State<StoryDummyScreen> {
  int _sceneIndex = 0;

  static const List<_ChapterScene> _scenes = [
    _ChapterScene(
      line: '수학체험센터에 온 것을 환영해!\n하우와 플레이와 함께 모험을 시작하자!',
      welcomeImageAsset: 'assets/images/chr_background.png',
    ),
    _ChapterScene(
      speaker: '하우',
      line: '큰일이야! 체험센터 불빛이 또 하나 꺼졌어!',
      characterAsset: 'assets/images/chr_how_worry.png',
    ),
    _ChapterScene(
      speaker: '플레이',
      line: '마지막 불빛까지 꺼지기 전에 첫 번째 별 조각을 찾아야 해!',
      characterAsset: 'assets/images/chr_play_worry.png',
    ),
    _ChapterScene(
      speaker: '하우',
      line: '저기! 벽에 빛나는 문장이 보여! 첫 번째 별 조각은 수학체험실에 있대!',
      characterAsset: 'assets/images/chr_how_left.png',
    ),
    _ChapterScene(
      speaker: '플레이',
      line: '찾았다! 그런데 문이 잠겨 있어! 문제를 풀어야 열 수 있나 봐!',
      characterAsset: 'assets/images/chr_play_confused.png',
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
      if (scene.characterAsset != null) {
        precacheImage(AssetImage(scene.characterAsset!), context);
      }
      if (scene.welcomeImageAsset != null) {
        precacheImage(AssetImage(scene.welcomeImageAsset!), context);
      }
    }
  }

  void _goNext() {
    if (_sceneIndex < _scenes.length - 1) {
      setState(() => _sceneIndex++);
      return;
    }
    Navigator.pushNamed(context, '/mission_low');
  }

  @override
  Widget build(BuildContext context) {
    final scene = _scenes[_sceneIndex];
    final isLast = _sceneIndex == _scenes.length - 1;
    final width = MediaQuery.of(context).size.width;
    final charHeight = width < 1100 ? width * 0.46 : 460.0;
    final isWelcome = scene.welcomeImageAsset != null;

    Color getSpeakerColor(String? name) {
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
          onPressed: () => Navigator.pop(context),
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
      body: isWelcome
          ? SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: width < 900 ? width * 0.78 : 700,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Image.asset(
                            scene.welcomeImageAsset!,
                            key: ValueKey(scene.welcomeImageAsset!),
                            fit: BoxFit.contain,
                            cacheHeight: 400,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        scene.line,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF163988),
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: width < 900 ? 220 : 260,
                        child: ElevatedButton(
                          onPressed: _goNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF133E97),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            '다음',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/chapter1_bg_1.png',
                    fit: BoxFit.cover,
                    cacheWidth: 800,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: const Color(0xFFF4F5F7)),
                  ),
                ),
                Positioned.fill(
                  child: Container(color: const Color(0x33000000)),
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
                            scene.characterAsset!,
                            key: ValueKey(scene.characterAsset!),
                            fit: BoxFit.contain,
                            alignment: Alignment.bottomCenter,
                            cacheHeight: 600,
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
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                22,
                                14,
                                22,
                                14,
                              ),
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
                                      scene.speaker!,
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
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1E1E1E),
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
                              isLast ? '문제 풀이 시작' : '다음',
                              style: const TextStyle(
                                fontSize: 26,
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

class _ChapterScene {
  const _ChapterScene({
    this.speaker,
    required this.line,
    this.characterAsset,
    this.welcomeImageAsset,
  });

  final String? speaker;
  final String line;
  final String? characterAsset;
  final String? welcomeImageAsset;
}

