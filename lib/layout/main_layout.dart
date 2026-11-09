import 'package:flutter/material.dart';
import 'sidebar.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final String activeRoute;

  const MainLayout({required this.child, this.activeRoute = '/', super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(activeRoute: activeRoute),
          Expanded(
            child: Container(color: const Color(0xfff6f7fb), child: child),
          ),
        ],
      ),
    );
  }
}
