import 'package:flutter/material.dart';
import 'bgm_controller.dart';
import 'bgm_toggle_button.dart';

class Chapter4StoryScreen extends StatelessWidget {
  const Chapter4StoryScreen({super.key});

  static const List<_Chapter4Scene> _scenes = [
    _Chapter4Scene(
      speaker: '플레이',
      line: '찾았다! 세 번째 별 조각이야!',
      characterAsset: 'assets/images/chr_play_cheering.png',
      backgroundAsset: 'assets/images/chapter3_bg_1.png',
    ),
    _Chapter4Scene(
      speaker: '하우',
      line: '와! 체험센터가 거의 다 밝아졌어!',
      characterAsset: 'assets/images/chr_how_laughing.png',
      backgroundAsset: 'assets/images/chapter3_bg_1.png',
    ),
    _Chapter4Scene(
      speaker: '플레이',
      line: '다음 단서가 보여! 마지막 별 조각은 수학융합실에 있대!',
      characterAsset: 'assets/images/chr_play_waving.png',
      backgroundAsset: 'assets/images/chapter3_bg_1.png',
    ),
    _Chapter4Scene(
      speaker: '하우',
      line: '마지막 조각만 찾으면 반짝별이 다시 빛날 거야!',
      characterAsset: 'assets/images/chr_how_thumbs_up.png',
    ),
    _Chapter4Scene(
      speaker: '플레이',
      line: '와! 여기가 수학융합실이구나!',
      characterAsset: 'assets/images/chr_play_laughing.png',
    ),
    _Chapter4Scene(
      speaker: '하우',
      line: '저기 빛나는 블록판이 보여! 첫 번째 장치인가 봐!',
      characterAsset: 'assets/images/chr_how_running.png',
    ),
    _Chapter4Scene(
      speaker: '플레이',
      line: '같은 모양의 블록을 찾으면 길이 열릴 것 같아!',
      characterAsset: 'assets/images/chr_play_thinking.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const _Chapter4StoryFlow(
      scenes: _scenes,
      nextRouteName: '/mission_chapter4_q1',
      finalButtonText: '문제 해결하기',
    );
  }
}

class Chapter4Story2Screen extends StatelessWidget {
  const Chapter4Story2Screen({super.key});

  static const List<_Chapter4Scene> _scenes = [
    _Chapter4Scene(
      speaker: '하우',
      line: '열렸어! 안쪽에 단서가 숨어 있었어!',
      characterAsset: 'assets/images/chr_how_surprised.png',
    ),
    _Chapter4Scene(
      speaker: '플레이',
      line: '벽에 코딩과 인공지능에 대한 단서가 나타났어. 마지막 별 조각이 가까워지고 있는 것 같아!',
      characterAsset: 'assets/images/chr_play_right.png',
    ),
    _Chapter4Scene(
      speaker: '하우',
      line: '단서의 뜻을 알아내고, 숨어 있는 낱말을 찾으면 별 조각이 있는 곳을 알 수 있을 거야!',
      characterAsset: 'assets/images/chr_how_presenting.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const _Chapter4StoryFlow(
      scenes: _scenes,
      nextRouteName: '/mission_chapter4_quiz',
      finalButtonText: '문제 해결하기',
    );
  }
}

class Chapter4StoryBeforeRpsScreen extends StatelessWidget {
  const Chapter4StoryBeforeRpsScreen({super.key});

  static const List<_Chapter4Scene> _scenes = [
    _Chapter4Scene(
      speaker: '하우',
      line: '찾았다! 낱말들이 하나로 맞춰지면서 새로운 길이 활짝 열렸어!',
      characterAsset: 'assets/images/chr_how_laughing.png',
    ),
    _Chapter4Scene(
      speaker: '플레이',
      line: '이 길은 수학융합실의 가위바위보 로봇이 서 있는 곳으로 연결되어 있어! 얼른 가 보자!',
      characterAsset: 'assets/images/chr_play_thinking.png',
    ),
    _Chapter4Scene(
      speaker: '하우',
      line: '로봇과의 대결을 통과한 뒤 마지막 QR 코드를 비추면, 반짝별을 깨울 마지막 빛을 얻을 수 있대!',
      characterAsset: 'assets/images/chr_how_running.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const _Chapter4StoryFlow(
      scenes: _scenes,
      nextRouteName: '/mission_chapter4_rps_qr',
      finalButtonText: '문제 해결하기',
    );
  }
}

class Chapter4Story3Screen extends StatelessWidget {
  const Chapter4Story3Screen({super.key});

  static const List<_Chapter4Scene> _scenes = [
    _Chapter4Scene(
      speaker: '하우',
      line: '와! 마지막 QR 코드가 통과되면서 숨겨져 있던 별 조각이 솟아올랐어!',
      characterAsset: 'assets/images/chr_how_thumbs_up.png',
    ),
    _Chapter4Scene(
      speaker: '플레이',
      line: '드디어 네 개의 별 조각을 모두 찾았어! 어서 반짝별로 달려가서 이 불빛을 전해주자!',
      characterAsset: 'assets/images/chr_play_heart_hands.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const _Chapter4StoryFlow(
      scenes: _scenes,
      nextRouteName: '/ending_story',
      finalButtonText: '문제 해결하기',
    );
  }
}

class _Chapter4StoryFlow extends StatefulWidget {
  const _Chapter4StoryFlow({
    required this.scenes,
    required this.nextRouteName,
    this.finalButtonText,
  });

  final List<_Chapter4Scene> scenes;
  final String nextRouteName;
  final String? finalButtonText;

  @override
  State<_Chapter4StoryFlow> createState() => _Chapter4StoryFlowState();
}

class _Chapter4StoryFlowState extends State<_Chapter4StoryFlow> {
  int _sceneIndex = 0;

  @override
  void initState() {
    super.initState();
    AppBgmController.playStory();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/images/chapter4_bg_1.png'), context);
    for (final scene in widget.scenes) {
      precacheImage(AssetImage(scene.backgroundAsset), context);
      precacheImage(AssetImage(scene.characterAsset), context);
    }
  }

  void _goNext() {
    if (_sceneIndex < widget.scenes.length - 1) {
      setState(() => _sceneIndex++);
      return;
    }

    Navigator.pushReplacementNamed(context, widget.nextRouteName);
  }

  @override
  Widget build(BuildContext context) {
    final scene = widget.scenes[_sceneIndex];
    final isLast = _sceneIndex == widget.scenes.length - 1;
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    final isMobile = width < 600;
    final charHeight = isMobile 
        ? (screenSize.height * 0.42).clamp(180.0, 320.0)
        : (width < 1100 ? width * 0.44 : 430.0);
    
    final dialogFontSize = isMobile ? (width * 0.055).clamp(18.0, 24.0) : 28.0;
    final buttonFontSize = isMobile ? 22.0 : 26.0;

    return Scaffold(
      appBar: _chapter4AppBar(context),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              scene.backgroundAsset,
              fit: BoxFit.cover,
              cacheWidth: 900,
              errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFFDFE6F7)),
            ),
          ),
          Positioned.fill(child: Container(color: const Color(0x66000000))),
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
                        border: Border.all(
                          color: scene.speaker == '하우'
                              ? const Color(0xFFFF6B80)
                              : const Color(0xFF3B82F6),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (scene.speaker == '하우'
                                    ? const Color(0xFFFF6B80)
                                    : const Color(0xFF3B82F6))
                                .withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SpeakerBadge(name: scene.speaker),
                            const SizedBox(height: 12),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        isLast ? (widget.finalButtonText ?? '문제 해결하기') : '다음',
                        style: TextStyle(fontSize: buttonFontSize, fontWeight: FontWeight.w800),
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

PreferredSizeWidget _chapter4AppBar(BuildContext context) {
  return AppBar(
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
  );
}

class _SpeakerBadge extends StatelessWidget {
  const _SpeakerBadge({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final color = name == '하우' ? const Color(0xFFFF6B80) : const Color(0xFF3B82F6);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        name,
        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _Chapter4Scene {
  const _Chapter4Scene({
    required this.speaker,
    required this.line,
    required this.characterAsset,
    this.backgroundAsset = 'assets/images/chapter4_bg_1.png',
  });

  final String speaker;
  final String line;
  final String characterAsset;
  final String backgroundAsset;
}
