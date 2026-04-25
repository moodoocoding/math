import 'package:flutter/material.dart';
import 'bgm_toggle_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '?섑븰 釉뚮┃ ?쇱쫹',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const BrickPuzzleScreen(),
    );
  }
}

/// 釉뚮┃ ?곗씠??紐⑤뜽
class Brick {
  final String id;
  final Color color;
  final List<(int row, int col)> shapeCells; // ?곷? 醫뚰몴 由ъ뒪??
  String currentBoard; // 'storage', 'number1', 'number2', 'number3', 'number4'
  int currentRow;
  int currentCol;

  Brick({
    required this.id,
    required this.color,
    required this.shapeCells,
    this.currentBoard = 'storage',
    this.currentRow = 0,
    this.currentCol = 0,
  });

  Brick copy() {
    return Brick(
      id: id,
      color: color,
      shapeCells: List.from(shapeCells),
      currentBoard: currentBoard,
      currentRow: currentRow,
      currentCol: currentCol,
    );
  }
}

/// ?レ옄 ?꾩븞 ?곗씠??紐⑤뜽
class NumberBoard {
  final String number;
  final List<List<bool>> grid; // true??移몃쭔 梨꾩썙????
  late final List<List<String?>> occupied; // ?대뒓 釉뚮┃???볦뿬?덈뒗吏 異붿쟻

  NumberBoard({
    required this.number,
    required this.grid,
  }) {
    occupied = List.generate(
      grid.length,
      (i) => List.generate(grid[i].length, (j) => null),
    );
  }

  bool canPlace(Brick brick, int row, int col) {
    // 紐⑤뱺 ???踰붿쐞 ?댁뿉 ?덈뒗吏, true 移몄씤吏, 鍮꾩뼱?덈뒗吏 ?뺤씤
    for (var (r, c) in brick.shapeCells) {
      int actualRow = row + r;
      int actualCol = col + c;

      // 踰붿쐞 ?뺤씤
      if (actualRow < 0 ||
          actualRow >= grid.length ||
          actualCol < 0 ||
          actualCol >= grid[actualRow].length) {
        return false;
      }

      // ?꾩븞 ?곸뿭 ?뺤씤 (true??移몄뿉留??볦쓣 ???덉쓬)
      if (!grid[actualRow][actualCol]) {
        return false;
      }

      // ?대? 李⑥엳??移??뺤씤
      if (occupied[actualRow][actualCol] != null) {
        return false;
      }
    }
    return true;
  }

  void place(Brick brick, int row, int col) {
    for (var (r, c) in brick.shapeCells) {
      int actualRow = row + r;
      int actualCol = col + c;
      occupied[actualRow][actualCol] = brick.id;
    }
  }

  void remove(Brick brick) {
    for (int i = 0; i < occupied.length; i++) {
      for (int j = 0; j < occupied[i].length; j++) {
        if (occupied[i][j] == brick.id) {
          occupied[i][j] = null;
        }
      }
    }
  }

  bool isFilled() {
    for (int i = 0; i < grid.length; i++) {
      for (int j = 0; j < grid[i].length; j++) {
        if (grid[i][j] && occupied[i][j] == null) {
          return false;
        }
      }
    }
    return true;
  }

  void reset() {
    occupied = List.generate(
      grid.length,
      (i) => List.generate(grid[i].length, (j) => null),
    );
  }
}

/// 硫붿씤 ?쇱쫹 ?붾㈃
class BrickPuzzleScreen extends StatefulWidget {
  const BrickPuzzleScreen({super.key, this.completedRouteName});

  final String? completedRouteName;

  @override
  State<BrickPuzzleScreen> createState() => _BrickPuzzleScreenState();
}

class _BrickPuzzleScreenState extends State<BrickPuzzleScreen> {
  late List<Brick> bricks;
  late Map<String, NumberBoard> boards;
  Map<String, (int row, int col)> initialPositions = {};

  @override
  void initState() {
    super.initState();
    _initializeBricks();
    _initializeBoards();
  }

  void _initializeBricks() {
    bricks = [
      // Simulation result: these reusable templates can fill all number boards.
      Brick(
        id: 'i4v',
        color: const Color(0xFF4A9BFF),
        shapeCells: [(0, 0), (1, 0), (2, 0), (3, 0)],
      ),
      Brick(
        id: 'i4h',
        color: const Color(0xFF2F7DE1),
        shapeCells: [(0, 0), (0, 1), (0, 2), (0, 3)],
      ),
      Brick(
        id: 'i3h',
        color: const Color(0xFFFF1493),
        shapeCells: [(0, 0), (0, 1), (0, 2)],
      ),
      Brick(
        id: 'i2v',
        color: const Color(0xFFFF4444),
        shapeCells: [(0, 0), (1, 0)],
      ),
      Brick(
        id: 'i2h',
        color: const Color(0xFFD93636),
        shapeCells: [(0, 0), (0, 1)],
      ),
      Brick(
        id: 'l3BottomRight',
        color: const Color(0xFF52C77E),
        shapeCells: [(0, 1), (1, 0), (1, 1)],
      ),
      Brick(
        id: 'l3BottomLeft',
        color: const Color(0xFF3CB96A),
        shapeCells: [(0, 0), (0, 1), (1, 0)],
      ),
      Brick(
        id: 't4Up',
        color: const Color(0xFFFFA500),
        shapeCells: [(0, 1), (1, 0), (1, 1), (1, 2)],
      ),
    ];

    for (int i = 0; i < bricks.length; i++) {
      initialPositions[bricks[i].id] = (i ~/ 4, i % 4);
    }
  }
  void _initializeBoards() {
    // 梨뺥꽣4: ?쒖씠???믪쓬 - ?レ옄 1, 2, 3, 4??紐⑥뼇????蹂듭옟??
    boards = {
      'number1': NumberBoard(
        number: '1',
        grid: [
          [false, false, true, false, false, false],
          [false, true, true, false, false, false],
          [false, false, true, false, false, false],
          [false, false, true, false, false, false],
          [false, false, true, false, false, false],
          [false, true, true, true, false, false],
        ],
      ),
      // ?レ옄 2??紐⑥뼇 (??蹂듭옟??
      'number2': NumberBoard(
        number: '2',
        grid: [
          [true, true, true, true, false, false],
          [false, false, false, true, false, false],
          [true, true, true, true, false, false],
          [true, false, false, false, false, false],
          [true, true, true, true, false, false],
          [false, false, false, false, false, false],
        ],
      ),
      // ?レ옄 3??紐⑥뼇
      'number3': NumberBoard(
        number: '3',
        grid: [
          [true, true, true, true, false, false],
          [false, false, false, true, false, false],
          [false, true, true, true, false, false],
          [false, false, false, true, false, false],
          [true, true, true, true, false, false],
          [false, false, false, false, false, false],
        ],
      ),
      // ?レ옄 4??紐⑥뼇
      'number4': NumberBoard(
        number: '4',
        grid: [
          [true, false, false, true, false, false],
          [true, false, false, true, false, false],
          [true, true, true, true, false, false],
          [false, false, false, true, false, false],
          [false, false, false, true, false, false],
          [false, false, false, false, false, false],
        ],
      ),
    };
  }

  void _resetPuzzle() {
    setState(() {
      for (var brick in bricks) {
        brick.currentBoard = 'storage';
        brick.currentRow = initialPositions[brick.id]!.$1;
        brick.currentCol = initialPositions[brick.id]!.$2;
      }
      for (var board in boards.values) {
        board.reset();
      }
    });
  }

  void _skipPuzzleForTest() {
    if (widget.completedRouteName != null) {
      Navigator.pushReplacementNamed(context, widget.completedRouteName!);
    } else {
      Navigator.maybePop(context);
    }
  }

  void _checkAnswer() {
    bool allFilled = boards.values.every((board) => board.isFilled());

    if (allFilled) {
      _showSuccessDialog();
    } else {
      _showTryAgainDialog();
    }
  }

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
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '?럦 ?뺣떟?낅땲?? ?럦',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF18BEB6),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '?꾨꼍?섍쾶 ?꾩꽦?덈꽕??\n?뺣쭚 ?섑뻽?댁슂!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF091F59),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (widget.completedRouteName != null) {
                    Navigator.pushReplacementNamed(
                      context,
                      widget.completedRouteName!,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF133E97),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  '?뺤씤',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
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
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '?꾩쭅?댁뿉??',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFE05C57),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '?ㅼ떆 ??踰??쒕룄??蹂댁꽭??\n醫 ???앷컖?댁꽌 留욎떠遊먯슂!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF091F59),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE05C57),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  '?뺤씤',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
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
                '?뮕 ?뚰듃',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF6F63D1),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '??釉뚮┃遺??癒쇱? 諛곗튂??蹂댁꽭??\n?묒? 釉뚮┃? ?⑥? 怨듦컙??梨꾩슦?붾뜲 ?꾩????쇱슂.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF091F59),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  '?뺤씤',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6F63D1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isCompact = screenSize.height < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      appBar: AppBar(
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
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 14,
              decoration: const BoxDecoration(
                color: Color(0xFFF6B51E),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(8),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(8, 12, 8, 10),
              padding: EdgeInsets.symmetric(vertical: isCompact ? 14 : 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
              child: Text(
                '문제1: 아래 보기 중 같은 블록 모양은 무엇일까요?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isCompact ? 28 : 38,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF091F59),
                ),
              ),
            ),

            // Middle: keep the reusable bricks and all target boards on one screen.
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(screenSize.width * 0.018),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: screenSize.width * 0.26,
                      child: _buildBrickStorage(screenSize, isCompact),
                    ),
                    SizedBox(width: screenSize.width * 0.018),
                    Expanded(
                      child: _buildNumberBoardsArea(screenSize, isCompact),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom buttons
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.03,
                vertical: isCompact ? 12 : 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFFE1E1E4),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _showHint,
                          icon: const Icon(Icons.lightbulb_outline, size: 24),
                          label: Text(
                            '힌트',
                            style: TextStyle(
                              fontSize: isCompact ? 18 : 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF6F63D1),
                            side: const BorderSide(
                              color: Color(0xFF6F63D1),
                              width: 2,
                            ),
                            padding: EdgeInsets.symmetric(vertical: isCompact ? 10 : 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: screenSize.width * 0.02),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _resetPuzzle,
                          icon: const Icon(Icons.refresh, size: 24),
                          label: Text(
                            '다시하기',
                            style: TextStyle(
                              fontSize: isCompact ? 18 : 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8A8A8A),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: isCompact ? 10 : 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: screenSize.width * 0.02),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _checkAnswer,
                          icon: const Icon(Icons.check_circle, size: 24),
                          label: Text(
                            '정답 확인',
                            style: TextStyle(
                              fontSize: isCompact ? 18 : 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF123E97),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: isCompact ? 10 : 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _skipPuzzleForTest,
                      icon: const Icon(Icons.skip_next_rounded),
                      label: const Text('테스트용: 문제 건너뛰고 다음으로'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF315FB8),
                        side: const BorderSide(
                          color: Color(0xFF5B80D7),
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        textStyle: TextStyle(
                          fontSize: isCompact ? 14 : 18,
                          fontWeight: FontWeight.w800,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrickStorage(Size screenSize, bool isCompact) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenSize.width * 0.014),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFF4C430), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: screenSize.width * 0.01),
              child: Text(
                '브릭 조각',
                style: TextStyle(
                  fontSize: isCompact ? 16 : 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF163988),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '조각은 사라지지 않아요.\n필요한 만큼 여러 번 끌어 쓰세요.',
              style: TextStyle(
                fontSize: isCompact ? 12 : 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF5B7BA6),
                height: 1.25,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: screenSize.width * 0.012,
              runSpacing: screenSize.height * 0.012,
              children: [
                for (var brick in bricks)
                  _buildBrickWidget(brick, screenSize, isCompact),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrickWidget(Brick brick, Size screenSize, bool isCompact) {
    final cellSize = screenSize.width * (isCompact ? 0.022 : 0.026);

    return Draggable<Brick>(
      data: brick,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.7,
          child: _buildBrickGrid(brick, cellSize),
        ),
      ),
      childWhenDragging: _buildBrickGrid(brick, cellSize),
      child: _buildBrickGrid(brick, cellSize),
    );
  }

  Widget _buildBrickGrid(Brick brick, double cellSize) {
    // 釉뚮┃??諛붿슫??諛뺤뒪 怨꾩궛
    int maxRow = 0;
    int maxCol = 0;
    for (var (r, c) in brick.shapeCells) {
      if (r > maxRow) maxRow = r;
      if (c > maxCol) maxCol = c;
    }

    return SizedBox(
      width: (maxCol + 1) * cellSize,
      height: (maxRow + 1) * cellSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var (r, c) in brick.shapeCells)
            Positioned(
              left: c * cellSize,
              top: r * cellSize,
              child: Container(
                width: cellSize,
                height: cellSize,
                decoration: BoxDecoration(
                  color: brick.color,
                  border: Border.all(
                    color: Colors.white,
                    width: 1.2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: brick.color.withValues(alpha: 0.28),
                      blurRadius: 4,
                      offset: const Offset(1.5, 1.5),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNumberBoardsArea(Size screenSize, bool isCompact) {
    final boardColors = [
      const Color(0xFFD4E6F1), // 1踰?- ?섎뒛??
      const Color(0xFFD5F4E6), // 2踰?- ?곕몢??
      const Color(0xFFFEF5E7), // 3踰?- ?щ┝??
      const Color(0xFFEAE5F5), // 4踰?- ?쇰깽??
    ];

    final borderColors = [
      const Color(0xFF3498DB), // 1踰?
      const Color(0xFF2ECC71), // 2踰?
      const Color(0xFFF39C12), // 3踰?
      const Color(0xFF9B59B6), // 4踰?
    ];

    final numbers = ['1', '2', '3', '4'];
    final boardKeys = ['number1', 'number2', 'number3', 'number4'];

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalGap = screenSize.width * 0.014;
        final verticalGap = screenSize.height * 0.014;
        final tileWidth = (constraints.maxWidth - horizontalGap) / 2;
        final tileHeight = (constraints.maxHeight - verticalGap) / 2;

        return GridView.count(
          crossAxisCount: 2,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: horizontalGap,
          mainAxisSpacing: verticalGap,
          childAspectRatio: tileWidth / tileHeight,
          children: [
            for (int i = 0; i < 4; i++)
              _buildNumberBoard(
                screenSize,
                isCompact,
                numbers[i],
                boardKeys[i],
                boards[boardKeys[i]]!,
                boardColors[i],
                borderColors[i],
              ),
          ],
        );
      },
    );
  }

  Widget _buildNumberBoard(
    Size screenSize,
    bool isCompact,
    String number,
    String boardKey,
    NumberBoard board,
    Color bgColor,
    Color borderColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: 3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Keep each number grid fitted inside its tile, regardless of screen ratio.
          LayoutBuilder(
            builder: (context, constraints) {
              final rows = board.grid.length;
              final cols = board.grid[0].length;
              final padding = screenSize.width * 0.008;
              final cellSize = [
                (constraints.maxWidth - padding * 2) / cols,
                (constraints.maxHeight - padding * 2) / rows,
              ].reduce((a, b) => a < b ? a : b);
              final gridWidth = cellSize * cols;
              final gridHeight = cellSize * rows;

              return Center(
                child: SizedBox(
                  width: gridWidth,
                  height: gridHeight,
                  child: Stack(
                    children: [
                      for (int row = 0; row < rows; row++)
                        for (int col = 0; col < cols; col++)
                          Positioned(
                            left: col * cellSize,
                            top: row * cellSize,
                            child: _buildBoardCell(
                              boardKey: boardKey,
                              board: board,
                              row: row,
                              col: col,
                              cellSize: cellSize,
                              borderColor: borderColor,
                            ),
                          ),
                    ],
                  ),
                ),
              );
            },
          ),

          // ?レ옄 ?쒖떆
          Positioned(
            bottom: screenSize.width * 0.02,
            right: screenSize.width * 0.02,
            child: Text(
              number,
              style: TextStyle(
                fontSize: screenSize.width * 0.08,
                fontWeight: FontWeight.w900,
                color: borderColor.withValues(alpha: 0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoardCell({
    required String boardKey,
    required NumberBoard board,
    required int row,
    required int col,
    required double cellSize,
    required Color borderColor,
  }) {
    final isActive = board.grid[row][col];
    final occupiedBy = board.occupied[row][col];

    return DragTarget<Brick>(
      onAcceptWithDetails: (details) {
        final brick = details.data;
        setState(() {
          // Storage bricks are reusable templates, so dropping one places a
          // copy and leaves the original available for the next placement.
          _placeBrickNearCell(brick, boardKey, row, col);
        });
      },
      builder: (context, candidates, rejects) {
        final isHovering = candidates.isNotEmpty;
        return Container(
          width: cellSize,
          height: cellSize,
          margin: EdgeInsets.all(cellSize * 0.04),
          decoration: BoxDecoration(
            color: isActive
                ? (occupiedBy != null
                    ? _getBrickColorById(occupiedBy)
                    : isHovering
                        ? borderColor.withValues(alpha: 0.18)
                        : Colors.white.withValues(alpha: 0.62))
                : Colors.transparent,
            border: Border.all(
              color: isActive
                  ? borderColor.withValues(alpha: isHovering ? 0.7 : 0.32)
                  : Colors.transparent,
              width: isHovering ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }

  void _placeBrickNearCell(Brick brick, String boardKey, int row, int col) {
    final board = boards[boardKey]!;

    // Try each brick cell as the user's intended anchor. This makes L/T
    // shapes easy to drop because learners can aim at visible target cells
    // instead of invisible bounding-box corners.
    for (final (shapeRow, shapeCol) in brick.shapeCells) {
      final topRow = row - shapeRow;
      final leftCol = col - shapeCol;
      if (board.canPlace(brick, topRow, leftCol)) {
        board.place(brick, topRow, leftCol);
        return;
      }
    }
  }

  Color _getBrickColorById(String brickId) {
    for (var brick in bricks) {
      if (brick.id == brickId) {
        return brick.color;
      }
    }
    return Colors.grey;
  }
}



