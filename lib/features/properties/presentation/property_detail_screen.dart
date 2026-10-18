import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/property.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/favorites_provider.dart';
import '../../../providers/property_provider.dart';
import '../../../repositories/report_repository.dart';
import '../../../shared/widgets/app_footer.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/external_contact_buttons.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/auth_prompt_dialog.dart';
import '../../property_requests/presentation/rental_request_modal.dart';

class PropertyDetailScreen extends ConsumerStatefulWidget {
  final String propertyId;

  const PropertyDetailScreen({super.key, required this.propertyId});

  @override
  ConsumerState<PropertyDetailScreen> createState() =>
      _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends ConsumerState<PropertyDetailScreen> {
  int _activeImageIndex = 0;

  void _showReportDialog(BuildContext context, Property property) {
    final reasonController = TextEditingController();
    String selectedReason = 'معلومات غير دقيقة أو مضللة';
    final reportReasons = [
      'معلومات غير دقيقة أو مضللة',
      'السعر غير مطابق للواقع',
      'العقار مكرر أو مباع بالفعل',
      'صور غير لائقة أو غير مطابقة',
      'انتحال صفة أو احتيال',
      'سبب آخر',
    ];

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'الإبلاغ عن إعلان مخالف',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ساعدنا في الحفاظ على موثوقية المنصة بإبلاغنا عن أي مخالفة.',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'سبب البلاغ *',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedReason,
                items: reportReasons
                    .map(
                      (r) => DropdownMenuItem(
                        value: r,
                        child: Text(r, style: GoogleFonts.cairo(fontSize: 13)),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedReason = val);
                },
              ),
              const SizedBox(height: 14),
              Text(
                'تفاصيل إضافية (اختياري)',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'وضّح سبب البلاغ بالتفصيل...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () async {
                final authUser = ref.read(authProvider).user;
                final reportRepo = ReportRepository();
                await reportRepo.submitReport(
                  propertyId: property.id,
                  reporterId: authUser?.id,
                  reason: selectedReason,
                  details: reasonController.text.trim(),
                );
                if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'تم استلام بلاغك بنجاح وسيقوم فريق الإدارة بمراجعته.',
                        style: GoogleFonts.cairo(),
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              child: const Text('إرسال البلاغ'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final propertyAsync = ref.watch(propertyDetailProvider(widget.propertyId));

    return Scaffold(
      appBar: const AppHeader(),
      body: propertyAsync.when(
        data: (property) => _buildDetailContent(context, property),
        loading: () =>
            const LoadingView(message: 'جاري تحميل تفاصيل العقار...'),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ErrorView(
                message: err.toString(),
                onRetry: () =>
                    ref.refresh(propertyDetailProvider(widget.propertyId)),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/search'),
                child: const Text('تصفح العقارات المتاحة'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailContent(BuildContext context, Property property) {
    final favoritesNotifier = ref.read(favoritesProvider.notifier);
    final isFav = ref
        .watch(favoritesProvider)
        .maybeWhen(
          data: (list) => list.any((p) => p.id == property.id),
          orElse: () => false,
        );
    final isDesktop = Responsive.isDesktop(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Navigation breadcrumb
                    Row(
                      children: [
                        InkWell(
                          onTap: () => context.go('/'),
                          child: Text(
                            'الرئيسية',
                            style: GoogleFonts.cairo(
                              color: AppColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const Text(
                          ' / ',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                        InkWell(
                          onTap: () => context.go('/search'),
                          child: Text(
                            'العقارات',
                            style: GoogleFonts.cairo(
                              color: AppColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const Text(
                          ' / ',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                        Expanded(
                          child: Text(
                            property.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Main Layout: Split (Desktop) or Vertical (Mobile)
                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildImageGallery(property),
                                const SizedBox(height: 24),
                                _buildPropertyDetails(property),
                              ],
                            ),
                          ),
                          const SizedBox(width: 32),
                          Expanded(
                            flex: 2,
                            child: _buildActionSidebar(
                              context,
                              property,
                              isFav,
                              favoritesNotifier,
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImageGallery(property),
                          const SizedBox(height: 20),
                          _buildActionSidebar(
                            context,
                            property,
                            isFav,
                            favoritesNotifier,
                          ),
                          const SizedBox(height: 24),
                          _buildPropertyDetails(property),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
          const AppFooter(),
        ],
      ),
    );
  }

  Widget _buildImageGallery(Property property) {
    final images = property.images;
    final hasImages = images.isNotEmpty;

    return Column(
      children: [
        // Main Image Display
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: hasImages
                ? CachedNetworkImage(
                    imageUrl: images[_activeImageIndex].imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: AppColors.surfaceVariant),
                    errorWidget: (_, __, ___) => _buildImagePlaceholder(),
                  )
                : _buildImagePlaceholder(),
          ),
        ),

        // Thumbnails Strip
        if (hasImages && images.length > 1) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 70,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final isSelected = index == _activeImageIndex;
                return InkWell(
                  onTap: () => setState(() => _activeImageIndex = index),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: CachedNetworkImage(
                      imageUrl: images[index].imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.surfaceVariant,
      child: const Center(
        child: Icon(Icons.apartment, size: 60, color: AppColors.textMuted),
      ),
    );
  }

  Widget _buildActionSidebar(
    BuildContext context,
    Property property,
    bool isFav,
    FavoritesNotifier favNotifier,
  ) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.divider),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price & Deal badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusBadge.dealType(property.dealType),
                IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? AppColors.error : AppColors.textSecondary,
                  ),
                  onPressed: () {
                    final auth = ref.read(authProvider);
                    if (!auth.isAuthenticated) {
                      AuthPromptDialog.show(
                        context,
                        message:
                            'لإكمال هذه العملية، يرجى إنشاء حساب وتأكيد بريدك الإلكتروني أولاً.',
                        redirectTo: '/property/${property.id}',
                      );
                      return;
                    }
                    favNotifier.toggleFavorite(property.id);
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Price text
            Text(
              Formatters.formatCurrency(property.price, property.currency),
              style: GoogleFonts.cairo(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 16),

            // Publisher Info
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.primaryMuted,
                  child: Icon(Icons.person, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.owner?.fullName ?? 'معلن موثق',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'تاريخ النشر: ${Formatters.formatDate(property.createdAt)}',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // External Contact Buttons (WhatsApp & Phone call)
            ExternalContactButtons(
              contactPhone: property.contactPhone,
              contactWhatsapp: property.contactWhatsapp,
              propertyTitle: property.title,
              propertyId: property.id,
            ),

            // Rental Request Button (if for rent)
            if (property.isForRent) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.assignment_outlined, size: 20),
                  label: Text(
                    'إرسال طلب استئجار',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    final auth = ref.read(authProvider);
                    if (!auth.isAuthenticated) {
                      AuthPromptDialog.show(
                        context,
                        message:
                            'لإكمال هذه العملية، يرجى إنشاء حساب وتأكيد بريدك الإلكتروني أولاً.',
                        redirectTo: '/property/${property.id}',
                      );
                      return;
                    }
                    RentalRequestModal.show(context, property);
                  },
                ),
              ),
            ],

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(
                  Icons.description_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                label: Text(
                  'معاينة وتشكيل العقد والطباعة',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                onPressed: () => context.push('/contract', extra: property),
              ),
            ),

            const SizedBox(height: 16),

            // Secondary Actions (Share & Report)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => _showReportDialog(context, property),
                  icon: const Icon(
                    Icons.flag_outlined,
                    size: 16,
                    color: AppColors.error,
                  ),
                  label: Text(
                    'إبلاغ عن مخالفة',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: AppColors.error,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'تم نسخ رابط العقار للمشاركة',
                          style: GoogleFonts.cairo(),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.share_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  label: Text(
                    'مشاركة الإعلان',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyDetails(Property property) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          property.title,
          style: GoogleFonts.cairo(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),

        // Location text
        Row(
          children: [
            const Icon(Icons.location_on, color: AppColors.primary, size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${property.city} - ${property.district} ${property.addressDetails != null ? '(${property.addressDetails})' : ''}',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Specs Grid
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Wrap(
            spacing: 24,
            runSpacing: 16,
            children: [
              _buildFeatureItem(
                Icons.straighten,
                'المساحة الإجمالية',
                Formatters.formatArea(property.areaSqm),
              ),
              _buildFeatureItem(
                Icons.category_outlined,
                'نوع العقار',
                property.propertyType?.nameAr ?? property.propertyTypeId,
              ),
              if (property.bedrooms > 0)
                _buildFeatureItem(
                  Icons.bed_outlined,
                  'عدد غرف النوم',
                  '${property.bedrooms} غرف',
                ),
              if (property.bathrooms > 0)
                _buildFeatureItem(
                  Icons.bathtub_outlined,
                  'دورات المياه',
                  '${property.bathrooms} حمامات',
                ),
              _buildFeatureItem(
                Icons.visibility_outlined,
                'عدد المشاهدات',
                '${property.viewsCount} زيارة',
              ),
              _buildFeatureItem(
                Icons.shield_outlined,
                'طريقة النشر',
                'مراجعة معلنة ذاتية',
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Full Description
        Text(
          'تفاصيل ووصف العقار',
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          property.description,
          style: GoogleFonts.cairo(
            fontSize: 14,
            height: 1.8,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String label, String value) {
    return SizedBox(
      width: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
