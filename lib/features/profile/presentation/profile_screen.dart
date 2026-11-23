import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/responsive.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../shared/widgets/app_footer.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/app_page_body.dart';
import '../../../shared/widgets/auth_prompt_dialog.dart';
import '../../../shared/widgets/empty_state_view.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final success = await ref
        .read(authProvider.notifier)
        .updateProfile(
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
        );

    setState(() {
      _isSaving = false;
      if (success) _isEditing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? context.l10n.prof_update_success
                : context.l10n.prof_update_failure,
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    if (!authState.isAuthenticated) {
      return Scaffold(
        appBar: const AppHeader(),
        drawer: Responsive.isDesktop(context) ? null : const AppDrawer(),
        bottomNavigationBar: Responsive.isDesktop(context)
            ? null
            : const AppBottomNavBar(currentRoute: '/profile'),
        body: AppPageBody(
          child: Center(
            child: EmptyStateView(
              icon: Icons.person_off_outlined,
              title: context.l10n.prof_login_required,
              description: context.l10n.prof_signup_prompt,
              actionText: context.l10n.prof_signup_or_login,
              onAction: () => AuthPromptDialog.show(
                context,
                message: context.l10n.prof_signup_prompt,
                redirectTo: '/profile',
              ),
            ),
          ),
        ),
      );
    }

    final user = authState.user!;

    return Scaffold(
      appBar: const AppHeader(),
      drawer: Responsive.isDesktop(context) ? null : const AppDrawer(),
      bottomNavigationBar: Responsive.isDesktop(context)
          ? null
          : const AppBottomNavBar(currentRoute: '/profile'),
      body: AppPageBody(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 30,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header card
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: BorderSide(color: AppColors.divider),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 36,
                                  backgroundColor: AppColors.primaryMuted,
                                  child: Text(
                                    user.fullName.isNotEmpty
                                        ? user.fullName[0]
                                        : 'U',
                                    style: GoogleFonts.cairo(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryInk,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              user.fullName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.cairo(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                          ),
                                          if (user.isAdmin) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColors.accent,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                user.role ==
                                                        AppConstants
                                                            .roleSuperAdmin
                                                    ? context
                                                          .l10n
                                                          .prof_super_admin
                                                    : context.l10n.prof_admin,
                                                style: GoogleFonts.cairo(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        user.phone ??
                                            context.l10n.prof_no_phone,
                                        style: GoogleFonts.cairo(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${context.l10n.prof_member_since} ${Formatters.formatDate(user.createdAt)}',
                                        style: GoogleFonts.cairo(
                                          fontSize: 11,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    _isEditing
                                        ? Icons.close
                                        : Icons.edit_outlined,
                                  ),
                                  onPressed: () =>
                                      setState(() => _isEditing = !_isEditing),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Edit Profile Form
                        if (_isEditing) ...[
                          const SizedBox(height: 20),
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: AppColors.divider),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.l10n.prof_edit_account,
                                      style: GoogleFonts.cairo(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      context.l10n.prof_full_name_required,
                                      style: GoogleFonts.cairo(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _nameController,
                                      validator: (val) =>
                                          Validators.requiredField(
                                            val,
                                            context.l10n.prof_full_name,
                                          ),
                                      decoration: InputDecoration(
                                        hintText:
                                            context.l10n.prof_full_name_hint,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      context.l10n.prof_phone_required,
                                      style: GoogleFonts.cairo(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _phoneController,
                                      validator: Validators.phone,
                                      decoration: const InputDecoration(
                                        hintText: '770000000',
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        ElevatedButton(
                                          onPressed: _isSaving
                                              ? null
                                              : _saveProfile,
                                          child: _isSaving
                                              ? const SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2,
                                                      ),
                                                )
                                              : Text(
                                                  context
                                                      .l10n
                                                      .prof_save_changes,
                                                ),
                                        ),
                                        const SizedBox(width: 10),
                                        OutlinedButton(
                                          onPressed: () => setState(
                                            () => _isEditing = false,
                                          ),
                                          child: Text(context.l10n.prof_cancel),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Account Shortcuts
                        Text(
                          context.l10n.prof_manage_activities,
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        _buildShortcutTile(
                          icon: Icons.apartment,
                          title: context.l10n.prof_my_listings_title,
                          subtitle: context.l10n.prof_my_listings_subtitle,
                          onTap: () => context.push('/my-properties'),
                        ),
                        const SizedBox(height: 10),
                        _buildShortcutTile(
                          icon: Icons.assignment_outlined,
                          title: context.l10n.prof_my_requests_title,
                          subtitle: context.l10n.prof_my_requests_subtitle,
                          onTap: () => context.push('/my-requests'),
                        ),
                        const SizedBox(height: 10),
                        _buildShortcutTile(
                          icon: Icons.favorite_border,
                          title: context.l10n.prof_favorites_title,
                          subtitle: context.l10n.prof_favorites_subtitle,
                          onTap: () => context.push('/favorites'),
                        ),

                        if (user.isAdmin) ...[
                          const SizedBox(height: 10),
                          _buildShortcutTile(
                            icon: Icons.admin_panel_settings_outlined,
                            title: context.l10n.prof_admin_title,
                            subtitle: context.l10n.prof_admin_subtitle,
                            isAccent: true,
                            onTap: () => context.push('/admin'),
                          ),
                        ],

                        const SizedBox(height: 32),

                        // Sign Out & Security
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 20,
                            ),
                          ),
                          icon: const Icon(Icons.logout, size: 18),
                          label: Text(context.l10n.prof_sign_out),
                          onPressed: () {
                            ref.read(authProvider.notifier).signOut();
                            context.go('/');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const AppFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShortcutTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isAccent = false,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isAccent ? AppColors.accent.withAlpha(120) : AppColors.divider,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isAccent
                ? AppColors.accentLight.withAlpha(120)
                : AppColors.primaryMuted,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isAccent ? AppColors.accentDark : AppColors.primary,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isAccent ? AppColors.accentDark : AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.cairo(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}
