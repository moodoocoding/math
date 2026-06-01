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

  int torque(int ri, int d) => cells(ri, d).fold(0, (s, c) => s + c.$1);
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

  (int, int)? _findValidAnchor(
    _CardDef card,
    int dragRot,
    int d,
    int row,
    bool isLeft,
  ) {
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
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showOnboardingTutorial();
    });
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
    return _kCards[_leftIdx!].cells(
      _leftRot,
      _leftDist,
      r: _leftStartRow,
      isLeft: true,
    );
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

  String get _leftFormulaText {
    if (_leftIdx == null || !_leftPlaced) return '0 점';
    final activeCount = math.min(_leftVisibleCells, _leftCells.length);
    if (activeCount == 0) return '0 점';
    final numbers = _leftCells.take(activeCount).map((c) => c.$1).toList();
    numbers.sort((a, b) => b.compareTo(a)); // 왼쪽부터 차례대로(큰 숫자부터) 정렬
    return '${numbers.join(' + ')} = $_leftTorque 점';
  }

  String get _rightFormulaText {
    if (_rightIdx == null || !_rightPlaced) return '0 점';
    final activeCount = math.min(_rightVisibleCells, _rightCells.length);
    if (activeCount == 0) return '0 점';
    final numbers = _rightCells.take(activeCount).map((c) => c.$1).toList();
    numbers.sort((a, b) => b.compareTo(a)); // 오른쪽도 큰 숫자부터 정렬
    return '${numbers.join(' + ')} = $_rightTorque 점';
  }

  void _animateSeesaw() {
    final diff = (_rightTorque - _leftTorque).toDouble();
    final target = (diff / 20.0 * 0.20).clamp(-0.20, 0.20);
    _seesawAnim = Tween<double>(
      begin: _prevTilt,
      end: target,
    ).animate(CurvedAnimation(parent: _seesawCtrl, curve: Curves.easeInOut));
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
                '🎉 균형의 빛이 켜졌어요! 🎉',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF13968F),
                  fontFamily: 'GangwonEduAll',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '양쪽 힘이 딱 맞았어요!\n시소 아래 장치가 열리고 있어요!',
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
                    Navigator.pushReplacementNamed(
                      context,
                      widget.completedRouteName,
                    );
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
                '아직 균형이 한쪽으로 기울었어요!',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFD64A45),
                  fontFamily: 'GangwonEduAll',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '도형이 놓인 자리의 힘을 다시 살펴볼까요?\n위치와 방향을 조금 바꿔 보세요!',
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
                    '다시 맞춰보기',
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

  Widget _buildSlide1Diagram() {
    return Container(
      height: 130,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBAC5E8), width: 1.5),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 시소 받침대와 빔
          Positioned(
            bottom: 26,
            child: Container(
              width: 320,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF8D6E63),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Positioned(
            bottom: 6,
            child: Container(
              width: 0,
              height: 0,
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(width: 14, color: Colors.transparent),
                  right: BorderSide(width: 14, color: Colors.transparent),
                  bottom: BorderSide(width: 22, color: Color(0xFF1A237E)),
                ),
              ),
            ),
          ),
          // 3번 위치에 배치된 세로 블록 (2칸으로 축소하여 3 + 3 = 6점 단순화!)
          Positioned(
            left: 111,
            bottom: 34,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                2,
                (index) => Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.only(bottom: 1.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E88E5),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ),
          ),
          // 왼쪽에 표시되는 4, 3, 2, 1 숫자 라벨들
          Positioned(
            left: 86,
            bottom: 8,
            child: const Text(
              '4',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF7986CB),
              ),
            ),
          ),
          Positioned(
            left: 119,
            bottom: 8,
            child: const Text(
              '3',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1A237E),
              ),
            ),
          ),
          Positioned(
            left: 152,
            bottom: 8,
            child: const Text(
              '2',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF7986CB),
              ),
            ),
          ),
          Positioned(
            left: 185,
            bottom: 8,
            child: const Text(
              '1',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF7986CB),
              ),
            ),
          ),
          // 점수 합산 말풍선 (3 + 3 = 6점)
          Positioned(
            right: 15,
            top: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1E88E5), width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                '3 + 3\n= 6 점! 🎉',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E88E5),
                  fontFamily: 'GangwonEduAll',
                ),
              ),
            ),
          ),
          // 지시선 화살표
          Positioned(
            left: 140,
            top: 48,
            child: const Icon(
              Icons.arrow_forward_rounded,
              color: Color(0xFF1E88E5),
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide2Diagram() {
    return Container(
      height: 130,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBAC5E8), width: 1.5),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 시소 받침대와 수평 빔
          Positioned(
            bottom: 26,
            child: Container(
              width: 320,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF8D6E63),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Positioned(
            bottom: 6,
            child: Container(
              width: 0,
              height: 0,
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(width: 14, color: Colors.transparent),
                  right: BorderSide(width: 14, color: Colors.transparent),
                  bottom: BorderSide(width: 22, color: Color(0xFF1A237E)),
                ),
              ),
            ),
          ),
          // 왼쪽 3번 칸의 보라색 T 블록 (4칸 = 12점)
          Positioned(
            left: 70,
            bottom: 34,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    3,
                    (index) => Container(
                      width: 14,
                      height: 14,
                      margin: const EdgeInsets.symmetric(horizontal: 0.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9C27B0),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF9C27B0),
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                ),
              ],
            ),
          ),
          // 오른쪽 3번 칸의 초록색 S 블록 (4칸 = 12점)
          Positioned(
            right: 70,
            bottom: 34,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 7),
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF43A047),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                    ),
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF43A047),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF43A047),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                    ),
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF43A047),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                    ),
                    const SizedBox(width: 7),
                  ],
                ),
              ],
            ),
          ),
          // 왼쪽 점수 & 오른쪽 점수 라벨
          Positioned(
            left: 45,
            top: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '왼쪽: 12점',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7B1FA2),
                ),
              ),
            ),
          ),
          Positioned(
            right: 45,
            top: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '오른쪽: 12점',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),
          ),
          // 수평 균형 마크
          const Positioned(
            top: 40,
            child: Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF2E7D32),
              size: 38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide3Diagram() {
    return Container(
      height: 130,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBAC5E8), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 0도 원래 모양 (L 블록)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '원래 모양 0°',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE65100),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    children: List.generate(
                      3,
                      (index) => Container(
                        width: 14,
                        height: 14,
                        margin: const EdgeInsets.only(bottom: 0.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFB8C00),
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(color: Colors.white, width: 0.8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 0.5),
                  Column(
                    children: [
                      const SizedBox(height: 29),
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFB8C00),
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(color: Colors.white, width: 0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // 탭하기 조작 화살표
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.touch_app_rounded,
                color: Color(0xFFFF4081),
                size: 32,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    '톡! 터치',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFF4081),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFFFF4081),
                    size: 14,
                  ),
                ],
              ),
            ],
          ),
          // 회전 후 모양 (90도 회전된 L 블록)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '돌아간 모양 90°',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE65100),
                ),
              ),
              const SizedBox(height: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      3,
                      (index) => Container(
                        width: 14,
                        height: 14,
                        margin: const EdgeInsets.only(right: 0.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFB8C00),
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(color: Colors.white, width: 0.8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 0.5),
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFB8C00),
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: Colors.white, width: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showOnboardingTutorial() {
    int tutorialStep = 0;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              width: 520,
              padding: const EdgeInsets.all(26),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '⚖️ 반짝별 시소 학교',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF133E97),
                          fontFamily: 'GangwonEduAll',
                        ),
                      ),
                      Text(
                        '${tutorialStep + 1} / 3',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20, thickness: 1.5),
                  const SizedBox(height: 12),
                  if (tutorialStep == 0) ...[
                    const Text(
                      '시소 칸 숫자의 비밀! 💡',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF091F59),
                        fontFamily: 'GangwonEduAll',
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      '시소 아래에 적힌 숫자(1~5)는 그 칸의 점수예요.\n도형 블록이 올라간 칸의 숫자를 모두 더하면\n나의 시소 점수가 된답니다!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4B5563),
                        height: 1.35,
                        fontFamily: 'GangwonEduAll',
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSlide1Diagram(),
                  ] else if (tutorialStep == 1) ...[
                    const Text(
                      '왼쪽 먼저, 오른쪽은 똑같이! 👈',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF091F59),
                        fontFamily: 'GangwonEduAll',
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      '1단계: 먼저 왼쪽에 아무 블록이나 올려서 점수를 만들어요.\n2단계: 오른쪽에 다른 블록을 올려서 왼쪽 점수와\n똑같은 점수를 만들면 성공이에요!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4B5563),
                        height: 1.4,
                        fontFamily: 'GangwonEduAll',
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSlide2Diagram(),
                  ] else ...[
                    const Text(
                      '블록을 톡! 터치해봐요! 🔄',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF091F59),
                        fontFamily: 'GangwonEduAll',
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      '블록을 올려놓은 후에 손가락으로 톡! 터치하면\n90도씩 빙글빙글 돌아가요!\n도형을 돌려서 올려놓는 칸을 바꿔 점수를 조절해 보세요.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4B5563),
                        height: 1.4,
                        fontFamily: 'GangwonEduAll',
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSlide3Diagram(),
                  ],
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (tutorialStep < 2) {
                          setDialogState(() {
                            tutorialStep++;
                          });
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF133E97),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        tutorialStep < 2 ? '다음' : '도전 시작하기! ⚖️',
                        style: const TextStyle(
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
          );
        },
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double availWidth = constraints.maxWidth;
                    final double availHeight = constraints.maxHeight;

                    // 가로 모드 여부 판단 (태블릿 가로 또는 모바일 가로)
                    final bool isLandscape =
                        mq.orientation == Orientation.landscape ||
                        availWidth > 750;

                    if (isLandscape) {
                      return _buildLandscapeLayout(
                        availWidth,
                        availHeight,
                        isMobile,
                        mq,
                      );
                    } else {
                      return _buildPortraitLayout(
                        availWidth,
                        availHeight,
                        isMobile,
                        mq,
                      );
                    }
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

  // ─────────────────────────────── 가로/세로 전용 레이아웃 위젯 빌더

  Widget _buildLandscapeLayout(
    double availWidth,
    double availHeight,
    bool isMobile,
    MediaQueryData mq,
  ) {
    // 2단 레이아웃: 좌측 단계/도구 패널은 고정 폭에 가깝게 잡고,
    // 남은 영역을 시소판에 몰아준다.
    final double sidebarWidth = (availWidth * 0.22).clamp(250.0, 330.0);
    final double gutter = (availWidth * 0.018).clamp(14.0, 24.0);
    final double gameAreaWidth = availWidth - sidebarWidth - gutter;

    // 셀 크기를 최대한 크게 계산 (사용 가능한 높이/너비에 맞춰)
    final double cellSzWidth = gameAreaWidth / 12.0;
    final double cellSzHeight = (availHeight - 142) / 4.8;
    final double cellSz = math.min(cellSzWidth, cellSzHeight).clamp(32.0, 72.0);
    final double gap = cellSz * 0.10;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // [좌측] 단계 가이드 + 도형 보관함
        SizedBox(
          width: sidebarWidth,
          child: _buildLeftSidebar(sidebarWidth, isMobile, true),
        ),
        SizedBox(width: gutter),
        // [우측] 균형 표시 + 좌우 점수 + 그리드
        Expanded(child: _buildBoardArea(gameAreaWidth, cellSz, gap, isMobile)),
      ],
    );
  }

  Widget _buildPortraitLayout(
    double availWidth,
    double availHeight,
    bool isMobile,
    MediaQueryData mq,
  ) {
    // 세로 모드: 단계 가이드 → 도형 보관함 → 시소 게임판
    final double storageHeight = availHeight * 0.27;

    final double cellSzWidth = availWidth / 12.5;
    final double cellSzHeight = (availHeight * 0.55 - 80) / 4.8;
    final double cellSz = math.min(cellSzWidth, cellSzHeight).clamp(26.0, 48.0);
    final double gap = cellSz * 0.10;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStageGuideCard(isMobile, false),
        const SizedBox(height: 8),
        SizedBox(
          height: storageHeight,
          width: double.infinity,
          child: _buildStorage(availWidth, isMobile),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _buildBoardArea(availWidth, cellSz, gap, isMobile),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeftSidebar(double width, bool isMobile, bool isLandscape) {
    return Column(
      children: [
        _buildStageGuideCard(isMobile, isLandscape),
        const SizedBox(height: 10),
        Expanded(child: _buildStorage(width, isMobile)),
      ],
    );
  }

  Widget _buildStageGuideCard(bool isMobile, bool isLandscape) {
    final int stage = !_leftPlaced ? 1 : (_leftPlaced && !_rightPlaced ? 2 : 3);

    Widget stageTile(int index, String title, String detail) {
      final bool active = stage == index;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFE9F0FF) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? const Color(0xFF1E4AA8) : const Color(0xFFD5DEF5),
            width: active ? 2 : 1.4,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: active
                  ? const Color(0xFF1E4AA8)
                  : const Color(0xFFB7C4EA),
              child: Text(
                '$index',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 13,
                      fontWeight: FontWeight.w900,
                      color: active
                          ? const Color(0xFF173D8F)
                          : const Color(0xFF44537C),
                    ),
                  ),
                  Text(
                    detail,
                    style: TextStyle(
                      fontSize: isMobile ? 10 : 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF5F6D8E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final steps = [
      stageTile(1, '1단계: 왼쪽 배치', '왼쪽에 첫 도형 놓기'),
      stageTile(2, '2단계: 오른쪽 배치', '오른쪽에 도형 배치'),
      stageTile(3, '3단계: 균형 확인', '두 점수가 같으면 성공'),
    ];

    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFC5D3F2), width: 2),
      ),
      child: isLandscape
          ? Column(
              children: [
                for (final s in steps)
                  Padding(padding: const EdgeInsets.only(bottom: 6), child: s),
              ],
            )
          : Row(
              children: [
                for (int i = 0; i < steps.length; i++)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i < 2 ? 6 : 0),
                      child: steps[i],
                    ),
                  ),
              ],
            ),
    );
  }

  String get _balanceStatusText {
    if (!_leftPlaced && !_rightPlaced) {
      return '왼쪽에 첫 도형을 놓아 보세요';
    }
    if (_leftPlaced && !_rightPlaced) {
      return '오른쪽에 도형을 놓아 왼쪽과 같은 점수를 만들어 보세요';
    }
    if (_leftTorque == _rightTorque) {
      return '양쪽 점수가 같아요';
    }
    return _leftTorque > _rightTorque ? '왼쪽이 더 무거워요' : '오른쪽이 더 무거워요';
  }

  Widget _buildBoardArea(
    double screenW,
    double cellSz,
    double gap,
    bool isMobile,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _seesawWidget(screenW, cellSz, gap),
        const SizedBox(height: 8),
        _buildSplitScoreRow(cellSz, gap, isMobile),
        const SizedBox(height: 8),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topCenter,
            child: _grid(cellSz, gap, isMobile),
          ),
        ),
        const SizedBox(height: 8),
        _buildBoardInstruction(isMobile),
      ],
    );
  }

  Widget _buildSplitScoreRow(double cellSz, double gap, bool isMobile) {
    final leftWidth = 5 * (cellSz + gap);
    final pivotWidth = cellSz * 0.65 + gap * 2;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: leftWidth,
          child: _scoreChip(
            title: '왼쪽',
            value: _leftFormulaText,
            color: const Color(0xFF1E88E5),
            isMobile: isMobile,
          ),
        ),
        SizedBox(width: pivotWidth),
        SizedBox(
          width: leftWidth,
          child: _scoreChip(
            title: '오른쪽',
            value: _rightPlaced ? _rightFormulaText : '0 점',
            color: const Color(0xFF13968F),
            isMobile: isMobile,
          ),
        ),
      ],
    );
  }

  Widget _scoreChip({
    required String title,
    required String value,
    required Color color,
    required bool isMobile,
  }) {
    return Container(
      height: isMobile ? 34 : 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.45), width: 1.6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              fontWeight: FontWeight.w900,
              color: color,
              fontFamily: 'GangwonEduAll',
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1A367C),
                fontFamily: 'GangwonEduAll',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoardInstruction(bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD7E0F5), width: 1.3),
      ),
      child: Text(
        _balanceStatusText,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: isMobile ? 12 : 14,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF29427A),
          fontFamily: 'GangwonEduAll',
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
      if (kDebugMode)
        IconButton(
          tooltip: '테스트용 스킵',
          icon: const Icon(Icons.skip_next_rounded, size: 40),
          onPressed: () => Navigator.pushReplacementNamed(
            context,
            widget.completedRouteName,
          ),
        ),
    ],
  );

  // ─────────────────────────────── 좌측 세로 도형 보관함

  Widget _buildStorage(double width, bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFBAC5E8), width: 2),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F1A367C),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 도형 선택 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.inventory_2_rounded,
                color: Color(0xFF133E97),
                size: 16,
              ),
              const SizedBox(width: 4),
              const Text(
                '도형 카드',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF133E97),
                  fontFamily: 'GangwonEduAll',
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(top: 4, bottom: 6),
            child: Text(
              '카드를 시소판으로 끌어 놓으세요',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4B5F86),
                fontFamily: 'GangwonEduAll',
              ),
            ),
          ),
          const Divider(height: 8, thickness: 1.2, color: Color(0xFFBAC5E8)),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double boxHeight = constraints.maxHeight;
                final double boxWidth = constraints.maxWidth;

                // Padding/Margin 보정
                final double netHeight = boxHeight - 2;
                final double netWidth = boxWidth - 2;

                // 2열 3행 그리드
                final double maxTileHeight = netHeight / 3;
                final double maxTileWidth = netWidth / 2;

                // 카드 크기 계산
                final double tileSize = math
                    .min(maxTileHeight * 1.22, maxTileWidth)
                    .clamp(54.0, 132.0);
                final double tileHeight = tileSize / 1.25;

                // GridView 크기
                final double gridWidth = tileSize * 2 + 4;
                final double gridHeight = tileHeight * 3 + 8;

                return Center(
                  child: SizedBox(
                    width: gridWidth.clamp(0.0, boxWidth),
                    height: gridHeight.clamp(0.0, boxHeight),
                    child: GridView.builder(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                            childAspectRatio: 1.25,
                          ),
                      itemCount: _kCards.length,
                      itemBuilder: (context, i) {
                        final card = _kCards[i];
                        final isUsed =
                            (_leftPlaced && _leftIdx == i) ||
                            (_rightPlaced && _rightIdx == i);

                        Widget cardTile = _storageCardTile(i, tileSize, isUsed);

                        if (isUsed) {
                          return cardTile;
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
                                  final maxC =
                                      card.rotations[0]
                                          .map((c) => c.$1)
                                          .reduce(math.max) +
                                      1;
                                  final maxR =
                                      card.rotations[0]
                                          .map((c) => c.$2)
                                          .reduce(math.max) +
                                      1;
                                  // 드래그 피드백 시에도 통일된 그리드 크기 유지
                                  final double feedbackCellSz = tileSize * 0.22;
                                  return SizedBox(
                                    width: feedbackCellSz * maxC,
                                    height: feedbackCellSz * maxR,
                                    child: CustomPaint(
                                      painter: _MiniShapePainter(
                                        cells: card.rotations[0],
                                        color: card.color,
                                        fixedCellSize: feedbackCellSz,
                                      ),
                                    ),
                                  );
                                },
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
                              _hoverLeftStartRow = null;
                              _hoverRightIdx = null;
                              _hoverRightDist = null;
                              _hoverRightStartRow = null;
                            });
                          },
                          child: cardTile,
                        );
                      },
                    ),
                  ),
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
    final double tileHeight = tileSize / 1.25;

    // 모든 카드 속 도형들의 두께를 완벽히 일치시키기 위한 고정 그리드 셀 크기 계산!
    // 타일 가로 크기(tileSize)의 약 16%를 한 셀의 크기로 설정합니다.
    final double cs = tileSize * 0.16;

    return Container(
      width: tileSize,
      height: tileHeight,
      decoration: BoxDecoration(
        color: isUsed ? Colors.black.withAlpha(100) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUsed ? Colors.black26 : card.color,
          width: 2,
        ),
        boxShadow: isUsed
            ? null
            : [
                BoxShadow(
                  color: card.color.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(6),
            child: Center(
              child: CustomPaint(
                size: Size(tileSize - 12, tileHeight - 12),
                painter: _MiniShapePainter(
                  cells: card.rotations[0],
                  color: isUsed
                      ? card.color.withValues(alpha: 0.3)
                      : card.color,
                  fixedCellSize: cs, // 고정 셀 크기 전달로 크기 불일치 및 왜곡 원천 차단!
                ),
              ),
            ),
          ),
          if (isUsed)
            Center(
              child: Icon(
                Icons.lock_rounded,
                color: Colors.white.withAlpha(180),
                size: tileSize * 0.26,
              ),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────── 시소 애니메이션

  Widget _seesawWidget(double screenW, double cellSz, double gap) {
    return SizedBox(
      height: 58,
      width: screenW,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFD7E0F5), width: 1.2),
        ),
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
      ],
    );
  }

  Widget _distRow(double sz, double gap) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      for (int d = 5; d >= 1; d--) _dLabel('$d', sz, gap),
      _pivotLabel(sz, gap),
      for (int d = 1; d <= 5; d++) _dLabel('$d', sz, gap),
    ],
  );

  Widget _dLabel(String t, double sz, double gap) => SizedBox(
    width: sz + gap,
    child: Text(
      t,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Color(0xFF3949AB),
      ),
    ),
  );

  Widget _pivotLabel(double sz, double gap) => SizedBox(
    width: sz * 0.65 + gap * 2,
    child: const Text(
      '0',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w900,
        color: Color(0xFF1A237E),
      ),
    ),
  );

  Widget _gridRow(int row, double sz, double gap) {
    final activeLeftCells = _leftIdx != null && _leftPlaced
        ? _kCards[_leftIdx!]
              .cells(_leftRot, _leftDist, r: _leftStartRow, isLeft: true)
              .take(_leftVisibleCells)
              .toSet()
        : <_Abs>{};

    final activeRightCells = _rightIdx != null && _rightPlaced
        ? _kCards[_rightIdx!]
              .cells(_rightRot, _rightDist, r: _rightStartRow)
              .take(_rightVisibleCells)
              .toSet()
        : <_Abs>{};

    final dragRotLeft = _hoverLeftIdx != null
        ? _getDragRotation(_kCards[_hoverLeftIdx!], true)
        : 0;
    final hoverLeftCells =
        _hoverLeftIdx != null &&
            _hoverLeftDist != null &&
            _hoverLeftStartRow != null
        ? _kCards[_hoverLeftIdx!]
              .cells(
                dragRotLeft,
                _hoverLeftDist!,
                r: _hoverLeftStartRow!,
                isLeft: true,
              )
              .toSet()
        : <_Abs>{};

    final dragRotRight = _hoverRightIdx != null
        ? _getDragRotation(_kCards[_hoverRightIdx!], false)
        : 0;
    final hoverRightCells =
        _hoverRightIdx != null &&
            _hoverRightDist != null &&
            _hoverRightStartRow != null
        ? _kCards[_hoverRightIdx!]
              .cells(dragRotRight, _hoverRightDist!, r: _hoverRightStartRow!)
              .toSet()
        : <_Abs>{};

    final leftColor = _leftIdx != null ? _kCards[_leftIdx!].color : Colors.grey;
    final rightColor = _rightIdx != null
        ? _kCards[_rightIdx!].color
        : Colors.grey;

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
                final isHover = hoverLeftCells.any(
                  (c) => c.$1 == d && c.$2 == row,
                );
                final isPlaced = activeLeftCells.any(
                  (c) => c.$1 == d && c.$2 == row,
                );
                final isOccupied =
                    _leftPlaced &&
                    _kCards[_leftIdx!]
                        .cells(
                          _leftRot,
                          _leftDist,
                          r: _leftStartRow,
                          isLeft: true,
                        )
                        .any((c) => c.$1 == d && c.$2 == row);

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
                            final maxC =
                                _kCards[_leftIdx!].rotations[_leftRot]
                                    .map((c) => c.$1)
                                    .reduce(math.max) +
                                1;
                            final maxR =
                                _kCards[_leftIdx!].rotations[_leftRot]
                                    .map((c) => c.$2)
                                    .reduce(math.max) +
                                1;
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
                          },
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
                final isHover = hoverRightCells.any(
                  (c) => c.$1 == d && c.$2 == row,
                );
                final isPlaced = activeRightCells.any(
                  (c) => c.$1 == d && c.$2 == row,
                );
                final isOccupied =
                    _rightPlaced &&
                    _kCards[_rightIdx!]
                        .cells(_rightRot, _rightDist, r: _rightStartRow)
                        .any((c) => c.$1 == d && c.$2 == row);

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
                            final maxC =
                                _kCards[_rightIdx!].rotations[_rightRot]
                                    .map((c) => c.$1)
                                    .reduce(math.max) +
                                1;
                            final maxR =
                                _kCards[_rightIdx!].rotations[_rightRot]
                                    .map((c) => c.$2)
                                    .reduce(math.max) +
                                1;
                            return SizedBox(
                              width: sz * maxC,
                              height: sz * maxR,
                              child: CustomPaint(
                                painter: _MiniShapePainter(
                                  cells:
                                      _kCards[_rightIdx!].rotations[_rightRot],
                                  color: _kCards[_rightIdx!].color,
                                  fixedCellSize: sz,
                                ),
                              ),
                            );
                          },
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
                context,
                widget.completedRouteName,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF123E97),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
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
                '균형 확인',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              onPressed: (_leftPlaced && _rightPlaced) ? _check : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF123E97),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
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
                  offset: const Offset(0, 2),
                ),
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
    final cs =
        fixedCellSize ??
        (math.min(size.width / maxC, size.height / maxR) * 0.84);
    final ox = (size.width - maxC * cs) / 2;
    final oy = (size.height - maxR * cs) / 2;
    final paint = Paint()..color = color;
    for (final c in cells) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(ox + c.$1 * cs + 1, oy + c.$2 * cs + 1, cs - 2, cs - 2),
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
    final cy = size.height * 0.45;

    final pivotPaint = Paint()..color = const Color(0xFF173A8A);
    canvas.drawPath(
      Path()
        ..moveTo(cx, cy + 6)
        ..lineTo(cx - 14, cy + 23)
        ..lineTo(cx + 14, cy + 23)
        ..close(),
      pivotPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + 26), width: 58, height: 6),
        const Radius.circular(3),
      ),
      pivotPaint,
    );

    // 빔 회전
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(tilt);

    final visualWidth = math.min(size.width * 0.38, 440.0);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: visualWidth, height: 8),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF2457B8),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: const Offset(0, -2),
          width: visualWidth - 10,
          height: 3,
        ),
        const Radius.circular(2),
      ),
      Paint()..color = Colors.white.withAlpha(95),
    );

    final endColor = balanced
        ? const Color(0xFF13968F)
        : const Color(0xFF3C5CCF);
    for (final sign in [-1.0, 1.0]) {
      canvas.drawCircle(
        Offset(sign * visualWidth / 2, 0),
        9,
        Paint()..color = endColor,
      );
      canvas.drawCircle(
        Offset(sign * visualWidth / 2, -2),
        3.5,
        Paint()..color = Colors.white.withAlpha(120),
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
