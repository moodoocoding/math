import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'bgm_toggle_button.dart';
import 'bgm_controller.dart';

class Chapter3MathQuizScreen extends StatefulWidget {
  const Chapter3MathQuizScreen({super.key, this.completedRouteName});

  final String? completedRouteName;

  @override
  State<Chapter3MathQuizScreen> createState() => _Chapter3MathQuizScreenState();
}

class _QuizQuestion {
  final String question;
  final String correctAnswer;
  final List<String> choices;
  final String explanation;

  const _QuizQuestion({
    required this.question,
    required this.correctAnswer,
    required this.choices,
    required this.explanation,
  });
}

class _Chapter3MathQuizScreenState extends State<Chapter3MathQuizScreen> {
  int _currentQuestionIndex = 0;
  final Set<String> _correctlyAnswered = {};
  late List<List<String>> _shuffledChoices;

  static const List<_QuizQuestion> _questions = [
    _QuizQuestion(
      question: '컴퓨터과학의 선구자로, 알고리즘과 계산 개념을 튜링 기계로 형식화하고, 기계 지능을 평가하는 튜링 테스트를 제안한 수학자는 누구일까요?',
      correctAnswer: '앨런 튜링',
      choices: ['앨런 튜링', '최석정', '피보나치', '가우스'],
      explanation: '제2차 세계대전 당시 독일군의 극비 암호인 \'에니그마\'를 해독하여 연합군의 승리를 견인하고 인류 수천만 명의 목숨을 구했습니다.',
    ),
    _QuizQuestion(
      question: '『구수략』을 저술하고, 오일러의 직교 라틴 마방진보다 61년 앞서 마방진을 연구한 수학자는 누구일까요?',
      correctAnswer: '최석정',
      choices: ['최석정', '앨런 튜링', '이상설', '이임학'],
      explanation: '오일러보다 61년 앞서 직교라틴방진을 발견했고, 마방진의 구성 원리를 음양오행 및 주역의 원리와 접목하여 철학적으로 규명했습니다.',
    ),
    _QuizQuestion(
      question: '이탈리아의 수학자로, 『산반서』를 저술하고 인도-아라비아 수 체계를 유럽에 소개하여 피보나치 수열로도 널리 알려진 수학자는 누구일까요?',
      correctAnswer: '피보나치',
      choices: ['피보나치', '가우스', '최석정', '앨런 튜링'],
      explanation: '그가 소개한 수열은 꽃잎 수, 파인애플 비늘, 달팽이 껍질 등 대자연의 황금비율 속에서 끊임없이 발견되는 신비한 성질을 가집니다.',
    ),
    _QuizQuestion(
      question: '1부터 100까지의 합을 순식간에 구한 일화로 유명하며, 정수론, 전자기학 등 수학과 과학의 다양한 분야에 큰 업적을 남겨 \'수학의 왕\'으로 불리는 수학자는 누구일까요?',
      correctAnswer: '가우스',
      choices: ['가우스', '피보나치', '최석정', '이임학'],
      explanation: '그는 정17각형을 작도하는 방법을 눈금 없는 자와 컴퍼스만으로 발견하여 자신의 묘비에 정17각형을 새겨달라고 유언을 남겼습니다.',
    ),
    _QuizQuestion(
      question: '헤이그 특사 중 한 명이자 독립운동가로, 한국 최초의 근대 수학 교과서인 『산술신서』를 저술하여 한국 근대 수학교육의 아버지로 불리는 분은 누구일까요?',
      correctAnswer: '이상설',
      choices: ['이상설', '이임학', '최석정', '가우스'],
      explanation: '그는 헤이그 특사 파견 외에도 최초의 신학문 학교인 서전서숙을 세워 수학을 직접 가르쳤으며 대한제국 최고의 수학 천재로 칭송받았습니다.',
    ),
    _QuizQuestion(
      question: '‘리 군(Ree group)’ 이론으로 세계 수학계에 이름을 알렸으며, 캐나다 수학회 등에서 활약하며 세계에 이름을 알린 최초의 한국인 수학자는 누구일까요?',
      correctAnswer: '이임학',
      choices: ['이임학', '이상설', '앨런 튜링', '피보나치'],
      explanation: '미국 수학회지에 실린 논문을 우연히 발견해 편지로 수학적 오류를 지적하면서 세계적인 천재로 인정받았고 이 메일은 리 군 이론의 시초가 되었습니다.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    AppBgmController.playProblem();
    _shuffledChoices = _questions.map((q) {
      final list = _ensureAnswerChoice(q.choices, q.correctAnswer);
      list.shuffle();
      return list;
    }).toList();
  }

  static List<String> _ensureAnswerChoice(
    List<String> choices,
    String correctAnswer,
  ) {
    final list = List<String>.from(choices);
    if (list.contains(correctAnswer)) return list;
    if (list.isEmpty) return [correctAnswer];
    list[list.length - 1] = correctAnswer;
    return list;
  }

  void _handleChoice(String selectedChoice) {
    final currentQuestion = _questions[_currentQuestionIndex];
    if (selectedChoice == currentQuestion.correctAnswer) {
      AppSfxController.playCorrect();
      _showCorrectDialog(currentQuestion.explanation);
    } else {
      AppSfxController.playWrong();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: const Text(
              '아직 알맞은 인물이 아니에요. 단서를 다시 살펴보세요!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          backgroundColor: const Color(0xFFD64A45),
          duration: const Duration(milliseconds: 900),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(20),
        ),
      );
    }
  }

  void _showCorrectDialog(String explanation) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/chr_play_correct.png',
                height: 160,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.check_circle, size: 80, color: Color(0xFF4CAF50)),
              ),
              const SizedBox(height: 18),
              const Text(
                '단서를 찾았어요! 🎉',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF13968F),
                  fontFamily: 'GangwonEduAll',
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  explanation,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                    height: 1.35,
                    fontFamily: 'GangwonEduAll',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _proceedToNext();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF133E97),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    '다음 초상화 보기',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _proceedToNext() {
    _correctlyAnswered.add(_questions[_currentQuestionIndex].correctAnswer);
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _showAllClearedDialog();
    }
  }

  void _showAllClearedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/chr_play_cheering.png',
                height: 160,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.emoji_events, size: 80, color: Color(0xFFFFC107)),
              ),
              const SizedBox(height: 18),
              const Text(
                '초상화의 문이 열렸어요! 🌟',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF133E97),
                  fontFamily: 'GangwonEduAll',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '수학자들의 이름이 빛 글자로 떠올랐어요.\n이제 글자판 속 이름들을 찾아보세요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4B5563),
                  height: 1.3,
                  fontFamily: 'GangwonEduAll',
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (widget.completedRouteName != null) {
                      Navigator.pushReplacementNamed(context, widget.completedRouteName!);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF133E97),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    '빛 글자 찾기',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
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
    final screenWidth = screenSize.width;
    final isMobile = screenWidth < 600;
    final currentQuestion = _questions[_currentQuestionIndex];
    final filteredChoices = _shuffledChoices[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF163988),
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 30),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false),
        ),
        title: const Text(
          '미션! 수학체험센터의 반짝별을 찾아서',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24),
        ),
        actions: [
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.skip_next_rounded, size: 36, color: Color(0xFF355AA8)),
              tooltip: '테스트용 스킵',
              onPressed: () {
                if (widget.completedRouteName != null) {
                  Navigator.pushReplacementNamed(context, widget.completedRouteName!);
                }
              },
            ),
          const BgmToggleButton(iconSize: 32),
          IconButton(
            icon: const Icon(Icons.home_rounded, size: 34),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              // 진행률 바
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))],
                ),
                child: Row(
                  children: [
                    Text(
                      '진행도: ${_currentQuestionIndex + 1} / ${_questions.length}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF133E97)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: (_currentQuestionIndex + 1) / _questions.length,
                          minHeight: 14,
                          backgroundColor: const Color(0xFFE5E7EB),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 질문 카드
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.3), width: 2),
                    boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 12, offset: Offset(0, 4))],
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Text(
                        currentQuestion.question,
                        style: TextStyle(
                          fontSize: isMobile ? 22 : 28,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E293B),
                          height: 1.3,
                          fontFamily: 'GangwonEduAll',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 세로 2열 6지선다 보기 영역
              Expanded(
                flex: 6,
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 14,
                    childAspectRatio: isMobile ? 3.4 : 4.5,
                  ),
                  itemCount: filteredChoices.length,
                  itemBuilder: (context, index) {
                    final choice = filteredChoices[index];
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(color: Color(0x0C000000), blurRadius: 6, offset: Offset(0, 3)),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => _handleChoice(choice),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF5F8FF),
                          foregroundColor: const Color(0xFF1E3A8A),
                          surfaceTintColor: Colors.white,
                          elevation: 1,
                          shadowColor: const Color(0x1F1A367C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: const BorderSide(color: Color(0xFFBAC5E8), width: 2),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: Text(
                          choice,
                          style: TextStyle(
                            fontSize: isMobile ? 20 : 26,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'GangwonEduAll',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
