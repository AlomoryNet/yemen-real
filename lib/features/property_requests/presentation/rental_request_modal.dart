import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_real_estate_portal/core/theme/app_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/utils/date_time_pickers.dart';
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
      barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.32),
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
  DateTime? _scheduledVisitAt;
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
        scheduledVisitAt: _scheduledVisitAt,
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
              '${context.l10n.req_error_prefix} ${e.toString()}',
              style: AppFonts.cairo(),
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
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
          decoration: BoxDecoration(
            color: AppColors.successFill,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_outline,
            size: 54,
            color: AppColors.successInk,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          context.l10n.req_success,
          style: AppFonts.cairo(
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
            '${context.l10n.req_reference_number} ${req.requestNumber}',
            style: AppFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryInk,
            ),
          ),
        ),
        if (req.scheduledVisitAt != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.event_available_outlined,
                size: 18,
                color: AppColors.infoInk,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '${context.l10n.req_scheduled_visit} ${Formatters.formatDateTime(req.scheduledVisitAt)}',
                  style: AppFonts.cairo(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.warningFill,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.warningInk,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.req_success_note,
                  style: AppFonts.cairo(
                    fontSize: 13,
                    color: AppColors.warningInk,
                    height: 1.45,
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
                child: Text(context.l10n.req_close),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  context.pop();
                  context.push('/my-requests');
                },
                child: Text(context.l10n.req_follow_my_requests),
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
                context.l10n.req_form_title,
                style: AppFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                tooltip: context.l10n.close,
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
            style: AppFonts.cairo(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Full Name
          Text(
            context.l10n.req_full_name_required,
            style: AppFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _nameController,
            validator: (val) =>
                Validators.requiredField(val, context.l10n.req_full_name),
            decoration: InputDecoration(
              hintText: context.l10n.req_full_name_hint,
              prefixIcon: const Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 14),

          // Phone Number
          Text(
            context.l10n.req_phone_required,
            style: AppFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            validator: Validators.phone,
            decoration: InputDecoration(
              hintText: '${context.l10n.req_phone_example_prefix} 770000000',
              prefixIcon: const Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 14),

          // Desired Start Date
          Text(
            context.l10n.req_desired_start_date,
            style: AppFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold),
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
                        : context.l10n.req_pick_date_hint,
                    style: AppFonts.cairo(
                      color: _selectedDate != null
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                      fontSize: 14,
                    ),
                  ),
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Preferred visit time
          Text(
            context.l10n.req_visit_label,
            style: AppFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: () async {
              final picked = await DateTimePickers.futureDateTime(context);
              if (picked != null && mounted) {
                setState(() => _scheduledVisitAt = picked);
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
                  Flexible(
                    child: Text(
                      _scheduledVisitAt != null
                          ? Formatters.formatDateTime(_scheduledVisitAt)
                          : context.l10n.req_pick_visit_hint,
                      style: AppFonts.cairo(
                        color: _scheduledVisitAt != null
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.event_available_outlined,
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
            context.l10n.req_notes_label,
            style: AppFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(hintText: context.l10n.req_notes_hint),
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
                        color: AppColors.textLight,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(context.l10n.req_submit),
            ),
          ),
        ],
      ),
    );
  }
}
