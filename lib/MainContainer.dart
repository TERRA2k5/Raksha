import 'package:Raksha/UI/HomePage.dart';
import 'package:Raksha/UI/Profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {

  int currentIndex = 0;
  PageController pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
          onPageChanged: (index){
          setState(() {
            currentIndex = index;
          });
          },
          children: [
            HomePage(),
            Profile()
          ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        backgroundColor: Colors.grey[200],
        onTap: (index) {
          pageController.animateToPage(index, duration: const Duration(milliseconds: 500), curve: Curves.ease);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile")
        ],
      ),
    );
  }
}
