import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../models/property.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/location_provider.dart';
import '../../../providers/property_provider.dart';
import '../../../services/storage_service.dart';
import '../../../shared/widgets/app_footer.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/empty_state_view.dart';

class AddEditPropertyScreen extends ConsumerStatefulWidget {
  final Property? propertyToEdit;

  const AddEditPropertyScreen({super.key, this.propertyToEdit});

  @override
  ConsumerState<AddEditPropertyScreen> createState() =>
      _AddEditPropertyScreenState();
}

class _AddEditPropertyScreenState extends ConsumerState<AddEditPropertyScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _areaController;
  late final TextEditingController _cityController;
  late final TextEditingController _districtController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  late final TextEditingController _whatsappController;
  late final TextEditingController _bedroomsController;
  late final TextEditingController _bathroomsController;

  String _dealType = AppConstants.dealSale;
  String _propertyTypeId = 'apartment';
  String _currency = AppConstants.currencyYer;
  bool _hasOwnershipPledge = true;

  final List<String> _imageUrls = [];
  final List<XFile> _pendingImages = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.propertyToEdit;
    final authUser = ref.read(authProvider).user;

    _titleController = TextEditingController(text: p?.title ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _priceController = TextEditingController(
      text: p != null ? p.price.toStringAsFixed(0) : '',
    );
    _areaController = TextEditingController(
      text: p != null ? p.areaSqm.toStringAsFixed(0) : '',
    );
    _cityController = TextEditingController(text: p?.city ?? 'صنعاء');
    _districtController = TextEditingController(text: p?.district ?? '');
    _addressController = TextEditingController(text: p?.addressDetails ?? '');
    _phoneController = TextEditingController(
      text: p?.contactPhone ?? authUser?.phone ?? '',
    );
    _whatsappController = TextEditingController(
      text: p?.contactWhatsapp ?? authUser?.phone ?? '',
    );
    _bedroomsController = TextEditingController(
      text: p != null && p.bedrooms > 0 ? p.bedrooms.toString() : '',
    );
    _bathroomsController = TextEditingController(
      text: p != null && p.bathrooms > 0 ? p.bathrooms.toString() : '',
    );

    if (p != null) {
      _dealType = p.dealType;
      _propertyTypeId = p.propertyTypeId;
      _currency = p.currency;
      _hasOwnershipPledge = p.hasOwnershipPledge;
      _imageUrls.addAll(p.images.map((img) => img.imageUrl));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _areaController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final storage = StorageService();
    final picked = await storage.pickMultiImages();
    if (picked.isNotEmpty) {
      setState(() {
        _pendingImages.addAll(picked);
      });
    }
  }

  void _showSelfReviewModal({required bool isDraft}) {
    if (!_formKey.currentState!.validate()) return;
    if (!_hasOwnershipPledge) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يجب الموافقة على إقرار ملكية الحق في نشر الإعلان للمتابعة',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.rate_review_outlined, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'المراجعة الذاتية للإعلان',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'يرجى مراجعة بيانات إعلانك بدقة قبل النشر الفعلي:',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                _buildReviewItem('العنوان', _titleController.text.trim()),
                _buildReviewItem(
                  'نوع العملية',
                  AppConstants.getDealTypeNameAr(_dealType),
                ),
                _buildReviewItem(
                  'السعر',
                  Formatters.formatCurrency(
                    double.tryParse(_priceController.text) ?? 0,
                    _currency,
                  ),
                ),
                _buildReviewItem(
                  'المساحة',
                  '${_areaController.text.trim()} م²',
                ),
                _buildReviewItem(
                  'الموقع',
                  '${_cityController.text.trim()} - ${_districtController.text.trim()}',
                ),
                _buildReviewItem('هاتف المعلن', _phoneController.text.trim()),
                _buildReviewItem(
                  'حالة النشر',
                  isDraft ? 'مسودة خاصة' : 'نشر فوري للعامة',
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryMuted,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'وفق آلية "المراجعة الذاتية" (self_review)، سيظهر إعلانك مباشرة في نتائج البحث مع مراقبة ومراجعة الإدارة للتقارير والبلاغات.',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('تعديل البيانات'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              _saveProperty(
                status: isDraft
                    ? AppConstants.statusDraft
                    : AppConstants.statusPublished,
              );
            },
            child: Text(isDraft ? 'حفظ كمسودة' : 'تأكيد ونشر الإعلان'),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProperty({required String status}) async {
    final authUser = ref.read(authProvider).user;
    if (authUser == null) {
      context.push('/login');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final storage = StorageService();
      final uploadedUrls = List<String>.from(_imageUrls);

      // Upload newly picked images
      for (final image in _pendingImages) {
        final url = await storage.uploadPropertyImage(
          file: image,
          userId: authUser.id,
          propertyId: widget.propertyToEdit?.id ?? 'temp',
        );
        uploadedUrls.add(url);
      }

      // If no images at all, add default high quality property photo
      if (uploadedUrls.isEmpty) {
        uploadedUrls.add(
          'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1200&q=80',
        );
      }

      final repo = ref.read(propertyRepositoryProvider);

      if (widget.propertyToEdit == null) {
        // Create new
        final newProp = Property(
          id: '',
          ownerId: authUser.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          dealType: _dealType,
          propertyTypeId: _propertyTypeId,
          city: _cityController.text.trim(),
          district: _districtController.text.trim(),
          addressDetails: _addressController.text.trim().isNotEmpty
              ? _addressController.text.trim()
              : null,
          price: double.parse(_priceController.text.trim()),
          currency: _currency,
          areaSqm: double.parse(_areaController.text.trim()),
          bedrooms: int.tryParse(_bedroomsController.text.trim()) ?? 0,
          bathrooms: int.tryParse(_bathroomsController.text.trim()) ?? 0,
          contactPhone: _phoneController.text.trim(),
          contactWhatsapp: _whatsappController.text.trim().isNotEmpty
              ? _whatsappController.text.trim()
              : null,
          status: status,
          publishingMode: 'self_review',
          hasOwnershipPledge: _hasOwnershipPledge,
          createdAt: DateTime.now(),
        );

        await repo.createProperty(property: newProp, imageUrls: uploadedUrls);
      } else {
        // Update existing
        final updated = widget.propertyToEdit!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          dealType: _dealType,
          propertyTypeId: _propertyTypeId,
          city: _cityController.text.trim(),
          district: _districtController.text.trim(),
          addressDetails: _addressController.text.trim().isNotEmpty
              ? _addressController.text.trim()
              : null,
          price: double.parse(_priceController.text.trim()),
          currency: _currency,
          areaSqm: double.parse(_areaController.text.trim()),
          bedrooms: int.tryParse(_bedroomsController.text.trim()) ?? 0,
          bathrooms: int.tryParse(_bathroomsController.text.trim()) ?? 0,
          contactPhone: _phoneController.text.trim(),
          contactWhatsapp: _whatsappController.text.trim().isNotEmpty
              ? _whatsappController.text.trim()
              : null,
          status: status,
        );

        await repo.updateProperty(updated);
      }

      ref.refresh(searchPropertiesProvider);
      ref.refresh(featuredPropertiesProvider);
      ref.refresh(propertiesForSaleProvider);
      ref.refresh(propertiesForRentProvider);

      setState(() => _isSaving = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == AppConstants.statusPublished
                  ? 'تم نشر الإعلان بنجاح في بوابة اليمن العقارية'
                  : 'تم حفظ مسودة الإعلان بنجاح',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/my-properties');
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء حفظ الإعلان: ${e.toString()}',
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
    final authState = ref.watch(authProvider);

    if (!authState.isAuthenticated) {
      return Scaffold(
        appBar: const AppHeader(),
        body: Center(
          child: EmptyStateView(
            icon: Icons.add_business_outlined,
            title: 'يرجى تسجيل الدخول أولاً',
            description:
                'يجب أن يكون لديك حساب مسجل في بوابة اليمن العقارية لإضافة إعلان عقاري جديد.',
            actionText: 'تسجيل الدخول',
            onAction: () => context.push('/login'),
          ),
        ),
      );
    }

    final typesAsync = ref.watch(propertyTypesProvider);

    return Scaffold(
      appBar: const AppHeader(),
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Page Title
                        Text(
                          widget.propertyToEdit == null
                              ? 'إضافة إعلان عقاري جديد'
                              : 'تعديل بيانات العقار',
                          style: GoogleFonts.cairo(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'أدخل بيانات العقار بدقة لضمان وصوله إلى المهتمين بأعلى كفاءة.',
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Section 1: Basic Ad Info
                        _buildSectionCard(
                          title: 'معلومات الإعلان والعملية',
                          icon: Icons.info_outline,
                          children: [
                            Text(
                              'عنوان الإعلان *',
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _titleController,
                              validator: (val) => Validators.requiredField(
                                val,
                                'عنوان الإعلان',
                              ),
                              decoration: const InputDecoration(
                                hintText:
                                    'مثال: شقة للبيع في حدة بتشطيب ديلوكس وموقع استراتيجي',
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Deal Type & Property Type Row
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'نوع العملية *',
                                        style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      DropdownButtonFormField<String>(
                                        value: _dealType,
                                        items: const [
                                          DropdownMenuItem(
                                            value: AppConstants.dealSale,
                                            child: Text('للبيع'),
                                          ),
                                          DropdownMenuItem(
                                            value: AppConstants.dealRent,
                                            child: Text('للإيجار'),
                                          ),
                                        ],
                                        onChanged: (val) {
                                          if (val != null) {
                                            setState(() => _dealType = val);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'نوع العقار *',
                                        style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      typesAsync.when(
                                        data: (types) =>
                                            DropdownButtonFormField<String>(
                                              value: _propertyTypeId,
                                              items: types
                                                  .map(
                                                    (t) => DropdownMenuItem(
                                                      value: t.id,
                                                      child: Text(t.nameAr),
                                                    ),
                                                  )
                                                  .toList(),
                                              onChanged: (val) {
                                                if (val != null)
                                                  setState(
                                                    () => _propertyTypeId = val,
                                                  );
                                              },
                                            ),
                                        loading: () =>
                                            const LinearProgressIndicator(),
                                        error: (_, __) =>
                                            const SizedBox.shrink(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Section 2: Pricing & Area
                        _buildSectionCard(
                          title: 'السعر والمساحة',
                          icon: Icons.payments_outlined,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'السعر المطلوب *',
                                        style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      TextFormField(
                                        controller: _priceController,
                                        keyboardType: TextInputType.number,
                                        validator: (val) =>
                                            Validators.positiveNumber(
                                              val,
                                              'السعر المطلوب',
                                            ),
                                        decoration: const InputDecoration(
                                          hintText: 'مثال: 50000000',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'العملة *',
                                        style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      DropdownButtonFormField<String>(
                                        value: _currency,
                                        items: AppConstants.supportedCurrencies
                                            .map(
                                              (c) => DropdownMenuItem(
                                                value: c,
                                                child: Text(
                                                  AppConstants.getCurrencyNameAr(
                                                    c,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (val) {
                                          if (val != null)
                                            setState(() => _currency = val);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'المساحة الإجمالية (م²) *',
                                        style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      TextFormField(
                                        controller: _areaController,
                                        keyboardType: TextInputType.number,
                                        validator: (val) =>
                                            Validators.positiveNumber(
                                              val,
                                              'المساحة',
                                            ),
                                        decoration: const InputDecoration(
                                          hintText: 'مثال: 180',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'عدد الغرف',
                                        style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      TextFormField(
                                        controller: _bedroomsController,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          hintText: '0 إذا لم ينطبق',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'دورات المياه',
                                        style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      TextFormField(
                                        controller: _bathroomsController,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          hintText: '0 إذا لم ينطبق',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Section 3: Location
                        _buildSectionCard(
                          title: 'الموقع الجغرافي',
                          icon: Icons.location_on_outlined,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'المدينة / المحافظة *',
                                        style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      TextFormField(
                                        controller: _cityController,
                                        validator: (val) =>
                                            Validators.requiredField(
                                              val,
                                              'المدينة',
                                            ),
                                        decoration: const InputDecoration(
                                          hintText: 'مثال: صنعاء',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'المنطقة أو الحي *',
                                        style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      TextFormField(
                                        controller: _districtController,
                                        validator: (val) =>
                                            Validators.requiredField(
                                              val,
                                              'الحي أو المنطقة',
                                            ),
                                        decoration: const InputDecoration(
                                          hintText: 'مثال: حدة، بيت بوس',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'تفاصيل العنوان والمعالم القريبة',
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _addressController,
                              decoration: const InputDecoration(
                                hintText:
                                    'مثال: بالقرب من جولة الرويشان - شارع 14',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Section 4: Description & Photos
                        _buildSectionCard(
                          title: 'الوصف والصور',
                          icon: Icons.photo_library_outlined,
                          children: [
                            Text(
                              'الوصف الكامل للعقار *',
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 4,
                              validator: (val) =>
                                  Validators.requiredField(val, 'الوصف'),
                              decoration: const InputDecoration(
                                hintText:
                                    'اذكر تفاصيل ومميزات العقار، التشطيبات، المداخل، والخدمات المتوفرة...',
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Photos picker
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'صور العقار (بحد أقصى 5 ميجابايت لكل صورة)',
                                  style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: _pickImages,
                                  icon: const Icon(
                                    Icons.add_photo_alternate_outlined,
                                  ),
                                  label: const Text('إضافة صور'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Preview list
                            if (_imageUrls.isNotEmpty ||
                                _pendingImages.isNotEmpty)
                              SizedBox(
                                height: 90,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    ..._imageUrls.map(
                                      (url) => _buildImageThumbnail(
                                        url,
                                        isNetwork: true,
                                      ),
                                    ),
                                    ..._pendingImages.map(
                                      (file) => _buildImageThumbnail(
                                        file.path,
                                        isNetwork: false,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.border,
                                    style: BorderStyle.solid,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    'لم يتم اختيار صور بعد. يمكنك إضافة صور لجذب المزيد من المشترين.',
                                    style: GoogleFonts.cairo(
                                      color: AppColors.textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Section 5: Contact Info & Pledge
                        _buildSectionCard(
                          title: 'بيانات التواصل والإقرار',
                          icon: Icons.phone_callback_outlined,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
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
                                        keyboardType: TextInputType.phone,
                                        validator: Validators.phone,
                                        decoration: const InputDecoration(
                                          hintText: '770000000',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'رقم الواتساب',
                                        style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      TextFormField(
                                        controller: _whatsappController,
                                        keyboardType: TextInputType.phone,
                                        decoration: const InputDecoration(
                                          hintText: 'اختياري للتواصل السريع',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Pledge Checkbox
                            CheckboxListTile(
                              value: _hasOwnershipPledge,
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Text(
                                'أقر وأتعهد بصحة كافة البيانات والمعلومات الواردة في هذا الإعلان، وبامتلاكي الحق النظامي والشرعي في تسويقه أو نشره.',
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              onChanged: (val) => setState(
                                () => _hasOwnershipPledge = val ?? false,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Action Buttons: Save Draft vs Self-Review & Publish
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _isSaving
                                    ? null
                                    : () => _showSelfReviewModal(isDraft: true),
                                child: const Text('حفظ كمسودة'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                onPressed: _isSaving
                                    ? null
                                    : () =>
                                          _showSelfReviewModal(isDraft: false),
                                icon: _isSaving
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.send_outlined),
                                label: Text(
                                  'معاينة الإعلان ونشره',
                                  style: GoogleFonts.cairo(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(String source, {required bool isNetwork}) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: isNetwork
          ? Image.network(source, fit: BoxFit.cover)
          : const Center(child: Icon(Icons.image, color: AppColors.primary)),
    );
  }
}
