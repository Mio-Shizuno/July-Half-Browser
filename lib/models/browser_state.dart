import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BrowserTab {
  String url;
  String title;
  bool isLoading;
  double progress;

  BrowserTab({
    this.url = '',
    this.title = '新标签页',
    this.isLoading = false,
    this.progress = 0,
  });
}

class BrowserState extends ChangeNotifier {
  List<BrowserTab> _tabs = [BrowserTab()];
  int _currentIndex = 0;
  List<String> _bookmarks = [];
  List<String> _history = [];

  List<BrowserTab> get tabs => _tabs;
  int get currentIndex => _currentIndex;
  BrowserTab get currentTab => _tabs[_currentIndex];
  List<String> get bookmarks => _bookmarks;
  List<String> get history => _history;

  BrowserState() {
    _loadData();
  }

  void addTab({String url = ''}) {
    _tabs.add(BrowserTab(url: url));
    _currentIndex = _tabs.length - 1;
    notifyListeners();
  }

  void closeTab(int index) {
    if (_tabs.length == 1) {
      _tabs[0] = BrowserTab();
      notifyListeners();
      return;
    }
    _tabs.removeAt(index);
    if (_currentIndex >= _tabs.length) {
      _currentIndex = _tabs.length - 1;
    }
    notifyListeners();
  }

  void switchTab(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void updateTab({String? url, String? title, bool? isLoading, double? progress}) {
    if (url != null) _tabs[_currentIndex].url = url;
    if (title != null) _tabs[_currentIndex].title = title;
    if (isLoading != null) _tabs[_currentIndex].isLoading = isLoading;
    if (progress != null) _tabs[_currentIndex].progress = progress;
    notifyListeners();
  }

  void addBookmark(String url) {
    if (!_bookmarks.contains(url)) {
      _bookmarks.insert(0, url);
      _saveData();
      notifyListeners();
    }
  }

  void removeBookmark(String url) {
    _bookmarks.remove(url);
    _saveData();
    notifyListeners();
  }

  bool isBookmarked(String url) => _bookmarks.contains(url);

  void addHistory(String url) {
    _history.remove(url);
    _history.insert(0, url);
    if (_history.length > 100) _history = _history.sublist(0, 100);
    _saveData();
    notifyListeners();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _bookmarks = prefs.getStringList('bookmarks') ?? [];
    _history = prefs.getStringList('history') ?? [];
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('bookmarks', _bookmarks);
    await prefs.setStringList('history', _history);
  }
}