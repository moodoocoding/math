import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'bgm_toggle_button.dart';
import 'bgm_controller.dart';

enum _ShapeChoiceType { square, circle, star, pentagon, unknown }

_ShapeChoiceType _parseShapeChoiceType(dynamic raw) {
  final value = raw?.toString().trim().toLowerCase() ?? '';
  switch (value) {
    case '네모':
    case '사각형':
    case 'square':
      return _ShapeChoiceType.square;
    case '동그라미':
    case '원':
    case 'circle':
      return _ShapeChoiceType.circle;
    case '별':
    case 'star':
      return _ShapeChoiceType.star;
    case '오각형':
    case 'pentagon':
      return _ShapeChoiceType.pentagon;
    default:
      return _ShapeChoiceType.unknown;
  }
}

bool _asTrue(dynamic value) {
  if (value is bool) return value;
  if (value == null) return false;
  return value.toString().trim().toLowerCase() == 'true';
}

class MissionLowScreen extends StatefulWidget {
  const MissionLowScreen({
    super.key,
    this.missionDataPath = 'assets/data/mission_low.json',
    this.completedRouteName,
  });

  final String missionDataPath;
  final String? completedRouteName;

  @override
  State<MissionLowScreen> createState() => _MissionLowScreenState();
}

class _MissionLowScreenState extends State<MissionLowScreen> {
  static const String _defaultMissionTitle = '미션! 수학체험센터의 반짝별을 찾아서';

  int currentStep = 0;
  List<dynamic> steps = [];
  String? _loadError;

  @override
  void initState() {
    super.initState();
    loadMissionData();
  }

  Future<void> _syncBgmForCurrentStep() async {
    if (steps.isEmpty) return;
    final step = steps[currentStep] as Map<String, dynamic>;
    final isQuizStep = step['type'] == 'quiz';
    if (isQuizStep) {
      await AppBgmController.playProblem();
    } else {
      await AppBgmController.playStory();
    }
  }

  Future<void> loadMissionData() async {
    if (!mounted) return;
    final assetBundle = DefaultAssetBundle.of(context);
    try {
      final jsonString = await assetBundle.loadString(widget.missionDataPath);
      final data = json.decode(jsonString) as Map<String, dynamic>;

      if (!mounted) return;
      setState(() {
        steps = data['steps'] as List<dynamic>;
        _loadError = null;
      });

      _syncBgmForCurrentStep();
      return;
    } catch (_) {
      // Fallback for stale asset cache / old builds.
    }

    if (widget.missionDataPath ==
        'assets/data/mission_chapter1_q2_hanoi.json') {
      try {
        final fallbackJson = await assetBundle.loadString(
          'assets/data/mission_chapter1_q2.json',
        );
        final data = json.decode(fallbackJson) as Map<String, dynamic>;
        if (!mounted) return;
        setState(() {
          steps = data['steps'] as List<dynamic>;
          _loadError = null;
        });
        _syncBgmForCurrentStep();
        return;
      } catch (_) {
        // keep going to show explicit error state
      }
    }

    if (!mounted) return;
    setState(() {
      _loadError = '문제 데이터를 불러오지 못했어요. 앱을 다시 시작해 주세요.';
      steps = const [];
    });
  }

  void nextStep() {
    if (currentStep < steps.length - 1) {
      setState(() {
        currentStep++;
      });
      _syncBgmForCurrentStep();
    } else {
      if (widget.completedRouteName != null) {
        Navigator.pushReplacementNamed(context, widget.completedRouteName!);
      } else {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF163988),
          surfaceTintColor: Colors.white,
          elevation: 0,
          title: const Text(
            _defaultMissionTitle,
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24),
          ),
          centerTitle: true,
          actions: const [BgmToggleButton(iconSize: 40)],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFE05C57),
                  size: 64,
                ),
                const SizedBox(height: 14),
                Text(
                  _loadError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: loadMissionData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF123E97),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (steps.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final step = steps[currentStep] as Map<String, dynamic>;
    final isLast = currentStep == steps.length - 1;
    final progress = (currentStep + 1) / steps.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
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
        title: Text(
          _defaultMissionTitle,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24),
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
          if (kDebugMode && step['type'] != 'story')
            IconButton(
              tooltip: '테스트용 스킵',
              icon: const Icon(Icons.skip_next_rounded, size: 40),
              onPressed: nextStep,
            ),
        ],
      ),
      body: step['type'] == 'story'
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: StoryScreen(step: step, onNext: nextStep, isLast: isLast),
            )
          : QuizScreen(
              step: step,
              onNext: nextStep,
              isLast: isLast,
              progress: progress,
            ),
    );
  }
}

class StoryScreen extends StatelessWidget {
  const StoryScreen({
    super.key,
    required this.step,
    required this.onNext,
    required this.isLast,
  });

  final Map<String, dynamic> step;
  final VoidCallback onNext;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final isMobile = screenWidth < 600;
    final imageHeight = isMobile
        ? screenSize.height * 0.35
        : (screenWidth < 900 ? screenWidth * 0.45 : 360.0);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              height: imageHeight,
              child: Image.asset(
                'assets/images/chr_background.png',
                fit: BoxFit.contain,
                cacheHeight: 600,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                step['text'].toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? (screenWidth * 0.07).clamp(20, 28) : 32,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF15347F),
                  height: 1.3,
                  fontFamily: 'GangwonEduAll',
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF123E97),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 24 : 32,
                  vertical: isMobile ? 12 : 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isLast ? '완료' : '다음',
                style: TextStyle(
                  fontSize: isMobile ? 22 : 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.step,
    required this.onNext,
    required this.isLast,
    required this.progress,
  });

  final Map<String, dynamic> step;
  final VoidCallback onNext;
  final bool isLast;
  final double progress;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  static const List<Color> _optionColors = [
    Color(0xFF1E40AF), // Royal Blue for Square
    Color(0xFFEA580C), // Coral/Orange for Circle
    Color(0xFFD97706), // Gold/Amber for Star
    Color(0xFF0F766E), // Deep Teal for Pentagon
  ];

  int? selectedChoiceIndex;
  String inputAnswer = '';
  int _simulationIndex = 0;
  int? _selectedHanoiPeg;
  int _hanoiMoveCount = 0;
  List<List<int>> _hanoiPegs = [
    [3, 2, 1],
    [],
    [],
  ];
  final TextEditingController _inputController = TextEditingController();
  static const Set<int> _magicSquareBlankIndexes = {7, 8};
  final Map<int, int?> _magicSquareInputs = {7: null, 8: null};
  int? _activeMagicSquareCell;

  @override
  void didUpdateWidget(covariant QuizScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step != widget.step) {
      selectedChoiceIndex = null;
      inputAnswer = '';
      _simulationIndex = 0;
      _resetHanoi();
      _inputController.clear();
      _magicSquareInputs.updateAll((key, value) => null);
      _activeMagicSquareCell = null;
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  bool _isAnswerReady(String quizType, Map<String, dynamic> step) {
    final visualType = (step['visual_type'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
    if (visualType == 'magic_square') {
      return _magicSquareBlankIndexes.every(
        (index) => _magicSquareInputs[index] != null,
      );
    }
    if (quizType == 'mcq') return selectedChoiceIndex != null;
    return inputAnswer.trim().isNotEmpty;
  }

  List<String> _resultCopyForStep(Map<String, dynamic> step, bool correct) {
    final visualType = (step['visual_type'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
    final hasHanoiVisual = _asTrue(step['show_hanoi_visual']);
    final hasShapeChoices = _asTrue(step['choices_as_shapes']);

    if (hasShapeChoices) {
      return correct
          ? const ['딱 맞는 모양이야', '빈틈 없이 바닥을 채울 수 있어!']
          : const ['아직 빈틈이 남아', '다른 모양도 바닥에 놓아 보자.'];
    }
    if (hasHanoiVisual) {
      return correct
          ? const ['최소 횟수를 찾았어', '작은 원판 블록들이 모두 제자리를 찾았어!']
          : const ['아직 최소 횟수가 아니야', '원반을 더 적게 옮기는 방법을 떠올려 보자.'];
    }
    if (visualType == 'magic_square') {
      return correct
          ? const ['숫자판이 맞춰졌어', '가로, 세로, 대각선의 합이 모두 같아!']
          : const ['합이 아직 맞지 않아', '빈칸에 들어갈 숫자를 다시 계산해 보자.'];
    }
    if (visualType == 'rod_numeral') {
      return correct
          ? const ['산가지 수를 읽었어', '자릿값을 정확히 짚었어!']
          : const ['자릿수를 다시 살펴보자', '백, 십, 일의 자리를 차례로 확인해 봐.'];
    }
    return correct
        ? const ['정답이야', '다음 단서로 이어가 보자!']
        : const ['아직 아니야', '문제의 조건을 한 번 더 살펴보자.'];
  }

  void _showMagicSquareKeypad(int cellIndex) {
    setState(() {
      _activeMagicSquareCell = cellIndex;
    });
    final isCompact = MediaQuery.of(context).size.width < 1100;
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '숫자를 선택하세요',
                  style: TextStyle(
                    fontSize: isCompact ? 24 : 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 10,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.5,
                  ),
                  itemBuilder: (context, index) {
                    return ElevatedButton(
                      onPressed: () {
                        AppSfxController.playClick();
                        setState(() {
                          _magicSquareInputs[cellIndex] = index;
                          _activeMagicSquareCell = cellIndex;
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF123E97),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        '$index',
                        style: TextStyle(
                          fontSize: isCompact ? 24 : 30,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _magicSquareInputs[cellIndex] = null;
                        _activeMagicSquareCell = cellIndex;
                      });
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.backspace_outlined),
                    label: const Text('입력 지우기'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _resetHanoi() {
    _selectedHanoiPeg = null;
    _hanoiMoveCount = 0;
    _hanoiPegs = [
      [3, 2, 1],
      [],
      [],
    ];
  }

  void _handleHanoiPegTap(int pegIndex) {
    final selectedPeg = _selectedHanoiPeg;

    if (selectedPeg == null) {
      if (_hanoiPegs[pegIndex].isEmpty) return;
      setState(() {
        _selectedHanoiPeg = pegIndex;
      });
      return;
    }

    if (selectedPeg == pegIndex) {
      setState(() {
        _selectedHanoiPeg = null;
      });
      return;
    }

    final movingDisk = _hanoiPegs[selectedPeg].last;
    final targetTopDisk = _hanoiPegs[pegIndex].isEmpty
        ? null
        : _hanoiPegs[pegIndex].last;
    if (targetTopDisk != null && targetTopDisk < movingDisk) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('큰 원반은 작은 원반 위에 올릴 수 없어요.')));
      setState(() {
        _selectedHanoiPeg = null;
      });
      return;
    }

    setState(() {
      _hanoiPegs[selectedPeg].removeLast();
      _hanoiPegs[pegIndex].add(movingDisk);
      _selectedHanoiPeg = null;
      _hanoiMoveCount++;
    });
  }

  void _showHint(String? hint) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = (screenWidth * 0.62).clamp(360.0, 760.0);
    final titleSize = 44.0;
    final hintSize = 30.0;
    final buttonSize = 28.0;

    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        child: SizedBox(
          width: dialogWidth,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 24, 30, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '💡 힌트',
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF6F63D1),
                    fontFamily: 'GangwonEduAll',
                  ),
                ),
                const SizedBox(height: 20),
                Image.asset(
                  'assets/images/chr_play_idea.png',
                  height: screenWidth < 1100 ? 150 : 180,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                Text(
                  (hint == null || hint.trim().isEmpty) ? '준비된 힌트가 없어요.' : hint,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: hintSize,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF091F59),
                    height: 1.3,
                    fontFamily: 'GangwonEduAll',
                  ),
                ),
                const SizedBox(height: 30),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    '확인',
                    style: TextStyle(
                      fontSize: buttonSize,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF6F63D1),
                      fontFamily: 'GangwonEduAll',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitAnswer(Map<String, dynamic> step, String quizType) {
    AppSfxController.playClick();
    if (!_isAnswerReady(quizType, step)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('답을 먼저 선택하거나 입력해 주세요.')));
      return;
    }

    bool correct = false;

    final visualType = (step['visual_type'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
    if (visualType == 'magic_square') {
      final rawAnswers =
          (step['magic_square_answers'] as Map<String, dynamic>?) ??
          const {'7': 1, '8': 6};
      correct = true;
      for (final entry in rawAnswers.entries) {
        final cell = int.tryParse(entry.key);
        final expected = int.tryParse(entry.value.toString());
        if (cell == null || expected == null) continue;
        if (_magicSquareInputs[cell] != expected) {
          correct = false;
          break;
        }
      }
    } else if (quizType == 'mcq') {
      final answerIndex = step['answer'] as int;
      correct = selectedChoiceIndex == answerIndex;
    } else if (quizType == 'input' || quizType == 'qr') {
      final expected = step['answer'].toString().trim();
      correct = inputAnswer.trim() == expected;
    }

    final resultCopy = _resultCopyForStep(step, correct);
    final resultTitle = resultCopy[0];
    final resultMessage = resultCopy[1];

    if (correct) {
      AppSfxController.playCorrect();
    } else {
      AppSfxController.playWrong();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.75), // Darkened background
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        // 팝업 너비 축소: 최대 500
        final dialogWidth = (screenWidth * 0.45).clamp(360.0, 500.0);
        // 캐릭터 높이 확대
        final imageHeight = screenWidth < 1100 ? 180.0 : 220.0;
        // 텍스트 크기 축소
        final titleSize = screenWidth < 1100 ? 32.0 : 38.0;
        final messageSize = screenWidth < 1100 ? 20.0 : 24.0;
        final confirmSize = screenWidth < 1100 ? 22.0 : 26.0;

        return Dialog(
          elevation: 20,
          shadowColor: Colors.black54,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            width: dialogWidth,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 30),
                // 상단 배경색 제거 및 캐릭터 사이즈 확대
                Center(
                  child: Image.asset(
                    correct
                        ? 'assets/images/chr_play_correct.png'
                        : 'assets/images/chr_how_fail.png',
                    height: imageHeight,
                    fit: BoxFit.contain,
                    cacheHeight: 500,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Text(
                        resultTitle,
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w900,
                          color: correct
                              ? const Color(0xFF13968F) // Desaturated cyan
                              : const Color(0xFFD64A45), // Adjusted red
                          fontFamily: 'GangwonEduAll',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        resultMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: messageSize,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF4B5563), // Dark gray
                          height: 1.3,
                          fontFamily: 'GangwonEduAll',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                // 버튼에 여백 주고 둥근 모서리(16) 적용
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (correct) {
                          widget.onNext();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF133E97,
                        ), // Main blue color
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        '확인',
                        style: TextStyle(
                          fontSize: confirmSize,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSimulationArea(List<String> images, {double? height}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final simulationHeight =
        (height ?? (screenHeight * (screenWidth < 1100 ? 0.48 : 0.52)))
            .clamp(340.0, 720.0)
            .toDouble();

    return Column(
      children: [
        const SizedBox(height: 14),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Image.asset(
            images[_simulationIndex],
            key: ValueKey<int>(_simulationIndex),
            height: simulationHeight,
            fit: BoxFit.contain,
            cacheHeight: 600,
            errorBuilder: (context, error, stackTrace) => Container(
              height: simulationHeight,
              color: Colors.grey[200],
              alignment: Alignment.center,
              child: const Text(
                '이미지 준비중...',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () async {
            if (_simulationIndex != 0) return; // 이미 실행 중이거나 완료된 경우 무시
            if (images.length < 2) return;

            setState(() {
              _simulationIndex = 1;
            });

            if (images.length > 2) {
              await Future.delayed(const Duration(milliseconds: 1200));
              if (!mounted) return;
              setState(() {
                _simulationIndex = 2;
              });
            }
          },
          icon: const Icon(Icons.balance),
          label: const Text(
            '직접 저울에 올려보기 ⚖️',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange[400],
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.step;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final quizType = (step['quiz_type'] ?? '').toString();
    final visualType = (step['visual_type'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
    final isMagicSquare = visualType == 'magic_square';
    final choices = (step['choices'] as List<dynamic>?) ?? const [];
    final showHanoiVisual = _asTrue(step['show_hanoi_visual']);
    final renderChoicesAsShapes = _asTrue(step['choices_as_shapes']);
    final hasSimulationImages =
        step['simulation_images'] != null &&
        (step['simulation_images'] as List<dynamic>).isNotEmpty;
    final choicesLayout = (step['choices_layout'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
    final useFourAcrossChoices =
        (quizType == 'mcq' && choices.length == 4) || choicesLayout == '4x1';
    final isMobile = screenWidth < 600;
    final isCompact = screenWidth < 1100;
    final questionText = step['question'].toString();
    final questionFontSize = isMobile
        ? (screenWidth * 0.06).clamp(18.0, 22.0)
        : (isCompact ? 24.0 : 30.0);
    final optionTextSize = isMobile
        ? (screenWidth * 0.07).clamp(24.0, 28.0)
        : (isCompact ? 30.0 : 34.0);
    final optionShapeSize = isMobile
        ? (screenWidth * 0.1).clamp(36.0, 48.0)
        : (isCompact ? 44.0 : 52.0);
    final actionFontSize = isMobile ? 18.0 : (isCompact ? 20.0 : 24.0);
    final actionButtonHeight = isMobile ? 48.0 : (isMagicSquare ? 52.0 : 56.0);
    final submitButtonLabel = isMagicSquare
        ? '숫자 확인'
        : showHanoiVisual
        ? '횟수 확인'
        : renderChoicesAsShapes
        ? '모양 확인'
        : '답 확인';

    final hanoiHeight =
        (screenHeight * (isMobile ? 0.42 : (isCompact ? 0.48 : 0.52)))
            .clamp(isMobile ? 280.0 : 360.0, 680.0)
            .toDouble();

    final rodVisualHeight =
        (screenHeight * (isMobile ? 0.46 : (isCompact ? 0.52 : 0.56)))
            .clamp(isMobile ? 320.0 : 390.0, 680.0)
            .toDouble();
    final magicSquareVisualHeight =
        (screenHeight * (isMobile ? 0.50 : (isCompact ? 0.56 : 0.60)))
            .clamp(isMobile ? 350.0 : 430.0, 720.0)
            .toDouble();

    final hasTopVisualSection =
        hasSimulationImages ||
        showHanoiVisual ||
        renderChoicesAsShapes ||
        visualType == 'rod_numeral' ||
        visualType == 'magic_square';
    final choicesTopGap = hasTopVisualSection
        ? (isMobile ? 8.0 : (isCompact ? 10.0 : 16.0))
        : 10.0;

    return Column(
      children: [
        Expanded(
          child: renderChoicesAsShapes
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFDDE3F0),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              questionText,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: questionFontSize,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF091F59),
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "(가이드: 오른쪽 보기에서 도형을 선택하여 왼쪽 모눈 바닥에 빈틈없이 채워지는지 관찰해 보세요.)",
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
                      const SizedBox(height: 16),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final availableHeight = constraints.maxHeight;
                            final availableWidth = constraints.maxWidth;

                            // Calculate grid size to prevent overflow (leave space for the hint box)
                            final gridSize = (math.min(
                              availableWidth * 5 / 9 - 16,
                              availableHeight - 90,
                            )).clamp(180.0, 420.0);

                            // Calculate childAspectRatio dynamically for right column 2x2 grid
                            final rightColW = availableWidth * 4 / 9 - 16;
                            final rightColH = availableHeight - 40;
                            final tileW = (rightColW - 10) / 2;
                            final tileH = (rightColH - 10) / 2;
                            final dynamicAspectRatio = (tileW / tileH).clamp(
                              1.05,
                              1.65,
                            );

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ── 왼쪽 영역: 오직 바닥 프리뷰만 ──
                                Expanded(
                                  flex: 5,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _TessellationFloorPreview(
                                        height: gridSize,
                                        selectedShape:
                                            selectedChoiceIndex != null
                                            ? _parseShapeChoiceType(
                                                choices[selectedChoiceIndex!]
                                                    .toString(),
                                              )
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // ── 오른쪽 영역: 2x2 큰 카드 도형 선택지 ──
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: 4,
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              crossAxisSpacing: 10,
                                              mainAxisSpacing: 10,
                                              childAspectRatio: isMobile
                                                  ? 1.05
                                                  : dynamicAspectRatio,
                                            ),
                                        itemBuilder: (context, index) {
                                          final selected =
                                              selectedChoiceIndex == index;
                                          final color =
                                              _optionColors[index %
                                                  _optionColors.length];
                                          final isEnabled =
                                              index < choices.length;
                                          final choiceText = isEnabled
                                              ? choices[index].toString()
                                              : '준비 중';
                                          final shapeType =
                                              _parseShapeChoiceType(choiceText);
                                          final textColor =
                                              color.computeLuminance() > 0.55
                                              ? const Color(0xFF163988)
                                              : Colors.white;

                                          return AnimatedScale(
                                            scale: selected ? 1.03 : 1.0,
                                            duration: const Duration(
                                              milliseconds: 180,
                                            ),
                                            curve: Curves.easeOutBack,
                                            child: GestureDetector(
                                              onTap: isEnabled
                                                  ? () => setState(
                                                      () =>
                                                          selectedChoiceIndex =
                                                              index,
                                                    )
                                                  : null,
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                  milliseconds: 180,
                                                ),
                                                curve: Curves.easeOut,
                                                decoration: BoxDecoration(
                                                  color: selected
                                                      ? color
                                                      : Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(18),
                                                  border: Border.all(
                                                    color: selected
                                                        ? const Color(
                                                            0xFF0B1F61,
                                                          )
                                                        : const Color(
                                                            0xFFDDE3F0,
                                                          ),
                                                    width: selected ? 4 : 2,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: selected
                                                          ? color.withValues(
                                                              alpha: 0.4,
                                                            )
                                                          : const Color(
                                                              0x14000000,
                                                            ),
                                                      blurRadius: selected
                                                          ? 18
                                                          : 8,
                                                      offset: const Offset(
                                                        0,
                                                        4,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Spacer(),
                                                    _ShapeOptionSymbol(
                                                      type: shapeType,
                                                      color: selected
                                                          ? textColor
                                                          : color,
                                                      size: optionShapeSize,
                                                      selected: selected,
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Text(
                                                      choiceText,
                                                      style: TextStyle(
                                                        fontSize: isMobile
                                                            ? 18
                                                            : 22,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        color: selected
                                                            ? textColor
                                                            : const Color(
                                                                0xFF2D3A5C,
                                                              ),
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    if (selected)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              bottom: 8,
                                                            ),
                                                        child: Icon(
                                                          Icons
                                                              .radio_button_checked_rounded,
                                                          color: textColor,
                                                          size: 26,
                                                        ),
                                                      )
                                                    else
                                                      const SizedBox(
                                                        height: 34,
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          questionText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: questionFontSize,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF091F59),
                            height: 1.2,
                          ),
                        ),
                      ),
                      if (hasSimulationImages)
                        _buildSimulationArea(
                          (step['simulation_images'] as List<dynamic>)
                              .cast<String>(),
                        ),
                      if (showHanoiVisual) ...[
                        const SizedBox(height: 14),
                        _InteractiveHanoiVisualPanel(
                          height: hanoiHeight,
                          pegs: _hanoiPegs,
                          selectedPeg: _selectedHanoiPeg,
                          moveCount: _hanoiMoveCount,
                          onPegTap: _handleHanoiPegTap,
                          onReset: () {
                            setState(_resetHanoi);
                          },
                        ),
                      ],
                      if (visualType == 'rod_numeral') ...[
                        const SizedBox(height: 12),
                        _RodNumeralVisualPanel(
                          height: rodVisualHeight,
                          tenThousands: step['rod_ten_thousands'] as int?,
                          thousands: step['rod_thousands'] as int?,
                          hundreds: step['rod_hundreds'] as int?,
                          tens: step['rod_tens'] as int?,
                          ones: step['rod_ones'] as int?,
                        ),
                      ],
                      if (visualType == 'magic_square') ...[
                        const SizedBox(height: 12),
                        _MagicSquareVisualPanel(
                          height: magicSquareVisualHeight,
                          blankIndexes: _magicSquareBlankIndexes,
                          values: _magicSquareInputs,
                          onBlankTap: _showMagicSquareKeypad,
                          activeBlankIndex: _activeMagicSquareCell,
                        ),
                      ],
                      SizedBox(height: choicesTopGap),
                      if (quizType == 'mcq' && !isMagicSquare)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 4,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: useFourAcrossChoices ? 4 : 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: useFourAcrossChoices
                                    ? (isMobile ? 3.0 : (isCompact ? 5.8 : 7.0))
                                    : (isMobile
                                          ? 3.5
                                          : (isCompact ? 5.5 : 7.5)),
                              ),
                          itemBuilder: (context, index) {
                            final selected = selectedChoiceIndex == index;
                            final color =
                                _optionColors[index % _optionColors.length];
                            final isEnabled = index < choices.length;
                            final choiceText = isEnabled
                                ? choices[index].toString()
                                : '준비 중';
                            final textColor = color.computeLuminance() > 0.55
                                ? const Color(0xFF163988)
                                : Colors.white;

                            // ── 기존 텍스트 선택지 디자인 ──
                            return AnimatedScale(
                              scale: selected ? 1.0 : 0.98,
                              duration: const Duration(milliseconds: 120),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 140),
                                curve: Curves.easeOut,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: selected
                                      ? Border.all(
                                          color: const Color(0xFF0B1F61),
                                          width: 5,
                                        )
                                      : null,
                                  boxShadow: selected
                                      ? const [
                                          BoxShadow(
                                            color: Color(0x33133E97),
                                            blurRadius: 8,
                                            offset: Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: isEnabled
                                        ? () => setState(
                                            () => selectedChoiceIndex = index,
                                          )
                                        : null,
                                    borderRadius: BorderRadius.circular(10),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        color: isEnabled
                                            ? color
                                            : const Color(0xFFB8B8BE),
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x22000000),
                                            blurRadius: 6,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                      ),
                                      child: Stack(
                                        children: [
                                          Center(
                                            child: Text(
                                              choiceText,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: textColor,
                                                fontSize: useFourAcrossChoices
                                                    ? (isCompact ? 22.0 : 26.0)
                                                    : optionTextSize,
                                                fontWeight: FontWeight.w900,
                                                shadows: selected
                                                    ? const [
                                                        Shadow(
                                                          color: Color(
                                                            0x55000000,
                                                          ),
                                                          blurRadius: 4,
                                                        ),
                                                      ]
                                                    : null,
                                              ),
                                            ),
                                          ),
                                          if (selected)
                                            Positioned(
                                              right: 10,
                                              top: 10,
                                              child: Icon(
                                                Icons.check_circle_rounded,
                                                color: textColor,
                                                size: 30,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      else if (!isMagicSquare)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF243B78),
                              width: 2,
                            ),
                          ),
                          child: TextField(
                            controller: _inputController,
                            onChanged: (value) => inputAnswer = value,
                            style: TextStyle(
                              fontSize: isCompact ? 22 : 26,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF091F59),
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: quizType == 'qr'
                                  ? 'QR 결과를 입력하세요'
                                  : '답을 입력하세요',
                              hintStyle: TextStyle(
                                fontSize: isCompact ? 20 : 24,
                                color: const Color(0xFF8A93AE),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
        ),
        // ── 항상 하단에 고정되는 버튼 영역 ──
        Container(
          color: const Color(0xFFF5F8FF),
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showHint(step['hint']?.toString()),
                      icon: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 28,
                      ),
                      label: Text(
                        '힌트',
                        style: TextStyle(
                          fontSize: actionFontSize,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF163988),
                        side: const BorderSide(
                          color: Color(0xFF21396C),
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: Size.fromHeight(actionButtonHeight),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isAnswerReady(quizType, step)
                          ? () => _submitAnswer(step, quizType)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF123E97),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: Size.fromHeight(actionButtonHeight),
                      ),
                      child: Text(
                        submitButtonLabel,
                        style: TextStyle(
                          fontSize: actionFontSize,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PentagonSymbolPainter extends CustomPainter {
  final Color color;
  _PentagonSymbolPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path();
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double r = size.width * 0.46;
    for (int i = 0; i < 5; i++) {
      final double angle = -3.14159265 / 2 + (i * 2 * 3.14159265 / 5);
      final double x = cx + r * math.cos(angle);
      final double y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StarSymbolPainter extends CustomPainter {
  final Color color;
  _StarSymbolPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path();
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double r = size.width * 0.50;
    const n = 5;
    for (var i = 0; i < n * 2; i++) {
      final angle = (i * 3.14159265 / n) - 3.14159265 / 2;
      final radius = i.isEven ? r : r * 0.45;
      final x = cx + radius * math.cos(angle);
      final y = cy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ShapeOptionSymbol extends StatelessWidget {
  const _ShapeOptionSymbol({
    required this.type,
    required this.color,
    required this.size,
    required this.selected,
  });

  final _ShapeChoiceType type;
  final Color color;
  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case _ShapeChoiceType.square:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.zero,
          ),
        );
      case _ShapeChoiceType.circle:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        );
      case _ShapeChoiceType.star:
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(painter: _StarSymbolPainter(color: color)),
        );
      case _ShapeChoiceType.pentagon:
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(painter: _PentagonSymbolPainter(color: color)),
        );
      case _ShapeChoiceType.unknown:
        return Text(
          '?',
          style: TextStyle(
            color: color,
            fontSize: size,
            fontWeight: FontWeight.w900,
            shadows: selected
                ? const [Shadow(color: Color(0xAA000000), blurRadius: 6)]
                : null,
          ),
        );
    }
  }
}

class _TessellationFloorPreview extends StatelessWidget {
  const _TessellationFloorPreview({required this.height, this.selectedShape});

  final double height;
  final _ShapeChoiceType? selectedShape;

  @override
  Widget build(BuildContext context) {
    // 선택된 도형에 따라 레이블 및 힌트 결정
    String hint;
    bool canTile;
    switch (selectedShape) {
      case _ShapeChoiceType.square:
        hint = '사각형은 빈틈 없이 꽉 채울 수 있어요! ✅';
        canTile = true;
      case _ShapeChoiceType.circle:
        hint = '원은 사이사이에 빈틈이 생겨요 ❌';
        canTile = false;
      case _ShapeChoiceType.star:
        hint = '별은 모양이 복잡해서 빈틈이 생겨요 ❌';
        canTile = false;
      case _ShapeChoiceType.pentagon:
        hint = '정오각형은 빈틈 없이 이으려 하면 옆의 도형과 겹쳐버려요! ❌';
        canTile = false;
      default:
        hint = '도형을 골라서 바닥에 깔아봐!';
        canTile = false;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: Column(
        key: ValueKey(selectedShape),
        children: [
          SizedBox(
            width: height,
            height: height,
            child: ClipRRect(
              borderRadius: BorderRadius
                  .zero, // Perfect rectangular boundary matching mathematical tessellation
              child: CustomPaint(
                painter: _TessellationFloorPainter(
                  selectedShape: selectedShape,
                  canTile: canTile,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selectedShape == null
                  ? Colors
                        .transparent // Soft natural caption styling without button confusion
                  : canTile
                  ? const Color(0xFFDFF7EC)
                  : const Color(0xFFFFEEEE),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selectedShape == null
                    ? Colors.transparent
                    : canTile
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFE57373),
                width: 1.5,
              ),
            ),
            child: Text(
              hint,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: selectedShape == null
                    ? const Color(0xFF6B7280) // Clean placeholder neutral text
                    : canTile
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFC62828),
                fontFamily: 'GangwonEduAll',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TessellationFloorPainter extends CustomPainter {
  const _TessellationFloorPainter({this.selectedShape, this.canTile = false});

  final _ShapeChoiceType? selectedShape;
  final bool canTile;

  @override
  void paint(Canvas canvas, Size size) {
    // 배경 (바닥 기본 색상)
    final floorPaint = Paint()..color = const Color(0xFFFFF7D8);
    // 벽면/테두리 영역 (수학적 테셀레이션 영역을 위한 직각형 바닥 처리)
    final bgPaint = Paint()..color = const Color(0xFFEAF1FF);

    canvas.drawRect(Offset.zero & size, bgPaint);

    // 바닥 영역을 꽉 채우도록 사각형 그림
    canvas.drawRect(Offset.zero & size, floorPaint);

    const rows = 5;
    const columns = 5;
    final cellWidth = size.width / columns;
    final cellHeight = size.height / rows;

    // ── 기본 모눈 격자선 ──
    // 사각형(네모)이거나 선택 전일 때만 격자 격자선을 그립니다. (오각형/원/별 등은 격자 구조의 한계를 벗어나 수학적 일관성을 지키기 위함)
    if (selectedShape == null || selectedShape == _ShapeChoiceType.square) {
      final baseGridPaint = Paint()
        ..color =
            const Color(0xFFC3CEF0) // 모눈종이 격자선 연청색
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;

      for (var row = 0; row < rows; row++) {
        final topY = row * cellHeight;
        final bottomY = (row + 1) * cellHeight;
        for (var col = 0; col < columns; col++) {
          final leftX = col * cellWidth;
          final rightX = (col + 1) * cellWidth;
          final tileRect = Rect.fromLTRB(leftX, topY, rightX, bottomY);
          canvas.drawRect(tileRect, baseGridPaint);
        }
      }
    }

    // ── 사용자가 선택한 도형 오버레이 (반투명 렌더링) ──
    if (selectedShape != null) {
      // 도형 선택 여부에 따라 타일 색상 결정 (반투명 적용)
      final Color tileColorA;
      final Color tileColorB;
      if (canTile) {
        tileColorA = const Color(0xFF81C784).withValues(alpha: 0.68);
        tileColorB = const Color(0xFFA5D6A7).withValues(alpha: 0.68);
      } else {
        tileColorA = const Color(0xFFEF9A9A).withValues(alpha: 0.68);
        tileColorB = const Color(0xFFFFCDD2).withValues(alpha: 0.68);
      }

      final tilePaintA = Paint()..color = tileColorA;
      final tilePaintB = Paint()..color = tileColorB;
      final gridPaint = Paint()
        ..color = canTile
            ? const Color(0xFF2E7D32).withValues(alpha: 0.8)
            : const Color(0xFFC62828).withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      // 1. 사각형 (테셀레이션 가능) - 격자 100% 꽉 채움
      if (selectedShape == _ShapeChoiceType.square) {
        for (var row = 0; row < rows; row++) {
          final topY = row * cellHeight;
          final bottomY = (row + 1) * cellHeight;

          for (var col = 0; col < columns; col++) {
            final leftX = col * cellWidth;
            final rightX = (col + 1) * cellWidth;

            final tile = Rect.fromLTRB(leftX, topY, rightX, bottomY);
            canvas.drawRect(tile, (row + col).isEven ? tilePaintA : tilePaintB);
            canvas.drawRect(tile, gridPaint);
          }
        }
      }
      // 2. 오각형: 한 꼭짓점에 3개를 모으면 108도 x 3 = 324도라
      // 36도 빈틈이 남고, 4개째는 겹친다는 사실을 각도로 보여줍니다.
      else if (selectedShape == _ShapeChoiceType.pentagon) {
        final double cx = size.width / 2;
        final double cy = size.height / 2;
        final sharedVertex = Offset(
          cx - size.width * 0.05,
          cy + size.height * 0.04,
        );
        final side = math.min(size.width, size.height) / 4.6;
        final startAngle = math.pi / 10; // 18도. 36도 빈틈이 오른쪽에 보이도록 배치.
        final strokePaint = Paint()
          ..color = gridPaint.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8;

        for (var i = 0; i < 3; i++) {
          final path = _regularPentagonFromVertex(
            sharedVertex,
            side,
            startAngle + i * 3 * math.pi / 5,
          );
          canvas.drawPath(path, i.isEven ? tilePaintA : tilePaintB);
          canvas.drawPath(path, strokePaint);
        }

        final gapStart = startAngle + 9 * math.pi / 5;
        final gapSweep = math.pi / 5;
        final gapRadius = side * 1.08;
        final gapPaint = Paint()
          ..color = const Color(0xFFFFEB3B).withValues(alpha: 0.82)
          ..style = PaintingStyle.fill;
        final gapBorderPaint = Paint()
          ..color = const Color(0xFFC62828)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0;
        final gapPath = Path()
          ..moveTo(sharedVertex.dx, sharedVertex.dy)
          ..arcTo(
            Rect.fromCircle(center: sharedVertex, radius: gapRadius),
            gapStart,
            gapSweep,
            false,
          )
          ..close();
        canvas.drawPath(gapPath, gapPaint);
        canvas.drawPath(gapPath, gapBorderPaint);

        canvas.drawCircle(
          sharedVertex,
          4.5,
          Paint()..color = const Color(0xFFC62828),
        );

        _drawWarningLabel(
          canvas,
          '36도 빈틈',
          Offset(
            sharedVertex.dx +
                gapRadius * 0.74 * math.cos(gapStart + gapSweep / 2),
            sharedVertex.dy +
                gapRadius * 0.74 * math.sin(gapStart + gapSweep / 2),
          ),
        );
        _drawWarningLabel(
          canvas,
          '108도 x 3 = 324도',
          Offset(sharedVertex.dx - side * 0.35, sharedVertex.dy - side * 1.08),
        );
      }
      // 3. 별: 꼭짓점을 맞대도 넓은 빈 공간이 남는 모습을 강조합니다.
      else if (selectedShape == _ShapeChoiceType.star) {
        final double cx = size.width / 2;
        final double cy = size.height / 2;
        final double r = math.min(size.width, size.height) / 7.0;
        final double gap = r * 2.05;
        final strokePaint = Paint()
          ..color = gridPaint.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8;

        final centers = <Offset>[
          Offset(cx - gap, cy - gap * 0.55),
          Offset(cx, cy - gap * 0.55),
          Offset(cx + gap, cy - gap * 0.55),
          Offset(cx - gap * 0.5, cy + gap * 0.55),
          Offset(cx + gap * 0.5, cy + gap * 0.55),
        ];

        final gapPaint = Paint()
          ..color = const Color(0xFFFFEB3B).withValues(alpha: 0.72)
          ..style = PaintingStyle.fill;
        final gapBorderPaint = Paint()
          ..color = const Color(0xFFC62828)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6;

        final bigGap = Path()
          ..moveTo(cx, cy - r * 0.9)
          ..lineTo(cx + r * 0.9, cy)
          ..lineTo(cx, cy + r * 0.9)
          ..lineTo(cx - r * 0.9, cy)
          ..close();
        canvas.drawPath(bigGap, gapPaint);
        canvas.drawPath(bigGap, gapBorderPaint);

        for (var i = 0; i < centers.length; i++) {
          _drawStar(canvas, centers[i], r, i.isEven ? tilePaintA : tilePaintB);
          _drawStar(canvas, centers[i], r, strokePaint);
        }

        _drawWarningLabel(canvas, '큰 빈틈!', Offset(cx, cy));
      }
      // 4. 원 (기타 테셀레이션 불가능한 도형 - 탄젠트 5x5 접합 렌더링)
      else {
        final shapeSize = cellHeight;

        for (var row = 0; row < rows; row++) {
          final centerY = row * cellHeight + cellHeight / 2;
          for (var col = 0; col < columns; col++) {
            final centerX = col * cellWidth + cellWidth / 2;
            final center = Offset(centerX, centerY);

            // 번갈아가며 색상 지정
            final currentPaint = (row + col).isEven ? tilePaintA : tilePaintB;

            _drawShapeSymbol(canvas, center, shapeSize, currentPaint.color);

            // 테두리선 그리기
            final strokePaint = Paint()
              ..color = gridPaint.color
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5;
            _drawShapeSymbolBorder(canvas, center, shapeSize, strokePaint);
          }
        }
      }
    }

    // 외곽 테두리 직각으로 감싸기
    final borderPaint = Paint()
      ..color = const Color(0xFF163988)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawRect(Offset.zero & size, borderPaint);

    // 선택 안 됐을 때 중앙 안내 텍스트
    if (selectedShape == null) {
      final textPainter = TextPainter(
        text: const TextSpan(
          text: '오른쪽에서 도형을 골라봐! →',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF8899CC),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (size.width - textPainter.width) / 2,
          (size.height - textPainter.height) / 2,
        ),
      );
    }
  }

  void _drawShapeSymbolBorder(
    Canvas canvas,
    Offset center,
    double size,
    Paint paint,
  ) {
    switch (selectedShape) {
      case _ShapeChoiceType.square:
        canvas.drawRect(
          Rect.fromCenter(center: center, width: size, height: size),
          paint,
        );
        break;
      case _ShapeChoiceType.circle:
        canvas.drawCircle(center, size * 0.5, paint);
        break;
      case _ShapeChoiceType.star:
        _drawStar(canvas, center, size * 0.5, paint);
        break;
      case _ShapeChoiceType.pentagon:
        _drawPentagon(canvas, center, size * 0.5, paint);
        break;
      default:
        break;
    }
  }

  void _drawShapeSymbol(
    Canvas canvas,
    Offset center,
    double size,
    Color color,
  ) {
    final paint = Paint()..color = color;
    switch (selectedShape) {
      case _ShapeChoiceType.square:
        canvas.drawRect(
          Rect.fromCenter(center: center, width: size, height: size),
          paint,
        );
        break;
      case _ShapeChoiceType.circle:
        canvas.drawCircle(center, size * 0.5, paint);
        break;
      case _ShapeChoiceType.star:
        _drawStar(canvas, center, size * 0.5, paint);
        break;
      case _ShapeChoiceType.pentagon:
        _drawPentagon(canvas, center, size * 0.5, paint);
        break;
      default:
        break;
    }
  }

  Path _regularPentagonFromVertex(
    Offset vertex,
    double side,
    double firstEdgeAngle,
  ) {
    final path = Path()..moveTo(vertex.dx, vertex.dy);
    var current = vertex;
    for (var i = 0; i < 4; i++) {
      final angle = firstEdgeAngle + i * 2 * math.pi / 5;
      current = Offset(
        current.dx + side * math.cos(angle),
        current.dy + side * math.sin(angle),
      );
      path.lineTo(current.dx, current.dy);
    }
    path.close();
    return path;
  }

  void _drawWarningLabel(Canvas canvas, String text, Offset center) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w900,
          color: Color(0xFFC62828),
          backgroundColor: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 3);
    final rect = Rect.fromCenter(
      center: center,
      width: textPainter.width + padding.horizontal,
      height: textPainter.height + padding.vertical,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(5)),
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(5)),
      Paint()
        ..color = const Color(0xFFC62828)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawStar(Canvas canvas, Offset center, double r, Paint paint) {
    final path = Path();
    const n = 5;
    for (var i = 0; i < n * 2; i++) {
      final angle = (i * math.pi / n) - math.pi / 2;
      final radius = i.isEven ? r : r * 0.45;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawPentagon(Canvas canvas, Offset center, double r, Paint paint) {
    final path = Path();
    final x = center.dx;
    final y = center.dy;
    for (int i = 0; i < 5; i++) {
      final double angle = -math.pi / 2 + (i * 2 * math.pi / 5);
      final double px = x + r * math.cos(angle);
      final double py = y + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TessellationFloorPainter old) =>
      old.selectedShape != selectedShape || old.canTile != canTile;
}

class _RodNumeralVisualPanel extends StatelessWidget {
  const _RodNumeralVisualPanel({
    required this.height,
    this.tenThousands,
    this.thousands,
    this.hundreds,
    this.tens,
    this.ones,
  });

  final double height;
  final int? tenThousands;
  final int? thousands;
  final int? hundreds;
  final int? tens;
  final int? ones;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 1100;
    final List<Widget> children = [];

    if (tenThousands != null) {
      children.add(
        Expanded(
          child: _RodGroupCard(
            label: '만의 자리',
            count: tenThousands!,
            horizontal: true,
          ),
        ),
      );
    }
    if (thousands != null) {
      if (children.isNotEmpty) children.add(const SizedBox(width: 12));
      children.add(
        Expanded(
          child: _RodGroupCard(
            label: '천의 자리',
            count: thousands!,
            horizontal: false,
          ),
        ),
      );
    }
    if (hundreds != null) {
      if (children.isNotEmpty) children.add(const SizedBox(width: 12));
      children.add(
        Expanded(
          child: _RodGroupCard(
            label: '백의 자리',
            count: hundreds!,
            horizontal: true,
          ),
        ),
      );
    }

    final activeTens =
        tens ??
        (tenThousands == null &&
                thousands == null &&
                hundreds == null &&
                ones == null
            ? 2
            : null);
    final activeOnes =
        ones ??
        (tenThousands == null &&
                thousands == null &&
                hundreds == null &&
                tens == null
            ? 3
            : null);

    if (activeTens != null) {
      if (children.isNotEmpty) children.add(const SizedBox(width: 12));
      children.add(
        Expanded(
          child: _RodGroupCard(
            label: '십의 자리',
            count: activeTens,
            horizontal: false,
          ),
        ),
      );
    }
    if (activeOnes != null) {
      if (children.isNotEmpty) children.add(const SizedBox(width: 12));
      children.add(
        Expanded(
          child: _RodGroupCard(
            label: '일의 자리',
            count: activeOnes,
            horizontal: true,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: height,
      padding: EdgeInsets.all(isCompact ? 12 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD6B06A), width: 2),
      ),
      child: Column(
        children: [
          Text(
            '산가지 수 모형',
            style: TextStyle(
              fontSize: isCompact ? 20 : 24,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF7C4D15),
            ),
          ),
          SizedBox(height: isCompact ? 8 : 12),
          Expanded(child: Row(children: children)),
        ],
      ),
    );
  }
}

class _RodGroupCard extends StatelessWidget {
  const _RodGroupCard({
    required this.label,
    required this.count,
    required this.horizontal,
  });

  final String label;
  final int count;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD6B06A), width: 2),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF7C4D15),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: Wrap(
                direction: horizontal ? Axis.vertical : Axis.horizontal,
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: List.generate(count, (index) {
                  return Container(
                    width: horizontal ? 56 : 12,
                    height: horizontal ? 12 : 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF9C6B2F),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 3,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MagicSquareVisualPanel extends StatelessWidget {
  const _MagicSquareVisualPanel({
    required this.height,
    required this.blankIndexes,
    required this.values,
    required this.onBlankTap,
    required this.activeBlankIndex,
  });

  final double height;
  final Set<int> blankIndexes;
  final Map<int, int?> values;
  final ValueChanged<int> onBlankTap;
  final int? activeBlankIndex;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 1100;
    final numberStyle = TextStyle(
      fontSize: isCompact ? 34 : 42,
      fontWeight: FontWeight.w900,
      color: const Color(0xFF5B3611),
    );

    final cells = const ['4', '9', '2', '3', '5', '7', '8', '?', '?'];

    return Container(
      width: double.infinity,
      height: height,
      padding: EdgeInsets.all(isCompact ? 12 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD6B06A), width: 2),
      ),
      child: Column(
        children: [
          Text(
            '마방진 판',
            style: TextStyle(
              fontSize: isCompact ? 20 : 24,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF7C4D15),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 9,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  final baseValue = cells[index];
                  final isBlank = blankIndexes.contains(index);
                  final typedValue = values[index];

                  final isActive = isBlank && activeBlankIndex == index;
                  final tile = Container(
                    decoration: BoxDecoration(
                      color: isBlank ? const Color(0xFFFFE7A8) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isBlank
                            ? (isActive
                                  ? const Color(0xFF163988)
                                  : const Color(0xFFD5962A))
                            : const Color(0xFFD6B06A),
                        width: isBlank ? (isActive ? 4 : 3) : 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        isBlank ? (typedValue?.toString() ?? '?') : baseValue,
                        style: numberStyle,
                      ),
                    ),
                  );

                  if (!isBlank) return tile;
                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => onBlankTap(index),
                    child: tile,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InteractiveHanoiVisualPanel extends StatelessWidget {
  const _InteractiveHanoiVisualPanel({
    required this.height,
    required this.pegs,
    required this.selectedPeg,
    required this.moveCount,
    required this.onPegTap,
    required this.onReset,
  });

  final double height;
  final List<List<int>> pegs;
  final int? selectedPeg;
  final int moveCount;
  final ValueChanged<int> onPegTap;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 1100 || height < 180;

    return Container(
      width: double.infinity,
      height: height,
      padding: EdgeInsets.all(isCompact ? 10 : 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFC8D8F2), width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '하노이의 탑 (원반 3개)  이동 $moveCount회',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isCompact ? 16 : 22,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF163988),
                  ),
                ),
              ),
              IconButton(
                tooltip: '초기화',
                onPressed: onReset,
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: Color(0xFF163988),
                ),
              ),
            ],
          ),
          Text(
            '기둥을 눌러 맨 위 원반을 고르고, 옮길 기둥을 다시 눌러요. 큰 원반은 작은 원반 위에 올릴 수 없어요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isCompact ? 13 : 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF4C6296),
              height: 1.2,
            ),
          ),
          SizedBox(height: isCompact ? 6 : 10),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    CustomPaint(
                      painter: _HanoiBasePainter(selectedPeg: selectedPeg),
                      child: const SizedBox.expand(),
                    ),
                    ..._buildDisks(constraints.biggest),
                    Row(
                      children: List.generate(3, (index) {
                        return Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => onPegTap(index),
                            child: const SizedBox.expand(),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDisks(Size size) {
    final baseTop = size.height * 0.86;
    final diskHeight = (size.height * 0.12).clamp(16.0, 30.0).toDouble();
    final pegWidth = size.width / 3;
    final diskColors = const {
      1: Color(0xFFA7D0FF),
      2: Color(0xFF78B7FF),
      3: Color(0xFF4A9BFF),
    };

    final widgets = <Widget>[];
    for (var pegIndex = 0; pegIndex < pegs.length; pegIndex++) {
      final peg = pegs[pegIndex];
      final pegCenter = pegWidth * pegIndex + pegWidth / 2;
      for (var level = 0; level < peg.length; level++) {
        final disk = peg[level];
        final isSelectedTop =
            selectedPeg == pegIndex && level == peg.length - 1;
        final diskWidth = pegWidth * (0.28 + disk * 0.16);
        final top =
            baseTop -
            diskHeight * (level + 1) -
            (isSelectedTop ? diskHeight * 0.75 : 0);
        widgets.add(
          AnimatedPositioned(
            key: ValueKey('hanoi-$disk'),
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            left: pegCenter - diskWidth / 2,
            top: top,
            width: diskWidth,
            height: diskHeight * 0.8,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: diskColors[disk],
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isSelectedTop
                      ? const Color(0xFFF0B126)
                      : const Color(0xFF2467B6),
                  width: isSelectedTop ? 3 : 2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
    return widgets;
  }
}

class _HanoiBasePainter extends CustomPainter {
  const _HanoiBasePainter({required this.selectedPeg});

  final int? selectedPeg;

  @override
  void paint(Canvas canvas, Size size) {
    final groundPaint = Paint()..color = const Color(0xFF2E4E9D);
    final rodPaint = Paint()..color = const Color(0xFF8B6B3D);
    final highlightPaint = Paint()..color = const Color(0x2AF0B126);

    final baseTop = size.height * 0.86;
    final pegWidth = size.width / 3;

    if (selectedPeg != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(pegWidth * selectedPeg!, 0, pegWidth, size.height),
          const Radius.circular(12),
        ),
        highlightPaint,
      );
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.02,
          baseTop,
          size.width * 0.96,
          size.height * 0.08,
        ),
        const Radius.circular(8),
      ),
      groundPaint,
    );

    final rodX = [pegWidth * 0.5, pegWidth * 1.5, pegWidth * 2.5];
    for (final x in rodX) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x - 5,
            size.height * 0.18,
            10,
            baseTop - size.height * 0.18,
          ),
          const Radius.circular(6),
        ),
        rodPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HanoiBasePainter oldDelegate) {
    return oldDelegate.selectedPeg != selectedPeg;
  }
}

// ignore: unused_element
class _HanoiVisualPanel extends StatelessWidget {
  const _HanoiVisualPanel({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 1100 || height < 180;

    return Container(
      width: double.infinity,
      height: height,
      padding: EdgeInsets.all(isCompact ? 10 : 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFC8D8F2), width: 2),
      ),
      child: Column(
        children: [
          Text(
            '하노이의 탑 (원반 3개)',
            style: TextStyle(
              fontSize: isCompact ? 16 : 22,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF163988),
            ),
          ),
          SizedBox(height: isCompact ? 6 : 10),
          Expanded(
            child: CustomPaint(
              painter: _HanoiTowerPainter(),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _HanoiTowerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final groundPaint = Paint()..color = const Color(0xFF2E4E9D);
    final rodPaint = Paint()..color = const Color(0xFF8B6B3D);

    final baseTop = size.height * 0.86;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.06,
          baseTop,
          size.width * 0.88,
          size.height * 0.08,
        ),
        const Radius.circular(8),
      ),
      groundPaint,
    );

    final rodX = [size.width * 0.22, size.width * 0.50, size.width * 0.78];
    for (final x in rodX) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x - 5,
            size.height * 0.24,
            10,
            baseTop - size.height * 0.24,
          ),
          const Radius.circular(6),
        ),
        rodPaint,
      );
    }

    final diskColors = const [
      Color(0xFF4A9BFF),
      Color(0xFF78B7FF),
      Color(0xFFA7D0FF),
    ];
    final diskWidths = [
      size.width * 0.22,
      size.width * 0.16,
      size.width * 0.10,
    ];
    final diskHeight = size.height * 0.09;
    final centerX = rodX[0];

    for (var i = 0; i < 3; i++) {
      final y = baseTop - diskHeight * (i + 1);
      final rect = Rect.fromCenter(
        center: Offset(centerX, y + diskHeight / 2),
        width: diskWidths[i],
        height: diskHeight * 0.78,
      );
      final fill = Paint()..color = diskColors[i];
      final stroke = Paint()
        ..color = const Color(0xFF2467B6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(10));
      canvas.drawRRect(rrect, fill);
      canvas.drawRRect(rrect, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
