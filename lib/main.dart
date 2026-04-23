import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:audioplayers/audioplayers.dart';
import 'mission_low.dart';
import 'story_dummy_screen.dart';
import 'chapter1_story2_tbd_screen.dart';

void main() {
  runApp(const MissionTourApp());
}

class LobbyBgmController {
  LobbyBgmController._();

  static final AudioPlayer _player = AudioPlayer();
  static bool _configured = false;
  static String? _currentAsset;
  static const List<String> _fallbackAssets = [
    'audio/bgm_bg.mp3',
    'audio/bgm_main.mp3',
    'audio/bgm.ogg',
  ];

  static Future<void> playBackground({bool forceRestart = false}) async {
    if (!_configured) {
      await _player.setReleaseMode(ReleaseMode.loop);
      _configured = true;
    }
    if (_currentAsset == 'audio/bgm_bg.mp3' && !forceRestart) {
      return;
    }

    if (forceRestart) {
      await _player.stop();
    }

    var played = false;
    for (final asset in _fallbackAssets) {
      try {
        await _player.play(AssetSource(asset), volume: 0.5);
        _currentAsset = asset;
        played = true;
        break;
      } catch (_) {
        // Try next asset candidate.
      }
    }

    if (!played) {
      _currentAsset = null;
    }
  }

  static Future<void> stop() async {
    _currentAsset = null;
    await _player.stop();
  }
}

class MissionTourApp extends StatelessWidget {
  const MissionTourApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '미션투어',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF4F5F7),
        fontFamily: 'sans-serif',
      ),
      home: const IntroScreen(),
      routes: {
        '/home': (context) => const MissionHomeScreen(),
        '/story_low_dummy': (context) => const StoryDummyScreen(),
        '/chapter1_story2_tbd': (context) => const Chapter1Story2TbdScreen(),
        '/mission_low': (context) {
          LobbyBgmController.stop();
          return const MissionLowScreen(completedRouteName: '/chapter1_story2_tbd');
        },
        '/mission_ch1_q2': (context) {
          LobbyBgmController.stop();
          return const MissionLowScreen(
            missionDataPath: 'assets/data/mission_chapter1_q2.json',
            completedRouteName: '/home',
          );
        },
      },
    );
  }
}

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/bg_intro.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFFF4F5F7)),
          ),
          Container(color: const Color(0x66000000)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  const Text(
                    '충북 수학체험센터에 온 걸 환영해!',
                    style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '준비되면 아래 버튼을 눌러 시작해 보자.',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 62,
                    child: ElevatedButton(
                      onPressed: () async {
                        await LobbyBgmController.playBackground(forceRestart: true);
                        if (!mounted) return;
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4358AD),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('입장하기', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MissionHomeScreen extends StatefulWidget {
  const MissionHomeScreen({super.key});

  @override
  State<MissionHomeScreen> createState() => _MissionHomeScreenState();
}

class _MissionHomeScreenState extends State<MissionHomeScreen> {
  static final Uri _reserveUrl = Uri.parse('https://www.cbnse.go.kr/reserve/');

  @override
  void initState() {
    super.initState();
    LobbyBgmController.playBackground();
  }

  Future<void> _goMissionLow() async {
    if (!mounted) return;
    Navigator.pushNamed(context, '/story_low_dummy');
  }

  Future<void> _openReservePage() async {
    final launched = await launchUrl(_reserveUrl, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('링크를 열 수 없습니다. 잠시 후 다시 시도해 주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = 18.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isUltraWide = screenWidth / screenHeight >= 2.1;
    final cardWidth = (screenWidth - (horizontalPadding * 2) - 10) / 2;
    final welcomeSize = isUltraWide ? 44.0 : 28.0;
    final adventureSize = isUltraWide ? 46.0 : 28.0;
    final infoTitleSize = isUltraWide ? 28.0 : 18.0;
    final infoBodySize = isUltraWide ? 40.0 : 22.0;
    final infoLinkSize = isUltraWide ? 24.0 : 16.0;

    return Scaffold(
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: const Color(0xFFEDEDED),
          padding: const EdgeInsets.fromLTRB(horizontalPadding, 14, horizontalPadding, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('과학체험관·수학체험센터를 한 곳에서!', style: TextStyle(fontSize: infoTitleSize, fontWeight: FontWeight.w500, color: const Color(0xFF2D2D2D))),
              const SizedBox(height: 6),
              Text('충북자연과학교육원에서 과학과 수학을 함께 체험해요.', style: TextStyle(fontSize: infoBodySize, fontWeight: FontWeight.w800, color: const Color(0xFF222222), height: 1.15)),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _openReservePage,
                child: Text(
                  '통합예약 바로가기  →',
                  style: TextStyle(
                    fontSize: infoLinkSize,
                    color: const Color(0xFF3E5FB8),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _StartButton(onPressed: _goMissionLow),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_intro.png',
              fit: BoxFit.cover,
              alignment: isUltraWide ? const Alignment(0, -0.35) : Alignment.center,
              errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFFF4F5F7)),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x33FFFFFF), Color(0x99FFFFFF)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(horizontalPadding, 18, horizontalPadding, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 8, 14, 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(0, 2))],
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/logo_cb_math.png',
                            width: 62,
                            height: 62,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 10),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('충북수학체험센터', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF163988), height: 1.1)),
                              SizedBox(height: 2),
                              Text('Chungbuk Math Experience Center', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2F477D))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFBAC5E8), width: 2)),
                      child: const Icon(Icons.volume_up_outlined, color: Color(0xFF6377BE), size: 24),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(horizontalPadding, 30, horizontalPadding, 0),
                child: Text('충북수학체험센터에 온 걸 환영해!', style: TextStyle(fontSize: welcomeSize, fontWeight: FontWeight.w600, color: Color(0xFF1E222A), height: 1.15)),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(horizontalPadding, 10, horizontalPadding, 0),
                child: Text('너만의 수학 모험을 시작해 봐!', style: TextStyle(fontSize: adventureSize, fontWeight: FontWeight.w900, color: Color(0xFF1E222A), height: 1.1)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(horizontalPadding, 20, horizontalPadding, 0),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _MissionCard(
                      width: cardWidth,
                      icon: Icons.landscape_rounded,
                      title: '미션! 수학체험센터의\n반짝별을 찾아서',
                      subtitle: '초등 저학년 추천',
                      backgroundColor: const Color(0xFFE9DCE9),
                      subtitleColor: const Color(0xFFDE5C85),
                      selected: true,
                      onTap: _goMissionLow,
                    ),
                    _MissionCard(width: cardWidth, icon: Icons.auto_awesome_rounded, title: '미션! 수사모의\n보물을 찾아서', subtitle: '초등 고학년 추천', backgroundColor: const Color(0xFFF0DEEA), subtitleColor: const Color(0xFFDE5C85)),
                    _MissionCard(width: cardWidth, icon: Icons.edit_note_rounded, title: '수학자의 비밀\n노트를 찾아라!', subtitle: '중학생 추천', backgroundColor: const Color(0xFFDDE2F5), subtitleColor: const Color(0xFF4A67BF)),
                    _MissionCard(width: cardWidth, icon: Icons.menu_book_rounded, title: '역설, 혹은\n모호함', subtitle: '고등학생 추천', backgroundColor: const Color(0xFFDDE2F5), subtitleColor: const Color(0xFF4A67BF)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.width, required this.icon, required this.title, required this.subtitle, required this.backgroundColor, required this.subtitleColor, this.selected = false, this.onTap});
  final double width;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color subtitleColor;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final ratio = screenWidth / screenHeight;
    final isUltraWide = ratio >= 2.1;
    final isWide = screenWidth >= 1400;
    final iconCircleSize = isUltraWide ? 126.0 : (isWide ? 108.0 : 88.0);
    final iconSize = isUltraWide ? 66.0 : (isWide ? 58.0 : 48.0);
    final titleSize = isUltraWide ? 36.0 : (isWide ? 26.0 : 20.0);
    final subtitleSize = isUltraWide ? 20.0 : (isWide ? 15.0 : 12.0);
    final minHeight = isUltraWide ? 300.0 : (isWide ? 240.0 : 200.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        constraints: BoxConstraints(minHeight: minHeight),
        padding: EdgeInsets.fromLTRB(isUltraWide ? 24 : (isWide ? 18 : 14), isUltraWide ? 22 : (isWide ? 16 : 14), isUltraWide ? 24 : (isWide ? 18 : 14), isUltraWide ? 20 : (isWide ? 14 : 12)),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: selected ? Border.all(color: const Color(0xFF4A66B6), width: 5) : null,
          boxShadow: const [BoxShadow(color: Color(0x18000000), blurRadius: 8, offset: Offset(0, 3))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: iconCircleSize,
              height: iconCircleSize,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              child: Icon(icon, size: iconSize, color: const Color(0xFFDE4C78)),
            ),
            SizedBox(height: isUltraWide ? 20 : (isWide ? 14 : 12)),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.w900, color: const Color(0xFF2D2F36), height: 1.2),
            ),
            SizedBox(height: isUltraWide ? 16 : (isWide ? 10 : 8)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: isUltraWide ? 18 : (isWide ? 12 : 10), vertical: isUltraWide ? 8 : (isWide ? 5 : 4)),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.72),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                subtitle,
                style: TextStyle(fontSize: subtitleSize, fontWeight: FontWeight.w800, color: subtitleColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 66,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4358AD), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 2),
        child: const Text('시작하기', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
