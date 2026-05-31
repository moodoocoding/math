import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'bgm_toggle_button.dart';
import 'bgm_controller.dart';

// ═══════════════════════════════════════════════════════════════
// Types
// ═══════════════════════════════════════════════════════════════

/// 도형 내 상대 셀: (열 오프셋, 행 오프셋) — 0-indexed
typedef _Rel = (int col, int row);

/// 시소 위 절대 셀: (중심으로부터의 거리 1-5, 행 1-4)
typedef _Abs = (int dist, int row);

// ═══════════════════════════════════════════════════════════════
// 카드 정의
// ═══════════════════════════════════════════════════════════════

class _CardDef {
  final String name;
  final Color color;

  /// 각 요소 = 1가지 회전 상태의 상대 셀 리스트
  final List<List<_Rel>> rotations;
  final List<String> rotationLabels;

  /// 왼쪽 자동 배치용 프리셋 2개: (rotIdx, startDist)
  final List<(int rot, int startDist)> leftPresets;

  const _CardDef({
    required this.name,
    required this.color,
    required this.rotations,
    required this.rotationLabels,
    required this.leftPresets,
  });

  int get rotCount => rotations.length;

  int _maxCol(int ri) => rotations[ri].map((c) => c.$1).reduce(math.max);
  int _maxRow(int ri) => rotations[ri].map((c) => c.$2).reduce(math.max);

  bool isValidAt(int ri, int d, {int r = 1}) =>
      d >= 1 && d + _maxCol(ri) <= 5 && r >= 1 && r + _maxRow(ri) <= 4;

  List<_Abs> cells(int ri, int d, {int r = 1, bool isLeft = false}) {
    if (isLeft) {
      final mc = _maxCol(ri);
      return rotations[ri].map((c) => (d + mc - c.$1, r + c.$2)).toList();
    } else {
      return rotations[ri].map((c) => (d + c.$1, r + c.$2)).toList();
    }
  }

  int torque(int ri, int d) =>
      cells(ri, d).fold(0, (s, c) => s + c.$1);
}

// ─────────────────────────────────────────────────────────────
// 6개 카드 데이터
// ─────────────────────────────────────────────────────────────
const _kCards = <_CardDef>[
  // ① I자
  _CardDef(
    name: 'I자',
    color: Color(0xFF1E88E5),
    rotations: [
      [(0, 0), (1, 0), (2, 0), (3, 0)], // 가로
      [(0, 0), (0, 1), (0, 2), (0, 3)], // 세로
    ],
    rotationLabels: ['가로', '세로'],
    leftPresets: [(0, 1), (1, 3)],
  ),
  // ② L자
  _CardDef(
    name: 'L자',
    color: Color(0xFFFB8C00),
    rotations: [
      [(0, 0), (0, 1), (0, 2), (1, 2)], // 0°
      [(0, 0), (1, 0), (2, 0), (0, 1)], // 90°
      [(0, 0), (1, 0), (1, 1), (1, 2)], // 180°
      [(2, 0), (0, 1), (1, 1), (2, 1)], // 270°
    ],
    rotationLabels: ['0°', '90°', '180°', '270°'],
    leftPresets: [(0, 1), (1, 2)],
  ),
  // ③ S자
  _CardDef(
    name: 'S자',
    color: Color(0xFF43A047),
    rotations: [
      [(1, 0), (2, 0), (0, 1), (1, 1)], // 가로
      [(0, 0), (0, 1), (1, 1), (1, 2)], // 세로
    ],
    rotationLabels: ['가로', '세로'],
    leftPresets: [(0, 1), (1, 2)],
  ),
  // ④ 2×2 사각형
  _CardDef(
    name: '2×2',
    color: Color(0xFFD81B60),
    rotations: [
      [(0, 0), (1, 0), (0, 1), (1, 1)],
    ],
    rotationLabels: ['기본'],
    leftPresets: [(0, 2), (0, 3)],
  ),
  // ⑤ T자
  _CardDef(
    name: 'T자',
    color: Color(0xFF9C27B0),
    rotations: [
      [(0, 0), (1, 0), (2, 0), (1, 1)], // 0°
      [(1, 0), (0, 1), (1, 1), (1, 2)], // 90°
      [(1, 0), (0, 1), (1, 1), (2, 1)], // 180°
      [(0, 0), (0, 1), (1, 1), (0, 2)], // 270°
    ],
    rotationLabels: ['0°', '90°', '180°', '270°'],
    leftPresets: [],
  ),
  // ⑥ Z자
  _CardDef(
    name: 'Z자',
    color: Color(0xFF00ACC1),
    rotations: [
      [(0, 0), (1, 0), (1, 1), (2, 1)], // 가로
      [(1, 0), (0, 1), (1, 1), (0, 2)], // 세로
    ],
    rotationLabels: ['가로', '세로'],
    leftPresets: [],
  ),
];

// ═══════════════════════════════════════════════════════════════
// SeesawPuzzleScreen
// ═══════════════════════════════════════════════════════════════

class SeesawPuzzleScreen extends StatefulWidget {
  final String completedRouteName;
  const SeesawPuzzleScreen({super.key, required this.completedRouteName});

  @override
  State<SeesawPuzzleScreen> createState() => _SeesawState();
}

class _SeesawState extends State<SeesawPuzzleScreen>
    with SingleTickerProviderStateMixin {
  // ── 상태 ──────────────────────────────────────────
  int? _leftIdx;
  int _leftRot = 0;
  int _leftDist = 1;
  int _leftStartRow = 1;
  bool _leftPlaced = false;
  int _leftVisibleCells = 0;
  Timer? _leftTimer;

  int? _rightIdx;
  int _rightRot = 0;
  int _rightDist = 1;
  int _rightStartRow = 1;
  bool _rightPlaced = false;
  int _rightVisibleCells = 0;
  Timer? _rightTimer;

  int? _hoverLeftIdx;
  int? _hoverLeftDist;
  int? _hoverLeftStartRow;
  int? _hoverRightIdx;
  int? _hoverRightDist;
  int? _hoverRightStartRow;

  bool? _result; // null=미확인, true=정답, false=오답

  // 시소 기울기 애니메이션용
  late final AnimationController _seesawCtrl;
  late Animation<double> _seesawAnim;
  double _prevTilt = 0;

  int _getDragRotation(_CardDef card, bool isLeftSideTarget) {
    final cardIndex = _kCards.indexOf(card);
    if (isLeftSideTarget) {
      if (_leftIdx == cardIndex) {
        return _leftRot;
      }
      return 0;
    } else {
      if (_rightIdx == cardIndex) {
        return _rightRot;
      }
      return 0;
    }
  }

  (int, int)? _findValidAnchor(_CardDef card, int dragRot, int d, int row, bool isLeft) {
    final cells = card.rotations[dragRot];
    final mc = card._maxCol(dragRot);
    for (final c in cells) {
      int startDist;
      if (isLeft) {
        startDist = d - mc + c.$1;
      } else {
        startDist = d - c.$1;
      }
      final startRow = row - c.$2;
      if (card.isValidAt(dragRot, startDist, r: startRow)) {
        return (startDist, startRow);
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _seesawCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _seesawAnim = const AlwaysStoppedAnimation(0);
    AppBgmController.playProblem();

    _leftIdx = null;
    _leftPlaced = false;
    _leftRot = 0;
    _leftDist = 1;
    _leftStartRow = 1;
    _leftVisibleCells = 0;

    _rightIdx = null;
    _rightPlaced = false;
    _rightRot = 0;
    _rightDist = 1;
    _rightStartRow = 1;
    _rightVisibleCells = 0;
  }

  @override
  void dispose() {
    _leftTimer?.cancel();
    _rightTimer?.cancel();
    _seesawCtrl.dispose();
    super.dispose();
  }

  // ── 계산값 ─────────────────────────────────────────
  List<_Abs> get _leftCells {
    if (_leftIdx == null) return const [];
    return _kCards[_leftIdx!].cells(_leftRot, _leftDist, r: _leftStartRow, isLeft: true);
  }

  int get _leftTorque {
    if (_leftIdx == null || !_leftPlaced) return 0;
    int torque = 0;
    for (int i = 0; i < math.min(_leftVisibleCells, _leftCells.length); i++) {
      torque += _leftCells[i].$1;
    }
    return torque;
  }

  List<_Abs> get _rightCells {
    if (_rightIdx == null) return const [];
    return _kCards[_rightIdx!].cells(_rightRot, _rightDist, r: _rightStartRow);
  }

  int get _rightTorque {
    if (_rightIdx == null || !_rightPlaced) return 0;
    int torque = 0;
    for (int i = 0; i < math.min(_rightVisibleCells, _rightCells.length); i++) {
      torque += _rightCells[i].$1;
    }
    return torque;
  }

  void _animateSeesaw() {
    final diff = (_leftTorque - _rightTorque).toDouble();
    final target = (diff / 20.0 * 0.20).clamp(-0.20, 0.20);
    _seesawAnim = Tween<double>(begin: _prevTilt, end: target).animate(
      CurvedAnimation(parent: _seesawCtrl, curve: Curves.easeInOut),
    );
    _prevTilt = target;
    _seesawCtrl.forward(from: 0);
  }

  // ── 액션 ──────────────────────────────────────────
  void _startLeftPlacementAnimation() {
    _leftTimer?.cancel();
    setState(() {
      _leftVisibleCells = 0;
    });
    int total = _leftCells.length;
    _leftTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _leftVisibleCells++;
        if (_leftVisibleCells >= total) {
          timer.cancel();
        }
      });
      _animateSeesaw();
    });
  }

  void _startRightPlacementAnimation() {
    _rightTimer?.cancel();
    setState(() {
      _rightVisibleCells = 0;
    });
    int total = _rightCells.length;
    _rightTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _rightVisibleCells++;
        if (_rightVisibleCells >= total) {
          timer.cancel();
        }
      });
      _animateSeesaw();
    });
  }

  void _rotateLeft() {
    if (_leftIdx == null || !_leftPlaced) return;
    final card = _kCards[_leftIdx!];
    int nextRot = (_leftRot + 1) % card.rotCount;
    int dist = _leftDist;
    int startRow = _leftStartRow;
    if (!card.isValidAt(nextRot, dist, r: startRow)) {
      final mc = card._maxCol(nextRot);
      final mr = card._maxRow(nextRot);
      dist = dist.clamp(1, 5 - mc);
      startRow = startRow.clamp(1, 4 - mr);
      if (!card.isValidAt(nextRot, dist, r: startRow)) {
        dist = 1;
        startRow = 1;
      }
    }
    HapticFeedback.lightImpact();
    AppSfxController.playClick();
    setState(() {
      _leftRot = nextRot;
      _leftDist = dist;
      _leftStartRow = startRow;
      _leftVisibleCells = card.rotations[nextRot].length;
    });
    _animateSeesaw();
  }

  void _rotateRight() {
    if (_rightIdx == null || !_rightPlaced) return;
    final card = _kCards[_rightIdx!];
    int nextRot = (_rightRot + 1) % card.rotCount;
    int dist = _rightDist;
    int startRow = _rightStartRow;
    if (!card.isValidAt(nextRot, dist, r: startRow)) {
      final mc = card._maxCol(nextRot);
      final mr = card._maxRow(nextRot);
      dist = dist.clamp(1, 5 - mc);
      startRow = startRow.clamp(1, 4 - mr);
      if (!card.isValidAt(nextRot, dist, r: startRow)) {
        dist = 1;
        startRow = 1;
      }
    }
    HapticFeedback.lightImpact();
    AppSfxController.playClick();
    setState(() {
      _rightRot = nextRot;
      _rightDist = dist;
      _rightStartRow = startRow;
      _rightVisibleCells = card.rotations[nextRot].length;
    });
    _animateSeesaw();
  }

  void _undoGhost() {
    HapticFeedback.lightImpact();
    AppSfxController.playClick();
    setState(() {
      _rightIdx = null;
      _rightPlaced = false;
      _result = null;
    });
    _animateSeesaw();
  }

  void _check() {
    if (!_leftPlaced || !_rightPlaced) return;
    HapticFeedback.heavyImpact();

    final correct = _leftTorque == _rightTorque;
    setState(() => _result = correct);

    if (correct) {
      AppSfxController.playCorrect();
      _showSuccessDialog();
    } else {
      AppSfxController.playWrong();
      _showTryAgainDialog();
    }
  }

  void _reset() {
    AppSfxController.playClick();
    setState(() {
      _leftIdx = null;
      _leftPlaced = false;
      _leftRot = 0;
      _leftDist = 1;
      _leftStartRow = 1;
      _leftVisibleCells = 0;

      _rightIdx = null;
      _rightPlaced = false;
      _rightRot = 0;
      _rightDist = 1;
      _rightStartRow = 1;
      _rightVisibleCells = 0;

      _result = null;
      _hoverLeftIdx = null;
      _hoverLeftDist = null;
      _hoverLeftStartRow = null;
      _hoverRightIdx = null;
      _hoverRightDist = null;
      _hoverRightStartRow = null;
    });
    _leftTimer?.cancel();
    _rightTimer?.cancel();
    _animateSeesaw();
  }

  // ── 정답/오답 팝업 대화상자 ────────────────────────────────
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Image.asset(
                  'assets/images/chr_play_correct.png',
                  height: 180,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '🎉 정답입니다! 🎉',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF13968F),
                  fontFamily: 'GangwonEduAll',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '양쪽 시소의 균형이 아주 잘 맞아요!\n정말 훌륭해요!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4B5563),
                  height: 1.3,
                  fontFamily: 'GangwonEduAll',
                ),
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, widget.completedRouteName);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF133E97),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTryAgainDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Image.asset(
                  'assets/images/chr_how_fail.png',
                  height: 180,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '아직 균형이 맞지 않아요!',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFD64A45),
                  fontFamily: 'GangwonEduAll',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '다시 한번 올려볼까요?\n위치와 방향을 잘 어림해 보세요!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4B5563),
                  height: 1.3,
                  fontFamily: 'GangwonEduAll',
                ),
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD64A45),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '다시 해보기',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHint() {
    AppSfxController.playClick();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '💡 힌트',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF6F63D1),
                  fontFamily: 'GangwonEduAll',
                ),
              ),
              const SizedBox(height: 20),
              Image.asset(
                'assets/images/chr_play_idea.png',
                height: 160,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              const Text(
                '도형이 차지하고 있는 칸이 나타내는 숫자는 모두 얼마인지 생각해보세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF091F59),
                  height: 1.4,
                  fontFamily: 'GangwonEduAll',
                ),
              ),
              const SizedBox(height: 26),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  '확인',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6F63D1),
                    fontFamily: 'GangwonEduAll',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 빌드 ───────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isMobile = mq.size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      appBar: _appBar(),
      body: SafeArea(
        child: Column(
          children: [
            // 상단 주황색 테두리 데코 바
            Container(
              width: double.infinity,
              height: 14,
              decoration: const BoxDecoration(
                color: Color(0xFFF6B51E),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
              ),
            ),
            // 문제 안내 영역 (상세 지시문 및 서브 가이드 보강)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(8, 12, 8, 8),
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                border: Border.all(color: const Color(0xFFDDE3F0), width: 1.5),
              ),
              child: Column(
                children: [
                  Text(
                    '문제: 시소가 균형을 이루도록 도형을 움직여 보세요',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 25,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF091F59),
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '(가이드: 도형을 드래그하여 시소 위에 올려놓은 후, 올려진 도형을 탭하면 90도씩 회전시킬 수 있습니다.)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isMobile ? 12.0 : 14.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            // 본문 영역: 가로 분할 구조 (기존 브릭 퍼즐 스타일 매칭)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double availWidth = constraints.maxWidth;
                    final double storageWidth = availWidth * 0.28;
                    final double gameAreaWidth = availWidth * 0.70;

                    // 우측 시소/그리드 영역을 위한 셀 크기 계산 (가로 세로 비율 모두 반영하여 화면 넘침 방지)
                    final double cellSzWidth = gameAreaWidth / 12.5;
                    final double cellSzHeight = (constraints.maxHeight - 190) / 4.8;
                    final double cellSz = math.min(cellSzWidth, cellSzHeight).clamp(28.0, 48.0);
                    final double gap = cellSz * 0.13;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // [왼쪽] 도형 보관함 (28% 너비)
                        SizedBox(
                          width: storageWidth,
                          child: _buildStorage(storageWidth, isMobile, cellSz),
                        ),
                        SizedBox(width: availWidth * 0.02),
                        // [오른쪽] 시소 및 5x5 그리드 보드 (70% 너비)
                        Expanded(
                          child: Column(
                            children: [
                              _seesawWidget(gameAreaWidth, cellSz, gap),
                              const SizedBox(height: 6),
                              Expanded(child: _grid(cellSz, gap, isMobile)),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            _bottomBar(mq),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────── AppBar

  PreferredSizeWidget _appBar() => AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF163988),
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 38),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          '미션! 수학체험센터의 반짝별을 찾아서',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24),
        ),
        actions: [
          const BgmToggleButton(iconSize: 40),
          IconButton(
            icon: const Icon(Icons.home_rounded, size: 44),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            ),
          ),
        ],
      );

  // ─────────────────────────────── 좌측 세로 도형 보관함

  Widget _buildStorage(double width, bool isMobile, double cellSz) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFF4C430), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: 1.25,
              ),
              itemCount: _kCards.length,
              itemBuilder: (context, i) {
                final card = _kCards[i];
                final isUsed = (_leftPlaced && _leftIdx == i) || (_rightPlaced && _rightIdx == i);

                // 2열 격자에서의 각 타일 대략적인 너비
                final double tileSize = (width - 28) / 2;

                // 드래그 대상 빌드
                Widget cardTile = _storageCardTile(i, tileSize, isUsed);

                if (isUsed) {
                  return cardTile; // 드래그 불가능 (잠금 상태)
                }

                return Draggable<_CardDef>(
                  data: card,
                  maxSimultaneousDrags: 1,
                  feedback: Material(
                    color: Colors.transparent,
                    child: Opacity(
                      opacity: 0.75,
                      child: Builder(
                        builder: (context) {
                          final maxC = card.rotations[0].map((c) => c.$1).reduce(math.max) + 1;
                          final maxR = card.rotations[0].map((c) => c.$2).reduce(math.max) + 1;
                          return SizedBox(
                            width: cellSz * maxC,
                            height: cellSz * maxR,
                            child: CustomPaint(
                              painter: _MiniShapePainter(
                                cells: card.rotations[0],
                                color: card.color,
                                fixedCellSize: cellSz,
                              ),
                            ),
                          );
                        }
                      ),
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.4,
                    child: cardTile,
                  ),
                  onDragEnd: (_) {
                    setState(() {
                      _hoverLeftIdx = null;
                      _hoverLeftDist = null;
                      _hoverRightIdx = null;
                      _hoverRightDist = null;
                    });
                  },
                  child: cardTile,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _storageCardTile(int idx, double tileSize, bool isUsed) {
    final card = _kCards[idx];

    return Container(
      width: tileSize,
      height: tileSize * 0.78,
      decoration: BoxDecoration(
        color: isUsed
            ? Colors.black.withAlpha(100)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUsed
              ? Colors.black26
              : card.color,
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(6),
            child: Center(
              child: CustomPaint(
                size: Size.square(tileSize * 0.55),
                painter: _MiniShapePainter(
                  cells: card.rotations[0],
                  color: isUsed
                      ? card.color.withValues(alpha: 0.3)
                      : card.color,
                ),
              ),
            ),
          ),
          if (isUsed)
            Center(
              child: Icon(Icons.lock_rounded,
                  color: Colors.white.withAlpha(180), size: tileSize * 0.28)),
        ],
      ),
    );
  }



  // ─────────────────────────────── 시소 애니메이션

  Widget _seesawWidget(double screenW, double cellSz, double gap) {
    return SizedBox(
      height: 74,
      width: screenW,
      child: AnimatedBuilder(
        animation: _seesawAnim,
        builder: (context, child) => CustomPaint(
          painter: _SeesawPainter(
            tilt: _seesawAnim.value,
            balanced: _result == true,
            cellSz: cellSz,
            gap: gap,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────── 그리드

  Widget _grid(double cellSz, double gap, bool isMobile) {
    return Column(
      children: [
        _distRow(cellSz, gap),
        const SizedBox(height: 4),
        for (int r = 1; r <= 4; r++)
          Padding(
            padding: EdgeInsets.only(bottom: gap),
            child: _gridRow(r, cellSz, gap),
          ),
        const SizedBox(height: 4),
        _distRow(cellSz, gap),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4C3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFCDDC39), width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                '왼쪽 기울기: $_leftTorque',
                style: TextStyle(
                  fontSize: isMobile ? 13 : 15,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF163988),
                ),
              ),
              const SizedBox(
                height: 14,
                child: VerticalDivider(
                  color: Color(0xFFCDDC39),
                  width: 16,
                  thickness: 1.5,
                ),
              ),
              Text(
                '오른쪽 기울기: ${_rightPlaced ? _rightTorque : 0}',
                style: TextStyle(
                  fontSize: isMobile ? 13 : 15,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF163988),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _distRow(double sz, double gap) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int d = 5; d >= 1; d--)
            _dLabel('$d', sz, gap),
          _pivotLabel(sz, gap),
          for (int d = 1; d <= 5; d++)
            _dLabel('$d', sz, gap),
        ],
      );

  Widget _dLabel(String t, double sz, double gap) => SizedBox(
        width: sz + gap,
        child: Text(t,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF3949AB))),
      );

  Widget _pivotLabel(double sz, double gap) => SizedBox(
        width: sz * 0.65 + gap * 2,
        child: const Text('0',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1A237E))),
      );

  Widget _gridRow(int row, double sz, double gap) {
    final activeLeftCells = _leftIdx != null && _leftPlaced
        ? _kCards[_leftIdx!].cells(_leftRot, _leftDist, r: _leftStartRow, isLeft: true).take(_leftVisibleCells).toSet()
        : <_Abs>{};

    final activeRightCells = _rightIdx != null && _rightPlaced
        ? _kCards[_rightIdx!].cells(_rightRot, _rightDist, r: _rightStartRow).take(_rightVisibleCells).toSet()
        : <_Abs>{};

    final dragRotLeft = _hoverLeftIdx != null ? _getDragRotation(_kCards[_hoverLeftIdx!], true) : 0;
    final hoverLeftCells = _hoverLeftIdx != null && _hoverLeftDist != null && _hoverLeftStartRow != null
        ? _kCards[_hoverLeftIdx!].cells(dragRotLeft, _hoverLeftDist!, r: _hoverLeftStartRow!, isLeft: true).toSet()
        : <_Abs>{};

    final dragRotRight = _hoverRightIdx != null ? _getDragRotation(_kCards[_hoverRightIdx!], false) : 0;
    final hoverRightCells = _hoverRightIdx != null && _hoverRightDist != null && _hoverRightStartRow != null
        ? _kCards[_hoverRightIdx!].cells(dragRotRight, _hoverRightDist!, r: _hoverRightStartRow!).toSet()
        : <_Abs>{};

    final leftColor = _leftIdx != null ? _kCards[_leftIdx!].color : Colors.grey;
    final rightColor = _rightIdx != null ? _kCards[_rightIdx!].color : Colors.grey;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 왼쪽: 거리 5→1
        for (int d = 5; d >= 1; d--)
          Padding(
            padding: EdgeInsets.only(right: gap),
            child: DragTarget<_CardDef>(
              onWillAcceptWithDetails: (details) {
                final card = details.data;
                final cardIndex = _kCards.indexOf(card);
                if (cardIndex == _rightIdx && _rightPlaced) return false;
                final dragRot = _getDragRotation(card, true);
                final anchor = _findValidAnchor(card, dragRot, d, row, true);
                if (anchor != null) {
                  setState(() {
                    _hoverLeftIdx = cardIndex;
                    _hoverLeftDist = anchor.$1;
                    _hoverLeftStartRow = anchor.$2;
                  });
                  return true;
                }
                return false;
              },
              onLeave: (data) {
                setState(() {
                  _hoverLeftIdx = null;
                  _hoverLeftDist = null;
                  _hoverLeftStartRow = null;
                });
              },
              onAcceptWithDetails: (details) {
                final card = details.data;
                final cardIndex = _kCards.indexOf(card);
                final dragRot = _getDragRotation(card, true);
                final anchor = _findValidAnchor(card, dragRot, d, row, true);
                if (anchor != null) {
                  setState(() {
                    _leftIdx = cardIndex;
                    _leftDist = anchor.$1;
                    _leftStartRow = anchor.$2;
                    _leftRot = dragRot;
                    _leftPlaced = true;
                    _result = null;
                    _hoverLeftIdx = null;
                    _hoverLeftDist = null;
                    _hoverLeftStartRow = null;
                  });
                  _startLeftPlacementAnimation();
                  _animateSeesaw();
                }
              },
              builder: (context, candidateData, rejectedData) {
                final isHover = hoverLeftCells.any((c) => c.$1 == d && c.$2 == row);
                final isPlaced = activeLeftCells.any((c) => c.$1 == d && c.$2 == row);
                final isOccupied = _leftPlaced && _kCards[_leftIdx!].cells(_leftRot, _leftDist, r: _leftStartRow, isLeft: true).any((c) => c.$1 == d && c.$2 == row);

                Widget cellWidget = _Cell(
                  size: sz,
                  hasWeight: isPlaced,
                  isGhost: false,
                  color: isHover ? _kCards[_hoverLeftIdx!].color : leftColor,
                  isHovering: isHover,
                );

                if (isOccupied) {
                  cellWidget = Draggable<_CardDef>(
                    data: _kCards[_leftIdx!],
                    maxSimultaneousDrags: 1,
                    feedback: Material(
                      color: Colors.transparent,
                      child: Opacity(
                        opacity: 0.7,
                        child: Builder(
                          builder: (context) {
                            final maxC = _kCards[_leftIdx!].rotations[_leftRot].map((c) => c.$1).reduce(math.max) + 1;
                            final maxR = _kCards[_leftIdx!].rotations[_leftRot].map((c) => c.$2).reduce(math.max) + 1;
                            return SizedBox(
                              width: sz * maxC,
                              height: sz * maxR,
                              child: CustomPaint(
                                painter: _MiniShapePainter(
                                  cells: _kCards[_leftIdx!].rotations[_leftRot],
                                  color: _kCards[_leftIdx!].color,
                                  fixedCellSize: sz,
                                ),
                              ),
                            );
                          }
                        ),
                      ),
                    ),
                    childWhenDragging: _Cell(
                      size: sz,
                      hasWeight: false,
                      isGhost: false,
                      color: Colors.grey.shade300,
                    ),
                    onDragStarted: () {
                      setState(() {
                        _leftPlaced = false;
                        _result = null;
                      });
                      _animateSeesaw();
                    },
                    onDragEnd: (details) {
                      setState(() {
                        if (!details.wasAccepted) {
                          _leftIdx = null;
                          _leftPlaced = false;
                        }
                        _hoverLeftIdx = null;
                        _hoverLeftDist = null;
                        _hoverLeftStartRow = null;
                        _hoverRightIdx = null;
                        _hoverRightDist = null;
                        _hoverRightStartRow = null;
                      });
                      _animateSeesaw();
                    },
                    child: GestureDetector(
                      onTap: _rotateLeft,
                      child: cellWidget,
                    ),
                  );
                }

                return cellWidget;
              },
            ),
          ),
        // 중심 기둥
        SizedBox(
          width: sz * 0.65 + gap * 2,
          height: sz,
          child: Center(
            child: Container(
              width: 5,
              height: sz * 1.2,
              decoration: BoxDecoration(
                color: const Color(0xFF1A237E),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        // 오른쪽: 거리 1→5 (드래그앤드롭 및 탭 회전 처리 영역)
        for (int d = 1; d <= 5; d++)
          Padding(
            padding: EdgeInsets.only(right: d < 5 ? gap : 0),
            child: DragTarget<_CardDef>(
              onWillAcceptWithDetails: (details) {
                final card = details.data;
                final cardIndex = _kCards.indexOf(card);
                if (cardIndex == _leftIdx && _leftPlaced) return false;
                final dragRot = _getDragRotation(card, false);
                final anchor = _findValidAnchor(card, dragRot, d, row, false);
                if (anchor != null) {
                  setState(() {
                    _hoverRightIdx = cardIndex;
                    _hoverRightDist = anchor.$1;
                    _hoverRightStartRow = anchor.$2;
                  });
                  return true;
                }
                return false;
              },
              onLeave: (data) {
                setState(() {
                  _hoverRightIdx = null;
                  _hoverRightDist = null;
                  _hoverRightStartRow = null;
                });
              },
              onAcceptWithDetails: (details) {
                final card = details.data;
                final cardIndex = _kCards.indexOf(card);
                final dragRot = _getDragRotation(card, false);
                final anchor = _findValidAnchor(card, dragRot, d, row, false);
                if (anchor != null) {
                  setState(() {
                    _rightIdx = cardIndex;
                    _rightDist = anchor.$1;
                    _rightStartRow = anchor.$2;
                    _rightRot = dragRot;
                    _rightPlaced = true;
                    _result = null;
                    _hoverRightIdx = null;
                    _hoverRightDist = null;
                    _hoverRightStartRow = null;
                  });
                  _startRightPlacementAnimation();
                  _animateSeesaw();
                }
              },
              builder: (context, candidateData, rejectedData) {
                final isHover = hoverRightCells.any((c) => c.$1 == d && c.$2 == row);
                final isPlaced = activeRightCells.any((c) => c.$1 == d && c.$2 == row);
                final isOccupied = _rightPlaced && _kCards[_rightIdx!].cells(_rightRot, _rightDist, r: _rightStartRow).any((c) => c.$1 == d && c.$2 == row);

                Widget cellWidget = _Cell(
                  size: sz,
                  hasWeight: isPlaced,
                  isGhost: false,
                  color: isHover ? _kCards[_hoverRightIdx!].color : rightColor,
                  isHovering: isHover,
                );

                if (isOccupied) {
                  cellWidget = Draggable<_CardDef>(
                    data: _kCards[_rightIdx!],
                    maxSimultaneousDrags: 1,
                    feedback: Material(
                      color: Colors.transparent,
                      child: Opacity(
                        opacity: 0.7,
                        child: Builder(
                          builder: (context) {
                            final maxC = _kCards[_rightIdx!].rotations[_rightRot].map((c) => c.$1).reduce(math.max) + 1;
                            final maxR = _kCards[_rightIdx!].rotations[_rightRot].map((c) => c.$2).reduce(math.max) + 1;
                            return SizedBox(
                              width: sz * maxC,
                              height: sz * maxR,
                              child: CustomPaint(
                                painter: _MiniShapePainter(
                                  cells: _kCards[_rightIdx!].rotations[_rightRot],
                                  color: _kCards[_rightIdx!].color,
                                  fixedCellSize: sz,
                                ),
                              ),
                            );
                          }
                        ),
                      ),
                    ),
                    childWhenDragging: _Cell(
                      size: sz,
                      hasWeight: false,
                      isGhost: false,
                      color: Colors.grey.shade300,
                    ),
                    onDragStarted: () {
                      setState(() {
                        _rightPlaced = false;
                        _result = null;
                      });
                      _animateSeesaw();
                    },
                    onDragEnd: (details) {
                      setState(() {
                        if (!details.wasAccepted) {
                          _rightIdx = null;
                          _rightPlaced = false;
                        }
                        _hoverLeftIdx = null;
                        _hoverLeftDist = null;
                        _hoverLeftStartRow = null;
                        _hoverRightIdx = null;
                        _hoverRightDist = null;
                        _hoverRightStartRow = null;
                      });
                      _animateSeesaw();
                    },
                    child: GestureDetector(
                      onTap: _rotateRight,
                      child: cellWidget,
                    ),
                  );
                }

                return cellWidget;
              },
            ),
          ),
      ],
    );
  }

  // ─────────────────────────────── 하단 바 (토크 텍스트 삭제 및 버튼 일치)

  Widget _bottomBar(MediaQueryData mq) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE1E1E4), width: 1)),
      ),
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + mq.padding.bottom),
      child: Row(
        children: [
          // 기존 토크 표시(왼쪽 하단)는 요구에 따라 전면 삭제됨
          const Spacer(),
          if (kDebugMode) ...[
            OutlinedButton.icon(
              onPressed: () => Navigator.pushReplacementNamed(context, widget.completedRouteName),
              icon: const Icon(Icons.skip_next_rounded, size: 20),
              label: const Text(
                '테스트용 스킵',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF355AA8),
                side: const BorderSide(color: Color(0xFF5C7EC5), width: 2),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          // 버튼 정렬 (기존 브릭 퍼즐 버튼 구성 매칭)
          OutlinedButton.icon(
            onPressed: _showHint,
            icon: const Icon(Icons.lightbulb_outline, size: 20),
            label: const Text(
              '힌트',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6F63D1),
              side: const BorderSide(color: Color(0xFF6F63D1), width: 2),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.refresh, size: 20),
            label: const Text(
              '다시하기',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8A8A8A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (_result == true)
            ElevatedButton.icon(
              icon: const Icon(Icons.check_circle, size: 20),
              label: const Text(
                '다음으로',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              onPressed: () => Navigator.pushReplacementNamed(
                  context, widget.completedRouteName),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF123E97),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          else ...[
            if (_rightPlaced) ...[
              ElevatedButton.icon(
                icon: const Icon(Icons.undo, size: 20),
                label: const Text(
                  '취소',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                onPressed: _undoGhost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8EAF6),
                  foregroundColor: const Color(0xFF1A237E),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            ElevatedButton.icon(
              icon: const Icon(Icons.check_circle, size: 20),
              label: const Text(
                '정답 확인',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              onPressed: (_leftPlaced && _rightPlaced) ? _check : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF123E97),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 재사용 위젯
// ═══════════════════════════════════════════════════════════════

class _Cell extends StatelessWidget {
  final double size;
  final bool hasWeight;
  final bool isGhost;
  final Color color;
  final bool isHovering;

  const _Cell({
    required this.size,
    required this.hasWeight,
    required this.isGhost,
    required this.color,
    this.isHovering = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: hasWeight
            ? color
            : isHovering
                ? color.withValues(alpha: 0.25)
                : const Color(0xFFCFD8DC),
        border: Border.all(
          color: hasWeight
              ? color.withValues(alpha: 0.9)
              : isHovering
                  ? color.withValues(alpha: 0.8)
                  : const Color(0xFFB0BEC5),
          width: hasWeight || isHovering ? 2.5 : 1.2,
        ),
        boxShadow: hasWeight
            ? [
                BoxShadow(
                    color: color.withValues(alpha: 0.45),
                    blurRadius: 5,
                    offset: const Offset(0, 2))
              ]
            : null,
      ),
      child: hasWeight
          ? Center(
              child: Container(
                width: size * 0.4,
                height: size * 0.4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.38),
                ),
              ),
            )
          : null,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CustomPainters
// ═══════════════════════════════════════════════════════════════

/// 카드 썸네일용 미니 도형 그리기
class _MiniShapePainter extends CustomPainter {
  final List<_Rel> cells;
  final Color color;
  final double? fixedCellSize;

  const _MiniShapePainter({
    required this.cells,
    required this.color,
    this.fixedCellSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (cells.isEmpty) return;
    final maxC = cells.map((c) => c.$1).reduce(math.max) + 1;
    final maxR = cells.map((c) => c.$2).reduce(math.max) + 1;
    final cs = fixedCellSize ?? (math.min(size.width / maxC, size.height / maxR) * 0.84);
    final ox = (size.width - maxC * cs) / 2;
    final oy = (size.height - maxR * cs) / 2;
    final paint = Paint()..color = color;
    for (final c in cells) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
              ox + c.$1 * cs + 1, oy + c.$2 * cs + 1, cs - 2, cs - 2),
          const Radius.circular(4),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_MiniShapePainter old) =>
      old.color != color || old.fixedCellSize != fixedCellSize;
}

/// 시소 빔 그리기
class _SeesawPainter extends CustomPainter {
  final double tilt;
  final bool balanced;
  final double cellSz;
  final double gap;

  const _SeesawPainter({
    required this.tilt,
    required this.balanced,
    required this.cellSz,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.52;

    // 받침점 삼각형
    final pivotPaint = Paint()..color = const Color(0xFF1A237E);
    canvas.drawPath(
      Path()
        ..moveTo(cx, cy + 8)
        ..lineTo(cx - 18, cy + 28)
        ..lineTo(cx + 18, cy + 28)
        ..close(),
      pivotPaint,
    );
    // 받침대
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, cy + 32), width: 72, height: 8),
        const Radius.circular(4),
      ),
      pivotPaint,
    );

    // 빔 회전
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(tilt);

    // 아래 숫자판 5번 셀 중심의 정확한 X좌표 계산 (중앙 0 기준)
    final endCircleX = 4.825 * cellSz + 5 * gap;
    final beamLen = endCircleX * 2 + 20; // 양옆에 10씩 마진 확보

    // 빔 몸체
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset.zero, width: beamLen, height: 14),
        const Radius.circular(7),
      ),
      Paint()..color = const Color(0xFF8D6E63),
    );

    // 빔 하이라이트
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: const Offset(0, -3), width: beamLen - 12, height: 5),
        const Radius.circular(3),
      ),
      Paint()..color = Colors.white.withAlpha(60),
    );

    // 양쪽 끝 원
    final endColor =
        balanced ? const Color(0xFF2E7D32) : const Color(0xFF3949AB);
    for (final sign in [-1.0, 1.0]) {
      canvas.drawCircle(
        Offset(sign * endCircleX, 0),
        13,
        Paint()..color = endColor,
      );
      canvas.drawCircle(
        Offset(sign * endCircleX, -3),
        5,
        Paint()..color = Colors.white.withAlpha(80),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SeesawPainter o) =>
      o.tilt != tilt ||
      o.balanced != balanced ||
      o.cellSz != cellSz ||
      o.gap != gap;
}
