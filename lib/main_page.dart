import 'package:flutter/material.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:get/get.dart';
import 'package:mktdata/auth/resume_page.dart';
import 'package:mktdata/pages/navs/history_screen.dart';
import 'package:mktdata/pages/navs/home_screen.dart';
import 'package:mktdata/pages/navs/more_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int initialPosition = 0;
  // Initialize the controller
  final PageController _controller = PageController(initialPage: 0);

  final List<Widget> pages = [
    const HomeScreen(),
    HistoryScreen(),
    MoreScreen(),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PopScope(
        canPop: false,
        child: FocusDetector(
          onForegroundGained: () => Get.to(() => ResumePage()),
          child: PageView(
            controller: _controller,
            children: pages,
            onPageChanged: (value) {
              // Update the bottom nav index when swiping
              setState(() {
                initialPosition = value;
              });
            },
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: initialPosition,
      onTap: (i) {
        // 1. Update the UI state
        setState(() {
          initialPosition = i;
        });
        // 2. Animate the PageView to the selected index
        _controller.animateToPage(
          i,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      selectedItemColor: const Color(0xFF667EEA),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'More'),
      ],
    );
  }
}
