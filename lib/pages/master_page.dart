import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:novella_app/routing_tpl.dart';

class MasterPage extends StatefulWidget {
  final Widget child;

  const MasterPage({
    required this.child,
    super.key,
  });

  @override
  State<MasterPage> createState() => _MasterPageState();
}

class _MasterPageState extends State<MasterPage> {
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith(Routes.home)) return 0;
    if (location.startsWith(Routes.search)) return 1;
    if (location.startsWith(Routes.library)) return 2;
    if (location.startsWith(Routes.writing_or_upload)) return 3;
    if (location.startsWith(Routes.notification)) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(Routes.home);
        break;
      case 1:
        context.go(Routes.search);
        break;
      case 2:
        context.go(Routes.library);
        break;
      case 3:
        context.go(Routes.writing_or_upload);
        break;
      case 4:
        context.go(Routes.notification);
        break;
    }
  }

  Widget _buildNavItem(IconData icon, int index, BuildContext context) {
    int selectedIndex = _calculateSelectedIndex(context);
    bool isSelected = selectedIndex == index;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isSelected ? Colors.orange : Colors.grey),
        const SizedBox(height: 4),
        isSelected
            ? Container(
                width: 25,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(2),
                ),
              )
            : const SizedBox(height: 3),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Novella',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          actions: [
           
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ],
        ),
        backgroundColor: Colors.black,
        body: widget.child,
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.black,
            selectedItemColor: Colors.orange,
            unselectedItemColor: Colors.grey,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            currentIndex: _calculateSelectedIndex(context),
            onTap: (index) => _onItemTapped(index, context),
            items: [
              BottomNavigationBarItem(
                icon: _buildNavItem(Icons.home, 0, context),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: _buildNavItem(Icons.search, 1, context),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: _buildNavItem(Icons.menu, 2, context),
                label: 'Library',
              ),
              BottomNavigationBarItem(
                icon: _buildNavItem(Icons.edit, 3, context),
                label: 'Write',
              ),
              BottomNavigationBarItem(
                icon: _buildNavItem(Icons.notifications, 4, context),
                label: 'notification',
              ),
            ],
          ),
        ));
  }
}
