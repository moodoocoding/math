import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'bgm_controller.dart';
import 'mission_low.dart';
import 'story_dummy_screen.dart';
import 'chapter1_story2_tbd_screen.dart';
import 'chapter2_story_screen.dart';

void main() {
  runApp(const MissionTourApp());
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
        '/chapter2_story': (context) => const Chapter2StoryScreen(),
        '/mission_low': (context) => const MissionLowScreen(completedRouteName: '/chapter1_story2_tbd'),
        '/mission_ch1_q2': (context) => const MissionLowScreen(
              missionDataPath: 'assets/data/mission_chapter1_q2.json',
              completedRouteName: '/chapter2_story',
            ),
        '/mission_chapter2_q1': (context) => const MissionLowScreen(
              missionDataPath: 'assets/data/mission_chapter2_q1.json',
              completedRouteName: '/mission_chapter2_q2',
            ),
        '/mission_chapter2_q2': (context) => const Chapter2PuzzleQ2Screen(),
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
            cacheWidth: 800,
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
                      onPressed: () {
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
    AppBgmController.playMain();
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
          padding: const EdgeInsets.fromLTRB(horizontalPadding, 10, horizontalPadding, 12),
          child: _StartButton(onPressed: _goMissionLow),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_intro.png',
              fit: BoxFit.cover,
              cacheWidth: 800,
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
                            cacheWidth: 150,
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
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                color: const Color(0xFFEDEDED),
                padding: const EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 18),
                child: Column(
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

class _PuzzlePiece {
  _PuzzlePiece({
    required this.id,
    required this.imagePath,
    this.currentCell,
  });

  final String id;
  final String imagePath;
  int? currentCell;
}

class _PlacedPiece {
  _PlacedPiece({
    required this.id,
    required this.imagePath,
    this.rotationQuarterTurns = 0,
  });

  final String id;
  final String imagePath;
  int rotationQuarterTurns;
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
  static const Map<int, int> _centerCellExpectedRotation = {
    5: 0,  // 좌상
    6: 1,  // 우상
    9: 3,  // 좌하
    10: 2, // 우하
  };
  static const Set<String> _curvePieceIds = {'piece4', 'piece5', 'piece6'};

  late final List<_PuzzlePiece> _pieceTemplates;
  final List<_PlacedPiece?> _boardCells = List<_PlacedPiece?>.filled(_totalCells, null);
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('보드에 놓인 조각을 먼저 선택해 주세요.')),
      );
      return;
    }

    setState(() {
      final piece = _boardCells[_selectedCell!]!;
      piece.rotationQuarterTurns = (piece.rotationQuarterTurns + 1) % 4;
    });
  }

  bool _isSquarePiece(_PlacedPiece piece) => piece.id == 'piece1';

  bool _isCurvePiece(_PlacedPiece piece) => _curvePieceIds.contains(piece.id);

  bool _isCorrect() {
    for (var i = 0; i < _totalCells; i++) {
      final current = _boardCells[i];
      if (current == null) return false;

      // 중앙 4칸: 원호 조각 + 회전값이 목표와 일치해야 함.
      if (_centerCells.contains(i)) {
        if (!_isCurvePiece(current)) return false;
        if (current.rotationQuarterTurns != _centerCellExpectedRotation[i]) return false;
        continue;
      }

      // 나머지 12칸: 사각 조각이어야 함.
      if (!_isSquarePiece(current)) return false;
    }
    return true;
  }

  void _checkPuzzle() {
    final correct = _isCorrect();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(correct ? '성공!' : '다시 도전!'),
        content: Text(
          correct
              ? '목표 모양을 정확히 만들었어요!'
              : '아직 목표 모양과 달라요. 조각을 다시 옮겨 보세요.',
          style: const TextStyle(height: 1.35),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
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
          border: selected ? Border.all(color: const Color(0xFF2F6BDD), width: 3) : null,
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

    return Draggable<_DragPayload>(
      data: payload,
      feedback: Material(
        color: Colors.transparent,
        child: _buildPieceVisual(
          pieceId: piece.id,
          imagePath: piece.imagePath,
          rotationQuarterTurns: 0,
          selected: false,
          size: size,
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: _buildPieceVisual(
          pieceId: piece.id,
          imagePath: piece.imagePath,
          rotationQuarterTurns: 0,
          selected: false,
          size: size,
        ),
      ),
      child: _buildPieceVisual(
        pieceId: piece.id,
        imagePath: piece.imagePath,
        rotationQuarterTurns: 0,
        selected: false,
        size: size,
      ),
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
      onDraggableCanceled: (_, __) => _returnPieceToTray(cellIndex),
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
              onAcceptWithDetails: (details) => _placePayloadOnCell(details.data, index),
              builder: (context, candidateData, rejectedData) {
                return Container(
                  decoration: BoxDecoration(
                    color: candidateData.isNotEmpty ? const Color(0xFFE2F7E7) : Colors.white,
                    border: Border.all(color: const Color(0xFF9DB4E8), width: 1.6),
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF7A5A00)),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/pieces/target.png',
              width: width - 20,
              height: width - 20,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: width - 20,
                height: width - 20,
                color: const Color(0xFFF7E7A2),
                alignment: Alignment.center,
                child: const Text(
                  'target.png',
                  style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF7A5A00)),
                ),
              ),
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
          '수학놀이실 문제 2',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF6FAFF),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 1000;
            final trayPieceSize = wide ? 80.0 : 70.0;

            return Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9F2FF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFA8C1F5), width: 2),
                    ),
                    child: const Text(
                      '조각 6개를 움직여서 오른쪽과 같은 모양을 만들어 보세요.',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF163988),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                width: constraints.maxWidth * 0.24,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: const Color(0xFFC8D8F2), width: 2),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '조각 보관함',
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF355AA8)),
                                      ),
                                      const SizedBox(height: 10),
                                      Expanded(
                                        child: GridView.count(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 10,
                                          mainAxisSpacing: 10,
                                          childAspectRatio: 1,
                                          children: _pieceTemplates
                                        .map((piece) => _buildTrayPiece(piece, size: trayPieceSize))
                                        .toList(growable: false),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: LayoutBuilder(
                                  builder: (context, rightConstraints) {
                                    final targetWidth = (rightConstraints.maxWidth * 0.26).clamp(170.0, 220.0).toDouble();
                                    final boardSide = math.min(
                                      rightConstraints.maxHeight - 6,
                                      rightConstraints.maxWidth - targetWidth - 14,
                                    ).clamp(240.0, 520.0).toDouble();

                                    return Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Center(
                                            child: _buildBoard(boardWidth: boardSide),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        _buildTargetCard(width: targetWidth),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          )
                        : SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildTargetCard(width: (constraints.maxWidth * 0.50).clamp(170.0, 240.0)),
                                const SizedBox(height: 10),
                                _buildBoard(boardWidth: (constraints.maxWidth - 28).clamp(240.0, 520.0).toDouble()),
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: const Color(0xFFC8D8F2), width: 2),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '조각 보관함',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF355AA8)),
                                      ),
                                      const SizedBox(height: 10),
                                      GridView.count(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                        childAspectRatio: 1,
                                        children: _pieceTemplates
                                        .map((piece) => _buildTrayPiece(piece, size: trayPieceSize))
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
                            minimumSize: const Size.fromHeight(58),
                            side: const BorderSide(color: Color(0xFF5C7EC5), width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            '다시하기',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF355AA8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _rotateSelectedCellPiece,
                          icon: const Icon(Icons.rotate_right_rounded),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(58),
                            side: const BorderSide(color: Color(0xFF5C7EC5), width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          label: const Text(
                            '돌리기',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF355AA8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _checkPuzzle,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(58),
                            backgroundColor: const Color(0xFF2F6BDD),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            '완성 확인',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
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
