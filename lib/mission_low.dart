import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'bgm_toggle_button.dart';
import 'bgm_controller.dart';

enum _ShapeChoiceType { square, circle, star, heart, unknown }

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
    case '하트':
    case 'heart':
      return _ShapeChoiceType.heart;
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
    final screenWidth = MediaQuery.of(context).size.width;
    final imageHeight = screenWidth < 900 ? screenWidth * 0.45 : 360.0;

    return Column(
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
        Text(
          step['text'].toString(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFF15347F),
            height: 1.3,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: onNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF123E97),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            isLast ? '완료' : '다음',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
        ),
      ],
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
    Color(0xFF123E97),
    Color(0xFFF4C430),
    Color(0xFF204FAE),
    Color(0xFFE8B91C),
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
    final titleSize = screenWidth < 1100 ? 44.0 : 54.0;
    final hintSize = screenWidth < 1100 ? 34.0 : 42.0;

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
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '힌트',
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Image.asset(
                  'assets/images/chr_how_idea.png',
                  height: screenWidth < 1100 ? 130 : 160,
                  fit: BoxFit.contain,
                  cacheHeight: 400,
                ),
                const SizedBox(height: 18),
                Text(
                  (hint == null || hint.trim().isEmpty) ? '준비된 힌트가 없어요.' : hint,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: hintSize,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF232323),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      '확인',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF6F63D1),
                      ),
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

    final resultTitle = correct ? '정답이야' : '정답이 아니야';
    final resultMessage = correct ? '잘했어, 정확하게 풀었네' : '다시 한번 풀어 볼래?';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final dialogWidth = (screenWidth * 0.82).clamp(520.0, 1320.0);
        final imageHeight = screenWidth < 1100 ? 190.0 : 240.0;
        final titleSize = screenWidth < 1100 ? 60.0 : 74.0;
        final messageSize = screenWidth < 1100 ? 42.0 : 52.0;
        final confirmSize = screenWidth < 1100 ? 44.0 : 56.0;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: SizedBox(
            width: dialogWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAF3F4),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Center(
                    child: Image.asset(
                      correct ? 'assets/images/chr_play_correct.png' : 'assets/images/chr_how_fail.png',
                      height: imageHeight,
                      fit: BoxFit.contain,
                      cacheHeight: 500,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
                  child: Column(
                    children: [
                      Text(
                        resultTitle,
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w900,
                          color: correct
                              ? const Color(0xFF18BEB6)
                              : const Color(0xFFE05C57),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        resultMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: messageSize,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF222222),
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFD7D7D7)),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (correct) {
                        widget.onNext();
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(24),
                        ),
                      ),
                    ),
                    child: Text(
                      '확인',
                      style: TextStyle(
                        fontSize: confirmSize,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF4A67BF),
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
    final isCompact = screenWidth < 1100;
    final questionText = step['question'].toString();
    final questionFontSize = isCompact ? 24.0 : 30.0;
    final optionTextSize = isCompact ? 30.0 : 34.0;
    final optionShapeSize = isCompact ? 30.0 : 34.0;
    final actionFontSize = isCompact ? 20.0 : 24.0;
    final actionButtonHeight = isMagicSquare ? 52.0 : 56.0;
    final hanoiHeight = (screenHeight * (isCompact ? 0.56 : 0.60))
        .clamp(430.0, 720.0)
        .toDouble();
    final floorPreviewHeight = (screenHeight * (isCompact ? 0.50 : 0.54))
        .clamp(360.0, 660.0)
        .toDouble();
    final rodVisualHeight = (screenHeight * (isCompact ? 0.52 : 0.56))
        .clamp(390.0, 680.0)
        .toDouble();
    final magicSquareVisualHeight = (screenHeight * (isCompact ? 0.56 : 0.60))
        .clamp(430.0, 720.0)
        .toDouble();
    final hasTopVisualSection =
        hasSimulationImages ||
        showHanoiVisual ||
        renderChoicesAsShapes ||
        visualType == 'rod_numeral' ||
        visualType == 'magic_square';
    final choicesTopGap = hasTopVisualSection
        ? (isCompact ? 22.0 : 28.0)
        : 14.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              minHeight: 14,
              value: widget.progress.clamp(0.0, 1.0),
              backgroundColor: const Color(0xFFE1E1E4),
              color: const Color(0xFFF0B126),
            ),
          ),
          const SizedBox(height: 14),
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
              (step['simulation_images'] as List<dynamic>).cast<String>(),
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
              tens: (step['rod_tens'] as int?) ?? 2,
              ones: (step['rod_ones'] as int?) ?? 3,
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
          if (renderChoicesAsShapes) ...[
            const SizedBox(height: 12),
            _TessellationFloorPreview(height: floorPreviewHeight),
          ],
          SizedBox(height: choicesTopGap),
          if (quizType == 'mcq' && !isMagicSquare)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: useFourAcrossChoices ? 4 : 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: useFourAcrossChoices
                    ? (isCompact ? 5.8 : 7.0)
                    : (isCompact ? 5.5 : 7.5),
              ),
              itemBuilder: (context, index) {
                final selected = selectedChoiceIndex == index;
                final color = _optionColors[index % _optionColors.length];
                final isEnabled = index < choices.length;
                final choiceText = isEnabled
                    ? choices[index].toString()
                    : '준비 중';
                final shapeType = _parseShapeChoiceType(choiceText);
                final textColor = color.computeLuminance() > 0.55
                    ? const Color(0xFF163988)
                    : Colors.white;

                return AnimatedScale(
                  scale: selected ? 1.0 : 0.98,
                  duration: const Duration(milliseconds: 120),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    curve: Curves.easeOut,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: selected
                          ? Border.all(color: const Color(0xFF0B1F61), width: 5)
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
                            ? () => setState(() => selectedChoiceIndex = index)
                            : null,
                        borderRadius: BorderRadius.circular(10),
                        child: Ink(
                          decoration: BoxDecoration(
                            color: isEnabled ? color : const Color(0xFFB8B8BE),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x22000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Stack(
                            children: [
                              Center(
                                child: renderChoicesAsShapes
                                    ? _ShapeOptionSymbol(
                                        type: shapeType,
                                        color: textColor,
                                        size: useFourAcrossChoices
                                            ? (isCompact ? 22 : 26)
                                            : optionShapeSize,
                                        selected: selected,
                                      )
                                    : Text(
                                        choiceText,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: useFourAcrossChoices
                                              ? (isCompact ? 22 : 26)
                                              : optionTextSize,
                                          fontWeight: FontWeight.w900,
                                          shadows: selected
                                              ? const [
                                                  Shadow(
                                                    color: Color(0x55000000),
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF243B78), width: 2),
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
                  hintText: quizType == 'qr' ? 'QR 결과를 입력하세요' : '답을 입력하세요',
                  hintStyle: TextStyle(
                    fontSize: isCompact ? 20 : 24,
                    color: const Color(0xFF8A93AE),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showHint(step['hint']?.toString()),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 28),
                  label: Text(
                    '힌트',
                    style: TextStyle(
                      fontSize: actionFontSize,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF163988),
                    side: const BorderSide(color: Color(0xFF21396C), width: 2),
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
                    '정답 제출',
                    style: TextStyle(
                      fontSize: actionFontSize,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (kDebugMode) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: widget.onNext,
                icon: const Icon(Icons.skip_next_rounded),
                label: Text(
                  '테스트용: 문제 건너뛰고 다음으로',
                  style: TextStyle(
                    fontSize: isCompact ? 14 : 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF355AA8),
                  side: const BorderSide(color: Color(0xFF5C7EC5), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size.fromHeight(42),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
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
            borderRadius: BorderRadius.circular(6),
          ),
        );
      case _ShapeChoiceType.circle:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        );
      case _ShapeChoiceType.star:
        return Icon(Icons.star_rounded, size: size + 6, color: color);
      case _ShapeChoiceType.heart:
        return Icon(Icons.favorite_rounded, size: size + 6, color: color);
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
  const _TessellationFloorPreview({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(painter: _TessellationFloorPainter()),
    );
  }
}

class _TessellationFloorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final wallPaint = Paint()..color = const Color(0xFFEAF1FF);
    final floorPaint = Paint()..color = const Color(0xFFFFF7D8);
    final tilePaintA = Paint()..color = const Color(0xFFFFD65A);
    final tilePaintB = Paint()..color = const Color(0xFFFFE78F);
    final gridPaint = Paint()
      ..color = const Color(0xFF9D7A20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final borderPaint = Paint()
      ..color = const Color(0xFF163988)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(10)),
      wallPaint,
    );

    final horizon = size.height * 0.18;
    final floor = Path()
      ..moveTo(size.width * 0.06, horizon)
      ..lineTo(size.width * 0.94, horizon)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(floor, floorPaint);

    final rows = 4;
    final columns = 14;
    for (var row = 0; row < rows; row++) {
      final topT = row / rows;
      final bottomT = (row + 1) / rows;
      final topY = _floorY(horizon, size.height, topT);
      final bottomY = _floorY(horizon, size.height, bottomT);
      final topLeft = _floorLeft(size.width, topT);
      final topRight = _floorRight(size.width, topT);
      final bottomLeft = _floorLeft(size.width, bottomT);
      final bottomRight = _floorRight(size.width, bottomT);

      for (var col = 0; col < columns; col++) {
        final leftT = col / columns;
        final rightT = (col + 1) / columns;
        final tile = Path()
          ..moveTo(_lerp(topLeft, topRight, leftT), topY)
          ..lineTo(_lerp(topLeft, topRight, rightT), topY)
          ..lineTo(_lerp(bottomLeft, bottomRight, rightT), bottomY)
          ..lineTo(_lerp(bottomLeft, bottomRight, leftT), bottomY)
          ..close();
        canvas.drawPath(tile, (row + col).isEven ? tilePaintA : tilePaintB);
        canvas.drawPath(tile, gridPaint);
      }
    }

    canvas.drawPath(floor, borderPaint);
  }

  double _floorY(double horizon, double bottom, double t) {
    return horizon + (bottom - horizon) * t;
  }

  double _floorLeft(double width, double t) {
    return _lerp(width * 0.06, 0, t);
  }

  double _floorRight(double width, double t) {
    return _lerp(width * 0.94, width, t);
  }

  double _lerp(double a, double b, double t) {
    return a + (b - a) * t;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RodNumeralVisualPanel extends StatelessWidget {
  const _RodNumeralVisualPanel({
    required this.height,
    required this.tens,
    required this.ones,
  });

  final double height;
  final int tens;
  final int ones;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 1100;
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
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _RodGroupCard(
                    label: '십의 자리',
                    count: tens,
                    horizontal: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _RodGroupCard(
                    label: '일의 자리',
                    count: ones,
                    horizontal: true,
                  ),
                ),
              ],
            ),
          ),
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
