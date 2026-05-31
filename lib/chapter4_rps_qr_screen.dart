import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'bgm_toggle_button.dart';
import 'bgm_controller.dart';

class Chapter4RpsQrScreen extends StatefulWidget {
  const Chapter4RpsQrScreen({super.key, this.completedRouteName});

  final String? completedRouteName;

  @override
  State<Chapter4RpsQrScreen> createState() => _Chapter4RpsQrScreenState();
}

class _Chapter4RpsQrScreenState extends State<Chapter4RpsQrScreen>
    with WidgetsBindingObserver {
  // --- 가위바위보 게임 상태 ---
  int _currentRound = 1;
  int _wins = 0;
  int _losses = 0;
  int _draws = 0;
  bool _isThinking = false;
  bool _roundCompleted = false;

  String? _playerChoice; // '가위', '바위', '보'
  String? _aiChoice;     // '가위', '바위', '보'
  String? _roundResult;   // '승리', '패배', '무승부'

  // --- QR 스캐너 상태 ---
  bool _showQrView = false;
  bool _handlingDetection = false;
  bool _isStartingScanner = false;
  final TextEditingController _manualQrController = TextEditingController();
  final int _previewRotationTurns = 3; // 가로 화면에 적합한 270도 회전

  final MobileScannerController _scannerController = MobileScannerController(
    autoStart: false,
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    formats: const [BarcodeFormat.qrCode],
  );

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    WidgetsBinding.instance.addObserver(this);
    AppBgmController.playProblem();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scannerController.dispose();
    _manualQrController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted || _handlingDetection || !_showQrView) return;
    switch (state) {
      case AppLifecycleState.resumed:
        _startScanner();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _stopScanner();
        break;
    }
  }

  // --- 가위바위보 핵심 로직 ---
  Future<void> _playRound(String choice) async {
    if (_isThinking || _roundCompleted) return;

    AppSfxController.playClick();
    setState(() {
      _isThinking = true;
      _playerChoice = choice;
      _aiChoice = null;
      _roundResult = null;
    });

    // 로봇이 알고리즘을 계산하는 듯한 1.2초 생각 딜레이 연출
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    final choices = ['가위', '바위', '보'];
    final robotChoice = choices[math.Random().nextInt(3)];

    String result;
    if (choice == robotChoice) {
      result = '무승부';
      _draws++;
      AppSfxController.playWrong(); // 비겼을 때 효과음
    } else if ((choice == '가위' && robotChoice == '보') ||
        (choice == '바위' && robotChoice == '가위') ||
        (choice == '보' && robotChoice == '바위')) {
      result = '승리';
      _wins++;
      AppSfxController.playCorrect(); // 이겼을 때 효과음
    } else {
      result = '패배';
      _losses++;
      AppSfxController.playWrong(); // 졌을 때 효과음
    }

    setState(() {
      _isThinking = false;
      _aiChoice = robotChoice;
      _roundResult = result;
      _roundCompleted = true;
    });
  }

  void _proceedToNext() {
    AppSfxController.playClick();
    if (_currentRound < 5) {
      setState(() {
        _currentRound++;
        _playerChoice = null;
        _aiChoice = null;
        _roundResult = null;
        _roundCompleted = false;
      });
    } else {
      // 5판 종료 후 QR 인증 뷰로 전환
      setState(() {
        _showQrView = true;
      });
      _startScanner();
    }
  }

  // --- QR 스캐너 연동 로직 ---
  Future<void> _startScanner() async {
    if (!mounted || _isStartingScanner) return;
    if (_scannerController.value.isRunning) return;

    setState(() => _isStartingScanner = true);
    try {
      await _scannerController.start();
    } on MobileScannerException {
      if (!mounted) return;
      setState(() {});
    } finally {
      if (mounted) {
        setState(() => _isStartingScanner = false);
      }
    }
  }

  Future<void> _stopScanner() async {
    if (!mounted) return;
    if (!_scannerController.value.isRunning) return;
    try {
      await _scannerController.stop();
    } on MobileScannerException {
      // 무시
    }
  }

  bool _isAcceptedQrValue(String rawValue) {
    final value = rawValue.trim();
    if (value.isEmpty) return false;

    // '수학융합실' 포함 여부만 확인
    if (value.contains('수학융합실')) {
      return true;
    }

    try {
      final decoded = Uri.decodeFull(value);
      if (decoded.contains('수학융합실')) {
        return true;
      }
    } catch (_) {}

    return false;
  }

  Future<void> _handleDetection(String rawValue) async {
    if (_handlingDetection) return;

    setState(() {
      _handlingDetection = true;
    });

    await _scannerController.stop();

    if (!mounted) return;

    if (_isAcceptedQrValue(rawValue)) {
      _showSuccessDialog();
    } else {
      _showFailureDialog();
    }
  }

  Future<void> _submitManualQr() async {
    final rawValue = _manualQrController.text.trim();
    if (rawValue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL 또는 QR 코드를 입력해 주세요.')),
      );
      return;
    }

    if (_isAcceptedQrValue(rawValue)) {
      _showSuccessDialog();
    } else {
      _showFailureDialog();
    }
  }

  void _showSuccessDialog() {
    AppSfxController.playCorrect();
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
                    const Icon(Icons.check_circle_rounded, size: 90, color: Color(0xFF10B981)),
              ),
              const SizedBox(height: 18),
              const Text(
                '미션 인증 완료! 🎉',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF10B981),
                  fontFamily: 'GangwonEduAll',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '로봇 가위바위보 대결과 QR인증 미션을\n모두 훌륭하게 완수하였습니다!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF374151),
                  height: 1.35,
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
                    '스토리로 이동',
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

  void _showFailureDialog() {
    AppSfxController.playWrong();
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
                'assets/images/chr_how_fail.png',
                height: 160,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.warning_amber_rounded, size: 90, color: Color(0xFFEF4444)),
              ),
              const SizedBox(height: 18),
              const Text(
                '인증 실패 ❌',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFEF4444),
                  fontFamily: 'GangwonEduAll',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '올바르지 않은 QR 코드입니다.\n충북수학체험센터의 공식 미션 QR코드를 스캔해 주세요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4B5563),
                  height: 1.35,
                  fontFamily: 'GangwonEduAll',
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _handlingDetection = false;
                    });
                    _startScanner();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4B5563),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    '다시 시도',
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

  // --- 도움말 다이얼로그 ---
  void _showHelpDialog() {
    AppSfxController.playClick();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Color(0xFF3B82F6), size: 30),
            SizedBox(width: 10),
            Text('미션 방법 설명', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1. 가위바위보 대결:',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF1E293B)),
            ),
            SizedBox(height: 6),
            Text(
              ' - 화면 우측의 가위(✌️), 바위(✊), 보(✋) 중 원하는 모양을 클릭하세요.\n - 인공지능 로봇과 총 5라운드 대결을 펼칩니다.\n - 승부 결과와 전적이 실시간으로 반영됩니다.',
              style: TextStyle(fontSize: 16, height: 1.3, color: Color(0xFF4B5563)),
            ),
            SizedBox(height: 16),
            Text(
              '2. QR코드 인증:',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF1E293B)),
            ),
            SizedBox(height: 6),
            Text(
              ' - 5회 대결이 모두 끝나면 QR코드 스캔 화면으로 전환됩니다.\n - 체험센터의 지정된 QR 코드를 읽히거나 수동 입력하여 인증을 완료하세요.',
              style: TextStyle(fontSize: 16, height: 1.3, color: Color(0xFF4B5563)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    final isMobile = width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // 세련된 어두운 테크 분위기 배경
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 28),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false),
        ),
        title: Text(
          _showQrView ? '2단계: 인공지능 로봇 QR 인증' : '2단계: 인공지능 로봇 가위바위보',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, size: 30, color: Color(0xFF3B82F6)),
            onPressed: _showHelpDialog,
            tooltip: '도움말',
          ),
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.skip_next_rounded, size: 36, color: Color(0xFF60A5FA)),
              tooltip: '테스트용 스킵',
              onPressed: () {
                if (widget.completedRouteName != null) {
                  Navigator.pushReplacementNamed(context, widget.completedRouteName!);
                }
              },
            ),
          const BgmToggleButton(iconSize: 32),
          IconButton(
            icon: const Icon(Icons.home_rounded, size: 32),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              // --- 상단 진행도 및 인디케이터 ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF334155), width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStepIndicator(
                      title: '가위바위보 대결 (5회)',
                      isActive: !_showQrView,
                      isCompleted: _showQrView,
                    ),
                    const Icon(Icons.arrow_forward_rounded, color: Colors.white54, size: 24),
                    _buildStepIndicator(
                      title: 'QR인증 미션',
                      isActive: _showQrView,
                      isCompleted: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --- 콘텐츠 영역 ---
              Expanded(
                child: _showQrView ? _buildQrContent(isMobile) : _buildGameContent(isMobile),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 스텝 인디케이터 위젯 ---
  Widget _buildStepIndicator({
    required String title,
    required bool isActive,
    required bool isCompleted,
  }) {
    Color indicatorColor = const Color(0xFF475569);
    if (isActive) {
      indicatorColor = const Color(0xFF3B82F6);
    } else if (isCompleted) {
      indicatorColor = const Color(0xFF10B981);
    }

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: indicatorColor,
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.5), blurRadius: 8)]
                : null,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, size: 18, color: Colors.white)
                : const Icon(Icons.circle, size: 8, color: Colors.white),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            color: isActive || isCompleted ? Colors.white : const Color(0xFF94A3B8),
            fontWeight: isActive || isCompleted ? FontWeight.w900 : FontWeight.w600,
            fontSize: 18,
            fontFamily: 'GangwonEduAll',
          ),
        ),
      ],
    );
  }

  // --- 가위바위보 게임화면 콘텐츠 ---
  Widget _buildGameContent(bool isMobile) {
    return Row(
      children: [
        // 왼쪽 패널: 배틀 아레나 (VS 카드)
        Expanded(
          flex: 5,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF334155), width: 2),
              boxShadow: const [
                BoxShadow(color: Color(0x20000000), blurRadius: 16, offset: Offset(0, 8)),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    '라운드 $_currentRound / 5',
                    style: const TextStyle(
                      color: Color(0xFF60A5FA),
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      fontFamily: 'GangwonEduAll',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // 로봇 진영
                        _buildBattleCard(
                          title: '인공지능 로봇',
                          icon: Icons.smart_toy_rounded,
                          color: const Color(0xFFEC4899),
                          choice: _aiChoice,
                          isThinking: _isThinking,
                        ),
                        // VS 텍스트
                        const Text(
                          'VS',
                          style: TextStyle(
                            color: Colors.white60,
                            fontWeight: FontWeight.w900,
                            fontSize: 32,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        // 플레이어 진영
                        _buildBattleCard(
                          title: '플레이어',
                          icon: Icons.person_rounded,
                          color: const Color(0xFF3B82F6),
                          choice: _playerChoice,
                          isThinking: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),

        // 오른쪽 패널: 게임 제어판 및 스코어
        Expanded(
          flex: 4,
          child: Column(
            children: [
              // 스코어 보드
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF334155), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🏆 누적 전적',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildScoreItem(label: '승리', value: _wins, color: const Color(0xFF10B981)),
                        _buildScoreItem(label: '무승부', value: _draws, color: Colors.amber),
                        _buildScoreItem(label: '패배', value: _losses, color: const Color(0xFFEF4444)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 상태창 & 버튼 제어 영역
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF334155), width: 1.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 결과 및 설명 메시지
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _roundCompleted
                                ? (_roundResult == '승리'
                                    ? const Color(0xFF10B981)
                                    : _roundResult == '패배'
                                        ? const Color(0xFFEF4444)
                                        : Colors.amber)
                                : const Color(0xFF334155),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          _isThinking
                              ? '로봇이 플레이어의 선택을 분석 중입니다... 🤔'
                              : _roundCompleted
                                  ? (_roundResult == '승리'
                                      ? '🎉 이겼습니다! 멋진 수였습니다!'
                                      : _roundResult == '패배'
                                          ? '😢 아쉽게 패했습니다. 다음 기회에!'
                                          : '🤝 비겼습니다! 다시 한번 겨뤄보세요!')
                                  : '가위, 바위, 보 중 하나를 선택해 주세요!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'GangwonEduAll',
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 인터랙티브 제어 버튼
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: _roundCompleted
                            ? SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _proceedToNext,
                                  icon: const Icon(Icons.navigate_next_rounded, size: 28),
                                  label: Text(
                                    _currentRound == 5 ? 'QR인증 미션 시작' : '다음 라운드 진행',
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3B82F6),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    elevation: 8,
                                    shadowColor: const Color(0x403B82F6),
                                  ),
                                ),
                              )
                            : Row(
                                children: [
                                  _buildRpsButton(label: '가위', emoji: '✌️'),
                                  const SizedBox(width: 10),
                                  _buildRpsButton(label: '바위', emoji: '✊'),
                                  const SizedBox(width: 10),
                                  _buildRpsButton(label: '보', emoji: '✋'),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- RPS 배틀 카드 위젯 ---
  Widget _buildBattleCard({
    required String title,
    required IconData icon,
    required Color color,
    required String? choice,
    required bool isThinking,
  }) {
    String emoji = '❔';
    if (choice == '가위') emoji = '✌️';
    if (choice == '바위') emoji = '✊';
    if (choice == '보') emoji = '✋';

    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 12),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isThinking
                  ? const Center(
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEC4899)),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        emoji,
                        key: ValueKey(emoji),
                        style: const TextStyle(fontSize: 64),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isThinking
                ? '분석 중...'
                : choice != null
                    ? '$choice 선택!'
                    : '대기 중',
            style: TextStyle(
              color: choice != null ? Colors.white : Colors.white38,
              fontWeight: FontWeight.w700,
              fontSize: 16,
              fontFamily: 'GangwonEduAll',
            ),
          ),
        ],
      ),
    );
  }

  // --- 스코어 아이템 ---
  Widget _buildScoreItem({
    required String label,
    required int value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 4),
        Text(
          '$value',
          style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 28),
        ),
      ],
    );
  }

  // --- RPS 입력 버튼 ---
  Widget _buildRpsButton({
    required String label,
    required String emoji,
  }) {
    final bool disabled = _isThinking || _roundCompleted;

    Color glowColor = const Color(0xFFBAC5E8);
    Color btnBg = const Color(0xFF1E293B);
    if (label == '가위') {
      glowColor = const Color(0xFFFFB020);
      btnBg = const Color(0xFF2E241E);
    } else if (label == '바위') {
      glowColor = const Color(0xFFFF528E);
      btnBg = const Color(0xFF2E1C24);
    } else if (label == '보') {
      glowColor = const Color(0xFF06B6D4);
      btnBg = const Color(0xFF172535);
    }

    return Expanded(
      child: Opacity(
        opacity: disabled ? 0.6 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: glowColor.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: disabled ? null : () => _playRound(label),
            style: ElevatedButton.styleFrom(
              backgroundColor: btnBg,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: glowColor, width: 2.2),
              ),
              elevation: 4,
              shadowColor: glowColor.withValues(alpha: 0.25),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 34)),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'GangwonEduAll',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- QR 인증화면 콘텐츠 ---
  Widget _buildQrContent(bool isMobile) {
    return Row(
      children: [
        // 왼쪽 영역: 안내문
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF334155), width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.smart_toy_rounded, color: Color(0xFF10B981), size: 20),
                      SizedBox(width: 6),
                      Text(
                        '1단계 완수 완료!',
                        style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '인공지능 로봇 대결 성공!\n이제 최종 QR 코드를 스캔하세요.',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 26,
                    height: 1.35,
                    fontFamily: 'GangwonEduAll',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '체험관 인공지능 로봇 근처에 부착된 미션 인증용 QR코드를 카메라에 인식시켜 최종 완료 승인을 받으세요.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.45,
                    fontFamily: 'GangwonEduAll',
                  ),
                ),
                const SizedBox(height: 30),
                // 수동 입력 필드 (테스트 및 모바일 카메라 부재 대응용)
                const Text(
                  '⌨️ 수동 입력 (미션 암호 또는 QR 값 입력)',
                  style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _manualQrController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: '예: 수학융합실',
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: const Color(0xFF0F172A),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF334155)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _submitManualQr,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('인증', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 20),

        // 오른쪽 영역: 카메라 뷰파인더 또는 디버그 모형
        Expanded(
          flex: 5,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF334155), width: 2),
              boxShadow: const [
                BoxShadow(color: Color(0x30000000), blurRadius: 16, offset: Offset(0, 8)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: RotatedBox(
                      quarterTurns: _previewRotationTurns,
                      child: MobileScanner(
                        controller: _scannerController,
                        onDetect: (capture) {
                          final List<Barcode> barcodes = capture.barcodes;
                          if (barcodes.isNotEmpty) {
                            final String? code = barcodes.first.rawValue;
                            if (code != null) {
                              _handleDetection(code);
                            }
                          }
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return _buildViewfinderMockup(
                            title: '📸 스캐너 시뮬레이션 및 안내',
                            subtitle: '에뮬레이터 환경이거나 카메라 권한이 없습니다. 실기기에서는 카메라가 정상 구동되며, 테스트 시 수동 입력을 이용하세요.',
                          );
                        },
                      ),
                    ),
                  ),

                  // 뷰파인더 포커스 프레임 오버레이
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF60A5FA), width: 3),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Stack(
                          children: [
                            _buildScannerCorner(top: 0, left: 0),
                            _buildScannerCorner(top: 0, right: 0),
                            _buildScannerCorner(bottom: 0, left: 0),
                            _buildScannerCorner(bottom: 0, right: 0),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 하단 카메라 가동 안내 메시지
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.center_focus_weak_rounded, color: Color(0xFF60A5FA), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'QR 코드를 중앙 사각형 안에 오도록 맞춰주세요.',
                            style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- 스캐너 모형 뷰 위젯 ---
  Widget _buildViewfinderMockup({required String title, required String subtitle}) {
    return Container(
      color: const Color(0xFF1E293B),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.qr_code_scanner_rounded, size: 64, color: Colors.white38),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 14)),
        ],
      ),
    );
  }

  // --- 스캐너 모퉁이 기호 ---
  Widget _buildScannerCorner({
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: const Color(0xFF3B82F6),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(top == 0 && left == 0 ? 8 : 0),
            topRight: Radius.circular(top == 0 && right == 0 ? 8 : 0),
            bottomLeft: Radius.circular(bottom == 0 && left == 0 ? 8 : 0),
            bottomRight: Radius.circular(bottom == 0 && right == 0 ? 8 : 0),
          ),
        ),
      ),
    );
  }
}
