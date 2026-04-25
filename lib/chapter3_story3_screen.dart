import 'package:flutter/material.dart';
import 'bgm_toggle_button.dart';
import 'bgm_controller.dart';

class Chapter3Story3Screen extends StatefulWidget {
  const Chapter3Story3Screen({super.key});

  @override
  State<Chapter3Story3Screen> createState() => _Chapter3Story3ScreenState();
}

class _Chapter3Story3ScreenState extends State<Chapter3Story3Screen> {
  @override
  void initState() {
    super.initState();
    AppBgmController.playStory();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/images/chapter3_bg_1.png'), context);
    precacheImage(const AssetImage('assets/images/chr_how_cheering.png'), context);
  }

  void _goNext() {
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final charHeight = width < 1100 ? width * 0.42 : 420.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF163988),
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 32),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false),
        ),
        centerTitle: true,
        title: const Text(
          '미션! 수학체험센터의 반짝별을 찾아서',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24),
        ),
        actions: [
          const BgmToggleButton(iconSize: 34),
          IconButton(
            icon: const Icon(Icons.home_rounded, size: 38),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/chapter3_bg_1.png',
              fit: BoxFit.cover,
              cacheWidth: 800,
              errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFFDFE6F7)),
            ),
          ),
          Positioned.fill(
            child: Container(color: const Color(0x66000000)),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                SizedBox(
                  height: charHeight,
                  child: Image.asset(
                    'assets/images/chr_how_cheering.png',
                    fit: BoxFit.fitHeight,
                    cacheHeight: 600,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFF133E97), width: 3),
                      boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 10, offset: Offset(0, 4))],
                    ),
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(22, 18, 22, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SpeakerBadge(name: '하우'),
                          SizedBox(height: 12),
                          Text(
                            '좋아! 세 번째 별 조각이 거의 다 보이기 시작했어!',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF1E1E1E), height: 1.25),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _goNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF133E97),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        '홈으로',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                      ),
                    ),
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

class _SpeakerBadge extends StatelessWidget {
  const _SpeakerBadge({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF133E97),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        name,
        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
      ),
    );
  }
}
