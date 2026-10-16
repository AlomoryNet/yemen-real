import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../models/property.dart';
import '../../../models/rental_request.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/rental_request_provider.dart';

class RentalRequestModal extends ConsumerStatefulWidget {
  final Property property;

  const RentalRequestModal({super.key, required this.property});

  static Future<void> show(BuildContext context, Property property) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RentalRequestModal(property: property),
    );
  }

  @override
  ConsumerState<RentalRequestModal> createState() => _RentalRequestModalState();
}

class _RentalRequestModalState extends ConsumerState<RentalRequestModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  final TextEditingController _notesController = TextEditingController();
  DateTime? _selectedDate;
  bool _isSubmitting = false;
  RentalRequest? _submittedRequest;

  @override
  void initState() {
    super.initState();
    final authUser = ref.read(authProvider).user;
    _nameController = TextEditingController(text: authUser?.fullName ?? '');
    _phoneController = TextEditingController(text: authUser?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authUser = ref.read(authProvider).user;
    if (authUser == null) {
      context.pop();
      context.push('/login');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(rentalRequestRepositoryProvider);
      final req = await repo.submitRentalRequest(
        propertyId: widget.property.id,
        userId: authUser.id,
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        requestedStartDate: _selectedDate,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        propertyTitle: widget.property.title,
        propertyPrice: widget.property.price,
        propertyCurrency: widget.property.currency,
      );

      ref.refresh(userRentalRequestsProvider);

      setState(() {
        _isSubmitting = false;
        _submittedRequest = req;
      });
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ: ${e.toString()}',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: _submittedRequest != null
            ? _buildSuccessView(context, _submittedRequest!)
            : _buildFormView(context),
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context, RentalRequest req) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.successMuted,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_outline,
            size: 54,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'تم استلام طلب الاستئجار بنجاح',
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'رقم الطلب المرجعي: ${req.requestNumber}',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.warningMuted,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppColors.warning,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ملاحظة: هذا الطلب يعد استفساراً ورغبة استئجار مبدئية فقط، ولا يعتبر عقداً رسمياً أو حجزاً نهائياً.',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.pop(),
                child: const Text('إغلاق'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  context.pop();
                  context.push('/my-requests');
                },
                child: const Text('متابعة طلباتي'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormView(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'طلب استئجار عقار',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.pop(),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            widget.property.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Full Name
          Text(
            'الاسم الكامل *',
            style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _nameController,
            validator: (val) => Validators.requiredField(val, 'الاسم الكامل'),
            decoration: const InputDecoration(
              hintText: 'أدخل اسمك الثلاثي أو الرباعي',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 14),

          // Phone Number
          Text(
            'رقم الهاتف للتواصل *',
            style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            validator: Validators.phone,
            decoration: const InputDecoration(
              hintText: 'مثال: 770000000',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 14),

          // Desired Start Date
          Text(
            'تاريخ الاستئجار المطلوب (اختياري)',
            style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 1)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedDate != null
                        ? Formatters.formatDate(_selectedDate)
                        : 'حدد التاريخ المتوقع لبدء الإيجار',
                    style: GoogleFonts.cairo(
                      color: _selectedDate != null
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                      fontSize: 14,
                    ),
                  ),
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Notes
          Text(
            'ملاحظات إضافية أو شروط خاصة',
            style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText:
                  'أذكر أي استفسارات، مدة الإيجار المرغوبة، أو عدد أفراد الأسرة...',
            ),
          ),
          const SizedBox(height: 20),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('إرسال طلب الاستئجار الآن'),
            ),
          ),
        ],
      ),
    );
  }
}
