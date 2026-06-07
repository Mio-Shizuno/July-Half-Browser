import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class AddressBar extends StatefulWidget {
  final String currentUrl;
  final bool isLoading;
  final double progress;
  final Function(String) onSubmit;

  const AddressBar({
    super.key,
    required this.currentUrl,
    required this.isLoading,
    required this.progress,
    required this.onSubmit,
  });

  @override
  State<AddressBar> createState() => _AddressBarState();
}

class _AddressBarState extends State<AddressBar> {
  late TextEditingController _ctrl;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.currentUrl);
  }

  @override
  void didUpdateWidget(AddressBar old) {
    super.didUpdateWidget(old);
    if (!_focused && old.currentUrl != widget.currentUrl) {
      _ctrl.text = widget.currentUrl;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    var url = _ctrl.text.trim();
    if (url.isEmpty) return;
    if (!url.startsWith('http')) {
      url = url.contains('.') ? 'https://$url' : 'https://www.baidu.com/s?wd=$url';
    }
    widget.onSubmit(url);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 38,
          decoration: BoxDecoration(
            color: HellTheme.paperBlack,
            border: Border.all(
              color: _focused ? HellTheme.bloodRed : HellTheme.rustRed,
              width: _focused ? 1.0 : 0.6,
            ),
            borderRadius: BorderRadius.circular(1),
          ),
          child: Row(
            children: [
              const SizedBox(width: 10),
              widget.isLoading
                  ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: HellTheme.bloodRed,
                        value: widget.progress > 0 ? widget.progress : null,
                      ),
                    )
                  : Icon(Icons.lock_outline,
                      color: HellTheme.dimRed, size: 14),
              const SizedBox(width: 8),
              Expanded(
                child: Focus(
                  onFocusChange: (f) => setState(() => _focused = f),
                  child: TextField(
                    controller: _ctrl,
                    style: GoogleFonts.notoSerifSc(
                        color: HellTheme.ghostWhite, fontSize: 13),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      hintText: '输入网址或搜索',
                      hintStyle: GoogleFonts.notoSerifSc(
                          color: HellTheme.ashWhite.withOpacity(0.25),
                          fontSize: 13),
                    ),
                    onTap: () => _ctrl.selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: _ctrl.text.length),
                    onSubmitted: (_) => _submit(),
                    textInputAction: TextInputAction.go,
                  ),
                ),
              ),
              if (widget.isLoading)
                GestureDetector(
                  onTap: () => widget.onSubmit('__stop__'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child:
                        Icon(Icons.close, color: HellTheme.ashWhite, size: 16),
                  ),
                )
              else
                GestureDetector(
                  onTap: _submit,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(Icons.arrow_forward_ios,
                        color: HellTheme.bloodRed, size: 14),
                  ),
                ),
            ],
          ),
        ),
        // 进度条
        if (widget.isLoading)
          LinearProgressIndicator(
            value: widget.progress,
            backgroundColor: HellTheme.dimRed.withOpacity(0.2),
            color: HellTheme.bloodRed,
            minHeight: 1.5,
          ),
      ],
    );
  }
}