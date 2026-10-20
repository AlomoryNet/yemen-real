import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../shared/widgets/app_footer.dart';
import '../../../shared/widgets/app_header.dart';
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
            success ? 'تم تحديث البيانات بنجاح' : 'تعذر تحديث البيانات',
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
        bottomNavigationBar: const AppBottomNavBar(currentRoute: '/profile'),
        body: Center(
          child: EmptyStateView(
            icon: Icons.person_off_outlined,
            title: 'تسجيل الدخول مطلوب',
            description:
                'لإكمال هذه العملية، يرجى إنشاء حساب وتأكيد بريدك الإلكتروني أولاً.',
            actionText: 'إنشاء حساب أو تسجيل الدخول',
            onAction: () => AuthPromptDialog.show(
              context,
              message:
                  'لإكمال هذه العملية، يرجى إنشاء حساب وتأكيد بريدك الإلكتروني أولاً.',
              redirectTo: '/profile',
            ),
          ),
        ),
      );
    }

    final user = authState.user!;

    return Scaffold(
      appBar: const AppHeader(),
      bottomNavigationBar: const AppBottomNavBar(currentRoute: '/profile'),
      body: SingleChildScrollView(
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
                          side: const BorderSide(color: AppColors.divider),
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
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          user.fullName,
                                          style: GoogleFonts.cairo(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        if (user.isAdmin) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
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
                                                  ? 'مدير عام'
                                                  : 'مدير',
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
                                      user.phone ?? 'لم يتم تعيين رقم هاتف',
                                      style: GoogleFonts.cairo(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'عضو منذ: ${Formatters.formatDate(user.createdAt)}',
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
                            side: const BorderSide(color: AppColors.divider),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'تعديل بيانات الحساب',
                                    style: GoogleFonts.cairo(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    'الاسم الكامل *',
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
                                          'الاسم الكامل',
                                        ),
                                    decoration: const InputDecoration(
                                      hintText: 'أدخل اسمك الكامل',
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    'رقم الهاتف للتواصل *',
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
                                            : const Text('حفظ التعديلات'),
                                      ),
                                      const SizedBox(width: 10),
                                      OutlinedButton(
                                        onPressed: () =>
                                            setState(() => _isEditing = false),
                                        child: const Text('إلغاء'),
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
                        'إدارة نشاطاتي العقارية',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildShortcutTile(
                        icon: Icons.apartment,
                        title: 'عقاراتي المعلنة',
                        subtitle:
                            'استعراض الإعلانات المنشورة والمسودات وتعديلها أو إخفائها',
                        onTap: () => context.push('/my-properties'),
                      ),
                      const SizedBox(height: 10),
                      _buildShortcutTile(
                        icon: Icons.assignment_outlined,
                        title: 'طلبات الاستئجار المقدمة',
                        subtitle:
                            'متابعة حالة وتفاصيل طلبات الاستئجار المرسلة للملاك',
                        onTap: () => context.push('/my-requests'),
                      ),
                      const SizedBox(height: 10),
                      _buildShortcutTile(
                        icon: Icons.favorite_border,
                        title: 'قائمة العقارات المفضلة',
                        subtitle:
                            'الوصول السريع إلى العقارات التي حفظتها سابقاً',
                        onTap: () => context.push('/favorites'),
                      ),

                      if (user.isAdmin) ...[
                        const SizedBox(height: 10),
                        _buildShortcutTile(
                          icon: Icons.admin_panel_settings_outlined,
                          title: 'لوحة الإدارة والتحكم',
                          subtitle:
                              'إدارة العقارات، المستخدمين، العمولات، والبلاغات',
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
                        label: const Text('تسجيل الخروج من الحساب'),
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
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}
