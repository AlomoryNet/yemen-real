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
/// user taps outside a field or deliberately scrolls the page.
class AppPageBody extends StatelessWidget {
  final Widget child;

  const AppPageBody({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final content = GestureDetector(
      // `translucent` also receives taps that land on a TextField, so opening
      // the keyboard on lower fields (currency rates, register form) instantly
      // unfocused them. Mirrors the global fix in main.dart: only react to taps
      // no interactive child consumed.
      behavior: HitTestBehavior.deferToChild,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: NotificationListener<ScrollStartNotification>(
        onNotification: (notification) {
          // Only a real user drag dismisses the keyboard. Programmatic scroll
          // updates (including the viewport shift when the IME opens) must not
          // steal focus from the field being edited.
          if (notification.dragDetails != null) {
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
