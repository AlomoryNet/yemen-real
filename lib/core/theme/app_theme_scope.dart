import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/settings_provider.dart';

/// Rebuilds a route subtree when the effective theme brightness changes.
///
/// `AppColors` exposes brightness-aware getters through a mutable static
/// mirror. Those getters cannot notify Flutter to rebuild the widgets that
/// read them, so a theme switch could leave directly-styled elements in the
/// previous palette until the user navigated elsewhere. Keying the route
/// subtree by effective brightness makes every widget on the page re-evaluate
/// its colors while the router keeps the same page/navigation state.
class AppThemeScope extends ConsumerWidget {
  const AppThemeScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(settingsProvider.select((s) => s.themeMode));
    final brightness = mode == ThemeMode.system
        ? MediaQuery.platformBrightnessOf(context)
        : (mode == ThemeMode.dark ? Brightness.dark : Brightness.light);

    return KeyedSubtree(
      key: ValueKey('app-theme-$brightness'),
      child: child,
    );
  }
}
