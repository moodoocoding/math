import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '수학 브릭 퍼즐',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const BrickPuzzleScreen(),
    );
  }
}

/// 브릭 데이터 모델
class Brick {
  final String id;
  final Color color;
  final List<(int row, int col)> shapeCells; // 상대 좌표 리스트
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

/// 숫자 도안 데이터 모델
class NumberBoard {
  final String number;
  final List<List<bool>> grid; // true인 칸만 채워야 함
  late final List<List<String?>> occupied; // 어느 브릭이 놓여있는지 추적

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
    // 모든 셀이 범위 내에 있는지, true 칸인지, 비어있는지 확인
    for (var (r, c) in brick.shapeCells) {
      int actualRow = row + r;
      int actualCol = col + c;

      // 범위 확인
      if (actualRow < 0 ||
          actualRow >= grid.length ||
          actualCol < 0 ||
          actualCol >= grid[actualRow].length) {
        return false;
      }

      // 도안 영역 확인 (true인 칸에만 놓을 수 있음)
      if (!grid[actualRow][actualCol]) {
        return false;
      }

      // 이미 차있는 칸 확인
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

/// 메인 퍼즐 화면
class BrickPuzzleScreen extends StatefulWidget {
  const BrickPuzzleScreen({super.key});

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
      // 파란색 I 모양 (4칸)
      Brick(
        id: 'brick1',
        color: const Color(0xFF4A9BFF),
        shapeCells: [(0, 0), (1, 0), (2, 0), (3, 0)],
      ),
      // 초록색 L 모양
      Brick(
        id: 'brick2',
        color: const Color(0xFF52C77E),
        shapeCells: [(0, 0), (1, 0), (1, 1)],
      ),
      // 노란색 T 모양
      Brick(
        id: 'brick3',
        color: const Color(0xFFFFA500),
        shapeCells: [(0, 0), (0, 1), (0, 2), (1, 1)],
      ),
      // 보라색 정사각형
      Brick(
        id: 'brick4',
        color: const Color(0xFFB17FDB),
        shapeCells: [(0, 0), (0, 1), (1, 0), (1, 1)],
      ),
      // 하늘색 모양
      Brick(
        id: 'brick5',
        color: const Color(0xFF78B7FF),
        shapeCells: [(0, 0), (0, 1), (1, 1), (1, 2)],
      ),
      // 분홍색 모양
      Brick(
        id: 'brick6',
        color: const Color(0xFFFF69B4),
        shapeCells: [(0, 0), (1, 0), (1, 1), (2, 1)],
      ),
      // 주황색 L 모양
      Brick(
        id: 'brick7',
        color: const Color(0xFFFF7F50),
        shapeCells: [(0, 0), (0, 1), (1, 1), (2, 1)],
      ),
      // 빨간색 작은 블록
      Brick(
        id: 'brick8',
        color: const Color(0xFFFF4444),
        shapeCells: [(0, 0), (1, 0)],
      ),
      // 또 다른 파란색 블록
      Brick(
        id: 'brick9',
        color: const Color(0xFF4169E1),
        shapeCells: [(0, 0), (0, 1), (1, 0)],
      ),
      // 초록색 추가 블록
      Brick(
        id: 'brick10',
        color: const Color(0xFF32CD32),
        shapeCells: [(0, 0)],
      ),
    ];

    // 초기 위치 저장
    for (int i = 0; i < bricks.length; i++) {
      initialPositions[bricks[i].id] = (i ~/ 5, (i % 5) * 2);
    }
  }

  void _initializeBoards() {
    // 숫자 1의 모양 (약 5x3 크기)
    boards = {
      'number1': NumberBoard(
        number: '1',
        grid: [
          [false, false, true, false, false],
          [false, true, true, false, false],
          [false, false, true, false, false],
          [false, false, true, false, false],
          [false, true, true, true, false],
        ],
      ),
      // 숫자 2의 모양
      'number2': NumberBoard(
        number: '2',
        grid: [
          [true, true, true, false, false],
          [false, false, true, false, false],
          [true, true, true, false, false],
          [true, false, false, false, false],
          [true, true, true, false, false],
        ],
      ),
      // 숫자 3의 모양
      'number3': NumberBoard(
        number: '3',
        grid: [
          [true, true, true, false, false],
          [false, false, true, false, false],
          [true, true, true, false, false],
          [false, false, true, false, false],
          [true, true, true, false, false],
        ],
      ),
      // 숫자 4의 모양
      'number4': NumberBoard(
        number: '4',
        grid: [
          [true, false, true, false, false],
          [true, false, true, false, false],
          [true, true, true, false, false],
          [false, false, true, false, false],
          [false, false, true, false, false],
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
                '🎉 정답입니다! 🎉',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF18BEB6),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '완벽하게 완성했네요!\n정말 잘했어요!',
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
                  backgroundColor: const Color(0xFF18BEB6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  '확인',
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
                '아직이에요!',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFE05C57),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '다시 한 번 시도해 보세요!\n좀 더 생각해서 맞춰봐요!',
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
                  '확인',
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
                '💡 힌트',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF6F63D1),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '큰 브릭부터 먼저 배치해 보세요!\n작은 브릭은 남은 공간을 채우는데 도움이 돼요.',
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
                  '확인',
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
      body: SafeArea(
        child: Column(
          children: [
            // 상단: 제목과 안내 문구
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.04,
                vertical: isCompact ? 12 : 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFFF4C430).withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '📐 수학 브릭 퍼즐 - 문제 1',
                    style: TextStyle(
                      fontSize: isCompact ? 24 : 32,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF163988),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '위의 브릭을 옮겨 숫자 모양을 완성해 보세요!',
                    style: TextStyle(
                      fontSize: isCompact ? 18 : 24,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF5B7BA6),
                    ),
                  ),
                ],
              ),
            ),

            // 중간: 브릭 저장소와 퍼즐 영역
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(screenSize.width * 0.03),
                  child: Column(
                    children: [
                      // 브릭 저장소
                      _buildBrickStorage(screenSize, isCompact),
                      SizedBox(height: screenSize.height * 0.02),

                      // 숫자 도안 영역 (2x2 그리드)
                      _buildNumberBoardsArea(screenSize, isCompact),
                    ],
                  ),
                ),
              ),
            ),

            // 하단: 버튼
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
              child: Row(
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrickStorage(Size screenSize, bool isCompact) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenSize.width * 0.02),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFF4C430), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: screenSize.width * 0.01),
            child: Text(
              '🧱 브릭 조각',
              style: TextStyle(
                fontSize: isCompact ? 16 : 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF163988),
              ),
            ),
          ),
          SizedBox(height: screenSize.height * 0.01),
          Wrap(
            spacing: screenSize.width * 0.015,
            runSpacing: screenSize.height * 0.015,
            children: [
              for (var brick in bricks)
                if (brick.currentBoard == 'storage')
                  _buildBrickWidget(brick, screenSize, isCompact),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBrickWidget(Brick brick, Size screenSize, bool isCompact) {
    final cellSize = screenSize.width * 0.03;

    return Draggable<Brick>(
      data: brick,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.7,
          child: _buildBrickGrid(brick, cellSize),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildBrickGrid(brick, cellSize),
      ),
      child: _buildBrickGrid(brick, cellSize),
    );
  }

  Widget _buildBrickGrid(Brick brick, double cellSize) {
    // 브릭의 바운딩 박스 계산
    int maxRow = 0;
    int maxCol = 0;
    for (var (r, c) in brick.shapeCells) {
      if (r > maxRow) maxRow = r;
      if (c > maxCol) maxCol = c;
    }

    return Container(
      width: (maxCol + 1) * cellSize,
      height: (maxRow + 1) * cellSize,
      padding: EdgeInsets.all(cellSize * 0.1),
      decoration: BoxDecoration(
        color: brick.color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: brick.color.withValues(alpha: 0.4),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          for (var (r, c) in brick.shapeCells)
            Positioned(
              left: c * cellSize,
              top: r * cellSize,
              child: Container(
                width: cellSize * 0.8,
                height: cellSize * 0.8,
                decoration: BoxDecoration(
                  color: brick.color,
                  border: Border.all(
                    color: Colors.white,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNumberBoardsArea(Size screenSize, bool isCompact) {
    final boardColors = [
      const Color(0xFFD4E6F1), // 1번 - 하늘색
      const Color(0xFFD5F4E6), // 2번 - 연두색
      const Color(0xFFFEF5E7), // 3번 - 크림색
      const Color(0xFFEAE5F5), // 4번 - 라벤더
    ];

    final borderColors = [
      const Color(0xFF3498DB), // 1번
      const Color(0xFF2ECC71), // 2번
      const Color(0xFFF39C12), // 3번
      const Color(0xFF9B59B6), // 4번
    ];

    final numbers = ['1', '2', '3', '4'];
    final boardKeys = ['number1', 'number2', 'number3', 'number4'];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: screenSize.width * 0.02,
      mainAxisSpacing: screenSize.height * 0.02,
      childAspectRatio: 1.0,
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
          // 격자 배경
          Padding(
            padding: EdgeInsets.all(screenSize.width * 0.01),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: board.grid[0].length,
                childAspectRatio: 1.0,
              ),
              itemCount: board.grid.length * board.grid[0].length,
              itemBuilder: (context, index) {
                int row = index ~/ board.grid[0].length;
                int col = index % board.grid[0].length;
                bool isActive = board.grid[row][col];
                String? occupiedBy = board.occupied[row][col];

                return DragTarget<Brick>(
                  onAcceptWithDetails: (details) {
                    final brick = details.data;
                    setState(() {
                      // 기존 위치에서 제거
                      if (brick.currentBoard != 'storage') {
                        boards[brick.currentBoard]!.remove(brick);
                      }

                      // 새 위치에 배치
                      if (boards[boardKey]!.canPlace(brick, row, col)) {
                        boards[boardKey]!.place(brick, row, col);
                        brick.currentBoard = boardKey;
                        brick.currentRow = row;
                        brick.currentCol = col;
                      }
                    });
                  },
                  builder: (context, candidates, rejects) {
                    return Container(
                      margin: EdgeInsets.all(screenSize.width * 0.004),
                      decoration: BoxDecoration(
                        color: isActive
                            ? (occupiedBy != null
                                ? _getBrickColorById(occupiedBy)
                            : Colors.white.withValues(alpha: 0.5))
                            : Colors.transparent,
                        border: Border.all(
                          color: isActive
                              ? borderColor.withValues(alpha: 0.3)
                              : Colors.transparent,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // 숫자 표시
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

  Color _getBrickColorById(String brickId) {
    for (var brick in bricks) {
      if (brick.id == brickId) {
        return brick.color;
      }
    }
    return Colors.grey;
  }
}
