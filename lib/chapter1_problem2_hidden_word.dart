import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'bgm_toggle_button.dart';
import 'bgm_controller.dart';
import 'sfx_controller.dart';

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
  const HiddenWordPuzzleScreen({super.key, this.completedRouteName});

  final String? completedRouteName;

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
    AppBgmController.playProblem();
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
    // 임의의 글자로 보드 채우기
    final random = math.Random();
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        board[i][j] = koreanChars[random.nextInt(koreanChars.length)];
      }
    }

    // 챕터 1 단어들 설정 (실제 미션 내용에 맞게 조정 필요시 수정 가능)
    words.add(WordData(
      word: '수학',
      startRow: 0,
      startCol: 1,
      direction: 'vertical',
    ));
    _placeWord(words.last);

    words.add(WordData(
      word: '체험',
      startRow: 2,
      startCol: 2,
      direction: 'horizontal',
    ));
    _placeWord(words.last);

    words.add(WordData(
      word: '센터',
      startRow: 4,
      startCol: 3,
      direction: 'vertical',
    ));
    _placeWord(words.last);

    words.add(WordData(
      word: '미션',
      startRow: 5,
      startCol: 0,
      direction: 'horizontal',
    ));
    _placeWord(words.last);

    words.add(WordData(
      word: '성공',
      startRow: 1,
      startCol: 5,
      direction: 'vertical',
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

  bool _isValidSelection(List<(int, int)> selected) {
    if (selected.isEmpty) return false;
    if (selected.length == 1) return false;

    int firstRow = selected[0].$1;
    int firstCol = selected[0].$2;

    bool isHorizontal = selected.every((cell) => cell.$1 == firstRow);
    bool isVertical = selected.every((cell) => cell.$2 == firstCol);

    if (!isHorizontal && !isVertical) return false;

    List<(int, int)> sorted = List.from(selected);
    sorted.sort((a, b) {
      if (a.$1 != b.$1) return a.$1.compareTo(b.$1);
      return a.$2.compareTo(b.$2);
    });

    for (int i = 1; i < sorted.length; i++) {
      if (isHorizontal && sorted[i].$2 != sorted[i - 1].$2 + 1) return false;
      if (isVertical && sorted[i].$1 != sorted[i - 1].$1 + 1) return false;
    }

    return true;
  }

  void _confirmSelection() {
    if (!_isValidSelection(currentSelection)) {
      setState(() {
        currentSelection = [];
      });
      return;
    }

    for (var word in words) {
      if (foundWords.contains(word.word)) continue;

      if (word.matchesSelection(currentSelection) || 
          word.matchesSelectionReverse(currentSelection)) {
        AppSfxController.playCorrect();
        setState(() {
          foundWords.add(word.word);
          foundPositions[word.word] = List.from(word.positions);
          currentSelection = [];
        });
        
        if (foundWords.length == words.length) {
          _showSuccessDialog();
        }
        return;
      }
    }

    setState(() {
      currentSelection = [];
    });
  }

  void _showSuccessDialog() {
    AppSfxController.playCorrect();
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
              const SizedBox(height: 30),
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
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF13968F),
                  fontFamily: 'GangwonEduAll',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '모든 낱말을 찾았어요!\n정말 잘했어요!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4B5563),
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
                    if (widget.completedRouteName != null) {
                      Navigator.pushReplacementNamed(
                        context,
                        widget.completedRouteName!,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF133E97),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(
                      fontSize: 28,
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

  void _resetPuzzle() {
    AppSfxController.playClick();
    setState(() {
      foundWords = {};
      foundPositions = {};
      currentSelection = [];
    });
  }

  void _showHint() {
    AppSfxController.playClick();
    int nextHintIndex = (lastHintIndex + 1) % words.length;
    int count = 0;
    while (foundWords.contains(words[nextHintIndex].word) && count < words.length) {
      nextHintIndex = (nextHintIndex + 1) % words.length;
      count++;
    }

    if (count == words.length) return;

    lastHintIndex = nextHintIndex;
    final hintWord = words[nextHintIndex].word;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '💡 힌트',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF6F63D1),
                  fontFamily: 'GangwonEduAll',
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '\'$hintWord\'을(를) 찾아보세요!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'GangwonEduAll',
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인', style: TextStyle(fontSize: 22)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _checkAnswer() {
    if (foundWords.length == words.length) {
      _showSuccessDialog();
    } else {
      AppSfxController.playWrong();
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/chr_how_fail.png',
                  height: 150,
                ),
                const SizedBox(height: 20),
                const Text(
                  '아직 다 못 찾았어요!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFD64A45),
                    fontFamily: 'GangwonEduAll',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '남은 낱말 수: ${words.length - foundWords.length}개',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'GangwonEduAll',
                  ),
                ),
                const SizedBox(height: 30),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('확인', style: TextStyle(fontSize: 22)),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

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
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF163988),
        elevation: 0,
        title: const Text('숨은 낱말 찾기', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          const BgmToggleButton(iconSize: 32),
          IconButton(
            icon: const Icon(Icons.home, size: 32),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.04,
                vertical: isCompact ? 8 : 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: const Color(0xFFF4C430).withOpacity(0.5), width: 2)),
              ),
              child: Column(
                children: [
                  Text(
                    '🔍 숨은 낱말 찾기',
                    style: TextStyle(
                      fontSize: isCompact ? 24 : 32,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF163988),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '글자판에서 숨은 수학 낱말을 찾아보세요!',
                    style: TextStyle(
                      fontSize: isCompact ? 18 : 24,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF5B7BA6),
                    ),
                  ),
                ],
              ),
            ),
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
                      _buildWordCard(word.word, foundWords.contains(word.word), isCompact, screenSize),
                  ],
                ),
              ),
            ),

            Expanded(
              child: Center(
                child: _buildGameBoard(screenSize, isCompact),
              ),
            ),

            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.03,
                vertical: isCompact ? 12 : 16,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE1E1E4), width: 1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _showHint,
                      icon: const Icon(Icons.lightbulb_outline),
                      label: const Text('힌트'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6F63D1),
                        side: const BorderSide(color: Color(0xFF6F63D1), width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _resetPuzzle,
                      icon: const Icon(Icons.refresh),
                      label: const Text('다시하기'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8A8A8A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _checkAnswer,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('정답 확인'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF123E97),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildGameBoard(Size screenSize, bool isCompact) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = math.min(constraints.maxWidth, constraints.maxHeight) * 0.95;
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
            child: GridView.builder(
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

                return Container(
                  decoration: BoxDecoration(
                    color: isFoundCell
                        ? const Color(0xFFB3E5FC).withOpacity(0.8)
                        : isSelected
                            ? const Color(0xFFFFF9C4)
                            : Colors.white,
                    border: Border.all(color: const Color(0xFFBDBDBD), width: 1),
                  ),
                  child: Center(
                    child: Text(
                      board[row][col],
                      style: TextStyle(
                        fontSize: cellSize * 0.5,
                        fontWeight: FontWeight.w900,
                        color: isFoundCell ? const Color(0xFF01579B) : const Color(0xFF091F59),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  (int, int)? _getGridPosition(Offset localPosition, double cellSize) {
    int col = (localPosition.dx / cellSize).floor();
    int row = (localPosition.dy / cellSize).floor();
    if (row >= 0 && row < 8 && col >= 0 && col < 8) return (row, col);
    return null;
  }

  bool _canAddToSelection((int, int) newCell) {
    if (currentSelection.contains(newCell)) return false;
    if (currentSelection.isEmpty) return true;

    int lastRow = currentSelection.last.$1;
    int lastCol = currentSelection.last.$2;

    bool isAdjacent = (lastRow == newCell.$1 && (lastCol - newCell.$2).abs() == 1) ||
        (lastCol == newCell.$2 && (lastRow - newCell.$1).abs() == 1);

    if (!isAdjacent) return false;

    if (currentSelection.length >= 2) {
      int row0 = currentSelection[0].$1;
      int col0 = currentSelection[0].$2;
      bool isHorizontal = currentSelection.every((cell) => cell.$1 == row0);
      bool isVertical = currentSelection.every((cell) => cell.$2 == col0);
      if (isHorizontal && newCell.$1 != row0) return false;
      if (isVertical && newCell.$2 != col0) return false;
    }
    return true;
  }
}
