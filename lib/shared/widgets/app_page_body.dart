import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import 'app_navigation_rail.dart';

/// Wraps a screen body with the desktop navigation rail.
///
/// On expanded windows (>= 1100dp) the body becomes:
///   Row([ NavigationRail, Expanded(content) ])
/// In RTL the Row's first child sits on the right, so the rail appears on the
/// right edge — matching Arabic reading order.
///
/// On compact/medium windows the rail is hidden; the screen keeps its own
/// Scaffold (drawer + bottom navigation bar) for primary navigation.
///
/// The wrapper also mirrors the effective brightness into [AppColors] (so
/// directly-styled text follows the theme) and dismisses the keyboard when the
/// user taps outside a field or scrolls.
class AppPageBody extends StatelessWidget {
  final Widget child;

  const AppPageBody({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final content = GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            FocusManager.instance.primaryFocus?.unfocus();
          }
          return false; // let other listeners see the notification
        },
        child: child,
      ),
    );

    if (Responsive.isDesktop(context)) {
      return Row(
        children: [
          const AppNavigationRail(),
          Expanded(child: content),
        ],
      );
    }
    return content;
  }
}
