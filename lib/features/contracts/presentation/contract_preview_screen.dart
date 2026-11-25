// Yemen Real Estate Portal — بوابة اليمن العقارية
// Contract Preview & Print Screen — شاشة معاينة وطباعة وتشكيل العقد اليمني

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yemen_real_estate_portal/core/theme/app_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../models/property.dart';
import '../../../models/property_contract.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/contract_service.dart';
import '../../../shared/widgets/auth_prompt_dialog.dart';

class ContractPreviewScreen extends ConsumerStatefulWidget {
  final Property property;
  final PropertyContract? initialContract;

  const ContractPreviewScreen({
    super.key,
    required this.property,
    this.initialContract,
  });

  @override
  ConsumerState<ContractPreviewScreen> createState() =>
      _ContractPreviewScreenState();
}

class _ContractPreviewScreenState extends ConsumerState<ContractPreviewScreen> {
  late PropertyContract _contract;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContract();
  }

  Future<void> _loadContract() async {
    if (widget.initialContract != null) {
      _contract = widget.initialContract!;
      setState(() => _isLoading = false);
      return;
    }

    final loaded = await ContractService.getPropertyContract(widget.property);
    setState(() {
      _contract = loaded;
      _isLoading = false;
    });
  }

  void _openContractEditor() {
    final auth = ref.read(authProvider);
    if (!auth.isAuthenticated) {
      AuthPromptDialog.show(
        context,
        message:
            context.l10n.contract_auth_prompt_message,
        redirectTo: '/property/${widget.property.id}',
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor:
          Theme.of(context).colorScheme.scrim.withValues(alpha: 0.32),
      builder: (ctx) => _ContractEditorSheet(
        contract: _contract,
        property: widget.property,
        onSave: (updated) async {
          setState(() => _contract = updated);
          await ContractService.savePropertyContract(updated);
          if (updated.isSavedAsDefaultTemplate) {
            await ContractService.saveAsDefaultTemplate(updated);
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  context.l10n.contract_clauses_saved,
                  style: AppFonts.cairo(),
                ),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
      ),
    );
  }

  String _generatePlainText() {
    final buffer = StringBuffer();
    buffer.writeln(context.l10n.contract_bismillah);
    buffer.writeln(context.l10n.contract_republic);
    buffer.writeln('==============================');
    buffer.writeln(_contract.title);
    buffer.writeln('==============================');
    buffer.writeln(
      '${context.l10n.contract_edit_date} ${_contract.startDate.isNotEmpty ? _contract.startDate : DateTime.now().toString().split(' ').first}',
    );
    buffer.writeln('');
    buffer.writeln(
      '${context.l10n.contract_first_party} ${_contract.ownerName.isNotEmpty ? _contract.ownerName : widget.property.owner?.fullName ?? context.l10n.misc_owner}',
    );
    buffer.writeln(
      '${context.l10n.contract_phone} ${_contract.ownerPhone.isNotEmpty ? _contract.ownerPhone : widget.property.contactPhone}',
    );
    buffer.writeln('${context.l10n.contract_address} ${_contract.ownerAddress}');
    buffer.writeln('');
    buffer.writeln(
      '${context.l10n.contract_second_party} ${_contract.tenantName.isNotEmpty ? _contract.tenantName : "........................................"}',
    );
    buffer.writeln(
      '${context.l10n.contract_id_card_number} ${_contract.tenantIdCard.isNotEmpty ? _contract.tenantIdCard : "...................."}',
    );
    buffer.writeln('');
    buffer.writeln(context.l10n.contract_leased_property);
    buffer.writeln(
      '${context.l10n.contract_property_in_governorate} ${AppConstants.getGovernorateNameAr(widget.property.city)} ${context.l10n.contract_district_label} ${AppConstants.getDistrictNameAr(widget.property.district)} - ${widget.property.addressDetails ?? ""}',
    );
    buffer.writeln('${context.l10n.contract_specifications} ${widget.property.title}');
    buffer.writeln('');
    buffer.writeln(context.l10n.contract_terms_title);
    buffer.writeln(
      '1. ${context.l10n.contract_clause1_title} ${_contract.durationText} ${context.l10n.contract_starts_from_date} ${_contract.startDate} ${context.l10n.contract_until_date} ${_contract.endDate}، ${_contract.isRenewableOnlyByOwner ? context.l10n.contract_non_renewable_plain : context.l10n.contract_auto_renew_plain}',
    );
    buffer.writeln(
      '2. ${context.l10n.contract_clause2_title} ${context.l10n.contract_amount_of} ${Formatters.formatCurrency(_contract.amount, _contract.currency)} ${context.l10n.contract_paid} ${_contract.paymentFrequency}.',
    );
    if (_contract.securityDeposit > 0) {
      buffer.writeln(
        '3. ${context.l10n.contract_clause3_title} ${Formatters.formatCurrency(_contract.securityDeposit, _contract.currency)} ${context.l10n.contract_deposit_return}',
      );
    }
    buffer.writeln('4. ${context.l10n.contract_clause4_title} ${_contract.utilitiesPayableBy}.');
    buffer.writeln('5. ${context.l10n.contract_clause5_title} ${_contract.maintenanceLiability}.');
    if (_contract.forbidSubleasing) {
      buffer.writeln(
        '6. ${context.l10n.contract_clause6_title} ${context.l10n.contract_sublease_ban_text}',
      );
    }
    buffer.writeln('7. ${context.l10n.contract_clause7_title} ${_contract.latePaymentPolicy}.');

    if (_contract.customClauses.isNotEmpty) {
      buffer.writeln(context.l10n.contract_clause8_title);
      for (int i = 0; i < _contract.customClauses.length; i++) {
        buffer.writeln('   - ${_contract.customClauses[i]}');
      }
    }

    buffer.writeln('');
    buffer.writeln(context.l10n.contract_owner_signature);
    buffer.writeln(context.l10n.contract_tenant_signature);
    buffer.writeln(
      context.l10n.contract_witnesses_line,
    );
    return buffer.toString();
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _generatePlainText()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.l10n.contract_text_copied,
          style: AppFonts.cairo(),
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }

  pw.Widget _buildPdfClause(
    int number,
    String text,
    pw.Font fontRegular,
    pw.Font fontBold,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '$number. ',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 9.5,
              color: PdfColors.black,
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              text,
              style: pw.TextStyle(
                font: fontRegular,
                fontSize: 9,
                color: PdfColors.black,
                lineSpacing: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    // Snapshot the active locale direction before the async font load so the
    // generated document stays internally consistent in English mode too.
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final pdfDirection = isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr;
    final clauseAlignment =
        isRtl ? pw.Alignment.centerRight : pw.Alignment.centerLeft;

    final pdf = pw.Document();
    final fontData = await rootBundle.load('assets/fonts/Cairo.ttf');
    final fontCairo = pw.Font.ttf(fontData);
    final fontCairoBold = fontCairo;

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(28),
        theme: pw.ThemeData.withFont(base: fontCairo, bold: fontCairoBold),
        build: (pw.Context ctx) {
          return pw.Directionality(
            textDirection: pdfDirection,
            child: pw.Container(
              padding: const pw.EdgeInsets.all(18),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey800, width: 1.2),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    context.l10n.contract_bismillah,
                    style: pw.TextStyle(font: fontCairoBold, fontSize: 13),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    context.l10n.contract_republic,
                    style: pw.TextStyle(font: fontCairoBold, fontSize: 12),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    _contract.title.isNotEmpty
                        ? _contract.title
                        : context.l10n.contract_default_title,
                    style: pw.TextStyle(
                      font: fontCairoBold,
                      fontSize: 15,
                      decoration: pw.TextDecoration.underline,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Divider(thickness: 0.8, color: PdfColors.grey500),
                  pw.SizedBox(height: 6),

                  // Parties Row
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              '${context.l10n.contract_first_party_pdf} ${_contract.ownerName.isNotEmpty ? _contract.ownerName : widget.property.owner?.fullName ?? context.l10n.misc_owner}',
                              style: pw.TextStyle(
                                font: fontCairoBold,
                                fontSize: 9.5,
                              ),
                            ),
                            pw.Text(
                              '${context.l10n.contract_id_number} ${_contract.ownerIdCard.isNotEmpty ? _contract.ownerIdCard : "...................."}',
                              style: pw.TextStyle(font: fontCairo, fontSize: 9),
                            ),
                            pw.Text(
                              '${context.l10n.contract_phone} ${_contract.ownerPhone.isNotEmpty ? _contract.ownerPhone : widget.property.contactPhone}',
                              style: pw.TextStyle(font: fontCairo, fontSize: 9),
                            ),
                            pw.Text(
                              '${context.l10n.contract_address} ${_contract.ownerAddress}',
                              style: pw.TextStyle(font: fontCairo, fontSize: 9),
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(width: 12),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              '${context.l10n.contract_second_party} ${_contract.tenantName.isNotEmpty ? _contract.tenantName : "...................................."}',
                              style: pw.TextStyle(
                                font: fontCairoBold,
                                fontSize: 9.5,
                              ),
                            ),
                            pw.Text(
                              '${context.l10n.contract_id_card_number} ${_contract.tenantIdCard.isNotEmpty ? _contract.tenantIdCard : "...................."}',
                              style: pw.TextStyle(font: fontCairo, fontSize: 9),
                            ),
                            pw.Text(
                              '${context.l10n.contract_tenant_phone} ${_contract.tenantPhone.isNotEmpty ? _contract.tenantPhone : "...................."}',
                              style: pw.TextStyle(font: fontCairo, fontSize: 9),
                            ),
                            pw.Text(
                              '${context.l10n.contract_residence} ${_contract.tenantAddress.isNotEmpty ? _contract.tenantAddress : "...................."}',
                              style: pw.TextStyle(font: fontCairo, fontSize: 9),
                            ),
                            pw.Text(
                              '${context.l10n.contract_start_date} ${_contract.startDate}',
                              style: pw.TextStyle(font: fontCairo, fontSize: 9),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 8),

                  // Leased Property Box
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey200,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                      '${context.l10n.contract_leased_property} ${context.l10n.contract_property_in_governorate} ${AppConstants.getGovernorateNameAr(widget.property.city)} ${context.l10n.contract_district_label} ${AppConstants.getDistrictNameAr(widget.property.district)} - ${widget.property.addressDetails ?? ""} (${widget.property.title})',
                      style: pw.TextStyle(font: fontCairoBold, fontSize: 9),
                    ),
                  ),
                  pw.SizedBox(height: 8),

                  // Clauses Title
                  pw.Align(
                    alignment: clauseAlignment,
                    child: pw.Text(
                      context.l10n.contract_pdf_terms_title,
                      style: pw.TextStyle(font: fontCairoBold, fontSize: 10),
                    ),
                  ),
                  pw.SizedBox(height: 5),

                  _buildPdfClause(
                    1,
                    '${context.l10n.contract_clause1_title} ${_contract.durationText} ${context.l10n.contract_starts_from_date} ${_contract.startDate} ${context.l10n.contract_until_date} ${_contract.endDate}، ${_contract.isRenewableOnlyByOwner ? context.l10n.contract_non_renewable_plain : context.l10n.contract_renew_by_mutual_consent}',
                    fontCairo,
                    fontCairoBold,
                  ),
                  _buildPdfClause(
                    2,
                    '${context.l10n.contract_monthly_rent_agreed} ${context.l10n.contract_amount_of} ${Formatters.formatCurrency(_contract.amount, _contract.currency)} ${context.l10n.contract_paid} ${_contract.paymentFrequency} ${context.l10n.contract_pdf_rent_tail}',
                    fontCairo,
                    fontCairoBold,
                  ),
                  _buildPdfClause(
                    3,
                    context.l10n.contract_personal_clause,
                    fontCairo,
                    fontCairoBold,
                  ),
                  _buildPdfClause(
                    4,
                    context.l10n.contract_tenant_acknowledgement,
                    fontCairo,
                    fontCairoBold,
                  ),
                  _buildPdfClause(
                    5,
                    context.l10n.contract_no_transfer_clause,
                    fontCairo,
                    fontCairoBold,
                  ),
                  _buildPdfClause(
                    6,
                    context.l10n.contract_liability_clause,
                    fontCairo,
                    fontCairoBold,
                  ),

                  if (_contract.securityDeposit > 0)
                    _buildPdfClause(
                      7,
                      '${context.l10n.contract_deposit_title} ${context.l10n.contract_paid_amount} ${Formatters.formatCurrency(_contract.securityDeposit, _contract.currency)} ${context.l10n.contract_deposit_tail}',
                      fontCairo,
                      fontCairoBold,
                    ),

                  if (_contract.customClauses.isNotEmpty)
                    ..._contract.customClauses.asMap().entries.map(
                      (entry) => _buildPdfClause(
                        8 + entry.key,
                        entry.value,
                        fontCairo,
                        fontCairoBold,
                      ),
                    ),

                  pw.Spacer(),

                  // Signatures Section
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        children: [
                          pw.Text(
                            context.l10n.contract_owner_signature_short,
                            style: pw.TextStyle(
                              font: fontCairoBold,
                              fontSize: 9,
                            ),
                          ),
                          pw.SizedBox(height: 20),
                          pw.Text(
                            '................................',
                            style: pw.TextStyle(font: fontCairo, fontSize: 9),
                          ),
                        ],
                      ),
                      pw.Column(
                        children: [
                          pw.Text(
                            context.l10n.contract_tenant_signature_short,
                            style: pw.TextStyle(
                              font: fontCairoBold,
                              fontSize: 9,
                            ),
                          ),
                          pw.SizedBox(height: 20),
                          pw.Text(
                            '................................',
                            style: pw.TextStyle(font: fontCairo, fontSize: 9),
                          ),
                        ],
                      ),
                      pw.Column(
                        children: [
                          pw.Text(
                            context.l10n.contract_witness_short,
                            style: pw.TextStyle(
                              font: fontCairoBold,
                              fontSize: 9,
                            ),
                          ),
                          pw.SizedBox(height: 20),
                          pw.Text(
                            '................................',
                            style: pw.TextStyle(font: fontCairo, fontSize: 9),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.Divider(thickness: 0.5, color: PdfColors.grey400),
                  pw.Text(
                    '${context.l10n.admin_pdf_copyright} ${context.l10n.contract_portal_name_suffix}',
                    style: pw.TextStyle(
                      font: fontCairo,
                      fontSize: 7.5,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<void> _saveAsPdf() async {
    final l10n = context.l10n;
    final auth = ref.read(authProvider);
    if (!auth.isAuthenticated) {
      AuthPromptDialog.show(
        context,
        message:
            context.l10n.contract_auth_prompt_message,
        redirectTo: '/property/${widget.property.id}',
      );
      return;
    }

    try {
      final pdfBytes = await _generatePdf(PdfPageFormat.a4);

      Directory? dir;
      try {
        if (Platform.isAndroid) {
          final downloadDir = Directory('/storage/emulated/0/Download');
          if (await downloadDir.exists()) {
            dir = downloadDir;
          } else {
            dir = await getExternalStorageDirectory();
          }
        } else {
          dir = await getApplicationDocumentsDirectory();
        }
      } catch (_) {
        dir = await getApplicationDocumentsDirectory();
      }

      final cleanCity = widget.property.city.replaceAll(' ', '_');
      final filename =
          '${l10n.contract_pdf_filename}_${cleanCity}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${dir!.path}/$filename');
      await file.writeAsBytes(pdfBytes);

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 26,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.contract_pdf_saved_title,
                  style: AppFonts.cairo(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Text(
              '${context.l10n.contract_pdf_saved_body_before}\n${file.path}\n\n${context.l10n.contract_pdf_saved_body_after}',
              style: AppFonts.cairo(height: 1.5, fontSize: 13),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _copyToClipboard();
                },
                child: Text(context.l10n.contract_copy_text),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(context.l10n.contract_ok),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${context.l10n.contract_pdf_save_error}: $e',
              style: AppFonts.cairo(),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _printContract() async {
    await _saveAsPdf();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          context.l10n.contract_app_bar_title,
          style: AppFonts.cairo(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: context.l10n.contract_edit_tooltip,
            icon: const Icon(Icons.tune),
            onPressed: _openContractEditor,
          ),
          IconButton(
            tooltip: context.l10n.contract_save_pdf,
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _saveAsPdf,
          ),
          IconButton(
            tooltip: context.l10n.contract_copy_text,
            icon: const Icon(Icons.copy),
            onPressed: _copyToClipboard,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.tune, size: 18),
                  label: Text(
                    context.l10n.contract_edit_clauses,
                    style: AppFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  onPressed: _openContractEditor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.textLight,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.picture_as_pdf, size: 18),
                  label: Text(
                    context.l10n.contract_save_pdf,
                    style: AppFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  onPressed: _saveAsPdf,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textLight,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.print, size: 18),
                  label: Text(
                    context.l10n.contract_print,
                    style: AppFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  onPressed: _printContract,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Card(
              color: AppColors.surface,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Islamic Header & Country
                    Center(
                      child: Column(
                        children: [
                          Text(
                            context.l10n.contract_bismillah,
                            style: AppFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.l10n.contract_republic,
                            style: AppFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryInk,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(20),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.primary),
                            ),
                            child: Text(
                              _contract.title,
                              style: AppFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryInk,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Divider(color: AppColors.divider, thickness: 1),
                    const SizedBox(height: 14),

                    // Date & Contract ID
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            '${context.l10n.contract_edit_date} ${_contract.startDate.isNotEmpty ? _contract.startDate : DateTime.now().toString().split(" ").first}',
                            style: AppFonts.cairo(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            '${context.l10n.contract_number} ${_contract.id}',
                            textAlign: TextAlign.end,
                            style: AppFonts.cairo(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Banner for interactive writing/editing
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryMuted,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_note,
                            color: AppColors.primaryInk,
                            size: 28,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.l10n.contract_fill_intro_title,
                                  style: AppFonts.cairo(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: AppColors.primaryInk,
                                  ),
                                ),
                                Text(
                                  context.l10n.contract_fill_intro_body,
                                  style: AppFonts.cairo(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.textLight,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            onPressed: _openContractEditor,
                            icon: const Icon(Icons.edit, size: 15),
                            label: Text(
                              context.l10n.contract_fill_fields,
                              style: AppFonts.cairo(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Parties Information Table
                    _buildSectionTitle(context.l10n.contract_section_parties),
                    const SizedBox(height: 8),
                    _buildPartyBox(
                      title: context.l10n.contract_first_party_box,
                      name: _contract.ownerName.isNotEmpty
                          ? _contract.ownerName
                          : (widget.property.owner?.fullName ?? context.l10n.misc_owner),
                      phone: _contract.ownerPhone.isNotEmpty
                          ? _contract.ownerPhone
                          : widget.property.contactPhone,
                      idCard: _contract.ownerIdCard.isNotEmpty
                          ? _contract.ownerIdCard
                          : '................................',
                      address: _contract.ownerAddress,
                      onEdit: _openContractEditor,
                    ),
                    const SizedBox(height: 10),
                    _buildPartyBox(
                      title: context.l10n.contract_second_party,
                      name: _contract.tenantName.isNotEmpty
                          ? _contract.tenantName
                          : '................................................',
                      phone: _contract.tenantPhone.isNotEmpty
                          ? _contract.tenantPhone
                          : '................................',
                      idCard: _contract.tenantIdCard.isNotEmpty
                          ? _contract.tenantIdCard
                          : '................................',
                      address: _contract.tenantAddress.isNotEmpty
                          ? _contract.tenantAddress
                          : '................................',
                      onEdit: _openContractEditor,
                    ),
                    const SizedBox(height: 20),

                    // Property Specs
                    _buildSectionTitle(context.l10n.contract_section_property),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        '${context.l10n.contract_property_in_governorate} ${AppConstants.getGovernorateNameAr(widget.property.city)} ${context.l10n.contract_district_label} ${AppConstants.getDistrictNameAr(widget.property.district)} - ${widget.property.addressDetails ?? ""}.\n${context.l10n.contract_specifications} ${widget.property.title} ${context.l10n.contract_approx_area_prefix} ${widget.property.areaSqm} ${context.l10n.contract_sqm_unit}.',
                        style: AppFonts.cairo(fontSize: 13, height: 1.6),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Contract Clauses
                    _buildSectionTitle(
                      context.l10n.contract_section_clauses,
                    ),
                    const SizedBox(height: 10),

                    _buildClauseItem(
                      number: '1',
                      title: context.l10n.contract_clause1_screen_title,
                      body:
                          '${context.l10n.contract_duration_label} (${_contract.durationText}) ${context.l10n.contract_starts_from_date} ${_contract.startDate} ${context.l10n.contract_ends_on_date} ${_contract.endDate}، ${_contract.isRenewableOnlyByOwner ? context.l10n.contract_non_renewable_screen : context.l10n.contract_renewable_by_consent}',
                    ),

                    _buildClauseItem(
                      number: '2',
                      title: context.l10n.contract_clause2_screen_title,
                      body:
                          '${context.l10n.contract_agreed_monthly_value} (${Formatters.formatCurrency(_contract.amount, _contract.currency)}) ${context.l10n.contract_paid} (${_contract.paymentFrequency}) ${context.l10n.contract_receipt_tail}',
                    ),

                    if (_contract.securityDeposit > 0)
                      _buildClauseItem(
                        number: '3',
                        title: context.l10n.contract_deposit_screen_title,
                        body:
                            '${context.l10n.contract_deposit_preamble} (${Formatters.formatCurrency(_contract.securityDeposit, _contract.currency)}) ${context.l10n.contract_deposit_screen_tail}',
                      ),

                    _buildClauseItem(
                      number: '4',
                      title: context.l10n.contract_utilities_screen_title,
                      body:
                          '${context.l10n.contract_bears_utilities} ${_contract.utilitiesPayableBy} ${context.l10n.contract_utilities_tail}',
                    ),

                    _buildClauseItem(
                      number: '5',
                      title: context.l10n.contract_maintenance_screen_title,
                      body:
                          '${_contract.maintenanceLiability}. ${context.l10n.contract_no_alterations}',
                    ),

                    if (_contract.forbidSubleasing)
                      _buildClauseItem(
                        number: '6',
                        title: context.l10n.contract_sublease_screen_title,
                        body:
                            context.l10n.contract_sublease_ban_screen_text,
                      ),

                    _buildClauseItem(
                      number: '7',
                      title: context.l10n.contract_termination_title,
                      body: '${_contract.latePaymentPolicy}.',
                    ),

                    if (_contract.customClauses.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.contract_extra_clauses_title,
                        style: AppFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.primaryInk,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ..._contract.customClauses.map(
                        (clause) => Padding(
                          padding: const EdgeInsetsDirectional.only(bottom: 6, end: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '• ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Expanded(
                                child: Text(
                                  clause,
                                  style: AppFonts.cairo(
                                    fontSize: 12.5,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 30),

                    // Signatures Section
                    _buildSectionTitle(context.l10n.contract_section_signatures),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSignatureBox(context.l10n.contract_owner_signature_short),
                        _buildSignatureBox(context.l10n.contract_tenant_signature_short),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSignatureBox(context.l10n.contract_witness1),
                        _buildSignatureBox(context.l10n.contract_witness2),
                      ],
                    ),

                    const SizedBox(height: 30),
                    Divider(color: AppColors.divider),
                    Center(
                      child: Text(
                        context.l10n.contract_footer_notice,
                        style: AppFonts.cairo(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
        border: BorderDirectional(
          start: BorderSide(color: AppColors.primaryInk, width: 4),
        ),
      ),
      child: Text(
        title,
        style: AppFonts.cairo(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: AppColors.primaryInk,
        ),
      ),
    );
  }

  Widget _buildPartyBox({
    required String title,
    required String name,
    required String phone,
    required String idCard,
    required String address,
    required VoidCallback onEdit,
  }) {
    final bool isFilled = name.isNotEmpty && !name.contains('...');
    return InkWell(
      onTap: onEdit,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isFilled ? AppColors.primaryMuted : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isFilled
                ? AppColors.primary.withOpacity(0.4)
                : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AppFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.primaryInk,
                  ),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: onEdit,
                  icon: Icon(
                    Icons.edit_note,
                    size: 16,
                    color: AppColors.primaryInk,
                  ),
                  label: Text(
                    context.l10n.contract_write_edit,
                    style: AppFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryInk,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${context.l10n.contract_name_label} $name',
                    style: AppFonts.cairo(
                      fontSize: 12,
                      fontWeight: isFilled
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${context.l10n.contract_phone} $phone',
                    style: AppFonts.cairo(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${context.l10n.contract_identity_label} $idCard',
                    style: AppFonts.cairo(fontSize: 12),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${context.l10n.contract_address} $address',
                    style: AppFonts.cairo(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClauseItem({
    required String number,
    required String title,
    required String body,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            margin: const EdgeInsetsDirectional.only(top: 2, start: 8),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppFonts.cairo(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.6,
                ),
                children: [
                  TextSpan(
                    text: '$title ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextSpan(text: body),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignatureBox(String role) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(12),
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              role,
              style: AppFonts.cairo(
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              context.l10n.contract_signature_stamp,
              style: TextStyle(fontSize: 10, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

/// نافذة تعديل وتشكيل بنود العقد (The Contract Editor Sheet)
class _ContractEditorSheet extends StatefulWidget {
  final PropertyContract contract;
  final Property property;
  final Function(PropertyContract) onSave;

  const _ContractEditorSheet({
    required this.contract,
    required this.property,
    required this.onSave,
  });

  @override
  State<_ContractEditorSheet> createState() => _ContractEditorSheetState();
}

class _ContractEditorSheetState extends State<_ContractEditorSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // الطرف الأول (المؤجر)
  late TextEditingController _ownerNameController;
  late TextEditingController _ownerPhoneController;
  late TextEditingController _ownerIdCardController;
  late TextEditingController _ownerAddressController;

  // الطرف الثاني (المستأجر)
  late TextEditingController _tenantNameController;
  late TextEditingController _tenantPhoneController;
  late TextEditingController _tenantIdCardController;
  late TextEditingController _tenantAddressController;

  // بنود العقد والماليات
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _depositController;
  late TextEditingController _durationController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _utilitiesController;
  late TextEditingController _maintenanceController;
  late TextEditingController _latePolicyController;
  late TextEditingController _newClauseController;

  late bool _isRenewableOnlyByOwner;
  late bool _forbidSubleasing;
  late bool _saveAsDefault;
  late List<String> _customClauses;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _ownerNameController = TextEditingController(
      text: widget.contract.ownerName.isNotEmpty
          ? widget.contract.ownerName
          : (widget.property.owner?.fullName ?? ''),
    );
    _ownerPhoneController = TextEditingController(
      text: widget.contract.ownerPhone.isNotEmpty
          ? widget.contract.ownerPhone
          : widget.property.contactPhone,
    );
    _ownerIdCardController = TextEditingController(
      text: widget.contract.ownerIdCard,
    );
    _ownerAddressController = TextEditingController(
      text: widget.contract.ownerAddress,
    );

    _tenantNameController = TextEditingController(
      text: widget.contract.tenantName,
    );
    _tenantPhoneController = TextEditingController(
      text: widget.contract.tenantPhone,
    );
    _tenantIdCardController = TextEditingController(
      text: widget.contract.tenantIdCard,
    );
    _tenantAddressController = TextEditingController(
      text: widget.contract.tenantAddress,
    );

    _titleController = TextEditingController(text: widget.contract.title);
    _amountController = TextEditingController(
      text: widget.contract.amount.toStringAsFixed(0),
    );
    _depositController = TextEditingController(
      text: widget.contract.securityDeposit.toStringAsFixed(0),
    );
    _durationController = TextEditingController(
      text: widget.contract.durationText,
    );
    _startDateController = TextEditingController(
      text: widget.contract.startDate,
    );
    _endDateController = TextEditingController(text: widget.contract.endDate);
    _utilitiesController = TextEditingController(
      text: widget.contract.utilitiesPayableBy,
    );
    _maintenanceController = TextEditingController(
      text: widget.contract.maintenanceLiability,
    );
    _latePolicyController = TextEditingController(
      text: widget.contract.latePaymentPolicy,
    );
    _newClauseController = TextEditingController();

    _isRenewableOnlyByOwner = widget.contract.isRenewableOnlyByOwner;
    _forbidSubleasing = widget.contract.forbidSubleasing;
    _saveAsDefault = widget.contract.isSavedAsDefaultTemplate;
    _customClauses = List.from(widget.contract.customClauses);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ownerNameController.dispose();
    _ownerPhoneController.dispose();
    _ownerIdCardController.dispose();
    _ownerAddressController.dispose();
    _tenantNameController.dispose();
    _tenantPhoneController.dispose();
    _tenantIdCardController.dispose();
    _tenantAddressController.dispose();
    _titleController.dispose();
    _amountController.dispose();
    _depositController.dispose();
    _durationController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _utilitiesController.dispose();
    _maintenanceController.dispose();
    _latePolicyController.dispose();
    _newClauseController.dispose();
    super.dispose();
  }

  void _addCustomClause() {
    final text = _newClauseController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _customClauses.add(text);
        _newClauseController.clear();
      });
    }
  }

  void _save() {
    final updated = widget.contract.copyWith(
      title: _titleController.text.trim(),
      ownerName: _ownerNameController.text.trim(),
      ownerPhone: _ownerPhoneController.text.trim(),
      ownerIdCard: _ownerIdCardController.text.trim(),
      ownerAddress: _ownerAddressController.text.trim(),
      tenantName: _tenantNameController.text.trim(),
      tenantPhone: _tenantPhoneController.text.trim(),
      tenantIdCard: _tenantIdCardController.text.trim(),
      tenantAddress: _tenantAddressController.text.trim(),
      amount: double.tryParse(_amountController.text) ?? widget.contract.amount,
      securityDeposit:
          double.tryParse(_depositController.text) ??
          widget.contract.securityDeposit,
      durationText: _durationController.text.trim(),
      startDate: _startDateController.text.trim(),
      endDate: _endDateController.text.trim(),
      utilitiesPayableBy: _utilitiesController.text.trim(),
      maintenanceLiability: _maintenanceController.text.trim(),
      latePaymentPolicy: _latePolicyController.text.trim(),
      isRenewableOnlyByOwner: _isRenewableOnlyByOwner,
      forbidSubleasing: _forbidSubleasing,
      isSavedAsDefaultTemplate: _saveAsDefault,
      customClauses: _customClauses,
    );

    widget.onSave(updated);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final keyboardHeight = media.viewInsets.bottom;
    final availableHeight =
        media.size.height - media.viewPadding.top - keyboardHeight - 16;
    final targetHeight = availableHeight.clamp(320.0, media.size.height * 0.90);

    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Container(
        height: targetHeight,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Drag indicator handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.edit_document,
                      color: AppColors.primaryInk,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.contract_sheet_title,
                      style: AppFonts.cairo(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryInk,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 6),
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primaryInk,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              labelStyle: AppFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              tabs: [
                Tab(
                  icon: const Icon(Icons.people_outline, size: 18),
                  text: context.l10n.contract_tab_parties,
                ),
                Tab(
                  icon: const Icon(Icons.gavel_outlined, size: 18),
                  text: context.l10n.contract_tab_terms,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Parties Information
                  ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.manual,
                    padding: const EdgeInsets.only(bottom: 16),
                    children: [
                      // الطرف الثاني: المستأجر
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  color: AppColors.primaryInk,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  context.l10n.contract_tenant_section_title,
                                  style: AppFonts.cairo(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: AppColors.primaryInk,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _buildField(
                              context.l10n.contract_tenant_name_label,
                              _tenantNameController,
                              hint: context.l10n.contract_tenant_name_hint,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildField(
                                    context.l10n.contract_tenant_id_label,
                                    _tenantIdCardController,
                                    hint: context.l10n.contract_id_hint,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildField(
                                    context.l10n.contract_contact_phone_label,
                                    _tenantPhoneController,
                                    hint: '770000000',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _buildField(
                              context.l10n.contract_tenant_address_label,
                              _tenantAddressController,
                              hint: context.l10n.contract_tenant_address_hint,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // الطرف الأول: المؤجر / المالك
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.real_estate_agent,
                                  color: AppColors.accentInk,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  context.l10n.contract_owner_section_title,
                                  style: AppFonts.cairo(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: AppColors.accentInk,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _buildField(
                              context.l10n.contract_owner_name_label,
                              _ownerNameController,
                              hint: context.l10n.contract_owner_name_hint,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildField(
                                    context.l10n.contract_owner_id_label,
                                    _ownerIdCardController,
                                    hint: context.l10n.contract_id_number_hint,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildField(
                                    context.l10n.contract_owner_phone_label,
                                    _ownerPhoneController,
                                    hint: context.l10n.contract_contact_phone_hint,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _buildField(
                              context.l10n.contract_owner_address_label,
                              _ownerAddressController,
                              hint: context.l10n.contract_owner_address_hint,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Tab 2: Financials & Clauses
                  ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.manual,
                    padding: const EdgeInsets.only(bottom: 16),
                    children: [
                      _buildField(context.l10n.contract_formal_title_label, _titleController),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              '${context.l10n.contract_rent_amount_label} (${widget.contract.currency})',
                              _amountController,
                              isNumber: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildField(
                              context.l10n.contract_deposit_label,
                              _depositController,
                              isNumber: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              context.l10n.contract_duration_label,
                              _durationController,
                              hint: context.l10n.contract_duration_hint,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildField(
                              context.l10n.contract_start_date_label,
                              _startDateController,
                              hint: '2026/10/17',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        context.l10n.contract_end_date_label,
                        _endDateController,
                        hint: '2027/10/17',
                      ),
                      const SizedBox(height: 16),

                      // Switches
                      Material(
                        color: Colors.transparent,
                        child: SwitchListTile(
                          title: Text(
                            context.l10n.contract_non_renewable_switch_title,
                            style: AppFonts.cairo(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          subtitle: Text(
                            context.l10n.contract_non_renewable_switch_subtitle,
                            style: AppFonts.cairo(fontSize: 11),
                          ),
                          value: _isRenewableOnlyByOwner,
                          onChanged: (val) =>
                              setState(() => _isRenewableOnlyByOwner = val),
                          activeColor: AppColors.primary,
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: SwitchListTile(
                          title: Text(
                            context.l10n.contract_sublease_switch_title,
                            style: AppFonts.cairo(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          subtitle: Text(
                            context.l10n.contract_sublease_switch_subtitle,
                            style: AppFonts.cairo(fontSize: 11),
                          ),
                          value: _forbidSubleasing,
                          onChanged: (val) =>
                              setState(() => _forbidSubleasing = val),
                          activeColor: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildField(
                        context.l10n.contract_utilities_label,
                        _utilitiesController,
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        context.l10n.contract_maintenance_label,
                        _maintenanceController,
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        context.l10n.contract_late_policy_label,
                        _latePolicyController,
                      ),
                      const SizedBox(height: 16),

                      // Custom Clauses
                      Text(
                        context.l10n.contract_extra_owner_clauses_title,
                        style: AppFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ..._customClauses.asMap().entries.map(
                        (entry) => Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: AppFonts.cairo(fontSize: 12),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: AppColors.error,
                                ),
                                onPressed: () => setState(
                                  () => _customClauses.removeAt(entry.key),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _newClauseController,
                              scrollPadding: const EdgeInsets.only(bottom: 90),
                              decoration: InputDecoration(
                                hintText:
                                    context.l10n.contract_custom_clause_hint,
                                hintStyle: AppFonts.cairo(fontSize: 12),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.textLight,
                            ),
                            onPressed: _addCustomClause,
                            child: Text(context.l10n.contract_add),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Save as template switch
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withAlpha(20),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.accent.withAlpha(80),
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: SwitchListTile(
                            title: Text(
                              context.l10n.contract_save_template_title,
                              style: AppFonts.cairo(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppColors.primaryInk,
                              ),
                            ),
                            subtitle: Text(
                              context.l10n.contract_save_template_subtitle,
                              style: AppFonts.cairo(fontSize: 11),
                            ),
                            value: _saveAsDefault,
                            onChanged: (val) =>
                                setState(() => _saveAsDefault = val),
                            activeColor: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Persistent Action Buttons docked right above the keyboard
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle_outline, size: 20),
                    label: Text(
                      context.l10n.contract_save_apply,
                      style: AppFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textLight,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _save,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      context.l10n.contract_cancel,
                      style: AppFonts.cairo(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
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

  Widget _buildField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          scrollPadding: const EdgeInsets.only(bottom: 90),
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: AppFonts.cairo(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppFonts.cairo(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 11,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}
