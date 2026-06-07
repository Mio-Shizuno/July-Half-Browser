import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/browser_state.dart';
import '../theme/app_theme.dart';

class NewTabScreen extends StatefulWidget {
  final Function(String) onNavigate;
  const NewTabScreen({super.key, required this.onNavigate});

  @override
  State<NewTabScreen> createState() => _NewTabScreenState();
}

class _NewTabScreenState extends State<NewTabScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _search() {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) return;
    final url = q.startsWith('http') ? q : 'https://www.baidu.com/s?wd=$q';
    widget.onNavigate(url);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BrowserState>();
    return Container(
      color: HellTheme.voidBlack,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(
          children: [
            // 背景噪点纹理
            Positioned.fill(child: _NoiseBackground()),
            // 背景竖线装饰
            Positioned.fill(child: _GridLines()),
            // 主内容
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    _buildHeader(),
                    const SizedBox(height: 48),
                    _buildSearchBar(),
                    const SizedBox(height: 48),
                    _buildQuickLinks(),
                    if (state.history.isNotEmpty) ...[
                      const SizedBox(height: 36),
                      _buildHistory(state),
                    ],
                    if (state.bookmarks.isNotEmpty) ...[
                      const SizedBox(height: 36),
                      _buildBookmarks(state),
                    ],
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // 顶部装饰线
        Row(
          children: [
            Expanded(child: Container(height: 0.5, color: HellTheme.dimRed)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('※',
                  style: TextStyle(color: HellTheme.bloodRed, fontSize: 14)),
            ),
            Expanded(child: Container(height: 0.5, color: HellTheme.dimRed)),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          '柒月半浏览器',
          style: GoogleFonts.notoSerifSc(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: HellTheme.bloodRed,
            letterSpacing: 8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '— 万 物 皆 可 览 —',
          style: GoogleFonts.notoSerifSc(
            fontSize: 12,
            color: HellTheme.ashWhite.withOpacity(0.5),
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: Container(height: 0.5, color: HellTheme.dimRed)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('※',
                  style: TextStyle(color: HellTheme.bloodRed, fontSize: 14)),
            ),
            Expanded(child: Container(height: 0.5, color: HellTheme.dimRed)),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: HellTheme.rustRed, width: 0.8),
        color: HellTheme.paperBlack,
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(Icons.search, color: HellTheme.bloodRed, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              style: GoogleFonts.notoSerifSc(
                  color: HellTheme.ghostWhite, fontSize: 14),
              decoration: InputDecoration(
                hintText: '搜索或输入网址...',
                hintStyle: GoogleFonts.notoSerifSc(
                    color: HellTheme.ashWhite.withOpacity(0.3), fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
          GestureDetector(
            onTap: _search,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              color: HellTheme.darkBlood,
              child: Text('觅',
                  style: GoogleFonts.notoSerifSc(
                      color: HellTheme.ghostWhite, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLinks() {
    final links = [
      ('百度', 'https://www.baidu.com', Icons.search),
      ('哔哩哔哩', 'https://www.bilibili.com', Icons.play_circle_outline),
      ('微博', 'https://www.weibo.com', Icons.chat_bubble_outline),
      ('知乎', 'https://www.zhihu.com', Icons.lightbulb_outline),
      ('Github', 'https://github.com', Icons.code),
      ('网易云', 'https://music.163.com', Icons.music_note_outlined),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('快速入口'),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: links
              .map((l) => _QuickLinkCard(
                    label: l.$1,
                    url: l.$2,
                    icon: l.$3,
                    onTap: () => widget.onNavigate(l.$2),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildHistory(BrowserState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('最近访问'),
        const SizedBox(height: 12),
        ...state.history.take(5).map((url) => _HistoryItem(
              url: url,
              onTap: () => widget.onNavigate(url),
            )),
      ],
    );
  }

  Widget _buildBookmarks(BrowserState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('书签'),
        const SizedBox(height: 12),
        ...state.bookmarks.take(5).map((url) => _HistoryItem(
              url: url,
              onTap: () => widget.onNavigate(url),
            )),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Row(
      children: [
        Container(width: 3, height: 14, color: HellTheme.bloodRed),
        const SizedBox(width: 8),
        Text(text,
            style: GoogleFonts.notoSerifSc(
                color: HellTheme.ashWhite,
                fontSize: 13,
                letterSpacing: 2)),
      ],
    );
  }
}

class _QuickLinkCard extends StatelessWidget {
  final String label, url;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickLinkCard(
      {required this.label,
      required this.url,
      required this.icon,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: HellTheme.ashBlack,
          border: Border.all(color: HellTheme.dimRed, width: 0.6),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: HellTheme.bloodRed, size: 20),
            const SizedBox(height: 6),
            Text(label,
                style: GoogleFonts.notoSerifSc(
                    color: HellTheme.ashWhite, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final String url;
  final VoidCallback onTap;

  const _HistoryItem({required this.url, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: HellTheme.paperBlack,
          border: Border.all(color: HellTheme.dimRed.withOpacity(0.5), width: 0.5),
        ),
        child: Row(
          children: [
            Icon(Icons.history, color: HellTheme.dimRed, size: 14),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                url,
                style: GoogleFonts.notoSerifSc(
                    color: HellTheme.ashWhite.withOpacity(0.7), fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 噪点背景
class _NoiseBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _NoisePainter());
  }
}

class _NoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = HellTheme.bloodRed.withOpacity(0.015);
    final random = List.generate(300, (i) => i);
    for (var i in random) {
      final x = (i * 137.5) % size.width;
      final y = (i * 97.3) % size.height;
      canvas.drawCircle(Offset(x, y), 1, paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// 网格线背景
class _GridLines extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GridPainter());
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = HellTheme.dimRed.withOpacity(0.08)
      ..strokeWidth = 0.3;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}