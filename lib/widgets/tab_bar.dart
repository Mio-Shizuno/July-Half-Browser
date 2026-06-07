import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/browser_state.dart';
import '../theme/app_theme.dart';

class HellTabBar extends StatelessWidget {
  const HellTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BrowserState>();
    return Container(
      height: 36,
      color: HellTheme.voidBlack,
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.tabs.length,
              itemBuilder: (ctx, i) {
                final tab = state.tabs[i];
                final active = i == state.currentIndex;
                return GestureDetector(
                  onTap: () => state.switchTab(i),
                  child: Container(
                    constraints:
                        const BoxConstraints(minWidth: 80, maxWidth: 160),
                    margin: const EdgeInsets.only(right: 1, top: 1),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: active
                          ? HellTheme.ashBlack
                          : HellTheme.voidBlack,
                      border: Border(
                        top: BorderSide(
                            color: active
                                ? HellTheme.bloodRed
                                : Colors.transparent,
                            width: 1.5),
                        left: BorderSide(
                            color: active
                                ? HellTheme.dimRed
                                : Colors.transparent,
                            width: 0.5),
                        right: BorderSide(
                            color: active
                                ? HellTheme.dimRed
                                : Colors.transparent,
                            width: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (tab.isLoading)
                          SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(
                              strokeWidth: 1,
                              color: HellTheme.bloodRed,
                            ),
                          )
                        else
                          Icon(Icons.circle,
                              size: 6,
                              color: active
                                  ? HellTheme.bloodRed
                                  : HellTheme.dimRed),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            tab.title,
                            style: GoogleFonts.notoSerifSc(
                              fontSize: 11,
                              color: active
                                  ? HellTheme.ghostWhite
                                  : HellTheme.ashWhite.withOpacity(0.4),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => state.closeTab(i),
                          child: Icon(Icons.close,
                              size: 12,
                              color: active
                                  ? HellTheme.ashWhite.withOpacity(0.6)
                                  : HellTheme.dimRed),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // 新标签按钮
          GestureDetector(
            onTap: () => state.addTab(),
            child: Container(
              width: 36,
              alignment: Alignment.center,
              child: Icon(Icons.add,
                  color: HellTheme.ashWhite.withOpacity(0.5), size: 18),
            ),
          ),
        ],
      ),
    );
  }
}