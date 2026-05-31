import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'bgm_controller.dart';
import 'bgm_toggle_button.dart';

class Chapter4RpsQrScreen extends StatefulWidget {
  const Chapter4RpsQrScreen({super.key, this.completedRouteName});

  final String? completedRouteName;

  @override
  State<Chapter4RpsQrScreen> createState() => _Chapter4RpsQrScreenState();
}

class _Chapter4RpsQrScreenState extends State<Chapter4RpsQrScreen>
    with WidgetsBindingObserver {
  bool _handlingDetection = false;
  bool _isStartingScanner = false;
  final TextEditingController _manualQrController = TextEditingController();
  final int _previewRotationTurns = 3;

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScanner());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _manualQrController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted || _handlingDetection) return;
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

  Future<void> _startScanner() async {
    if (!mounted || _isStartingScanner) return;
    if (_scannerController.value.isRunning) return;

    setState(() => _isStartingScanner = true);
    try {
      await _scannerController.start();
    } on MobileScannerException {
      if (mounted) setState(() {});
    } finally {
      if (mounted) setState(() => _isStartingScanner = false);
    }
  }

  Future<void> _stopScanner() async {
    if (!_scannerController.value.isRunning) return;
    try {
      await _scannerController.stop();
    } on MobileScannerException {
      // Scanner can already be stopped during lifecycle changes.
    }
  }

  bool _isAcceptedQrValue(String rawValue) {
    final value = rawValue.trim();
    if (value.isEmpty) return false;

    if (value.contains('수학융합실')) return true;

    try {
      return Uri.decodeFull(value).contains('수학융합실');
    } catch (_) {
      return false;
    }
  }

  Future<void> _handleDetection(String rawValue) async {
    if (_handlingDetection) return;
    setState(() => _handlingDetection = true);
    await _stopScanner();

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
        const SnackBar(content: Text('QR 코드 내용 또는 인증 문구를 입력해 주세요.')),
      );
      return;
    }

    setState(() => _handlingDetection = true);
    await _stopScanner();

    if (!mounted) return;
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
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.check_circle_rounded,
                  size: 90,
                  color: Color(0xFF10B981),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'QR 인증 완료! 🎉',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF10B981),
                  fontFamily: 'GangwonEduAll',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '수학융합실 인증 QR 코드를 확인했어요.\n마지막 별 조각을 찾으러 가 볼까요?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                  color: Color(0xFF374151),
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
                      Navigator.pushReplacementNamed(
                        context,
                        widget.completedRouteName!,
                      );
                    } else {
                      Navigator.maybePop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF133E97),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    '다음으로',
                    style: TextStyle(
                      fontSize: 24,
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

  void _showFailureDialog() {
    AppSfxController.playWrong();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/chr_play_wrong.png',
                height: 150,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.qr_code_2_rounded,
                  size: 90,
                  color: Color(0xFFD64A45),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                '다시 인증해 주세요',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFD64A45),
                  fontFamily: 'GangwonEduAll',
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                '안내데스크에서 받은 인증 QR 코드가 아니에요.\nQR 코드를 다시 스캔하거나 담당 선생님께 확인해 주세요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                  color: Color(0xFF374151),
                  fontFamily: 'GangwonEduAll',
                ),
              ),
              const SizedBox(height: 22),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => _handlingDetection = false);
                  _startScanner();
                },
                child: const Text(
                  '다시 스캔하기',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF133E97),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _skipForTest() {
    if (widget.completedRouteName != null) {
      Navigator.pushReplacementNamed(context, widget.completedRouteName!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 1100;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF163988),
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '미션! 수학체험센터의 반짝별을 찾아서',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
        ),
        centerTitle: true,
        actions: [
          if (kDebugMode)
            IconButton(
              icon: const Icon(
                Icons.skip_next_rounded,
                size: 36,
                color: Color(0xFF355AA8),
              ),
              tooltip: '테스트용 스킵',
              onPressed: _skipForTest,
            ),
          const BgmToggleButton(iconSize: 32),
          IconButton(
            icon: const Icon(Icons.home_rounded, size: 34),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
          child: Row(
            children: [
              Expanded(
                flex: 6,
                child: _buildScannerPanel(isCompact),
              ),
              const SizedBox(width: 18),
              Expanded(
                flex: 5,
                child: _buildGuidePanel(isCompact),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScannerPanel(bool isCompact) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD7E3FF), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 18,
              vertical: isCompact ? 12 : 16,
            ),
            color: const Color(0xFF133E97),
            child: Text(
              '안내데스크 QR 코드를 화면 중앙에 맞춰 주세요',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isCompact ? 19 : 23,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontFamily: 'GangwonEduAll',
              ),
            ),
          ),
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                RotatedBox(
                  quarterTurns: _previewRotationTurns,
                  child: MobileScanner(
                    controller: _scannerController,
                    onDetect: (capture) {
                      String? value;
                      for (final barcode in capture.barcodes) {
                        final rawValue = barcode.rawValue;
                        if (rawValue != null && rawValue.trim().isNotEmpty) {
                          value = rawValue;
                          break;
                        }
                      }
                      if (value != null) _handleDetection(value);
                    },
                  ),
                ),
                Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: Colors.white,
                        width: 5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x66000000),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner_rounded,
                      size: 70,
                      color: Colors.white70,
                    ),
                  ),
                ),
                if (_isStartingScanner)
                  Container(
                    color: const Color(0x99000000),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidePanel(bool isCompact) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 20 : 26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD7E3FF), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.smart_toy_rounded,
            size: isCompact ? 58 : 72,
            color: const Color(0xFF133E97),
          ),
          const SizedBox(height: 14),
          Text(
            '인공지능 가위바위보 로봇 체험 후\nQR 인증을 진행해요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isCompact ? 25 : 30,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0B235F),
              height: 1.25,
              fontFamily: 'GangwonEduAll',
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '실제 수학융합실의 인공지능 가위바위보 로봇을 체험한 뒤, 안내데스크에서 받은 QR 코드를 스캔해 주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isCompact ? 18 : 21,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF4B5563),
              height: 1.35,
              fontFamily: 'GangwonEduAll',
            ),
          ),
          const SizedBox(height: 22),
          const Spacer(),
          TextField(
            controller: _manualQrController,
            style: TextStyle(
              fontSize: isCompact ? 18 : 20,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              labelText: 'QR 인식이 안 될 때만 수동 입력',
              hintText: '담당 선생님 안내에 따라 입력',
              prefixIcon: const Icon(Icons.keyboard_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onSubmitted: (_) => _submitManualQr(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: isCompact ? 50 : 58,
            child: ElevatedButton.icon(
              onPressed: _submitManualQr,
              icon: const Icon(Icons.verified_rounded),
              label: const Text('QR 인증 확인'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF133E97),
                foregroundColor: Colors.white,
                textStyle: TextStyle(
                  fontSize: isCompact ? 19 : 22,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'GangwonEduAll',
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
