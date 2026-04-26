import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '숨은 낱말 찾기 퍼즐',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HiddenWordPuzzleScreen(),
    );
  }
}

/// 낱말 데이터 모델
class WordData {
  final String word;
  final int startRow;
  final int startCol;
  final String direction; // 'horizontal' or 'vertical'
  late final List<(int, int)> positions; // 낱말이 차지하는 모든 칸

  WordData({
    required this.word,
    required this.startRow,
    required this.startCol,
    required this.direction,
  }) {
    // 낱말의 모든 칸 좌표 계산
    positions = [];
    for (int i = 0; i < word.length; i++) {
      if (direction == 'horizontal') {
        positions.add((startRow, startCol + i));
      } else {
        positions.add((startRow + i, startCol));
      }
    }
  }

  /// 이 낱말이 주어진 칸들의 선택과 정확히 일치하는지 확인
  bool matchesSelection(List<(int, int)> selected) {
    if (selected.length != word.length) return false;

    // 같은 순서로 일치하는지 확인
    for (int i = 0; i < positions.length; i++) {
      if (positions[i] != selected[i]) return false;
    }
    return true;
  }

  /// 역순으로도 일치하는지 확인 (거울상)
  bool matchesSelectionReverse(List<(int, int)> selected) {
    if (selected.length != word.length) return false;

    for (int i = 0; i < positions.length; i++) {
      if (positions[i] != selected[positions.length - 1 - i]) {
        return false;
      }
    }
    return true;
  }
}

/// 메인 게임 화면
class HiddenWordPuzzleScreen extends StatefulWidget {
  const HiddenWordPuzzleScreen({super.key});

  @override
  State<HiddenWordPuzzleScreen> createState() =>
      _HiddenWordPuzzleScreenState();
}

class _HiddenWordPuzzleScreenState extends State<HiddenWordPuzzleScreen> {
  late List<List<String>> board; // 8x8 글자판
  late List<WordData> words; // 찾을 낱말들
  late Set<String> foundWords; // 찾은 낱말 목록
  late List<(int, int)> currentSelection; // 현재 선택 중인 칸들
  late Map<String, List<(int, int)>> foundPositions; // 찾은 낱말의 위치들
  int lastHintIndex = -1; // 마지막으로 힌트한 낱말 인덱스

  // 글자판에 쓸 한글 문자들
  static const String koreanChars =
      '가나다라마바사아자차카타파하나누네노뭐버서어여오유이우은은인임일입인인';

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    board = List.generate(8, (i) => List.filled(8, ''));
    words = [];
    foundWords = {};
    currentSelection = [];
    foundPositions = {};

    _generateBoard();
  }

  void _generateBoard() {
    // 먼저 보드를 임의의 글자로 채우기
    final random = DateTime.now().microsecond;
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        board[i][j] =
            koreanChars[(random + i * 8 + j) % koreanChars.length];
      }
    }

    // 낱말 배치
    // 낱말: 원, 각도, 삼각형, 덧셈, 마방진

    // 1. "원" - 가로, (0, 0)부터
    words.add(WordData(
      word: '원',
      startRow: 0,
      startCol: 0,
      direction: 'horizontal',
    ));
    _placeWord(words.last);

    // 2. "각도" - 세로, (1, 2)부터
    words.add(WordData(
      word: '각도',
      startRow: 1,
      startCol: 2,
      direction: 'vertical',
    ));
    _placeWord(words.last);

    // 3. "삼각형" - 가로, (2, 3)부터
    words.add(WordData(
      word: '삼각형',
      startRow: 2,
      startCol: 3,
      direction: 'horizontal',
    ));
    _placeWord(words.last);

    // 4. "덧셈" - 세로, (3, 0)부터
    words.add(WordData(
      word: '덧셈',
      startRow: 3,
      startCol: 0,
      direction: 'vertical',
    ));
    _placeWord(words.last);

    // 5. "마방진" - 가로, (5, 1)부터
    words.add(WordData(
      word: '마방진',
      startRow: 5,
      startCol: 1,
      direction: 'horizontal',
    ));
    _placeWord(words.last);
  }

  void _placeWord(WordData wordData) {
    for (int i = 0; i < wordData.word.length; i++) {
      if (wordData.direction == 'horizontal') {
        board[wordData.startRow][wordData.startCol + i] =
            wordData.word[i];
      } else {
        board[wordData.startRow + i][wordData.startCol] =
            wordData.word[i];
      }
    }
  }

  /// 선택 가능한지 확인 (가로 또는 세로 직선)
  bool _isValidSelection(List<(int, int)> selected) {
    if (selected.isEmpty) return false;

    // 한 칸만 선택된 경우는 유효하지 않음
    if (selected.length == 1) return false;

    int firstRow = selected[0].$1;
    int firstCol = selected[0].$2;

    // 모두 같은 행인지 (가로)
    bool isHorizontal =
        selected.every((cell) => cell.$1 == firstRow);

    // 모두 같은 열인지 (세로)
    bool isVertical =
        selected.every((cell) => cell.$2 == firstCol);

    if (!isHorizontal && !isVertical) return false;

    // 연속된 칸인지 확인
    selected.sort((a, b) {
      if (a.$1 != b.$1) return a.$1.compareTo(b.$1);
      return a.$2.compareTo(b.$2);
    });

    for (int i = 1; i < selected.length; i++) {
      int prevRow = selected[i - 1].$1;
      int prevCol = selected[i - 1].$2;
      int currRow = selected[i].$1;
      int currCol = selected[i].$2;

      if (isHorizontal && currCol != prevCol + 1) return false;
      if (isVertical && currRow != prevRow + 1) return false;
    }

    return true;
  }

  /// 선택 확인 및 낱말 매칭
  void _confirmSelection() {
    if (!_isValidSelection(currentSelection)) {
      setState(() {
        currentSelection = [];
      });
      return;
    }

    for (var word in words) {
      if (foundWords.contains(word.word)) continue;

      // 정방향 확인
      if (word.matchesSelection(currentSelection)) {
        setState(() {
          foundWords.add(word.word);
          foundPositions[word.word] = List.from(word.positions);
          currentSelection = [];
        });
        return;
      }

      // 역방향 확인
      if (word.matchesSelectionReverse(currentSelection)) {
        setState(() {
          foundWords.add(word.word);
          foundPositions[word.word] = List.from(word.positions);
          currentSelection = [];
        });
        return;
      }
    }

    // 일치하는 낱말이 없으면 선택 초기화
    setState(() {
      currentSelection = [];
    });
  }

  void _resetPuzzle() {
    setState(() {
      foundWords.clear();
      foundPositions.clear();
      currentSelection = [];
      lastHintIndex = -1;
    });
  }

  void _showHint() {
    // 아직 찾지 못한 낱말 찾기
    for (int i = 0; i < words.length; i++) {
      if (!foundWords.contains(words[i].word)) {
        lastHintIndex = i;

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
                  Text(
                    '"${words[i].word}"를 찾아보세요!',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF091F59),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${words[i].direction == 'horizontal' ? '가로' : '세로'} 방향으로 있습니다.',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF5B7BA6),
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
        return;
      }
    }

    // 모두 찾은 경우
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🎉 모두 찾았어요!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _checkAnswer() {
    bool allFound = foundWords.length == words.length;

    if (allFound) {
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
                  '모든 낱말을 찾았어요!\n정말 잘했어요!',
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
    } else {
      int remaining = words.length - foundWords.length;
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
                  '아직이에요!',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFE05C57),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '아직 $remaining개의 낱말이 남았어요.\n계속 찾아보세요!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
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
  }

  /// 특정 칸이 찾은 낱말에 포함되는지 확인
  bool _isCellInFoundWord(int row, int col) {
    for (var positions in foundPositions.values) {
      if (positions.contains((row, col))) {
        return true;
      }
    }
    return false;
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
                vertical: isCompact ? 8 : 12,
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
                    '🔍 숨은 낱말 찾기 - 문제 2',
                    style: TextStyle(
                      fontSize: isCompact ? 24 : 32,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF163988),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '글자판에서 숨은 수학 낱말 5개를 찾아보세요!',
                    style: TextStyle(
                      fontSize: isCompact ? 18 : 24,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF5B7BA6),
                    ),
                  ),
                ],
              ),
            ),

            // 낱말 목록
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.04,
                vertical: screenSize.height * 0.01,
              ),
              child: SizedBox(
                height: isCompact ? 50 : 70,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (var word in words)
                      _buildWordCard(word.word, foundWords.contains(word.word),
                          isCompact, screenSize),
                  ],
                ),
              ),
            ),

            // 글자판
            Expanded(
              child: Center(
                child: _buildGameBoard(screenSize, isCompact),
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

  /// 낱말 카드 위젯
  Widget _buildWordCard(String word, bool found, bool isCompact, Size screenSize) {
    return Container(
      margin: EdgeInsets.only(right: screenSize.width * 0.02),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: found ? const Color(0xFFC8E6C9) : const Color(0xFFFFE0B2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: found ? const Color(0xFF4CAF50) : const Color(0xFFFFA726),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            word,
            style: TextStyle(
              fontSize: isCompact ? 16 : 20,
              fontWeight: FontWeight.w800,
              color: found ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
              decoration: found ? TextDecoration.lineThrough : null,
            ),
          ),
          if (found) ...[
            const SizedBox(width: 8),
            const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 20),
          ],
        ],
      ),
    );
  }

  /// 게임 보드 위젯
  Widget _buildGameBoard(Size screenSize, bool isCompact) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 가용 공간 중 작은 쪽을 기준으로 정사각형 보드 크기 결정
        final boardSize = math.min(constraints.maxWidth, constraints.maxHeight);
        final cellSize = boardSize / 8;

        return GestureDetector(
          onPanStart: (details) {
            final pos = _getGridPosition(details.localPosition, cellSize);
            if (pos != null) {
              setState(() {
                currentSelection = [pos];
              });
            }
          },
          onPanUpdate: (details) {
            final pos = _getGridPosition(details.localPosition, cellSize);
            if (pos != null && _canAddToSelection(pos)) {
              setState(() {
                currentSelection.add(pos);
              });
            }
          },
          onPanEnd: (details) {
            _confirmSelection();
          },
          child: Container(
            width: boardSize,
            height: boardSize,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFF163988), width: 3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                // 글자 격자
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                  ),
                  itemCount: 64,
                  itemBuilder: (context, index) {
                    int row = index ~/ 8;
                    int col = index % 8;
                    bool isSelected = currentSelection.contains((row, col));
                    bool isFoundCell = _isCellInFoundWord(row, col);

                    return GestureDetector(
                      onTap: () {
                        if (_canAddToSelection((row, col))) {
                          setState(() {
                            currentSelection.add((row, col));
                            _confirmSelection();
                          });
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isFoundCell
                              ? const Color(0xFFB3E5FC).withValues(alpha: 0.8)
                              : isSelected
                                  ? const Color(0xFFFFF9C4)
                                  : Colors.white,
                          border: Border.all(
                            color: const Color(0xFFBDBDBD),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            board[row][col],
                            style: TextStyle(
                              fontSize: cellSize * 0.5,
                              fontWeight: FontWeight.w900,
                              color: isFoundCell
                                  ? const Color(0xFF01579B)
                                  : const Color(0xFF091F59),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 터치 위치에서 격자 위치 계산
  (int, int)? _getGridPosition(Offset localPosition, double cellSize) {
    int col = (localPosition.dx / cellSize).floor();
    int row = (localPosition.dy / cellSize).floor();

    if (row >= 0 && row < 8 && col >= 0 && col < 8) {
      return (row, col);
    }
    return null;
  }

  /// 선택에 칸을 추가할 수 있는지 확인
  bool _canAddToSelection((int, int) newCell) {
    if (currentSelection.contains(newCell)) return false;

    if (currentSelection.length == 1) {
      int row1 = currentSelection[0].$1;
      int col1 = currentSelection[0].$2;
      int row2 = newCell.$1;
      int col2 = newCell.$2;

      // 인접한 칸인지 확인
      bool isAdjacent = (row1 == row2 && (col1 - col2).abs() == 1) ||
          (col1 == col2 && (row1 - row2).abs() == 1);

      return isAdjacent;
    }

    // 이미 여러 칸을 선택한 경우
    int lastRow = currentSelection.last.$1;
    int lastCol = currentSelection.last.$2;

    // 마지막 칸과 인접해야 함
    bool isAdjacent = (lastRow == newCell.$1 && (lastCol - newCell.$2).abs() == 1) ||
        (lastCol == newCell.$2 && (lastRow - newCell.$1).abs() == 1);

    if (!isAdjacent) return false;

    // 직선 방향 유지 확인
    if (currentSelection.length >= 2) {
      int row0 = currentSelection[0].$1;
      int col0 = currentSelection[0].$2;

      bool isHorizontal = currentSelection.every((cell) => cell.$1 == row0);
      bool isVertical = currentSelection.every((cell) => cell.$2 == col0);

      if (!isHorizontal && !isVertical) return false;

      // 직선 방향으로만 추가 가능
      if (isHorizontal && newCell.$1 != row0) return false;
      if (isVertical && newCell.$2 != col0) return false;
    }

    return true;
  }
}
