import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'bgm_toggle_button.dart';
import 'bgm_controller.dart';
import 'mission_low.dart';
import 'story_dummy_screen.dart';
import 'chapter1_story2_tbd_screen.dart';
import 'chapter2_story_screen.dart';
import 'chapter2_story2_screen.dart';
import 'chapter2_story3_screen.dart';
import 'chapter3_story_screen.dart';
import 'chapter3_story2_screen.dart';
import 'chapter4_story_screen.dart';
import 'ending_story_screen.dart';

void main() {
  runApp(const MissionTourApp());
}

class MissionTourApp extends StatelessWidget {
  const MissionTourApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '충북수학체험센터',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF4F5F7),
        fontFamily: 'Pretendard',
      ),
      home: const IntroScreen(),
      routes: {
        '/home': (context) => const MissionHomeScreen(),
        '/story_low_dummy': (context) => const StoryDummyScreen(),
        '/chapter1_story2_tbd': (context) => const Chapter1Story2TbdScreen(),
        '/chapter2_story': (context) => const Chapter2StoryScreen(),
        '/chapter2_story2': (context) => const Chapter2Story2Screen(),
        '/chapter2_story3': (context) => const Chapter2Story3Screen(),
        '/chapter3_story': (context) => const Chapter3StoryScreen(),
        '/chapter3_story2': (context) => const Chapter3Story2Screen(),
        '/chapter4_story': (context) => const Chapter4StoryScreen(),
        '/chapter4_story2': (context) => const Chapter4Story2Screen(),
        '/chapter4_story3': (context) => const Chapter4Story3Screen(),
        '/mission_chapter4_q1_tbd': (context) =>
            const Chapter4ProblemPlaceholderScreen(
              question: '문제1: 아래 보기 중 같은 블록 모양은 무엇일까요?',
              nextRouteName: '/chapter4_story2',
            ),
        '/mission_chapter4_q2_tbd': (context) =>
            const Chapter4ProblemPlaceholderScreen(
              question: '문제2: 글자판에서 찾을 수 있는 수학 낱말은 무엇일까요?',
              nextRouteName: '/chapter4_story3',
            ),
        '/mission_low': (context) =>
            const MissionLowScreen(completedRouteName: '/chapter1_story2_tbd'),
        '/mission_ch1_q2': (context) => const MissionLowScreen(
          missionDataPath: 'assets/data/mission_chapter1_q2.json',
          completedRouteName: '/chapter2_story',
        ),
        '/mission_chapter2_q1': (context) => const MissionLowScreen(
          missionDataPath: 'assets/data/mission_chapter2_q1.json',
          completedRouteName: '/chapter2_story2',
        ),
        '/mission_chapter2_q2': (context) => const Chapter2PuzzleQ2Screen(),
        '/mission_chapter2_q3_qr': (context) =>
            const Chapter2QrVerificationScreen(),
        '/mission_chapter3_q1': (context) => const MissionLowScreen(
          missionDataPath: 'assets/data/mission_chapter3_q1.json',
          completedRouteName: '/chapter3_story2',
        ),
        '/mission_chapter3_q2': (context) => const MissionLowScreen(
          missionDataPath: 'assets/data/mission_chapter3_q2.json',
          completedRouteName: '/chapter4_story',
        ),
        '/ending_story': (context) => const EndingStoryScreen(),
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
  void initState() {
    super.initState();
    AppSfxController.playIntro();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/bg_intro.png',
            fit: BoxFit.cover,
            cacheWidth: 1800,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) =>
                Container(color: const Color(0xFFF4F5F7)),
          ),
          // Smoother gradient overlay for better text readability
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x22000000), // Lighter at top
                  Color(0x99000000), // Darker at bottom
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  const Text(
                    '충북 수학체험센터에 온 걸 환영해!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      shadows: [
                        Shadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 4)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '준비되면 아래 버튼을 눌러 시작해 보자.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Premium Gradient Button
                  Container(
                    width: double.infinity,
                    height: 68,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x44000000),
                          blurRadius: 15,
                          offset: Offset(0, 8),
                        ),
                      ],
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5A75D7), Color(0xFF354896)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if (!mounted) return;
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        '입장하기',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
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
    AppBgmController.playMain();
  }

  Future<void> _goMissionLow() async {
    if (!mounted) return;
    Navigator.pushNamed(context, '/story_low_dummy');
  }

  Future<void> _openReservePage() async {
    final launched = await launchUrl(
      _reserveUrl,
      mode: LaunchMode.externalApplication,
    );
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_intro.png',
              fit: BoxFit.cover,
              cacheWidth: 1800, // Higher cache width for better resolution
              filterQuality: FilterQuality.high, // Improve anti-aliasing
              alignment: isUltraWide
                  ? const Alignment(0, -0.35)
                  : Alignment.center,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: const Color(0xFFF4F5F7)),
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
                    padding: const EdgeInsets.fromLTRB(
                      horizontalPadding,
                      18,
                      horizontalPadding,
                      0,
                    ),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1A000000),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: BackdropFilter(
                              filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(10, 8, 14, 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.55),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                                ),
                                child: Row(
                            children: [
                              Image.asset(
                                'assets/images/logo_cb_math.png',
                                width: 62,
                                height: 62,
                                cacheWidth: 300,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: 10),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '충북수학체험센터',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF163988),
                                      height: 1.1,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Chungbuk Math Experience Center',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2F477D),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFBAC5E8),
                              width: 2,
                            ),
                          ),
                          child: const BgmToggleButton(
                            iconSize: 24,
                            color: Color(0xFF6377BE),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFBAC5E8),
                              width: 2,
                            ),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.power_settings_new,
                              size: 24,
                              color: Color(0xFF6377BE),
                            ),
                            onPressed: () {
                              SystemNavigator.pop();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      30,
                      horizontalPadding,
                      0,
                    ),
                    child: Text(
                      '충북수학체험센터에 온 걸 환영해!',
                      style: TextStyle(
                        fontSize: welcomeSize,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF162547),
                        height: 1.15,
                        shadows: [
                          Shadow(
                            color: Colors.white.withValues(alpha: 0.85),
                            blurRadius: 16,
                          ),
                          Shadow(
                            color: Colors.white.withValues(alpha: 0.85),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      10,
                      horizontalPadding,
                      0,
                    ),
                    child: Text(
                      '너만의 수학 모험을 시작해 봐!',
                      style: TextStyle(
                        fontSize: adventureSize,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF162547),
                        height: 1.1,
                        shadows: [
                          Shadow(
                            color: Colors.white.withValues(alpha: 0.85),
                            blurRadius: 16,
                          ),
                          Shadow(
                            color: Colors.white.withValues(alpha: 0.85),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      horizontalPadding,
                      20,
                      horizontalPadding,
                      0,
                    ),
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
                        _MissionCard(
                          width: cardWidth,
                          icon: Icons.auto_awesome_rounded,
                          title: '미션! 수사모의\n보물을 찾아서',
                          subtitle: '초등 고학년 추천',
                          backgroundColor: const Color(0xFFF0DEEA),
                          subtitleColor: const Color(0xFFDE5C85),
                        ),
                        _MissionCard(
                          width: cardWidth,
                          icon: Icons.edit_note_rounded,
                          title: '수학자의 비밀\n노트를 찾아라!',
                          subtitle: '중학생 추천',
                          backgroundColor: const Color(0xFFDDE2F5),
                          subtitleColor: const Color(0xFF4A67BF),
                        ),
                        _MissionCard(
                          width: cardWidth,
                          icon: Icons.menu_book_rounded,
                          title: '역설, 혹은\n모호함',
                          subtitle: '고등학생 추천',
                          backgroundColor: const Color(0xFFDDE2F5),
                          subtitleColor: const Color(0xFF4A67BF),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: horizontalPadding),
                    child: _StartButton(onPressed: _goMissionLow),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFEDEDED),
                    padding: const EdgeInsets.fromLTRB(
                      horizontalPadding,
                      16,
                      horizontalPadding,
                      18,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '과학체험관·수학체험센터를 한 곳에서!',
                          style: TextStyle(
                            fontSize: infoTitleSize,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF2D2D2D),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '충북자연과학교육원에서 과학과 수학을 함께 체험해요.',
                          style: TextStyle(
                            fontSize: infoBodySize,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF222222),
                            height: 1.15,
                          ),
                        ),
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
  const _MissionCard({
    required this.width,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.subtitleColor,
    this.selected = false,
    this.onTap,
  });
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x15000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              constraints: BoxConstraints(minHeight: minHeight),
              padding: EdgeInsets.fromLTRB(
                isUltraWide ? 24 : (isWide ? 18 : 14),
                isUltraWide ? 22 : (isWide ? 16 : 14),
                isUltraWide ? 24 : (isWide ? 18 : 14),
                isUltraWide ? 20 : (isWide ? 14 : 12),
              ),
              decoration: BoxDecoration(
                color: backgroundColor.withValues(alpha: 0.68),
                borderRadius: BorderRadius.circular(16),
                border: selected
                    ? Border.all(color: const Color(0xFF4A66B6), width: 4)
                    : Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
              ),
              child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: iconCircleSize,
              height: iconCircleSize,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Icon(icon, size: iconSize, color: const Color(0xFFDE4C78)),
            ),
            SizedBox(height: isUltraWide ? 20 : (isWide ? 14 : 12)),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF2D2F36),
                height: 1.2,
              ),
            ),
            SizedBox(height: isUltraWide ? 16 : (isWide ? 10 : 8)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isUltraWide ? 18 : (isWide ? 12 : 10),
                vertical: isUltraWide ? 8 : (isWide ? 5 : 4),
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: subtitleSize,
                  fontWeight: FontWeight.w800,
                  color: subtitleColor,
                ),
              ),
            ),
          ],
        ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PuzzlePiece {
  _PuzzlePiece({required this.id, required this.imagePath});

  final String id;
  final String imagePath;
}

class _PlacedPiece {
  _PlacedPiece({required this.id, required this.imagePath});

  final String id;
  final String imagePath;
  int rotationQuarterTurns = 0;
}

class _DragPayload {
  _DragPayload({
    required this.pieceId,
    required this.imagePath,
    required this.fromTray,
    this.fromCell,
  });

  final String pieceId;
  final String imagePath;
  final bool fromTray;
  final int? fromCell;
}

class Chapter2PuzzleQ2Screen extends StatefulWidget {
  const Chapter2PuzzleQ2Screen({super.key});

  @override
  State<Chapter2PuzzleQ2Screen> createState() => _Chapter2PuzzleQ2ScreenState();
}

class _Chapter2PuzzleQ2ScreenState extends State<Chapter2PuzzleQ2Screen> {
  static const int _boardSize = 4;
  static const int _totalCells = _boardSize * _boardSize;

  // 목표 모양(원형 중앙)을 기준으로 칸별 판정 규칙.
  // 테두리 12칸은 사각 조각, 중앙 4칸은 원호 조각 + 회전값을 검사한다.
  static const List<int> _centerCells = [5, 6, 9, 10];
  // ignore: unused_field
  static const Map<int, int> _centerCellExpectedRotation = {
    5: 0, // 좌상
    6: 1, // 우상
    9: 3, // 좌하
    10: 2, // 우하
  };
  static const Map<int, int> _centerCellTargetRotation = {
    5: 2,
    6: 3,
    9: 1,
    10: 0,
  };

  late final List<_PuzzlePiece> _pieceTemplates;
  final List<_PlacedPiece?> _boardCells = List<_PlacedPiece?>.filled(
    _totalCells,
    null,
  );
  int? _selectedCell;

  @override
  void initState() {
    super.initState();
    AppBgmController.playProblem();
    _pieceTemplates = List<_PuzzlePiece>.generate(
      6,
      (index) => _PuzzlePiece(
        id: 'piece${index + 1}',
        imagePath: 'assets/pieces/piece${index + 1}.png',
      ),
    );
  }

  // 조각을 보드 칸에 배치. 한 칸에는 1개만 허용.
  void _placePayloadOnCell(_DragPayload payload, int targetCell) {
    if (payload.fromTray) {
      setState(() {
        _boardCells[targetCell] = _PlacedPiece(
          id: payload.pieceId,
          imagePath: payload.imagePath,
        );
        _selectedCell = targetCell;
      });
      return;
    }

    final fromCell = payload.fromCell;
    if (fromCell == null) return;
    if (fromCell == targetCell) {
      setState(() {
        _selectedCell = targetCell;
      });
      return;
    }

    setState(() {
      final moving = _boardCells[fromCell];
      final displaced = _boardCells[targetCell];
      _boardCells[targetCell] = moving;
      _boardCells[fromCell] = displaced;
      _selectedCell = targetCell;
    });
  }

  // 보드 밖으로 드래그해서 놓았을 때 트레이로 복귀.
  void _returnPieceToTray(int fromCell) {
    setState(() {
      _boardCells[fromCell] = null;
      if (_selectedCell == fromCell) _selectedCell = null;
    });
  }

  void _resetPuzzle() {
    setState(() {
      for (var i = 0; i < _totalCells; i++) {
        _boardCells[i] = null;
      }
      _selectedCell = null;
    });
  }

  void _selectCell(int cellIndex) {
    setState(() {
      _selectedCell = cellIndex;
    });
  }

  void _rotateSelectedCellPiece() {
    if (_selectedCell == null || _boardCells[_selectedCell!] == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('보드에 놓인 조각을 먼저 선택해 주세요.')));
      return;
    }

    setState(() {
      final piece = _boardCells[_selectedCell!]!;
      piece.rotationQuarterTurns = (piece.rotationQuarterTurns + 1) % 4;
    });
  }

  bool _isSquarePiece(_PlacedPiece piece) => piece.id == 'piece1';

  bool _isCenterPiece(_PlacedPiece piece) => piece.id == 'piece4';

  int _targetRotationForCell(int cellIndex) =>
      _centerCellTargetRotation[cellIndex]!;

  bool _hasCorrectCenterPieces() {
    int? sharedOffset;

    for (final cellIndex in _centerCells) {
      final piece = _boardCells[cellIndex];
      if (piece == null || !_isCenterPiece(piece)) return false;

      final offset =
          (piece.rotationQuarterTurns - _targetRotationForCell(cellIndex)) % 4;
      sharedOffset ??= offset;
      if (sharedOffset != offset) return false;
    }

    return true;
  }

  bool _isCorrect() {
    for (var i = 0; i < _totalCells; i++) {
      final current = _boardCells[i];
      if (current == null) return false;

      // 중앙 4칸: 원호 조각 + 회전값이 목표와 일치해야 함.
      if (_centerCells.contains(i)) continue;

      // 나머지 12칸: 사각 조각이어야 함.
      if (!_isSquarePiece(current)) return false;
    }
    return _hasCorrectCenterPieces();
  }

  void _handlePuzzleSolved() {
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, '/chapter2_story3');
  }

  void _skipPuzzleForTest() {
    Navigator.pushReplacementNamed(context, '/chapter2_story3');
  }

  void _checkPuzzle() {
    final correct = _isCorrect();
    showPremiumFeedbackDialog(
      context: context,
      isCorrect: correct,
      title: correct ? '성공!' : '다시 도전!',
      message: correct
          ? '목표 모양을 정확히 만들었어요!'
          : '아직 목표 모양과 달라요. 조각을 다시 옮겨 보세요.',
      onConfirm: correct ? _handlePuzzleSolved : () {},
    );
  }

  Widget _buildPieceVisual({
    required String pieceId,
    required String imagePath,
    required int rotationQuarterTurns,
    required bool selected,
    double size = 72,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          border: selected
              ? Border.all(color: const Color(0xFF2F6BDD), width: 3)
              : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Transform.rotate(
          angle: rotationQuarterTurns * (math.pi / 2),
          child: Image.asset(
            imagePath,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: size,
              height: size,
              color: const Color(0xFFFFE7EC),
              alignment: Alignment.center,
              child: Text(
                pieceId.replaceFirst('piece', '조각'),
                style: const TextStyle(
                  color: Color(0xFFB33961),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrayPiece(_PuzzlePiece piece, {required double size}) {
    final payload = _DragPayload(
      pieceId: piece.id,
      imagePath: piece.imagePath,
      fromTray: true,
    );
    Widget trayItem({double opacity = 1}) {
      return Opacity(
        opacity: opacity,
        child: Container(
          width: size + 14,
          height: size + 14,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F6FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFAEC4F5), width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Center(
            child: _buildPieceVisual(
              pieceId: piece.id,
              imagePath: piece.imagePath,
              rotationQuarterTurns: 0,
              selected: false,
              size: size - 4,
            ),
          ),
        ),
      );
    }

    return Draggable<_DragPayload>(
      data: payload,
      feedback: Material(color: Colors.transparent, child: trayItem()),
      childWhenDragging: trayItem(opacity: 0.35),
      child: trayItem(),
    );
  }

  Widget _buildBoardPiece({
    required int cellIndex,
    required _PlacedPiece piece,
    required double size,
  }) {
    return Draggable<_DragPayload>(
      data: _DragPayload(
        pieceId: piece.id,
        imagePath: piece.imagePath,
        fromTray: false,
        fromCell: cellIndex,
      ),
      feedback: Material(
        color: Colors.transparent,
        child: _buildPieceVisual(
          pieceId: piece.id,
          imagePath: piece.imagePath,
          rotationQuarterTurns: piece.rotationQuarterTurns,
          selected: false,
          size: size,
        ),
      ),
      onDragStarted: () => _selectCell(cellIndex),
      onDraggableCanceled: (velocity, offset) => _returnPieceToTray(cellIndex),
      childWhenDragging: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0x33FFFFFF),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: GestureDetector(
        onTap: () => _selectCell(cellIndex),
        child: _buildPieceVisual(
          pieceId: piece.id,
          imagePath: piece.imagePath,
          rotationQuarterTurns: piece.rotationQuarterTurns,
          selected: _selectedCell == cellIndex,
          size: size,
        ),
      ),
    );
  }

  Widget _buildBoard({required double boardWidth}) {
    final cellSize = (boardWidth - 12) / _boardSize;
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF97B0E9), width: 2),
      ),
      child: SizedBox(
        width: boardWidth - 12,
        height: boardWidth - 12,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _totalCells,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _boardSize,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
          ),
          itemBuilder: (context, index) {
            final piece = _boardCells[index];
            return DragTarget<_DragPayload>(
              onWillAcceptWithDetails: (details) => true,
              onAcceptWithDetails: (details) =>
                  _placePayloadOnCell(details.data, index),
              builder: (context, candidateData, rejectedData) {
                return Container(
                  decoration: BoxDecoration(
                    color: candidateData.isNotEmpty
                        ? const Color(0xFFE2F7E7)
                        : Colors.white,
                    border: Border.all(
                      color: const Color(0xFF9DB4E8),
                      width: 1.6,
                    ),
                  ),
                  child: piece == null
                      ? null
                      : Center(
                          child: _buildBoardPiece(
                            cellIndex: index,
                            piece: piece,
                            size: cellSize - 6,
                          ),
                        ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildTargetPreview({required double side}) {
    final cellSize = (side - 12) / _boardSize;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF97B0E9), width: 2),
      ),
      child: SizedBox(
        width: side - 12,
        height: side - 12,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _totalCells,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _boardSize,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
          ),
          itemBuilder: (context, index) {
            final isCenter = _centerCells.contains(index);
            final pieceId = isCenter ? 'piece4' : 'piece1';
            final rotationQuarterTurns = isCenter
                ? _targetRotationForCell(index)
                : 0;

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFF9DB4E8), width: 1.6),
              ),
              child: Center(
                child: _buildPieceVisual(
                  pieceId: pieceId,
                  imagePath: 'assets/pieces/$pieceId.png',
                  rotationQuarterTurns: rotationQuarterTurns,
                  selected: false,
                  size: cellSize - 6,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTargetCard({required double width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7D6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFECC94B), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '목표 모양',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF7A5A00),
            ),
          ),
          const SizedBox(height: 8),
          _buildTargetPreview(side: width - 20),
        ],
      ),
    );
  }

  Widget _buildPuzzleStepChip({required String stepNo, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFB8CAEE), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Color(0xFF2F6BDD),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              stepNo,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF29427A),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF163988),
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          '미션! 수학체험센터의 반짝별을 찾아서',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24),
        ),
        centerTitle: true,
        actions: [
          const BgmToggleButton(iconSize: 36),
          IconButton(
            icon: const Icon(Icons.home_rounded, size: 38),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF6FAFF),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 1000;
            final trayPieceSize = wide ? 64.0 : 62.0;

            return Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9F2FF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFA8C1F5),
                        width: 2,
                      ),
                    ),
                    child: const Text(
                      '문제2: 조각 6개를 움직여 목표 무늬를 완성하세요.',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF163988),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildPuzzleStepChip(stepNo: '1', label: '조각 놓기'),
                      _buildPuzzleStepChip(stepNo: '2', label: '필요하면 돌리기'),
                      _buildPuzzleStepChip(stepNo: '3', label: '완성 확인'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: wide
                        ? LayoutBuilder(
                            builder: (context, rightConstraints) {
                              final sidePanelWidth =
                                  (rightConstraints.maxWidth * 0.28)
                                      .clamp(220.0, 300.0)
                                      .toDouble();
                              // wideTrayPieceSize is now computed inside LayoutBuilder per tray
                              final boardSide = math
                                  .min(
                                    rightConstraints.maxHeight - 6,
                                    rightConstraints.maxWidth -
                                        sidePanelWidth -
                                        14,
                                  )
                                  .clamp(260.0, 560.0)
                                  .toDouble();

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Center(
                                      child: _buildBoard(boardWidth: boardSide),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  SizedBox(
                                    width: sidePanelWidth,
                                    child: Column(
                                      children: [
                                        // 목표 모양: 사용 가능 높이에 비례해 크기 결정
                                        Expanded(
                                          flex: 5,
                                          child: LayoutBuilder(
                                            builder: (ctx, sideC) {
                                              final previewSide = math
                                                  .min(
                                                    sideC.maxWidth - 20,
                                                    sideC.maxHeight - 48,
                                                  )
                                                  .clamp(60.0, 260.0)
                                                  .toDouble();
                                              return Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFFF7D6),
                                                  borderRadius: BorderRadius.circular(14),
                                                  border: Border.all(
                                                    color: const Color(0xFFECC94B),
                                                    width: 2,
                                                  ),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.max,
                                                  children: [
                                                    const Text(
                                                      '목표 모양',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.w900,
                                                        color: Color(0xFF7A5A00),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Expanded(
                                                      child: Center(
                                                        child: _buildTargetPreview(
                                                          side: previewSide + 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // 조각 보관함: LayoutBuilder로 2행 3열이 딱 맞도록 비율 계산
                                        Expanded(
                                          flex: 5,
                                          child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(14),
                                              border: Border.all(
                                                color: const Color(0xFFC8D8F2),
                                                width: 2,
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  '조각 보관함',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w900,
                                                    color: Color(0xFF355AA8),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Expanded(
                                                  child: LayoutBuilder(
                                                    builder: (ctx, trayC) {
                                                      final cellW = (trayC.maxWidth - 2 * 8) / 3;
                                                      final cellH = (trayC.maxHeight - 8) / 2;
                                                      final ratio = (cellW / cellH).clamp(0.4, 3.0);
                                                      final pSize = (math.min(cellW, cellH) * 0.72).clamp(28.0, 64.0);
                                                      return GridView.count(
                                                        physics: const NeverScrollableScrollPhysics(),
                                                        crossAxisCount: 3,
                                                        crossAxisSpacing: 8,
                                                        mainAxisSpacing: 8,
                                                        childAspectRatio: ratio,
                                                        children: _pieceTemplates
                                                            .map(
                                                              (piece) => _buildTrayPiece(
                                                                piece,
                                                                size: pSize,
                                                              ),
                                                            )
                                                            .toList(growable: false),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          )
                        : SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildBoard(
                                  boardWidth: (constraints.maxWidth - 20)
                                      .clamp(260.0, 560.0)
                                      .toDouble(),
                                ),
                                const SizedBox(height: 10),
                                _buildTargetCard(
                                  width: (constraints.maxWidth * 0.62).clamp(
                                    200.0,
                                    300.0,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: const Color(0xFFC8D8F2),
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '조각 보관함',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF355AA8),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      GridView.count(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 8,
                                        mainAxisSpacing: 8,
                                        childAspectRatio: 1,
                                        children: _pieceTemplates
                                            .map(
                                              (piece) => _buildTrayPiece(
                                                piece,
                                                size: trayPieceSize,
                                              ),
                                            )
                                            .toList(growable: false),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _resetPuzzle,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(56),
                            side: const BorderSide(
                              color: Color(0xFF5C7EC5),
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            '다시하기',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF355AA8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _rotateSelectedCellPiece,
                          icon: const Icon(Icons.rotate_right_rounded),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(56),
                            side: const BorderSide(
                              color: Color(0xFF5C7EC5),
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          label: const Text(
                            '돌리기',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF355AA8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _checkPuzzle,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(56),
                            backgroundColor: const Color(0xFF2F6BDD),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            '완성 확인',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (kDebugMode) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _skipPuzzleForTest,
                        icon: const Icon(Icons.skip_next_rounded),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(42),
                          side: const BorderSide(
                            color: Color(0xFF5C7EC5),
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        label: const Text(
                          '테스트용: 문제 건너뛰고 다음으로',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF355AA8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class Chapter2QrVerificationScreen extends StatefulWidget {
  const Chapter2QrVerificationScreen({super.key});

  @override
  State<Chapter2QrVerificationScreen> createState() =>
      _Chapter2QrVerificationScreenState();
}

class _Chapter2QrVerificationScreenState
    extends State<Chapter2QrVerificationScreen>
    with WidgetsBindingObserver {
  static const Set<String> _allowedSchemes = {'https', 'http'};
  static const Set<String> _allowedHosts = {
    'www.cbnse.go.kr',
    'cbnse.go.kr',
    'm.cbnse.go.kr',
  };

  final MobileScannerController _scannerController = MobileScannerController(
    autoStart: false,
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    formats: const [BarcodeFormat.qrCode],
  );

  bool _handlingDetection = false;
  bool _isStartingScanner = false;
  String? _lastScannedValue;
  final TextEditingController _manualQrController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AppBgmController.stop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScanner();
    });
  }

  Future<void> _startScanner() async {
    if (!mounted || _isStartingScanner) return;
    if (_scannerController.value.isRunning) return;

    _isStartingScanner = true;
    try {
      await _scannerController.start();
    } on MobileScannerException {
      if (!mounted) return;
      setState(() {});
    } finally {
      _isStartingScanner = false;
    }
  }

  Future<void> _stopScanner() async {
    if (!mounted) return;
    if (!_scannerController.value.isRunning) return;
    try {
      await _scannerController.stop();
    } on MobileScannerException {
      // Ignore stop failures during lifecycle transitions.
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted || _handlingDetection) return;
    switch (state) {
      case AppLifecycleState.resumed:
        _startScanner();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _stopScanner();
        break;
    }
  }

  bool _isAllowedHost(String host) {
    final normalized = host.trim().toLowerCase();
    if (normalized.isEmpty) return false;
    return _allowedHosts.contains(normalized) ||
        normalized.endsWith('.cbnse.go.kr');
  }

  bool _matchesAcceptedUri(Uri uri) {
    final scheme = uri.scheme.toLowerCase();
    if (scheme.isNotEmpty && !_allowedSchemes.contains(scheme)) return false;
    if (_isAllowedHost(uri.host)) return true;

    for (final values in uri.queryParametersAll.values) {
      for (final value in values) {
        final decoded = Uri.decodeFull(value.trim());
        if (decoded.isEmpty) continue;
        final nestedCandidate = decoded.contains('://')
            ? decoded
            : 'https://$decoded';
        final nested = Uri.tryParse(nestedCandidate);
        if (nested != null && _isAllowedHost(nested.host)) {
          return true;
        }
      }
    }

    return false;
  }

  bool _isAcceptedQrValue(String rawValue) {
    final value = rawValue.trim();
    if (value.isEmpty) return false;

    // Some QR payloads include a redirected URL string; allow known domain tokens.
    final decodedLower = Uri.decodeFull(value).toLowerCase();
    if (decodedLower.contains('cbnse.go.kr')) return true;

    Uri? uri = Uri.tryParse(value);
    if ((uri == null || uri.host.isEmpty) && !value.contains('://')) {
      // Some QR codes contain host/path only (without http/https).
      uri = Uri.tryParse('https://$value');
    }
    if (uri == null) return false;

    return _matchesAcceptedUri(uri);
  }

  Future<void> _showResultDialog({
    required bool success,
    required String title,
    required String message,
  }) async {
    await showPremiumFeedbackDialog(
      context: context,
      isCorrect: success,
      title: title,
      message: message,
      onConfirm: () async {
        if (!mounted) return;
        if (success) {
          Navigator.pushReplacementNamed(context, '/chapter3_story');
        } else {
          setState(() {
            _handlingDetection = false;
          });
          await _startScanner();
        }
      },
    );
  }

  Future<void> _handleDetection(String rawValue) async {
    if (_handlingDetection) return;

    setState(() {
      _handlingDetection = true;
      _lastScannedValue = rawValue;
    });

    await _scannerController.stop();

    if (!mounted) return;

    if (_isAcceptedQrValue(rawValue)) {
      await _showResultDialog(
        success: true,
        title: '미션 인증 완료!',
        message: 'QR 인증이 완료됐어요! 다음 단계로 이동할 준비가 되었어요.',
      );
      return;
    }

    await _showResultDialog(
      success: false,
      title: '다시 스캔해 주세요',
      message: '인증용 QR 코드가 아니에요. 충북수학체험센터 QR 코드를 다시 읽어 주세요.',
    );
  }

  Future<void> _submitManualQr() async {
    final rawValue = _manualQrController.text.trim();
    if (rawValue.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('URL 또는 QR 값을 입력해 주세요.')));
      return;
    }

    setState(() {
      _lastScannedValue = rawValue;
    });

    if (_isAcceptedQrValue(rawValue)) {
      await _showResultDialog(
        success: true,
        title: '미션 인증 완료!',
        message: 'QR 인증이 완료됐어요! 다음 단계로 이동할 준비가 되었어요.',
      );
      return;
    }

    await _showResultDialog(
      success: false,
      title: '인증 실패',
      message: '입력한 값이 인증용 QR 코드가 아니에요.',
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _manualQrController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  String _errorTextFor(MobileScannerException error) {
    switch (error.errorCode) {
      case MobileScannerErrorCode.permissionDenied:
        return '카메라 권한이 꺼져 있어요. 설정에서 카메라 권한을 허용한 뒤 다시 시도해 주세요.';
      case MobileScannerErrorCode.unsupported:
        return '현재 실행 환경에서는 카메라 스캔이 지원되지 않아요. Android/iOS 기기에서 실행해 주세요.';
      default:
        return '카메라를 시작하지 못했어요. 권한 확인 후 다시 시도해 주세요.';
    }
  }

  Widget _buildScannerError(MobileScannerException error) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 36),
              const SizedBox(height: 12),
              Text(
                _errorTextFor(error),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: _startScanner,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F6BDD),
                  foregroundColor: Colors.white,
                ),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF163988),
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          '미션! 수학체험센터의 반짝별을 찾아서',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: '카메라 전환',
            onPressed: () => _scannerController.switchCamera(),
            icon: const Icon(Icons.cameraswitch_rounded, size: 32),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF6FAFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F2FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFA8C1F5), width: 2),
                ),
                child: const Column(
                  children: [
                    Text(
                      '다음 단계 QR 인증',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF163988),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '다음 단계로 이동하려면 현장 QR 코드를 스캔해 인증해 보세요.',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF163988),
                        height: 1.25,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFC8D8F2),
                      width: 2,
                    ),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final scannerSide = math
                          .min(constraints.maxWidth, constraints.maxHeight)
                          .clamp(260.0, 560.0);

                      return Center(
                        child: SizedBox(
                          width: scannerSide,
                          height: scannerSide,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                MobileScanner(
                                  controller: _scannerController,
                                  errorBuilder: (context, error, child) {
                                    return _buildScannerError(error);
                                  },
                                  onDetect: (capture) {
                                    final rawValue = capture.barcodes
                                        .map(
                                          (barcode) =>
                                              barcode.rawValue?.trim() ?? '',
                                        )
                                        .firstWhere(
                                          (value) => value.isNotEmpty,
                                          orElse: () => '',
                                        );
                                    if (rawValue.isEmpty) return;
                                    _handleDetection(rawValue);
                                  },
                                ),
                                IgnorePointer(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0x99FFFFFF),
                                        width: 3,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFC8D8F2),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _manualQrController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          hintText: '테스트용: URL/QR 값을 직접 입력',
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _submitManualQr,
                          icon: const Icon(Icons.verified_outlined),
                          label: const Text(
                            '직접 입력으로 인증',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      '/chapter3_story',
                    ),
                    icon: const Icon(Icons.skip_next_rounded),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(42),
                      side: const BorderSide(
                        color: Color(0xFF5C7EC5),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    label: const Text(
                      '테스트용: 인증 건너뛰고 다음으로',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF355AA8),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFC8D8F2), width: 2),
                ),
                child: Text(
                  _lastScannedValue == null
                      ? '충북수학체험센터 QR 코드를 비추면 자동으로 인증 여부를 확인합니다.'
                      : '최근 스캔 결과: $_lastScannedValue',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF29427A),
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
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
        onPressed: () {
        AppSfxController.playMissionStart();
        onPressed();
      },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4358AD),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        child: const Text(
          '시작하기',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

Future<void> showPremiumFeedbackDialog({
  required BuildContext context,
  required bool isCorrect,
  required String title,
  required String message,
  required VoidCallback onConfirm,
}) async {
  final screenWidth = MediaQuery.of(context).size.width;
  final dialogWidth = (screenWidth * 0.45).clamp(360.0, 500.0);
  final imageHeight = screenWidth < 1100 ? 180.0 : 220.0;
  final titleSize = screenWidth < 1100 ? 32.0 : 38.0;
  final messageSize = screenWidth < 1100 ? 20.0 : 24.0;
  final confirmSize = screenWidth < 1100 ? 22.0 : 26.0;

  if (isCorrect) {
    AppSfxController.playCorrect();
  } else {
    AppSfxController.playWrong();
  }

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.75),
    builder: (context) {
      return Dialog(
        elevation: 20,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          width: dialogWidth,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Image.asset(
                  isCorrect
                      ? 'assets/images/chr_play_correct.png'
                      : 'assets/images/chr_how_fail.png',
                  height: imageHeight,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w900,
                  color: isCorrect
                      ? const Color(0xFF13968F)
                      : const Color(0xFFD64A45),
                  fontFamily: 'GangwonEduAll',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: messageSize,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4B5563),
                  height: 1.3,
                  fontFamily: 'GangwonEduAll',
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onConfirm();
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
                  child: Text(
                    '확인',
                    style: TextStyle(
                      fontSize: confirmSize,
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
