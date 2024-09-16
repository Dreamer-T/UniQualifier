import 'package:flutter/material.dart';
import 'package:uniqualifier/profile.dart';

class MainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  bool _isSearching = false; // 是否处于搜索状态

  final List<Widget> _pages = [
    Center(
      child: Text("History Page"),
    ),
    Center(
      child: Text("Ask a teacher Page"),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      if (_currentIndex != 1) {
        _isSearching = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _pages.isNotEmpty
              ? _pages[_currentIndex]
              : Center(child: CircularProgressIndicator()),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: IconButton(
                  icon: Icon(Icons.person),
                  iconSize: 40,
                  onPressed: () {
                    Navigator.of(context).push(_createPageTransition());
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: _isSearching ? null : CircularNotchedRectangle(),
        notchMargin: _isSearching ? 0.0 : 10.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              iconSize: 30.0,
              icon: Icon(Icons.history),
              tooltip: "History",
              color: _currentIndex == 0 ? Colors.green : Colors.grey,
              onPressed: () {
                _onItemTapped(0);
              },
            ),
            SizedBox(width: 40), // 留出位置给浮动按钮
            IconButton(
              iconSize: 30.0,
              icon: Icon(Icons.school),
              tooltip: "Ask a teacher",
              color: _currentIndex == 1 ? Colors.green : Colors.grey,
              onPressed: () {
                _onItemTapped(1);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: 80.0,
        height: 80.0,
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              _isSearching = true;
              Navigator.pushNamed(context, "/home/camera");
            });
          },
          child: Icon(
            Icons.camera_alt_outlined,
            size: 40,
            color: Colors.white,
          ),
          tooltip: 'Search',
          elevation: 5.0,
          backgroundColor: Colors.green,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  PageRouteBuilder _createPageTransition() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        // Define the new page to navigate to
        return ProfileScreen();
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Define the animation for page transition
        const begin = Offset(1.0, 0.0); // Starting point (slide from right)
        const end = Offset.zero; // Ending point (slide to the current position)
        const curve = Curves.easeInOut; // Curve for the animation

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }
}
