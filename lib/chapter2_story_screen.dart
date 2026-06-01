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
      line: '와! 첫 번째 별 조각을 돌려놓으니까 복도의 불빛이 다시 환하게 켜졌어!',
      characterAsset: 'assets/images/chr_how_happy.png',
    ),
    _Chapter2Scene(
      speaker: '플레이',
      line: '별 조각이 되살아나면서 새로운 길이 열린 거야. 조각 뒤에 새겨진 단서를 함께 읽어보자!',
      characterAsset: 'assets/images/chr_play_thumbs_up.png',
    ),
    _Chapter2Scene(
      speaker: '하우',
      line: '두 번째 별 조각은 움직임의 힘이 깃든 \'수학놀이실\'에 있대!',
      characterAsset: 'assets/images/chr_how_presenting.png',
    ),
    _Chapter2Scene(
      speaker: '플레이',
      line: '여기가 수학놀이실이구나! 저기 공중에 은은하게 떠올라 있는 시소가 보여.',
      characterAsset: 'assets/images/chr_play_idea.png',
    ),
    _Chapter2Scene(
      speaker: '하우',
      line: '시소의 무너진 균형을 다시 맞춰주면, 다음 공간으로 향하는 닫힌 문이 열릴 거야!',
      characterAsset: 'assets/images/chr_how_laughing.png',
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
    final availableHeight =
        media.size.height - media.padding.top - kToolbarHeight;
    final desiredCharacterHeight = _sceneIndex == 0
        ? width * 0.40
        : width * 0.34;
    final maxCharacterHeight = availableHeight * 0.46;
    final isMobile = width < 600;
    final sceneCharHeight = isMobile 
        ? (availableHeight * 0.4).clamp(180.0, 300.0)
        : desiredCharacterHeight.clamp(220.0, maxCharacterHeight).toDouble();

    final dialogFontSize = isMobile ? (width * 0.055).clamp(18.0, 24.0) : (width < 1100 ? 26.0 : 28.0);
    final buttonFontSize = isMobile ? 22.0 : 26.0;
    final buttonBottomPadding = isMobile ? 16.0 : (media.padding.bottom > 0 ? media.padding.bottom : 12.0) + 10.0;
    final backgroundAsset = _sceneIndex <= 2
        ? 'assets/images/chapter1_bg_1.png'
        : 'assets/images/chapter2_bg_1.png';

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
              backgroundAsset,
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
                  height: sceneCharHeight,
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
                            _SpeakerBadge(name: scene.speaker, color: speakerColor),
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
                  padding: EdgeInsets.fromLTRB(18, 0, 18, buttonBottomPadding),
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

class _SpeakerBadge extends StatelessWidget {
  const _SpeakerBadge({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color,
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
        name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
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
