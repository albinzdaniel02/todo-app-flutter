import 'package:flutter/material.dart';

/// A wrapper widget that switches between [mobileLayout] and [desktopLayout]
/// depending on the screen width. By default, it uses a breakpoint of 768.0 logical pixels.
class ResponsiveLayout extends StatelessWidget {
  final Widget mobileLayout;
  final Widget desktopLayout;
  final double breakpoint;

  const ResponsiveLayout({
    super.key,
    required this.mobileLayout,
    required this.desktopLayout,
    this.breakpoint = 768.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= breakpoint) {
          return desktopLayout;
        }
        return mobileLayout;
      },
    );
  }
}
