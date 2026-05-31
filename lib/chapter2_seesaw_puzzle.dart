import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'bgm_toggle_button.dart';

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

  bool isValidAt(int ri, int d) =>
      d >= 1 && d + _maxCol(ri) <= 5;

  List<_Abs> cells(int ri, int d) =>
      rotations[ri].map((c) => (d + c.$1, c.$2 + 1)).toList();

  int torque(int ri, int d) =>
      cells(ri, d).fold(0, (s, c) => s + c.$1);
}

// ─────────────────────────────────────────────────────────────
// 5개 카드 데이터
//
// 토크 = Σ(각 추의 거리)
// 공식: 각 회전별 Σ(col_offset) 를 C 라 하면  torque = 4d + C
//
// I  가로: C=6  → d=1:10, d=2:14
// I  세로: C=0  → d=2:8,  d=3:12
// L  0°  : C=1  → d=1:5,  d=2:9
// L  90° : C=3  → d=2:11, d=1:7
// S  가로: C=4  → d=1:8,  d=2:12
// S  세로: C=2  → d=2:10, d=3:14
// 2×2    : C=2  → d=2:10, d=3:14
// T  0°  : C=4  → d=1:8,  d=2:12
// T  90° : C=1  → d=1:5,  d=2:9
// T  270°: C=3  → d=1:7,  d=2:11
// ─────────────────────────────────────────────────────────────
const _kCards = <_CardDef>[
  // ① I자
  _CardDef(
    name: 'I자',
    color: Color(0xFF1E88E5),
    rotations: [
      [(0, 0), (1, 0), (2, 0), (3, 0)], // 가로: torque=4d+6
      [(0, 0), (0, 1), (0, 2), (0, 3)], // 세로: torque=4d
    ],
    rotationLabels: ['가로', '세로'],
    leftPresets: [(0, 1), (1, 3)], // 가로@d=1→10, 세로@d=3→12
  ),
  // ② L자
  _CardDef(
    name: 'L자',
    color: Color(0xFFFB8C00),
    rotations: [
      [(0, 0), (0, 1), (0, 2), (1, 2)], // 0°:   torque=4d+1
      [(0, 0), (1, 0), (2, 0), (0, 1)], // 90°:  torque=4d+3
      [(0, 0), (1, 0), (1, 1), (1, 2)], // 180°: torque=4d+3
      [(2, 0), (0, 1), (1, 1), (2, 1)], // 270°: torque=4d+5
    ],
    rotationLabels: ['0°', '90°', '180°', '270°'],
    leftPresets: [(0, 1), (1, 2)], // 0°@d=1→5, 90°@d=2→11
  ),
  // ③ S자
  _CardDef(
    name: 'S자',
    color: Color(0xFF43A047),
    rotations: [
      [(1, 0), (2, 0), (0, 1), (1, 1)], // 가로: torque=4d+4
      [(0, 0), (0, 1), (1, 1), (1, 2)], // 세로: torque=4d+2
    ],
    rotationLabels: ['가로', '세로'],
    leftPresets: [(0, 1), (1, 2)], // 가로@d=1→8, 세로@d=2→10
  ),
  // ④ 2×2 사각형
  _CardDef(
    name: '2×2',
    color: Color(0xFFD81B60),
    rotations: [
      [(0, 0), (1, 0), (0, 1), (1, 1)], // torque=4d+2
    ],
    rotationLabels: ['기본'],
    leftPresets: [(0, 2), (0, 3)], // d=2→10, d=3→14
  ),
  // ⑤ T자
  _CardDef(
    name: 'T자',
    color: Color(0xFF8E24AA),
    rotations: [
      [(0, 0), (1, 0), (2, 0), (1, 1)], // 0°:   torque=4d+4
      [(0, 0), (0, 1), (1, 1), (0, 2)], // 90°:  torque=4d+1
      [(1, 0), (0, 1), (1, 1), (2, 1)], // 180°: torque=4d+4
      [(1, 0), (0, 1), (1, 1), (1, 2)], // 270°: torque=4d+3
    ],
    rotationLabels: ['0°', '90°', '180°', '270°'],
    leftPresets: [(0, 1), (1, 2)], // 0°@d=1→8, 90°@d=2→9
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
  int? _leftIdx;     // 왼쪽 카드 인덱스
  int _leftPreset = 0; // 2개 프리셋 중 랜덤 선택

  int? _rightIdx;    // 오른쪽 (학생) 카드 인덱스
  int _rightRot = 0; // 오른쪽 회전 인덱스
  int _rightDist = 1; // 오른쪽 고스트 시작 거리
  bool _ghostPlaced = false; // 추를 놓은 상태

  bool? _result; // null=미확인, true=정답, false=오답

  // 시소 기울기 애니메이션용
  late final AnimationController _seesawCtrl;
  late Animation<double> _seesawAnim;
  double _prevTilt = 0;

  @override
  void initState() {
    super.initState();
    _seesawCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _seesawAnim = const AlwaysStoppedAnimation(0);
  }

  @override
  void dispose() {
    _seesawCtrl.dispose();
    super.dispose();
  }

  // ── 계산값 ─────────────────────────────────────────
  List<_Abs> get _leftCells {
    if (_leftIdx == null) return const [];
    final p = _kCards[_leftIdx!].leftPresets[_leftPreset];
    return _kCards[_leftIdx!].cells(p.$1, p.$2);
  }

  int get _leftTorque => _leftCells.fold(0, (s, c) => s + c.$1);

  List<_Abs> get _ghostCells {
    if (_rightIdx == null) return const [];
    return _kCards[_rightIdx!].cells(_rightRot, _rightDist);
  }

  int get _rightTorque =>
      _ghostPlaced ? _ghostCells.fold(0, (s, c) => s + c.$1) : 0;

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
  void _selectLeft(int idx) {
    HapticFeedback.selectionClick();
    setState(() {
      _leftIdx = idx;
      _leftPreset = math.Random().nextInt(2);
      _rightIdx = null;
      _rightRot = 0;
      _rightDist = 1;
      _ghostPlaced = false;
      _result = null;
    });
    _animateSeesaw();
  }

  void _selectRight(int idx) {
    if (_leftIdx == null || idx == _leftIdx) return;
    HapticFeedback.selectionClick();
    setState(() {
      _rightIdx = idx;
      _rightRot = 0;
      _rightDist = 1;
      _ghostPlaced = false;
      _result = null;
    });
  }

  void _rotate() {
    if (_rightIdx == null || _ghostPlaced) return;
    final card = _kCards[_rightIdx!];
    int nextRot = (_rightRot + 1) % card.rotCount;
    int dist = _rightDist;
    if (!card.isValidAt(nextRot, dist)) dist = 1;
    HapticFeedback.lightImpact();
    setState(() {
      _rightRot = nextRot;
      _rightDist = dist;
    });
  }

  void _shift(int delta) {
    if (_rightIdx == null || _ghostPlaced) return;
    final next = _rightDist + delta;
    if (_kCards[_rightIdx!].isValidAt(_rightRot, next)) {
      HapticFeedback.selectionClick();
      setState(() => _rightDist = next);
    }
  }

  void _placeGhost() {
    if (_rightIdx == null || _ghostPlaced) return;
    HapticFeedback.mediumImpact();
    setState(() => _ghostPlaced = true);
    _animateSeesaw();
  }

  void _undoGhost() {
    HapticFeedback.lightImpact();
    setState(() {
      _ghostPlaced = false;
      _result = null;
    });
    _animateSeesaw();
  }

  void _check() {
    if (!_ghostPlaced || _leftIdx == null) return;
    HapticFeedback.heavyImpact();
    setState(() => _result = _leftTorque == _rightTorque);
  }

  void _reset() {
    setState(() {
      _leftIdx = null;
      _rightIdx = null;
      _leftPreset = 0;
      _rightRot = 0;
      _rightDist = 1;
      _ghostPlaced = false;
      _result = null;
    });
    _animateSeesaw();
  }

  // ── 빌드 ───────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isMobile = mq.size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: _appBar(),
      body: SafeArea(
        child: Column(
          children: [
            _cardRow(isMobile),
            _hintBar(),
            Expanded(
              child: Column(
                children: [
                  _seesawWidget(mq.size.width),
                  Expanded(child: _grid()),
                  if (_rightIdx != null && !_ghostPlaced) _ghostControls(),
                  _bottomBar(mq),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────── AppBar

  PreferredSizeWidget _appBar() => AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        title: const Text('시소 균형 맞추기',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        actions: [
          const BgmToggleButton(),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: '처음부터',
            onPressed: _reset,
          ),
        ],
      );

  // ─────────────────────────────── 카드 선택 행

  Widget _cardRow(bool isMobile) {
    final h = isMobile ? 100.0 : 118.0;
    return Container(
      height: h,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF283593)],
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: _kCards.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (_, i) => _cardTile(i, h - 20),
      ),
    );
  }

  Widget _cardTile(int idx, double size) {
    final card = _kCards[idx];
    final isLeft = _leftIdx == idx;
    final isRight = _rightIdx == idx;

    return GestureDetector(
      onTap: () {
        if (_leftIdx == null) {
          _selectLeft(idx);
        } else if (!isLeft) {
          _selectRight(idx);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isLeft
              ? Colors.black.withAlpha(140)
              : isRight
                  ? card.color
                  : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isLeft
                ? Colors.black54
                : isRight
                    ? Colors.white
                    : card.color,
            width: isRight ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isLeft ? Colors.black : card.color).withAlpha(80),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 18),
              child: Center(
                child: CustomPaint(
                  size: Size.square(size - 26),
                  painter: _MiniShapePainter(
                    cells: card.rotations[0],
                    color: isLeft
                        ? Colors.white.withAlpha(80)
                        : isRight
                            ? Colors.white
                            : card.color,
                  ),
                ),
              ),
            ),
            if (isLeft)
              Center(
                child: Icon(Icons.lock_rounded,
                    color: Colors.white.withAlpha(160), size: size * 0.28)),
            Positioned(
              bottom: 4,
              left: 0,
              right: 0,
              child: Text(
                card.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isLeft
                      ? Colors.white54
                      : isRight
                          ? Colors.white
                          : card.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────── 힌트 바

  Widget _hintBar() {
    final (msg, bg) = _hintInfo();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: bg,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(msg,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
    );
  }

  (String, Color) _hintInfo() {
    if (_result == true) {
      return ('🎉 정답! 왼쪽과 오른쪽의 토크가 같아요!', const Color(0xFF1B5E20));
    }
    if (_result == false) {
      return ('❌ 균형이 맞지 않아요. 다른 카드나 위치를 찾아봐요!', const Color(0xFFB71C1C));
    }
    if (_leftIdx == null) {
      return ('카드를 선택해서 왼쪽 시소에 올려보세요!', const Color(0xFF283593));
    }
    if (_rightIdx == null) {
      return ('균형 맞출 카드를 선택하세요 (🔒 카드는 선택 불가)', const Color(0xFF1565C0));
    }
    if (!_ghostPlaced) {
      return ('도형을 이동·회전하여 위치를 정하고 "추 놓기"를 누르세요', const Color(0xFF2E7D32));
    }
    return ('"정답 확인" 버튼을 눌러보세요!', const Color(0xFF00695C));
  }

  // ─────────────────────────────── 시소 애니메이션

  Widget _seesawWidget(double screenW) {
    return SizedBox(
      height: 74,
      width: screenW,
      child: AnimatedBuilder(
        animation: _seesawAnim,
        builder: (context, child) => CustomPaint(
          painter: _SeesawPainter(
            tilt: _seesawAnim.value,
            leftLabel: _leftIdx != null ? '$_leftTorque' : '',
            rightLabel: _ghostPlaced ? '$_rightTorque' : '',
            balanced: _result == true,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────── 그리드

  Widget _grid() {
    return LayoutBuilder(builder: (context, box) {
      final avail = box.maxWidth - 24;
      final cellSz = (avail / 11.8).clamp(22.0, 38.0);
      final gap = cellSz * 0.13;

      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          children: [
            _distRow(cellSz, gap),
            const SizedBox(height: 6),
            for (int r = 1; r <= 4; r++)
              Padding(
                padding: EdgeInsets.only(bottom: gap),
                child: _gridRow(r, cellSz, gap),
              ),
            const SizedBox(height: 6),
            _distRow(cellSz, gap),
          ],
        ),
      );
    });
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
    final leftDists = {
      for (final c in _leftCells.where((c) => c.$2 == row)) c.$1
    };
    final ghostDists = {
      for (final c in _ghostCells.where((c) => c.$2 == row)) c.$1
    };
    final leftColor =
        _leftIdx != null ? _kCards[_leftIdx!].color : Colors.grey;
    final rightColor =
        _rightIdx != null ? _kCards[_rightIdx!].color : Colors.grey;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 왼쪽: 거리 5→1
        for (int d = 5; d >= 1; d--)
          Padding(
            padding: EdgeInsets.only(right: gap),
            child: _Cell(
              size: sz,
              hasWeight: leftDists.contains(d),
              isGhost: false,
              color: leftColor,
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
        // 오른쪽: 거리 1→5
        for (int d = 1; d <= 5; d++)
          Padding(
            padding: EdgeInsets.only(right: d < 5 ? gap : 0),
            child: _Cell(
              size: sz,
              hasWeight: _ghostPlaced && ghostDists.contains(d),
              isGhost: !_ghostPlaced && ghostDists.contains(d),
              color: rightColor,
            ),
          ),
      ],
    );
  }

  // ─────────────────────────────── 고스트 컨트롤

  Widget _ghostControls() {
    if (_rightIdx == null) return const SizedBox.shrink();
    final card = _kCards[_rightIdx!];
    final canL = _rightDist > 1;
    final canR = card.isValidAt(_rightRot, _rightDist + 1);

    return Container(
      color: const Color(0xFFE8EAF6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ← 이동
          _CtrlBtn(
            icon: Icons.chevron_left_rounded,
            enabled: canL,
            color: card.color,
            onTap: () => _shift(-1),
          ),
          // 회전 + 추 놓기
          Row(mainAxisSize: MainAxisSize.min, children: [
            if (card.rotCount > 1) ...[
              _PillBtn(
                label: '↻ ${card.rotationLabels[_rightRot]}',
                color: card.color,
                onTap: _rotate,
              ),
              const SizedBox(width: 8),
            ],
            _PillBtn(
              label: '⬇ 추 놓기',
              color: const Color(0xFF00897B),
              onTap: _placeGhost,
            ),
          ]),
          // → 이동
          _CtrlBtn(
            icon: Icons.chevron_right_rounded,
            enabled: canR,
            color: card.color,
            onTap: () => _shift(1),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────── 하단 바

  Widget _bottomBar(MediaQueryData mq) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            colors: [Color(0xFF1A237E), Color(0xFF0D47A1)]),
      ),
      padding:
          EdgeInsets.fromLTRB(16, 12, 16, 12 + mq.padding.bottom),
      child: Row(
        children: [
          // 토크 표시
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _torqueText('왼쪽', _leftTorque, const Color(0xFF90CAF9)),
              const SizedBox(height: 2),
              _torqueText('오른쪽', _rightTorque, const Color(0xFFA5D6A7)),
            ],
          ),
          const Spacer(),
          // 버튼
          if (_result == true)
            _ActionBtn(
              label: '다음으로 →',
              color: const Color(0xFF2E7D32),
              onTap: () => Navigator.pushReplacementNamed(
                  context, widget.completedRouteName),
            )
          else ...[
            if (_ghostPlaced) ...[
              _ActionBtn(
                label: '취소',
                color: Colors.grey.shade600,
                onTap: _undoGhost,
              ),
              const SizedBox(width: 8),
            ],
            if (_ghostPlaced)
              _ActionBtn(
                label: '정답 확인',
                color: const Color(0xFF43A047),
                onTap: _check,
              ),
          ],
        ],
      ),
    );
  }

  Widget _torqueText(String side, int t, Color c) => RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          children: [
            TextSpan(
                text: '$side: ',
                style: TextStyle(color: c.withAlpha(200))),
            TextSpan(
                text: '$t',
                style: TextStyle(
                    color: c,
                    fontWeight: FontWeight.w900,
                    fontSize: 16)),
          ],
        ),
      );
}

// ═══════════════════════════════════════════════════════════════
// 재사용 위젯
// ═══════════════════════════════════════════════════════════════

class _Cell extends StatelessWidget {
  final double size;
  final bool hasWeight;
  final bool isGhost;
  final Color color;

  const _Cell({
    required this.size,
    required this.hasWeight,
    required this.isGhost,
    required this.color,
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
            : isGhost
                ? color.withAlpha(90)
                : const Color(0xFFCFD8DC),
        border: Border.all(
          color: hasWeight
              ? color.withAlpha(230)
              : isGhost
                  ? color.withAlpha(170)
                  : const Color(0xFFB0BEC5),
          width: hasWeight || isGhost ? 2.5 : 1.2,
        ),
        boxShadow: hasWeight
            ? [
                BoxShadow(
                    color: color.withAlpha(115),
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
                  color: Colors.white.withAlpha(100),
                ),
              ),
            )
          : null,
    );
  }
}

class _CtrlBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final Color color;
  final VoidCallback onTap;

  const _CtrlBtn(
      {required this.icon,
      required this.enabled,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: enabled ? color.withAlpha(38) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: enabled ? color : Colors.grey.shade300),
        ),
        child:
            Icon(icon, color: enabled ? color : Colors.grey.shade400),
      ),
    );
  }
}

class _PillBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PillBtn(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: color.withAlpha(100),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13)),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: color.withAlpha(115),
                blurRadius: 6,
                offset: const Offset(0, 3))
          ],
        ),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14)),
      ),
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

  const _MiniShapePainter({required this.cells, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (cells.isEmpty) return;
    final maxC = cells.map((c) => c.$1).reduce(math.max) + 1;
    final maxR = cells.map((c) => c.$2).reduce(math.max) + 1;
    final cs = math.min(size.width / maxC, size.height / maxR) * 0.84;
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
  bool shouldRepaint(_MiniShapePainter old) => old.color != color;
}

/// 시소 빔 그리기
class _SeesawPainter extends CustomPainter {
  final double tilt;
  final String leftLabel;
  final String rightLabel;
  final bool balanced;

  const _SeesawPainter({
    required this.tilt,
    required this.leftLabel,
    required this.rightLabel,
    required this.balanced,
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

    final beamLen = size.width * 0.82;

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
        Offset(sign * (beamLen / 2 - 12), 0),
        13,
        Paint()..color = endColor,
      );
      canvas.drawCircle(
        Offset(sign * (beamLen / 2 - 12), -3),
        5,
        Paint()..color = Colors.white.withAlpha(80),
      );
    }
    canvas.restore();

    // 토크 레이블
    if (leftLabel.isNotEmpty) {
      _drawLabel(canvas, leftLabel, Offset(cx * 0.25, cy - 24));
    }
    if (rightLabel.isNotEmpty) {
      _drawLabel(canvas, rightLabel, Offset(cx * 1.75, cy - 24));
    }
  }

  void _drawLabel(Canvas canvas, String text, Offset center) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFF1A237E),
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy));
  }

  @override
  bool shouldRepaint(_SeesawPainter o) =>
      o.tilt != tilt ||
      o.leftLabel != leftLabel ||
      o.rightLabel != rightLabel ||
      o.balanced != balanced;
}
