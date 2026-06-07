import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/browser_state.dart';
import '../theme/app_theme.dart';
import '../widgets/address_bar.dart';
import '../widgets/nav_bar.dart';
import '../widgets/tab_bar.dart';
import 'new_tab_screen.dart';

class BrowserScreen extends StatefulWidget {
  const BrowserScreen({super.key});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  InAppWebViewController? _webCtrl;
  bool _canGoBack = false;
  bool _canGoForward = false;

  final InAppWebViewSettings _settings = InAppWebViewSettings(
    javaScriptEnabled: true,
    domStorageEnabled: true,
    databaseEnabled: true,
    supportZoom: true,
    useWideViewPort: true,
    loadWithOverviewMode: true,
    useShouldOverrideUrlLoading: true,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
  );

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BrowserState>();
    final tab = state.currentTab;
    final isNewTab = tab.url.isEmpty;

    return Scaffold(
      backgroundColor: HellTheme.voidBlack,
      body: SafeArea(
        child: Column(
          children: [
            // 标签栏
            const HellTabBar(),
            // 地址栏
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              color: HellTheme.ashBlack,
              child: AddressBar(
                currentUrl: tab.url,
                isLoading: tab.isLoading,
                progress: tab.progress,
                onSubmit: (url) {
                  if (url == '__stop__') {
                    _webCtrl?.stopLoading();
                  } else {
                    _navigate(url, state);
                  }
                },
              ),
            ),
            // 主内容区
            Expanded(
              child: Stack(
                children: [
                  // WebView（始终存在，新标签时隐藏）
                  Offstage(
                    offstage: isNewTab,
                    child: InAppWebView(
                      key: ValueKey(state.currentIndex),
                      initialUrlRequest: tab.url.isNotEmpty
                          ? URLRequest(url: WebUri(tab.url))
                          : null,
                      initialSettings: _settings,
                      onWebViewCreated: (ctrl) => _webCtrl = ctrl,
                      onLoadStart: (ctrl, url) {
                        state.updateTab(
                          url: url?.toString() ?? '',
                          isLoading: true,
                        );
                      },
                      onLoadStop: (ctrl, url) async {
                        final title = await ctrl.getTitle();
                        final back = await ctrl.canGoBack();
                        final forward = await ctrl.canGoForward();
                        final u = url?.toString() ?? '';
                        state.updateTab(
                          url: u,
                          title: title ?? u,
                          isLoading: false,
                          progress: 1.0,
                        );
                        state.addHistory(u);
                        setState(() {
                          _canGoBack = back;
                          _canGoForward = forward;
                        });
                      },
                      onProgressChanged: (ctrl, progress) {
                        state.updateTab(progress: progress / 100);
                      },
                      onTitleChanged: (ctrl, title) {
                        state.updateTab(title: title ?? '');
                      },
                      // 🎯 核心修复：在这里建立安检，拦截所有非网页跳转
                      shouldOverrideUrlLoading: (ctrl, action) async {
                        final uri = action.request.url;
                        if (uri != null && !['http', 'https', 'about', 'file'].contains(uri.scheme)) {
                          // 如果不是正常的网页协议（比如 ms-windows-store://, weixin://, alipays:// 等）
                          // 直接取消加载，阻止 WebView 报错
                          return NavigationActionPolicy.CANCEL;
                        }
                        return NavigationActionPolicy.ALLOW;
                      },
                    ),
                  ),
                  // 新标签页
                  if (isNewTab)
                    NewTabScreen(
                      onNavigate: (url) => _navigate(url, state),
                    ),
                ],
              ),
            ),
            // 导航栏
            NavBar(
              canGoBack: _canGoBack,
              canGoForward: _canGoForward,
              isBookmarked: state.isBookmarked(tab.url),
              onBack: () async {
                if (await _webCtrl?.canGoBack() ?? false) {
                  _webCtrl?.goBack();
                }
              },
              onForward: () async {
                if (await _webCtrl?.canGoForward() ?? false) {
                  _webCtrl?.goForward();
                }
              },
              onRefresh: () => _webCtrl?.reload(),
              onHome: () {
                state.updateTab(url: '', title: '新标签页');
                _webCtrl?.loadUrl(
                    urlRequest: URLRequest(url: WebUri('about:blank')));
              },
              onBookmark: () {
                final url = tab.url;
                if (url.isEmpty) return;
                if (state.isBookmarked(url)) {
                  state.removeBookmark(url);
                  _showToast(context, '已移除书签');
                } else {
                  state.addBookmark(url);
                  _showToast(context, '已添加书签');
                }
              },
              onMenu: () => _showMenu(context, state),
            ),
          ],
        ),
      ),
    );
  }

  // 核心改装大闸口：拦截所有搜索和网址请求，完美切换至 Edge(Bing) 引擎
  void _navigate(String url, BrowserState state) {
    String targetUrl = url.trim();

    if (targetUrl.contains('baidu.com/s?wd=')) {
      targetUrl = targetUrl.replaceAll('baidu.com/s?wd=', 'bing.com/search?q=');
    } 
    else if (targetUrl == 'https://www.baidu.com' || targetUrl == 'http://www.baidu.com' || targetUrl == 'www.baidu.com' || targetUrl == 'baidu.com') {
      targetUrl = 'https://www.bing.com';
    }
    else if (!targetUrl.startsWith('http://') && !targetUrl.startsWith('https://')) {
      if (targetUrl.contains('.') && !targetUrl.contains(' ')) {
        targetUrl = 'https://$targetUrl'; 
      } else {
        targetUrl = 'https://www.bing.com/search?q=${Uri.encodeComponent(targetUrl)}';
      }
    }

    state.updateTab(url: targetUrl, title: '加载中...', isLoading: true);
    if (_webCtrl != null) {
      _webCtrl!.loadUrl(urlRequest: URLRequest(url: WebUri(targetUrl)));
    }
  }

  void _showToast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: GoogleFonts.notoSerifSc(color: HellTheme.ghostWhite)),
      backgroundColor: HellTheme.ashBlack,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 1),
    ));
  }

  void _showMenu(BuildContext context, BrowserState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: HellTheme.ashBlack,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (_) => Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: HellTheme.bloodRed, width: 1)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MenuItem(
              icon: Icons.add,
              label: '新建标签页',
              onTap: () {
                Navigator.pop(context);
                state.addTab();
              },
            ),
            _MenuItem(
              icon: Icons.bookmark_border,
              label: '所有书签',
              onTap: () {
                Navigator.pop(context);
                _showBookmarks(context, state);
              },
            ),
            _MenuItem(
              icon: Icons.history,
              label: '历史记录',
              onTap: () {
                Navigator.pop(context);
                _showHistory(context, state);
              },
            ),
            _MenuItem(
              icon: Icons.share_outlined,
              label: '分享页面',
              onTap: () => Navigator.pop(context),
            ),
            Container(
                height: 0.5,
                margin: const EdgeInsets.symmetric(vertical: 4),
                color: HellTheme.dimRed),
            _MenuItem(
              icon: Icons.info_outline,
              label: '关于柒月半浏览器',
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookmarks(BuildContext context, BrowserState state) {
    _showListSheet(context, '书签', state.bookmarks,
        (url) => _navigate(url, state));
  }

  void _showHistory(BuildContext context, BrowserState state) {
    _showListSheet(context, '历史记录', state.history,
        (url) => _navigate(url, state));
  }

  void _showListSheet(BuildContext context, String title, List<String> items,
      Function(String) onTap) {
    showModalBottomSheet(
      context: context,
      backgroundColor: HellTheme.ashBlack,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (_, ctrl) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(color: HellTheme.bloodRed, width: 1),
                    bottom: BorderSide(color: HellTheme.dimRed, width: 0.5)),
              ),
              child: Row(
                children: [
                  Container(
                      width: 3, height: 16, color: HellTheme.bloodRed),
                  const SizedBox(width: 10),
                  Text(title,
                      style: GoogleFonts.notoSerifSc(
                          color: HellTheme.ghostWhite,
                          fontSize: 15,
                          letterSpacing: 2)),
                ],
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text('空无一物',
                          style: GoogleFonts.notoSerifSc(
                              color: HellTheme.dimRed, fontSize: 14)))
                  : ListView.builder(
                      controller: ctrl,
                      itemCount: items.length,
                      itemBuilder: (_, i) => ListTile(
                        dense: true,
                        leading: Icon(Icons.circle,
                            size: 6, color: HellTheme.bloodRed),
                        title: Text(
                          items[i],
                          style: GoogleFonts.notoSerifSc(
                              color: HellTheme.ashWhite, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          onTap(items[i]);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: HellTheme.bloodRed, size: 20),
      title: Text(label,
          style: GoogleFonts.notoSerifSc(
              color: HellTheme.ghostWhite, fontSize: 13, letterSpacing: 1)),
      onTap: onTap,
    );
  }
}