import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../models/property.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/location_provider.dart';
import '../../../providers/property_provider.dart';
import '../../../services/storage_service.dart';
import '../../../shared/widgets/app_footer.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/app_page_body.dart';
import '../../../shared/widgets/auth_prompt_dialog.dart';
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

  double? _selectedLatitude;
  double? _selectedLongitude;
  late final MapController _mapController;

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
      _selectedLatitude = p.latitude;
      _selectedLongitude = p.longitude;
    }
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
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
    final authUser = ref.read(authProvider).user;
    if (authUser == null || !authUser.isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.addprop_verified_login_required,
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      context.push('/login');
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    if (!_hasOwnershipPledge) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.addprop_ownership_pledge_required,
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
            Icon(Icons.rate_review_outlined, color: AppColors.primaryInk),
            const SizedBox(width: 8),
            Text(
              context.l10n.addprop_self_review_title,
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
                  context.l10n.addprop_review_intro,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                _buildReviewItem(context.l10n.addprop_review_title_label, _titleController.text.trim()),
                _buildReviewItem(
                  context.l10n.addprop_review_deal_type_label,
                  AppConstants.getDealTypeNameAr(_dealType),
                ),
                _buildReviewItem(
                  context.l10n.addprop_review_price_label,
                  Formatters.formatCurrency(
                    double.tryParse(_priceController.text) ?? 0,
                    _currency,
                  ),
                ),
                _buildReviewItem(
                  context.l10n.addprop_review_area_label,
                  '${_areaController.text.trim()} ${context.l10n.addprop_sqm_unit}',
                ),
                _buildReviewItem(
                  context.l10n.addprop_review_location_label,
                  '${_cityController.text.trim()} - ${_districtController.text.trim()}',
                ),
                _buildReviewItem(context.l10n.addprop_review_phone_label, _phoneController.text.trim()),
                _buildReviewItem(
                  context.l10n.addprop_review_status_label,
                  isDraft
                      ? context.l10n.addprop_status_private_draft
                      : (ref.read(authProvider).isAdmin
                            ? context.l10n.addprop_status_instant_publish
                            : context.l10n.addprop_status_pending_review),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryMuted,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ref.read(authProvider).isAdmin
                        ? context.l10n.addprop_admin_publish_note
                        : context.l10n.addprop_review_policy_note,
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
            child: Text(context.l10n.addprop_edit_data),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              final isAdmin = ref.read(authProvider).isAdmin;
              _saveProperty(
                status: isDraft
                    ? AppConstants.statusDraft
                    : (isAdmin
                          ? AppConstants.statusPublished
                          : AppConstants.statusPending),
              );
            },
            child: Text(
              isDraft
                  ? context.l10n.addprop_save_draft
                  : (ref.read(authProvider).isAdmin
                        ? context.l10n.addprop_confirm_publish
                        : context.l10n.addprop_submit_request),
            ),
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
    if (authUser == null || !authUser.isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.addprop_confirm_email_required,
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: AppColors.error,
        ),
      );
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
        final defaultCoords = AppConstants.getCoordinatesForGovernorate(
          _cityController.text.trim(),
        );
        final finalLat = _selectedLatitude ?? defaultCoords.$1;
        final finalLng = _selectedLongitude ?? defaultCoords.$2;

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
          latitude: finalLat,
          longitude: finalLng,
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
        final defaultCoords = AppConstants.getCoordinatesForGovernorate(
          _cityController.text.trim(),
        );
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
          latitude: _selectedLatitude ??
              widget.propertyToEdit!.latitude ??
              defaultCoords.$1,
          longitude: _selectedLongitude ??
              widget.propertyToEdit!.longitude ??
              defaultCoords.$2,
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
                  ? context.l10n.addprop_published_success
                  : (status == AppConstants.statusPending
                        ? context.l10n.addprop_request_sent_success
                        : context.l10n.addprop_draft_saved_success),
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
              '${context.l10n.addprop_save_error}: ${e.toString()}',
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
        appBar: AppHeader(title: context.l10n.title_add_property, showBack: true),
        drawer: Responsive.isDesktop(context)
            ? null
            : const AppDrawer(),
        body: AppPageBody(
          child: Center(
            child: EmptyStateView(
            icon: Icons.add_business_outlined,
            title: context.l10n.addprop_login_required_title,
            description:
                context.l10n.addprop_login_required_desc,
            actionText: context.l10n.addprop_login_required_action,
            onAction: () => AuthPromptDialog.show(
              context,
              message:
                  context.l10n.addprop_login_required_desc,
              redirectTo: '/add-property',
            ),
          ),
          ),
        ),
      );
    }

    final typesAsync = ref.watch(propertyTypesProvider);

    return Scaffold(
      appBar: AppHeader(title: context.l10n.title_add_property, showBack: true),
      drawer: Responsive.isDesktop(context)
          ? null
          : const AppDrawer(),
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Page Title
                        Text(
                          widget.propertyToEdit == null
                              ? context.l10n.addprop_new_title
                              : context.l10n.addprop_edit_title,
                          style: GoogleFonts.cairo(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.l10n.addprop_intro,
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Section 1: Basic Ad Info
                        _buildSectionCard(
                          title: context.l10n.addprop_section_basic_info,
                          icon: Icons.info_outline,
                          children: [
                            Text(
                              context.l10n.addprop_title_label,
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
                                context.l10n.addprop_title_field_name,
                              ),
                              decoration: InputDecoration(
                                hintText:
                                    context.l10n.addprop_title_hint,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Deal Type & Property Type Row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        context.l10n.addprop_deal_type_label,
                                        style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      DropdownButtonFormField<String>(
                                        isExpanded: true,
                                        value: _dealType,
                                        items: [
                                          DropdownMenuItem(
                                            value: AppConstants.dealSale,
                                            child: Text(context.l10n.addprop_deal_sale),
                                          ),
                                          DropdownMenuItem(
                                            value: AppConstants.dealRent,
                                            child: Text(context.l10n.addprop_deal_rent),
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
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        context.l10n.addprop_property_type_label,
                                        style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      typesAsync.when(
                                        data: (types) =>
                                            DropdownButtonFormField<String>(
                                              isExpanded: true,
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
                                                if (val != null) {
                                                  setState(
                                                    () => _propertyTypeId = val,
                                                  );
                                                }
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
                          title: context.l10n.addprop_section_price_area,
                          icon: Icons.payments_outlined,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        context.l10n.addprop_price_label,
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
                                              context.l10n.addprop_price_field_name,
                                            ),
                                        decoration: InputDecoration(
                                          hintText: context.l10n.addprop_price_hint,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        context.l10n.addprop_currency_label,
                                        style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      DropdownButtonFormField<String>(
                                        isExpanded: true,
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
                                          if (val != null) {
                                            setState(() => _currency = val);
                                          }
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
                                        context.l10n.addprop_area_label,
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
                                              context.l10n.addprop_area_field_name,
                                            ),
                                        decoration: InputDecoration(
                                          hintText: context.l10n.addprop_area_hint,
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
                                        context.l10n.addprop_bedrooms_label,
                                        style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      TextFormField(
                                        controller: _bedroomsController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          hintText: context.l10n.addprop_na_hint,
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
                                        context.l10n.addprop_bathrooms_label,
                                        style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      TextFormField(
                                        controller: _bathroomsController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          hintText: context.l10n.addprop_na_hint,
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
                          title: context.l10n.addprop_section_location,
                          icon: Icons.location_on_outlined,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        context.l10n.addprop_governorate_label,
                                        style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      DropdownButtonFormField<String>(
                                        isExpanded: true,
                                        value:
                                            AppConstants.yemeniGovernorates
                                                .contains(
                                                  _cityController.text.trim(),
                                                )
                                            ? _cityController.text.trim()
                                            : 'صنعاء',
                                        items: AppConstants.yemeniGovernorates
                                            .map(
                                              (gov) => DropdownMenuItem(
                                                value: gov,
                                                child: Text(gov),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (val) {
                                          if (val != null) {
                                            setState(() {
                                              _cityController.text = val;
                                              final coords =
                                                  AppConstants.getCoordinatesForGovernorate(
                                                    val,
                                                  );
                                              _selectedLatitude = coords.$1;
                                              _selectedLongitude = coords.$2;
                                            });
                                            _mapController.move(
                                              LatLng(
                                                _selectedLatitude!,
                                                _selectedLongitude!,
                                              ),
                                              12.5,
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        context.l10n.addprop_district_label,
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
                                              context.l10n.addprop_district_field_name,
                                            ),
                                        decoration: InputDecoration(
                                          hintText:
                                              context.l10n.addprop_district_hint,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            // Quick district chips for the selected governorate
                            Builder(
                              builder: (context) {
                                final currentGov =
                                    _cityController.text.trim().isNotEmpty
                                    ? _cityController.text.trim()
                                    : 'صنعاء';
                                final districts =
                                    AppConstants.getDistrictsForGovernorate(
                                      currentGov,
                                    );
                                if (districts.isEmpty)
                                  return const SizedBox.shrink();
                                return Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${context.l10n.addprop_common_districts_intro} $currentGov ${context.l10n.addprop_common_districts_quick_pick}',
                                        style: GoogleFonts.cairo(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: districts.take(8).map((d) {
                                          final isChosen =
                                              _districtController.text.trim() ==
                                              d;
                                          return ChoiceChip(
                                            label: Text(
                                              d,
                                              style: GoogleFonts.cairo(
                                                fontSize: 11,
                                                fontWeight: isChosen
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                                color: isChosen
                                                  ? AppColors.primaryDark
                                                  : AppColors.textPrimary,
                                              ),
                                            ),
                                            selected: isChosen,
                                            selectedColor:
                                                AppColors.primaryMuted,
                                            backgroundColor:
                                                AppColors.surfaceVariant,
                                            onSelected: (_) {
                                              setState(() {
                                                _districtController.text = d;
                                              });
                                            },
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 14),
                            Text(
                              context.l10n.addprop_address_details_label,
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _addressController,
                              decoration: InputDecoration(
                                hintText:
                                    context.l10n.addprop_address_hint,
                              ),
                            ),
                            const SizedBox(height: 18),
                            // Interactive Location Map Picker
                            Row(
                              children: [
                                const Icon(
                                  Icons.pin_drop_rounded,
                                  color: Color(0xFF0F766E),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  context.l10n.addprop_map_picker_label,
                                  style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 220,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.divider),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Stack(
                                children: [
                                  FlutterMap(
                                    mapController: _mapController,
                                    options: MapOptions(
                                      initialCenter: LatLng(
                                        _selectedLatitude ??
                                            AppConstants.getCoordinatesForGovernorate(
                                              _cityController.text.trim(),
                                            ).$1,
                                        _selectedLongitude ??
                                            AppConstants.getCoordinatesForGovernorate(
                                              _cityController.text.trim(),
                                            ).$2,
                                      ),
                                      initialZoom: 12.5,
                                      onTap: (tapPosition, point) {
                                        setState(() {
                                          _selectedLatitude = point.latitude;
                                          _selectedLongitude = point.longitude;
                                        });
                                      },
                                    ),
                                    children: [
                                      TileLayer(
                                        urlTemplate:
                                            'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
                                        userAgentPackageName:
                                            'com.yemenreal.portal',
                                        maxZoom: 19,
                                        errorTileCallback: (tile, error,
                                            stackTrace) {
                                          debugPrint(
                                            'Location map tile failed to load: $error',
                                          );
                                        },
                                      ),
                                      if (_selectedLatitude != null &&
                                          _selectedLongitude != null)
                                        MarkerLayer(
                                          markers: [
                                            Marker(
                                              point: LatLng(
                                                _selectedLatitude!,
                                                _selectedLongitude!,
                                              ),
                                              width: 44,
                                              height: 44,
                                              child: const Icon(
                                                Icons.location_on,
                                                color: Colors.red,
                                                size: 44,
                                              ),
                                            ),
                                          ],
                                        ),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 56),
                                        child: RichAttributionWidget(
                                          alignment:
                                              AttributionAlignment.bottomRight,
                                          attributions: [
                                            TextSourceAttribution(
                                              'Tiles © Esri — Sources: Esri, HERE, Garmin, USGS, OpenStreetMap contributors, GIS User Community',
                                              onTap: () {
                                                final uri = Uri.parse(
                                                  'https://goto.arcgisonline.com/maps/World_Street_Map',
                                                );
                                                canLaunchUrl(uri).then((ok) {
                                                  if (ok) {
                                                    launchUrl(
                                                      uri,
                                                      mode: LaunchMode
                                                          .externalApplication,
                                                    );
                                                  }
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    left: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withAlpha(235),
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withAlpha(30),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.touch_app,
                                            size: 16,
                                            color: Color(0xFF0F766E),
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              _selectedLatitude != null
                                                  ? '${context.l10n.addprop_location_pinned} ${_selectedLatitude!.toStringAsFixed(4)}, ${_selectedLongitude!.toStringAsFixed(4)}'
                                                  : context.l10n.addprop_map_tap_hint,
                                              style: GoogleFonts.cairo(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF0F766E),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Section 4: Description & Photos
                        _buildSectionCard(
                          title: context.l10n.addprop_section_description_photos,
                          icon: Icons.photo_library_outlined,
                          children: [
                            Text(
                              context.l10n.addprop_description_label,
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
                                  Validators.requiredField(val, context.l10n.addprop_description_field_name),
                              decoration: InputDecoration(
                                hintText:
                                    context.l10n.addprop_description_hint,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Photos picker
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  context.l10n.addprop_photos_label,
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
                                  label: Text(context.l10n.addprop_add_photos),
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
                                    context.l10n.addprop_no_images_hint,
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
                          title: context.l10n.addprop_section_contact_pledge,
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
                                        context.l10n.addprop_phone_label,
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
                                        decoration: InputDecoration(
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
                                        context.l10n.addprop_whatsapp_label,
                                        style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      TextFormField(
                                        controller: _whatsappController,
                                        keyboardType: TextInputType.phone,
                                        decoration: InputDecoration(
                                          hintText: context.l10n.addprop_whatsapp_hint,
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
                                context.l10n.addprop_pledge_text,
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

                        const SizedBox(height: 24),

                        // Section: Contract Customization & Print
                        _buildSectionCard(
                          title: context.l10n.addprop_section_contract,
                          icon: Icons.description_outlined,
                          children: [
                            Text(
                              context.l10n.addprop_contract_intro,
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                side: BorderSide(
                                  color: AppColors.primaryInk,
                                ),
                              ),
                              icon: Icon(
                                Icons.edit_note,
                                color: AppColors.primaryInk,
                              ),
                              label: Text(
                                context.l10n.addprop_customize_contract,
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryInk,
                                ),
                              ),
                              onPressed: () {
                                final tempProp = Property(
                                  id:
                                      widget.propertyToEdit?.id ??
                                      'temp-${DateTime.now().millisecondsSinceEpoch}',
                                  ownerId:
                                      ref.read(authProvider).user?.id ??
                                      'owner',
                                  title: _titleController.text.trim().isNotEmpty
                                      ? _titleController.text.trim()
                                      : context.l10n.misc_listed_property,
                                  description: _descriptionController.text
                                      .trim(),
                                  dealType: _dealType,
                                  propertyTypeId: _propertyTypeId,
                                  city: _cityController.text.trim().isNotEmpty
                                      ? _cityController.text.trim()
                                      : 'صنعاء',
                                  district: _districtController.text.trim(),
                                  addressDetails: _addressController.text
                                      .trim(),
                                  price:
                                      double.tryParse(_priceController.text) ??
                                      0,
                                  currency: _currency,
                                  areaSqm:
                                      double.tryParse(_areaController.text) ??
                                      100,
                                  contactPhone: _phoneController.text.trim(),
                                  contactWhatsapp: _whatsappController.text
                                      .trim(),
                                  createdAt: DateTime.now(),
                                );
                                context.push('/contract', extra: tempProp);
                              },
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
                                child: Text(context.l10n.addprop_save_draft),
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
                                  context.l10n.addprop_preview_publish,
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
        side: BorderSide(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primaryInk),
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
          : Center(child: Icon(Icons.image, color: AppColors.primaryInk)),
    );
  }
}
