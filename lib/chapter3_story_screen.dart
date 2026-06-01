import 'package:flutter/material.dart';
import 'bgm_toggle_button.dart';
import 'bgm_controller.dart';

class Chapter3StoryScreen extends StatefulWidget {
  const Chapter3StoryScreen({super.key});

  @override
  State<Chapter3StoryScreen> createState() => _Chapter3StoryScreenState();
}

class _Chapter3StoryScreenState extends State<Chapter3StoryScreen> {
  int _sceneIndex = 0;

  static const List<_Chapter3Scene> _scenes = [
    _Chapter3Scene(
      speaker: '하우',
      line: '찾았다! 두 번째 별 조각이야!',
      characterAsset: 'assets/images/chr_how_heart.png',
    ),
    _Chapter3Scene(
      speaker: '플레이',
      line: '두 번째 별 조각을 찾으니 체험센터가 더 환해졌어! 빛이 퍼져나가며 잠들었던 공간이 다시 밝아지고 있어.',
      characterAsset: 'assets/images/chr_play_clapping.png',
    ),
    _Chapter3Scene(
      speaker: '하우',
      line: '단서가 가리키는 다음 목적지는 위대한 지혜들이 잠든 \'수학역사실\'이야!',
      characterAsset: 'assets/images/chr_how_lefttalk.png',
    ),
    _Chapter3Scene(
      speaker: '플레이',
      line: '여기가 수학역사실이구나... 저기 신비로운 기운이 흐르는 계산 막대들이 놓여 있어!',
      characterAsset: 'assets/images/chr_play_surprised.png',
    ),
    _Chapter3Scene(
      speaker: '하우',
      line: '계산 막대들에 숨겨진 숫자의 비밀을 밝혀내면 문이 열릴 것 같아!',
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
    precacheImage(const AssetImage('assets/images/chapter3_bg_1.png'), context);
    for (var scene in _scenes) {
      precacheImage(AssetImage(scene.characterAsset), context);
    }
  }

  void _goNext() {
    if (_sceneIndex < _scenes.length - 1) {
      setState(() => _sceneIndex++);
      return;
    }
    Navigator.pushReplacementNamed(context, '/mission_chapter3_q1');
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
        : (width < 1100 ? width * 0.44 : 430.0);
    
    final dialogFontSize = isMobile ? (width * 0.055).clamp(18.0, 24.0) : 28.0;
    final buttonFontSize = isMobile ? 22.0 : 26.0;
    final backgroundAsset = _sceneIndex <= 2 ? 'assets/images/chapter2_bg_1.png' : 'assets/images/chapter3_bg_1.png';

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
                        isLast ? '문제 해결하기' : '다음',
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

class _Chapter3Scene {
  const _Chapter3Scene({
    required this.speaker,
    required this.line,
    required this.characterAsset,
  });

  final String speaker;
  final String line;
  final String characterAsset;
}
