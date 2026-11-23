import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/l10n/context_l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';

/// App bar for every screen.
///
/// - On root screens (Home): shows menu icon + centered app name.
/// - On pushed screens: shows back arrow + centered screen title.
/// - Desktop (>=1100dp): menu button hidden (rail used instead).
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title;           // screen-specific title; default = app_name
  final bool showBack;           // show back arrow instead of menu
  final VoidCallback? onBack;     // default: context.pop()

  const AppHeader({
    super.key,
    this.title,
    this.showBack = false,
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final showMenu = !Responsive.isDesktop(context) && !showBack;

    return Material(
      color: AppColors.surface,
      elevation: 0,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                if (showMenu || showBack)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Builder(
                      builder: (scaffoldContext) => IconButton(
                        key: ValueKey(showBack
                            ? 'app_header_back_button'
                            : 'app_header_menu_button'),
                        icon: Icon(
                          showBack ? Icons.arrow_back_rounded : Icons.menu_rounded,
                        ),
                        color: AppColors.textPrimary,
                        tooltip: showBack
                            ? 'Back'
                            : MaterialLocalizations.of(scaffoldContext)
                                .openAppDrawerTooltip,
                        onPressed: showBack
                            ? (onBack ?? () {
                                if (scaffoldContext.canPop()) {
                                  context.pop();
                                } else {
                                  context.go('/');
                                }
                              })
                            : () {
                                final scaffold =
                                    Scaffold.maybeOf(scaffoldContext);
                                if (scaffold != null && scaffold.hasDrawer) {
                                  scaffold.openDrawer();
                                }
                              },
                      ),
                    ),
                  ),
                Center(
                  child: Text(
                    title ?? context.l10n.app_name,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}