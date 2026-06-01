import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'bgm_toggle_button.dart';
import 'bgm_controller.dart';

class WordData {
  final String word;
  final int startRow;
  final int startCol;
  final String direction; // 'horizontal' or 'vertical'
  late final List<(int, int)> positions;

  WordData({
    required this.word,
    required this.startRow,
    required this.startCol,
    required this.direction,
  }) {
    positions = [];
    for (int i = 0; i < word.length; i++) {
      if (direction == 'horizontal') {
        positions.add((startRow, startCol + i));
      } else {
        positions.add((startRow + i, startCol));
      }
    }
  }

  bool matchesSelection(List<(int, int)> selected) {
    if (selected.length != word.length) return false;
    for (int i = 0; i < positions.length; i++) {
      if (positions[i] != selected[i]) return false;
    }
    return true;
  }

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

class HiddenWordPuzzleScreen extends StatefulWidget {
  const HiddenWordPuzzleScreen({super.key, this.completedRouteName});

  final String? completedRouteName;

  @override
  State<HiddenWordPuzzleScreen> createState() => _HiddenWordPuzzleScreenState();
}

class _HiddenWordPuzzleScreenState extends State<HiddenWordPuzzleScreen> {
  late List<List<String>> board; // 10x10 글자판
  late List<WordData> words; // 찾을 낱말들
  late Set<String> foundWords; // 찾은 낱말 목록
  late List<(int, int)> currentSelection; // 현재 선택 중인 칸들
  late Map<String, List<(int, int)>> foundPositions; // 찾은 낱말들의 위치들
  int lastHintIndex = -1;
  List<(int, int)>? _hintPositions;

  static const List<String> layout = [
    '알고리즘가머나루다라',
    '마바사아조신자프페로',
    '인공지능건러카타이봇',
    '하거너더문닝파하스차',
    '코딩블록디리미비로머',
    '미비시이지치키티봇리',
    '자율주행히제미있수학',
    '놀이공원에서만나요로',
    '센서감지작동명령실봇',
    '즐거운코딩교실최고야',
  ];

  @override
  void initState() {
    super.initState();
    AppBgmController.playProblem();
    _initializeGame();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showOnboardingTutorial();
    });
  }

  void _initializeGame() {
    board = List.generate(10, (i) => List.filled(10, ''));
    words = [];
    foundWords = {};
    currentSelection = [];
    foundPositions = {};
    _hintPositions = null;

    _generateBoard();
  }

  void _generateBoard() {
    // 10x10 고정 글자판 문자 파싱 및 할당
    for (int i = 0; i < 10; i++) {
      for (int j = 0; j < 10; j++) {
        board[i][j] = layout[i][j];
      }
    }

    // 8개 AI & 코딩 낱말 설정 및 좌표 정의
    words.add(
      WordData(word: '알고리즘', startRow: 0, startCol: 0, direction: 'horizontal'),
    );
    words.add(
      WordData(word: '인공지능', startRow: 2, startCol: 0, direction: 'horizontal'),
    );
    words.add(
      WordData(word: '코딩블록', startRow: 4, startCol: 0, direction: 'horizontal'),
    );
    words.add(
      WordData(word: '자율주행', startRow: 6, startCol: 0, direction: 'horizontal'),
    );
    words.add(
      WordData(word: '머신러닝', startRow: 0, startCol: 5, direction: 'vertical'),
    );
    words.add(
      WordData(word: '조건문', startRow: 1, startCol: 4, direction: 'vertical'),
    );
    words.add(
      WordData(word: '루프', startRow: 0, startCol: 7, direction: 'vertical'),
    );
    words.add(
      WordData(word: '페이스로봇', startRow: 1, startCol: 8, direction: 'vertical'),
    );
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
      int prevRow = sorted[i - 1].$1;
      int prevCol = sorted[i - 1].$2;
      int currRow = sorted[i].$1;
      int currCol = sorted[i].$2;

      if (isHorizontal && currCol != prevCol + 1) return false;
      if (isVertical && currRow != prevRow + 1) return false;
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
          _hintPositions = null;
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
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.check_circle,
                    size: 80,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '🎉 숨은 단서를 모두 찾았어요! 🎉',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF13968F),
                  fontFamily: 'GangwonEduAll',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '코딩 단서들이 하나로 이어졌어요!\n다음 체험으로 가는 길이 열렸어요!',
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
      _hintPositions = null;
    });
  }

  void _showHint() {
    AppSfxController.playClick();
    int nextHintIndex = (lastHintIndex + 1) % words.length;
    int count = 0;
    while (foundWords.contains(words[nextHintIndex].word) &&
        count < words.length) {
      nextHintIndex = (nextHintIndex + 1) % words.length;
      count++;
    }

    if (count == words.length) return;

    lastHintIndex = nextHintIndex;
    final targetWord = words[nextHintIndex];
    final hintWord = targetWord.word;

    setState(() {
      _hintPositions = targetWord.positions;
    });

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
                '찾아야 할 단서 낱말: \'$hintWord\'',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'GangwonEduAll',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '위치 힌트: ${targetWord.startRow + 1}번째 줄, ${targetWord.startCol + 1}번째 칸에서 ${targetWord.direction == 'horizontal' ? '가로(오른쪽)' : '세로(아래쪽)'} 방향으로 단서가 이어져요.\n빨간색으로 반짝이는 글자를 따라가 보세요.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4B5563),
                  height: 1.35,
                  fontFamily: 'GangwonEduAll',
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  '확인',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _skipPuzzleForTest() {
    if (widget.completedRouteName != null) {
      Navigator.pushReplacementNamed(context, widget.completedRouteName!);
    }
  }

  void _checkAnswer() {
    if (foundWords.length == words.length) {
      _showSuccessDialog();
    } else {
      AppSfxController.playWrong();
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/chr_how_fail.png',
                  height: 150,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Color(0xFFD64A45),
                  ),
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
              width: 540,
              padding: const EdgeInsets.all(26),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '🔍 숨은 코딩 단서 찾기',
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
                      '글자판이란? 🔍',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF091F59),
                        fontFamily: 'GangwonEduAll',
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      '10×10 글자판 안에 코딩과 인공지능 단서가\n가로 또는 세로 방향으로 숨어 있어요!\n다른 글자 사이에 섞여 있으니 잘 찾아보세요.',
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
                    _buildTutorialSlide1(),
                  ] else if (tutorialStep == 1) ...[
                    const Text(
                      '이렇게 찾아요! 👆',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF091F59),
                        fontFamily: 'GangwonEduAll',
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      '첫 글자에서 마지막 글자까지\n손가락으로 쭉 드래그하세요!\n맞으면 글자 색이 바뀌어요.',
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
                    _buildTutorialSlide2(),
                  ] else ...[
                    const Text(
                      '힌트를 활용해요! 💡',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF091F59),
                        fontFamily: 'GangwonEduAll',
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      '못 찾겠을 땐 힌트 버튼을 눌러보세요!\n아직 못 찾은 단서의 위치가\n빨간색으로 표시돼요.',
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
                    _buildTutorialSlide3(),
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
                        tutorialStep < 2 ? '다음' : '도전 시작하기! 🔍',
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

  Widget _buildTutorialSlide1() {
    final sampleLetters = [
      ['알', '고', '리', '즘', '가', '나', '다', '라', '마', '바'],
      ['사', '아', '자', '차', '조', '카', '타', '파', '페', '로'],
      ['인', '공', '지', '능', '건', '러', '하', '이', '봇', '수'],
      ['코', '딩', '블', '록', '디', '리', '미', '비', '로', '학'],
    ];
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF133E97), width: 2),
      ),
      child: Column(
        children: [
          for (int r = 0; r < sampleLetters.length; r++)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int c = 0; c < sampleLetters[r].length; c++)
                  Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: (r == 0 && c <= 3) || (r == 2 && c <= 3)
                          ? const Color(0xFFB3E5FC)
                          : Colors.white,
                      border: Border.all(
                        color: const Color(0xFFBDBDBD),
                        width: 0.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        sampleLetters[r][c],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: (r == 0 && c <= 3) || (r == 2 && c <= 3)
                              ? const Color(0xFF01579B)
                              : const Color(0xFF091F59),
                          fontFamily: 'GangwonEduAll',
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 14, height: 14, color: const Color(0xFFB3E5FC)),
              const SizedBox(width: 6),
              const Text(
                '= 숨은 단서 (가로/세로)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'GangwonEduAll',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialSlide2() {
    final letters = ['코', '딩', '블', '록'];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF133E97), width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final ch in letters)
                Container(
                  width: 48,
                  height: 48,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9C4),
                    border: Border.all(
                      color: const Color(0xFFFBC02D),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      ch,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF091F59),
                        fontFamily: 'GangwonEduAll',
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          const Icon(Icons.arrow_downward, color: Color(0xFF133E97), size: 28),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final ch in letters)
                Container(
                  width: 48,
                  height: 48,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB3E5FC),
                    border: Border.all(
                      color: const Color(0xFF0288D1),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      ch,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF01579B),
                        fontFamily: 'GangwonEduAll',
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 14, height: 14, color: const Color(0xFFFFF9C4)),
              const SizedBox(width: 4),
              const Text(
                '드래그 중',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'GangwonEduAll',
                ),
              ),
              const SizedBox(width: 12),
              Container(width: 14, height: 14, color: const Color(0xFFB3E5FC)),
              const SizedBox(width: 4),
              const Text(
                '찾기 완료!',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'GangwonEduAll',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialSlide3() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF133E97), width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final ch in ['루', '프'])
                Container(
                  width: 48,
                  height: 48,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    border: Border.all(color: Colors.redAccent, width: 2.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      ch,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.red,
                        fontFamily: 'GangwonEduAll',
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF6F63D1), width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.lightbulb_outline,
                  color: Color(0xFF6F63D1),
                  size: 22,
                ),
                SizedBox(width: 6),
                Text(
                  '힌트 버튼 → 빨간 표시!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6F63D1),
                    fontFamily: 'GangwonEduAll',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isCompact = screenSize.height < 600;
    final isMobile = screenSize.width < 600;

    final mainContent = Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(8, 4, 8, 4),
          padding: EdgeInsets.symmetric(vertical: isCompact ? 8 : 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '글자판 속에 숨어든 AI와 코딩 단서 낱말을 모두 찾아보세요!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isCompact ? 22 : 28,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF091F59),
                  fontFamily: 'GangwonEduAll',
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '(가이드: 글자판의 글자들을 드래그하여 단어를 연결해 보세요.)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isCompact ? 15 : 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF3B82F6),
                  fontFamily: 'GangwonEduAll',
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
            height: isCompact ? 50 : 66,
            child: Center(
              child: ListView(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
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
        ),
        Expanded(child: Center(child: _buildGameBoard(screenSize, isCompact))),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.width * 0.03,
            vertical: isCompact ? 10 : 14,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE1E1E4), width: 1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _showHint,
                      icon: Icon(
                        Icons.lightbulb_outline,
                        size: isMobile ? 20 : 24,
                      ),
                      label: Text(
                        '힌트',
                        style: TextStyle(fontSize: isMobile ? 16 : 18),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6F63D1),
                        side: const BorderSide(
                          color: Color(0xFF6F63D1),
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _resetPuzzle,
                      icon: Icon(Icons.refresh, size: isMobile ? 20 : 24),
                      label: Text(
                        '다시하기',
                        style: TextStyle(fontSize: isMobile ? 16 : 18),
                      ),
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
                      icon: Icon(Icons.check_circle, size: isMobile ? 20 : 24),
                      label: Text(
                        '단서 확인',
                        style: TextStyle(fontSize: isMobile ? 16 : 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF123E97),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 6),
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
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF163988),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 30),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
          ),
        ),
        title: const Text(
          '미션! 수학체험센터의 반짝별을 찾아서',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          const BgmToggleButton(iconSize: 32),
          IconButton(
            icon: const Icon(Icons.home, size: 32),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            ),
          ),
        ],
      ),
      body: SafeArea(child: mainContent),
    );
  }

  Widget _buildWordCard(
    String word,
    bool found,
    bool isCompact,
    Size screenSize,
  ) {
    return Container(
      margin: EdgeInsets.only(right: screenSize.width * 0.02),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: found ? const Color(0xFFE2F9E5) : const Color(0xFFEBF0FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: found ? const Color(0xFF78DB8F) : const Color(0xFF9FB2EB),
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
              color: found ? const Color(0xFF1D6B30) : const Color(0xFF1A367C),
              decoration: found ? TextDecoration.lineThrough : null,
              fontFamily: 'GangwonEduAll',
            ),
          ),
          if (found) ...[
            const SizedBox(width: 8),
            const Icon(Icons.check_circle, color: Color(0xFF1D6B30), size: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildGameBoard(Size screenSize, bool isCompact) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize =
            math.min(constraints.maxWidth, constraints.maxHeight) * 0.95;
        final cellSize = boardSize / 10;

        return GestureDetector(
          onPanStart: (details) {
            final pos = _getGridPosition(details.localPosition, cellSize);
            if (pos != null) {
              setState(() {
                _hintPositions = null;
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
                crossAxisCount: 10,
              ),
              itemCount: 100,
              itemBuilder: (context, index) {
                int row = index ~/ 10;
                int col = index % 10;
                bool isSelected = currentSelection.contains((row, col));
                bool isFoundCell = _isCellInFoundWord(row, col);
                bool isHintCell =
                    _hintPositions != null &&
                    _hintPositions!.contains((row, col));

                return Container(
                  decoration: BoxDecoration(
                    color: isFoundCell
                        ? const Color(0xFFB3E5FC).withValues(alpha: 0.8)
                        : isSelected
                        ? const Color(0xFFFFF9C4)
                        : isHintCell
                        ? const Color(0xFFFFEBEE)
                        : Colors.white,
                    border: isHintCell
                        ? Border.all(color: Colors.redAccent, width: 2.5)
                        : Border.all(color: const Color(0xFFBDBDBD), width: 1),
                  ),
                  child: Center(
                    child: Text(
                      board[row][col],
                      style: TextStyle(
                        fontSize: cellSize * 0.5,
                        fontWeight: FontWeight.w900,
                        color: isFoundCell
                            ? const Color(0xFF01579B)
                            : isHintCell
                            ? Colors.red
                            : const Color(0xFF091F59),
                        fontFamily: 'GangwonEduAll',
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
    if (row >= 0 && row < 10 && col >= 0 && col < 10) return (row, col);
    return null;
  }

  bool _canAddToSelection((int, int) newCell) {
    if (currentSelection.contains(newCell)) return false;
    if (currentSelection.isEmpty) return true;

    int lastRow = currentSelection.last.$1;
    int lastCol = currentSelection.last.$2;

    bool isAdjacent =
        (lastRow == newCell.$1 && (lastCol - newCell.$2).abs() == 1) ||
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
