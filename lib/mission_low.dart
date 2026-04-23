import 'dart:convert';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

final Random _random = Random();

String randomCharacterAsset(String mood) {
  final prefix = _random.nextBool() ? 'play' : 'how';
  return 'assets/images/chr_${prefix}_$mood.png';
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
  String missionTitle = _defaultMissionTitle;

  final AudioPlayer _bgmPlayer = AudioPlayer();
  String? _currentBgmAsset;

  @override
  void initState() {
    super.initState();
    loadMissionData();
    _playBgm('audio/bgm_main.mp3');
  }

  Future<void> _playBgm(String assetPath) async {
    if (_currentBgmAsset == assetPath) return;
    _currentBgmAsset = assetPath;
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.play(AssetSource(assetPath), volume: 0.35);
  }

  Future<void> _syncBgmForCurrentStep() async {
    if (steps.isEmpty) return;
    final step = steps[currentStep] as Map<String, dynamic>;
    final isQuizStep = step['type'] == 'quiz';
    await _playBgm(isQuizStep ? 'audio/bgm_problem.mp3' : 'audio/bgm_main.mp3');
  }

  @override
  void dispose() {
    _bgmPlayer.dispose();
    super.dispose();
  }

  Future<void> loadMissionData() async {
    final jsonString = await DefaultAssetBundle.of(context).loadString(widget.missionDataPath);
    final data = json.decode(jsonString) as Map<String, dynamic>;

    setState(() {
      steps = data['steps'] as List<dynamic>;
      missionTitle = (data['title'] ?? _defaultMissionTitle).toString();
    });

    await _syncBgmForCurrentStep();
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
          missionTitle,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_rounded, size: 44),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false),
          ),
        ],
      ),
      body: step['type'] == 'story'
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: StoryScreen(step: step, onNext: nextStep, isLast: isLast),
            )
          : QuizScreen(step: step, onNext: nextStep, isLast: isLast, progress: progress),
    );
  }
}

class StoryScreen extends StatelessWidget {
  const StoryScreen({super.key, required this.step, required this.onNext, required this.isLast});

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
          ),
        ),
        const SizedBox(height: 16),
        Text(
          step['text'].toString(),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF15347F), height: 1.3),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: onNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF123E97),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(isLast ? '완료' : '다음', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.step, required this.onNext, required this.isLast, required this.progress});

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
  final TextEditingController _inputController = TextEditingController();

  @override
  void didUpdateWidget(covariant QuizScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step != widget.step) {
      selectedChoiceIndex = null;
      inputAnswer = '';
      _inputController.clear();
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  bool _isAnswerReady(String quizType) {
    if (quizType == 'mcq') return selectedChoiceIndex != null;
    return inputAnswer.trim().isNotEmpty;
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
                  child: Text('힌트', style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.w900)),
                ),
                const SizedBox(height: 18),
                Image.asset(randomCharacterAsset('surprised'), height: screenWidth < 1100 ? 130 : 160, fit: BoxFit.contain),
                const SizedBox(height: 18),
                Text(
                  (hint == null || hint.trim().isEmpty) ? '준비된 힌트가 없어요.' : hint,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: hintSize, fontWeight: FontWeight.w700, color: const Color(0xFF232323), height: 1.2),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('확인', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Color(0xFF6F63D1))),
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
    if (!_isAnswerReady(quizType)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('답을 먼저 선택하거나 입력해 주세요.')),
      );
      return;
    }

    bool correct = false;

    if (quizType == 'mcq') {
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Center(
                    child: Image.asset(
                      randomCharacterAsset(correct ? 'happy' : 'fail'),
                      height: imageHeight,
                      fit: BoxFit.contain,
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
                          color: correct ? const Color(0xFF18BEB6) : const Color(0xFFE05C57),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        resultMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: messageSize, fontWeight: FontWeight.w700, color: const Color(0xFF222222), height: 1.15),
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
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                      ),
                    ),
                    child: Text(
                      '확인',
                      style: TextStyle(fontSize: confirmSize, fontWeight: FontWeight.w800, color: const Color(0xFF4A67BF)),
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

  @override
  Widget build(BuildContext context) {
    final step = widget.step;
    final quizType = (step['quiz_type'] ?? '').toString();
    final choices = (step['choices'] as List<dynamic>?) ?? const [];

    final isCompact = MediaQuery.of(context).size.width < 1100;
    final bannerFontSize = isCompact ? 18.0 : 22.0;
    final questionFontSize = isCompact ? 28.0 : 40.0;
    final optionFontSize = isCompact ? 42.0 : 54.0;
    final actionFontSize = isCompact ? 28.0 : 38.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFF4C430), width: 2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '하우와 플레이와 함께하는 신나는 수학 보물탐험 떠나자!',
                    style: TextStyle(
                      color: const Color(0xFF163988),
                      fontSize: bannerFontSize,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Image.asset('assets/images/chr_howplay.png', height: isCompact ? 78 : 92, fit: BoxFit.contain),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              minHeight: 14,
              value: widget.progress.clamp(0.0, 1.0),
              backgroundColor: const Color(0xFFE1E1E4),
              color: const Color(0xFFF0B126),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              step['question'].toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: questionFontSize,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF091F59),
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (quizType == 'mcq')
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 4.5,
              ),
              itemBuilder: (context, index) {
                final selected = selectedChoiceIndex == index;
                final color = _optionColors[index % _optionColors.length];
                final isEnabled = index < choices.length;
                final choiceText = isEnabled ? choices[index].toString() : '준비 중';
                final textColor = color.computeLuminance() > 0.55 ? const Color(0xFF163988) : Colors.white;

                return AnimatedScale(
                  scale: selected ? 1.0 : 0.98,
                  duration: const Duration(milliseconds: 120),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    curve: Curves.easeOut,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: selected ? Border.all(color: const Color(0xFF0B1F61), width: 5) : null,
                      boxShadow: selected
                          ? const [
                              BoxShadow(
                                color: Color(0x55133E97),
                                blurRadius: 16,
                                spreadRadius: 1,
                                offset: Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: isEnabled ? () => setState(() => selectedChoiceIndex = index) : null,
                        borderRadius: BorderRadius.circular(10),
                        child: Ink(
                          decoration: BoxDecoration(
                            color: isEnabled ? color : const Color(0xFFB8B8BE),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(color: Color(0x22000000), blurRadius: 6, offset: Offset(0, 2)),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Stack(
                            children: [
                              Center(
                                child: Text(
                                  choiceText,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: optionFontSize,
                                    fontWeight: FontWeight.w900,
                                    shadows: selected ? const [Shadow(color: Color(0xAA000000), blurRadius: 6)] : null,
                                  ),
                                ),
                              ),
                              if (selected)
                                Positioned(
                                  right: 10,
                                  top: 10,
                                  child: Icon(Icons.check_circle_rounded, color: textColor, size: 30),
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
          else
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
                style: TextStyle(fontSize: isCompact ? 22 : 26, fontWeight: FontWeight.w700, color: const Color(0xFF091F59)),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: quizType == 'qr' ? 'QR 결과를 입력하세요' : '답을 입력하세요',
                  hintStyle: TextStyle(fontSize: isCompact ? 20 : 24, color: const Color(0xFF8A93AE), fontWeight: FontWeight.w600),
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
                  label: Text('힌트', style: TextStyle(fontSize: actionFontSize, fontWeight: FontWeight.w800)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF163988),
                    side: const BorderSide(color: Color(0xFF21396C), width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size.fromHeight(72),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _submitAnswer(step, quizType),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF123E97),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size.fromHeight(72),
                  ),
                  child: Text('정답 제출', style: TextStyle(fontSize: actionFontSize, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
