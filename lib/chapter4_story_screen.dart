import 'package:flutter/material.dart';
import 'bgm_controller.dart';
import 'bgm_toggle_button.dart';
import 'chapter4_problem1_brick_puzzle.dart' as chapter4_problem1;
import 'chapter4_problem2_hidden_word.dart' as chapter4_problem2;

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
      characterAsset: 'assets/images/chr_how_cheering.png',
      backgroundAsset: 'assets/images/chapter3_bg_1.png',
    ),
    _Chapter4Scene(
      speaker: '플레이',
      line: '다음 단서가 보여! 마지막 별 조각은 수학융합실에 있대!',
      characterAsset: 'assets/images/chr_play_happy.png',
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
      characterAsset: 'assets/images/chr_play_surprised.png',
    ),
    _Chapter4Scene(
      speaker: '하우',
      line: '저기 빛나는 블록판이 보여! 첫 번째 장치인가 봐!',
      characterAsset: 'assets/images/chr_how_surprised.png',
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
      nextRouteName: '/mission_chapter4_q1_tbd',
    );
  }
}

class Chapter4Story2Screen extends StatelessWidget {
  const Chapter4Story2Screen({super.key});

  static const List<_Chapter4Scene> _scenes = [
    _Chapter4Scene(
      speaker: '하우',
      line: '열렸어! 안쪽에 글자판이 숨어 있었어!',
      characterAsset: 'assets/images/chr_how_surprised.png',
    ),
    _Chapter4Scene(
      speaker: '플레이',
      line: '이번엔 글자 속에 숨은 수학 낱말을 찾아야 하나 봐!',
      characterAsset: 'assets/images/chr_play_explaining.png',
    ),
    _Chapter4Scene(
      speaker: '하우',
      line: '잘 보면 마지막 단서가 나타날 거야!',
      characterAsset: 'assets/images/chr_how_idea.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const _Chapter4StoryFlow(
      scenes: _scenes,
      nextRouteName: '/mission_chapter4_q2_tbd',
    );
  }
}

class Chapter4Story3Screen extends StatelessWidget {
  const Chapter4Story3Screen({super.key});

  static const List<_Chapter4Scene> _scenes = [
    _Chapter4Scene(
      speaker: '플레이',
      line: '드디어 마지막 별 조각이야! 이제 반짝별을 다시 빛나게 하자!',
      characterAsset: 'assets/images/chr_play_cheering.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const _Chapter4StoryFlow(
      scenes: _scenes,
      nextRouteName: '/home',
      finalButtonText: '홈으로',
      replaceAllOnFinish: true,
    );
  }
}

class Chapter4ProblemPlaceholderScreen extends StatelessWidget {
  const Chapter4ProblemPlaceholderScreen({
    super.key,
    required this.question,
    required this.nextRouteName,
  });

  final String question;
  final String nextRouteName;

  @override
  Widget build(BuildContext context) {
    if (nextRouteName == '/chapter4_story2') {
      return chapter4_problem1.BrickPuzzleScreen(
        completedRouteName: nextRouteName,
      );
    }
    if (nextRouteName == '/chapter4_story3') {
      return chapter4_problem2.HiddenWordPuzzleScreen(
        completedRouteName: nextRouteName,
      );
    }

    return Scaffold(
      appBar: _chapter4AppBar(context),
      backgroundColor: const Color(0xFFF4F8FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFA8C1F5), width: 2),
                ),
                child: Text(
                  question,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF091F59),
                    height: 1.2,
                  ),
                ),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    '문제는 준비 중이에요.',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF355AA8),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushReplacementNamed(context, nextRouteName),
                  icon: const Icon(Icons.skip_next_rounded),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF133E97),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(58),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  label: const Text(
                    '테스트용: 다음 화면으로',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chapter4StoryFlow extends StatefulWidget {
  const _Chapter4StoryFlow({
    required this.scenes,
    required this.nextRouteName,
    this.finalButtonText,
    this.replaceAllOnFinish = false,
  });

  final List<_Chapter4Scene> scenes;
  final String nextRouteName;
  final String? finalButtonText;
  final bool replaceAllOnFinish;

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

    if (widget.replaceAllOnFinish) {
      Navigator.pushNamedAndRemoveUntil(context, widget.nextRouteName, (route) => false);
      return;
    }
    Navigator.pushReplacementNamed(context, widget.nextRouteName);
  }

  @override
  Widget build(BuildContext context) {
    final scene = widget.scenes[_sceneIndex];
    final isLast = _sceneIndex == widget.scenes.length - 1;
    final width = MediaQuery.of(context).size.width;
    final charHeight = width < 1100 ? width * 0.44 : 430.0;

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
                        border: Border.all(color: const Color(0xFF133E97), width: 3),
                        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 10, offset: Offset(0, 4))],
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
                        isLast ? (widget.finalButtonText ?? '다음 화면으로') : '다음',
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF133E97),
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
