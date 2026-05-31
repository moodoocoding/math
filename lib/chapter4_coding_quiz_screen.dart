import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'bgm_toggle_button.dart';
import 'bgm_controller.dart';

class Chapter4CodingQuizScreen extends StatefulWidget {
  const Chapter4CodingQuizScreen({super.key, this.completedRouteName});

  final String? completedRouteName;

  @override
  State<Chapter4CodingQuizScreen> createState() => _Chapter4CodingQuizScreenState();
}

class _CodingQuestion {
  final String question;
  final String correctAnswer;
  final List<String> choices;
  final String explanation;

  const _CodingQuestion({
    required this.question,
    required this.correctAnswer,
    required this.choices,
    required this.explanation,
  });
}

class _Chapter4CodingQuizScreenState extends State<Chapter4CodingQuizScreen> {
  int _currentQuestionIndex = 0;
  final Set<String> _correctlyAnswered = {};

  static const List<_CodingQuestion> _questions = [
    _CodingQuestion(
      question: '어떤 문제를 해결하기 위해 정해진 순서와 방법을 말하며, 컴퓨터 프로그램이 작동하는 논리적 뼈대가 되는 개념은 무엇일까요?',
      correctAnswer: '알고리즘',
      choices: ['알고리즘', '인공지능', '코딩블록', '자율주행', '머신러닝', '조건문'],
      explanation: '알고리즘은 문제를 해결하는 순서와 방법을 뜻하며, 프로그래밍의 가장 기초적인 논리 흐름입니다.',
    ),
    _CodingQuestion(
      question: '사람처럼 스스로 생각하고, 학습하고, 판단할 수 있도록 똑똑하게 만들어진 컴퓨터 프로그램 기술을 무엇이라고 할까요?',
      correctAnswer: '인공지능',
      choices: ['알고리즘', '인공지능', '자율주행', '머신러닝', '페이스로봇', '로봇'],
      explanation: '인공지능(AI)은 인간의 인지 능력을 컴퓨터 소프트웨어로 재현하여 구현한 지능형 기술입니다.',
    ),
    _CodingQuestion(
      question: '텍스트 명령어를 직접 치지 않고, 블록을 쌓듯 쉽고 재미있게 이어 붙여서 프로그래밍을 배울 수 있게 만든 도구는 무엇일까요?',
      correctAnswer: '코딩블록',
      choices: ['알고리즘', '코딩블록', '조건문', '루프', '인공지능', '로봇'],
      explanation: '코딩블록은 복잡한 문법 대신 직관적인 블록 드래그 방식으로 쉽게 프로그래밍할 수 있게 도와줍니다.',
    ),
    _CodingQuestion(
      question: '사람이 운전대를 잡지 않아도 센서와 인공지능을 이용해 도로의 상황을 감지하고, 스스로 목적지까지 안전하게 찾아가는 자동차 기술은 무엇일까요?',
      correctAnswer: '자율주행',
      choices: ['인공지능', '자율주행', '머신러닝', '페이스로봇', '로봇', '알고리즘'],
      explanation: '자율주행은 자동차가 스스로 주변 환경을 인식하고 판단하여 운행하는 미래 모빌리티 기술입니다.',
    ),
    _CodingQuestion(
      question: '컴퓨터에 정답을 직접 알려주는 대신, 엄청나게 많은 데이터를 입력하여 컴퓨터가 스스로 패턴을 학습하고 똑똑해지도록 만드는 기술은 무엇일까요?',
      correctAnswer: '머신러닝',
      choices: ['알고리즘', '인공지능', '머신러닝', '조건문', '페이스로봇', '로봇'],
      explanation: '머신러닝(기계학습)은 데이터를 활용해 인공지능이 스스로 학습하고 진화하도록 만드는 기술입니다.',
    ),
    _CodingQuestion(
      question: '컴퓨터가 명령을 실행할 때, \'만약 ~라면\'이라는 규칙을 정해서 주어진 조건의 참과 거짓에 따라 다르게 작동하도록 만드는 코딩 명령어는 무엇일까요?',
      correctAnswer: '조건문',
      choices: ['알고리즘', '코딩블록', '조건문', '루프', '머신러닝', '인공지능'],
      explanation: '조건문은 프로그램 내부에서 상황에 맞는 올바른 분기(판단)를 수행하게 만드는 필수 제어 명령입니다.',
    ),
    _CodingQuestion(
      question: '코딩을 할 때 동일하거나 비슷한 동작을 여러 번 타이핑하지 않고, 정해진 횟수나 조건 동안 계속 반복하여 움직이게 만드는 명령어는 무엇일까요?',
      correctAnswer: '루프',
      choices: ['알고리즘', '조건문', '루프', '코딩블록', '자율주행', '로봇'],
      explanation: '루프(반복문)는 반복되는 명령을 컴퓨터가 효율적으로 자동 처리하게 만드는 제어 구조입니다.',
    ),
    _CodingQuestion(
      question: '단순한 기계를 넘어 사람의 다양한 표정과 감정을 카메라로 인식하고, 얼굴 근육 모터를 조절해 사람처럼 웃거나 울며 감정을 나누는 로봇은 무엇일까요?',
      correctAnswer: '페이스로봇',
      choices: ['인공지능', '자율주행', '페이스로봇', '로봇', '머신러닝', '코딩블록'],
      explanation: '페이스로봇은 인간과의 정서적 교감을 목적으로 얼굴 움직임과 표정을 고도로 모방한 첨단 서비스 로봇입니다.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    AppBgmController.playProblem();
  }

  void _handleChoice(String selectedChoice) {
    final currentQuestion = _questions[_currentQuestionIndex];
    if (selectedChoice == currentQuestion.correctAnswer) {
      AppSfxController.playCorrect();
      _showCorrectDialog(currentQuestion.explanation);
    } else {
      AppSfxController.playWrong();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: const Text(
              '❌ 오답입니다. 다시 한번 잘 생각해 보세요!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          backgroundColor: const Color(0xFFD64A45),
          duration: const Duration(seconds: 2),
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
                '정답입니다! 🎉',
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
                    '다음 문제',
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
                '퀴즈 통과! 🌟',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF133E97),
                  fontFamily: 'GangwonEduAll',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'AI & 코딩 퀴즈를 모두 맞혔습니다!\n다음은 퀴즈 정답이었던 코딩 낱말을 글자판에서 찾아보세요.',
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
                    '낱말 찾기 시작',
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
    final filteredChoices = currentQuestion.choices
        .where((choice) => !_correctlyAnswered.contains(choice))
        .toList();

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
          '1단계: AI & 코딩 상식 퀴즈',
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
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 14,
                    childAspectRatio: 3.4,
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
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1E293B),
                          surfaceTintColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
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
