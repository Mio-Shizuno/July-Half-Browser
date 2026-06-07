import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/browser_state.dart';
import '../theme/app_theme.dart';

class NavBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onForward;
  final VoidCallback onRefresh;
  final VoidCallback onHome;
  final VoidCallback onBookmark;
  final VoidCallback onMenu;
  final bool canGoBack;
  final bool canGoForward;
  final bool isBookmarked;

  const NavBar({
    super.key,
    required this.onBack,
    required this.onForward,
    required this.onRefresh,
    required this.onHome,
    required this.onBookmark,
    required this.onMenu,
    required this.canGoBack,
    required this.canGoForward,
    required this.isBookmarked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: HellTheme.ashBlack,
        border: Border(
            top: BorderSide(color: HellTheme.dimRed, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavBtn(
              icon: Icons.arrow_back_ios,
              onTap: canGoBack ? onBack : null,
              active: canGoBack),
          _NavBtn(
              icon: Icons.arrow_forward_ios,
              onTap: canGoForward ? onForward : null,
              active: canGoForward),
          _NavBtn(icon: Icons.refresh, onTap: onRefresh, active: true),
          _NavBtn(
              icon: Icons.home_outlined, onTap: onHome, active: true),
          _NavBtn(
              icon: isBookmarked
                  ? Icons.bookmark
                  : Icons.bookmark_border,
              onTap: onBookmark,
              active: true,
              highlight: isBookmarked),
          _NavBtn(
              icon: Icons.menu, onTap: onMenu, active: true),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool active;
  final bool highlight;

  const _NavBtn({
    required this.icon,
    required this.onTap,
    required this.active,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Icon(
          icon,
          size: 20,
          color: highlight
              ? HellTheme.bloodRed
              : active
                  ? HellTheme.ashWhite.withOpacity(0.8)
                  : HellTheme.dimRed.withOpacity(0.3),
        ),
      ),
    );
  }
}