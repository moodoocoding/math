import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'bgm_controller.dart';
import 'bgm_toggle_button.dart';

class EndingStoryScreen extends StatefulWidget {
  const EndingStoryScreen({super.key});

  @override
  State<EndingStoryScreen> createState() => _EndingStoryScreenState();
}

class _EndingStoryScreenState extends State<EndingStoryScreen> {
  int _sceneIndex = 0;
  bool _showVideo = false;
  late VideoPlayerController _videoController;
  bool _videoInitialized = false;

  final List<_EndingScene> _scenes = [
    const _EndingScene(
      speaker: '하우',
      line: '서둘러! 마지막 별 조각을 반짝별 앞으로 가져가자!',
      characterAsset: 'assets/images/chr_how_cheering.png', // 기본 캐릭터 사용
    ),
    const _EndingScene(
      speaker: '플레이',
      line: '봐! 마지막 별 조각이 반짝별과 하나로 모이고 있어!',
      characterAsset: 'assets/images/chr_play_happy.png', // 기본 캐릭터 사용
    ),
  ];

  @override
  void initState() {
    super.initState();
    AppBgmController.playStory();
    _initVideo();
  }

  Future<void> _initVideo() async {
    _videoController = VideoPlayerController.asset('assets/video/ending_video.mp4');
    try {
      await _videoController.initialize();
      _videoController.addListener(() {
        if (_videoController.value.position >= _videoController.value.duration &&
            _videoController.value.duration != Duration.zero) {
          _onVideoEnd();
        }
      });
      if (mounted) {
        setState(() {
          _videoInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Video initialization failed: $e');
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_sceneIndex < _scenes.length - 1) {
      setState(() => _sceneIndex++);
      return;
    }
    
    // 마지막 장면 이후 비디오 재생
    setState(() {
      _showVideo = true;
    });
    AppBgmController.stop(); // 비디오 재생 시 BGM 중지
    _videoController.play();
  }

  void _onVideoEnd() {
    _videoController.removeListener(_onVideoEnd);
    AppBgmController.playEnding(); // 엔딩곡 재생
    _showFinishDialog();
  }

  void _showFinishDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final dialogWidth = (screenWidth * 0.45).clamp(360.0, 500.0);

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            width: dialogWidth,
            padding: const EdgeInsets.fromLTRB(30, 40, 30, 30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '해냈어!',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF133E97),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '반짝별이 다시 빛나기 시작했어!\n하우와 플레이와 함께\n수학체험센터의 빛을 되찾았어!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4B5563),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF133E97),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '홈으로 가기',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showVideo) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: _videoInitialized
              ? AspectRatio(
                  aspectRatio: _videoController.value.aspectRatio,
                  child: VideoPlayer(_videoController),
                )
              : const CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final scene = _scenes[_sceneIndex];
    final isLast = _sceneIndex == _scenes.length - 1;


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
          '미션 완료! 반짝별의 귀환',
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
              'assets/images/ending.png',
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
                        isLast ? '엔딩 보기' : '다음',
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

class _EndingScene {
  const _EndingScene({
    required this.speaker,
    required this.line,
    required this.characterAsset,
  });

  final String speaker;
  final String line;
  final String characterAsset;
}
