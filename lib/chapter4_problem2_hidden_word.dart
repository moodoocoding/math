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
      title: '?⑥? ?깅쭚 李얘린 ?쇱쫹',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HiddenWordPuzzleScreen(),
    );
  }
}

/// ?깅쭚 ?곗씠??紐⑤뜽
class WordData {
  final String word;
  final int startRow;
  final int startCol;
  final String direction; // 'horizontal' or 'vertical'
  late final List<(int, int)> positions; // ?깅쭚??李⑥??섎뒗 紐⑤뱺 移?

  WordData({
    required this.word,
    required this.startRow,
    required this.startCol,
    required this.direction,
  }) {
    // ?깅쭚??紐⑤뱺 移?醫뚰몴 怨꾩궛
    positions = [];
    for (int i = 0; i < word.length; i++) {
      if (direction == 'horizontal') {
        positions.add((startRow, startCol + i));
      } else {
        positions.add((startRow + i, startCol));
      }
    }
  }

  /// ???깅쭚??二쇱뼱吏?移몃뱾???좏깮怨??뺥솗???쇱튂?섎뒗吏 ?뺤씤
  bool matchesSelection(List<(int, int)> selected) {
    if (selected.length != word.length) return false;

    // 媛숈? ?쒖꽌濡??쇱튂?섎뒗吏 ?뺤씤
    for (int i = 0; i < positions.length; i++) {
      if (positions[i] != selected[i]) return false;
    }
    return true;
  }

  /// ??닚?쇰줈???쇱튂?섎뒗吏 ?뺤씤 (嫄곗슱??
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

/// 硫붿씤 寃뚯엫 ?붾㈃
class HiddenWordPuzzleScreen extends StatefulWidget {
  const HiddenWordPuzzleScreen({super.key, this.completedRouteName});

  final String? completedRouteName;

  @override
  State<HiddenWordPuzzleScreen> createState() =>
      _HiddenWordPuzzleScreenState();
}

class _HiddenWordPuzzleScreenState extends State<HiddenWordPuzzleScreen> {
  late List<List<String>> board; // 8x8 湲?먰뙋
  late List<WordData> words; // 李얠쓣 ?깅쭚??
  late Set<String> foundWords; // 李얠? ?깅쭚 紐⑸줉
  late List<(int, int)> currentSelection; // ?꾩옱 ?좏깮 以묒씤 移몃뱾
  late Map<String, List<(int, int)>> foundPositions; // 李얠? ?깅쭚???꾩튂??
  int lastHintIndex = -1; // 留덉?留됱쑝濡??뚰듃???깅쭚 ?몃뜳??

  static const String koreanChars =
      '가나다라마바사아자차카타파하거너더러머버서어저처커터퍼허고노도로모보소오조초코토포호';

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
    // 癒쇱? 蹂대뱶瑜??꾩쓽??湲?먮줈 梨꾩슦湲?
    final random = DateTime.now().microsecond;
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        board[i][j] =
            koreanChars[(random + i * 8 + j) % koreanChars.length];
      }
    }

    // Chapter 4 words. Each word has at least two letters so it can be selected.
    words.add(WordData(
      word: '도형',
      startRow: 0,
      startCol: 0,
      direction: 'horizontal',
    ));
    _placeWord(words.last);

    words.add(WordData(
      word: '각도',
      startRow: 1,
      startCol: 2,
      direction: 'vertical',
    ));
    _placeWord(words.last);

    words.add(WordData(
      word: '삼각형',
      startRow: 2,
      startCol: 3,
      direction: 'horizontal',
    ));
    _placeWord(words.last);

    words.add(WordData(
      word: '덧셈',
      startRow: 3,
      startCol: 0,
      direction: 'vertical',
    ));
    _placeWord(words.last);

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

  /// ?좏깮 媛?ν븳吏 ?뺤씤 (媛濡??먮뒗 ?몃줈 吏곸꽑)
  bool _isValidSelection(List<(int, int)> selected) {
    if (selected.isEmpty) return false;

    // ??移몃쭔 ?좏깮??寃쎌슦???좏슚?섏? ?딆쓬
    if (selected.length == 1) return false;

    int firstRow = selected[0].$1;
    int firstCol = selected[0].$2;

    // 紐⑤몢 媛숈? ?됱씤吏 (媛濡?
    bool isHorizontal =
        selected.every((cell) => cell.$1 == firstRow);

    // 紐⑤몢 媛숈? ?댁씤吏 (?몃줈)
    bool isVertical =
        selected.every((cell) => cell.$2 == firstCol);

    if (!isHorizontal && !isVertical) return false;

    // ?곗냽??移몄씤吏 ?뺤씤
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

  /// ?좏깮 ?뺤씤 諛??깅쭚 留ㅼ묶
  void _confirmSelection() {
    if (!_isValidSelection(currentSelection)) {
      setState(() {
        currentSelection = [];
      });
      return;
    }

    for (var word in words) {
      if (foundWords.contains(word.word)) continue;

      // ?뺣갑???뺤씤
      if (word.matchesSelection(currentSelection)) {
        setState(() {
          foundWords.add(word.word);
          foundPositions[word.word] = List.from(word.positions);
          currentSelection = [];
        });
        return;
      }

      // ??갑???뺤씤
      if (word.matchesSelectionReverse(currentSelection)) {
        setState(() {
          foundWords.add(word.word);
          foundPositions[word.word] = List.from(word.positions);
          currentSelection = [];
        });
        return;
      }
    }

    // ?쇱튂?섎뒗 ?깅쭚???놁쑝硫??좏깮 珥덇린??
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

  void _skipPuzzleForTest() {
    if (widget.completedRouteName != null) {
      Navigator.pushReplacementNamed(context, widget.completedRouteName!);
    } else {
      Navigator.maybePop(context);
    }
  }

  void _showHint() {
    // ?꾩쭅 李얠? 紐삵븳 ?깅쭚 李얘린
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
                    '?뮕 ?뚰듃',
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
        return;
      }
    }

    // 紐⑤몢 李얠? 寃쎌슦
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '?럦 紐⑤몢 李얠븯?댁슂!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('?뺤씤'),
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
                  '?럦 ?뺣떟?낅땲?? ?럦',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF18BEB6),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '紐⑤뱺 ?깅쭚??李얠븯?댁슂!\n?뺣쭚 ?섑뻽?댁슂!',
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
                  '?꾩쭅?댁뿉??',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFE05C57),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '?꾩쭅 $remaining媛쒖쓽 ?깅쭚???⑥븯?댁슂.\n怨꾩냽 李얠븘蹂댁꽭??',
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
  }

  /// ?뱀젙 移몄씠 李얠? ?깅쭚???ы븿?섎뒗吏 ?뺤씤
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
                '문제2: 글자판에서 찾을 수 있는 수학 낱말은 무엇일까요?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isCompact ? 28 : 38,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF091F59),
                ),
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
                      _buildWordCard(
                        word.word,
                        foundWords.contains(word.word),
                        isCompact,
                        screenSize,
                      ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: Center(
                child: _buildGameBoard(screenSize, isCompact),
              ),
            ),

            // ?섎떒: 踰꾪듉
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

  /// ?깅쭚 移대뱶 ?꾩젽
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

  /// 寃뚯엫 蹂대뱶 ?꾩젽
  Widget _buildGameBoard(Size screenSize, bool isCompact) {
    final boardSize = screenSize.height * 0.55;
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
            // 湲??寃⑹옄
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
              ),
              itemCount: 64,
              itemBuilder: (context, index) {
                int row = index ~/ 8;
                int col = index % 8;
                bool isSelected =
                    currentSelection.contains((row, col));
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
                          fontWeight: FontWeight.w800,
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
  }

  /// ?곗튂 ?꾩튂?먯꽌 寃⑹옄 ?꾩튂 怨꾩궛
  (int, int)? _getGridPosition(Offset localPosition, double cellSize) {
    int col = (localPosition.dx / cellSize).floor();
    int row = (localPosition.dy / cellSize).floor();

    if (row >= 0 && row < 8 && col >= 0 && col < 8) {
      return (row, col);
    }
    return null;
  }

  /// ?좏깮??移몄쓣 異붽??????덈뒗吏 ?뺤씤
  bool _canAddToSelection((int, int) newCell) {
    if (currentSelection.contains(newCell)) return false;

    if (currentSelection.length == 1) {
      int row1 = currentSelection[0].$1;
      int col1 = currentSelection[0].$2;
      int row2 = newCell.$1;
      int col2 = newCell.$2;

      // ?몄젒??移몄씤吏 ?뺤씤
      bool isAdjacent = (row1 == row2 && (col1 - col2).abs() == 1) ||
          (col1 == col2 && (row1 - row2).abs() == 1);

      return isAdjacent;
    }

    // ?대? ?щ윭 移몄쓣 ?좏깮??寃쎌슦
    int lastRow = currentSelection.last.$1;
    int lastCol = currentSelection.last.$2;

    // 留덉?留?移멸낵 ?몄젒?댁빞 ??
    bool isAdjacent = (lastRow == newCell.$1 && (lastCol - newCell.$2).abs() == 1) ||
        (lastCol == newCell.$2 && (lastRow - newCell.$1).abs() == 1);

    if (!isAdjacent) return false;

    // 吏곸꽑 諛⑺뼢 ?좎? ?뺤씤
    if (currentSelection.length >= 2) {
      int row0 = currentSelection[0].$1;
      int col0 = currentSelection[0].$2;

      bool isHorizontal = currentSelection.every((cell) => cell.$1 == row0);
      bool isVertical = currentSelection.every((cell) => cell.$2 == col0);

      if (!isHorizontal && !isVertical) return false;

      // 吏곸꽑 諛⑺뼢?쇰줈留?異붽? 媛??
      if (isHorizontal && newCell.$1 != row0) return false;
      if (isVertical && newCell.$2 != col0) return false;
    }

    return true;
  }
}
