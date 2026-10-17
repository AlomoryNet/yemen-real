// Yemen Real Estate Portal — بوابة اليمن العقارية
// Contract Preview & Print Screen — شاشة معاينة وطباعة وتشكيل العقد اليمني

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/property.dart';
import '../../../models/property_contract.dart';
import '../../../services/contract_service.dart';

class ContractPreviewScreen extends StatefulWidget {
  final Property property;
  final PropertyContract? initialContract;

  const ContractPreviewScreen({
    super.key,
    required this.property,
    this.initialContract,
  });

  @override
  State<ContractPreviewScreen> createState() => _ContractPreviewScreenState();
}

class _ContractPreviewScreenState extends State<ContractPreviewScreen> {
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
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
                  'تم حفظ وتحديث بنود العقد بنجاح',
                  style: GoogleFonts.cairo(),
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
    buffer.writeln('بسم الله الرحمن الرحيم');
    buffer.writeln('الجمهورية اليمنية');
    buffer.writeln('==============================');
    buffer.writeln(_contract.title);
    buffer.writeln('==============================');
    buffer.writeln('تاريخ التحرير: ${_contract.startDate.isNotEmpty ? _contract.startDate : DateTime.now().toString().split(' ').first}');
    buffer.writeln('');
    buffer.writeln('الطرف الأول (المؤجر / المالك): ${_contract.ownerName.isNotEmpty ? _contract.ownerName : widget.property.owner?.fullName ?? 'المالك'}');
    buffer.writeln('هاتف: ${_contract.ownerPhone.isNotEmpty ? _contract.ownerPhone : widget.property.contactPhone}');
    buffer.writeln('العنوان: ${_contract.ownerAddress}');
    buffer.writeln('');
    buffer.writeln('الطرف الثاني (المستأجر): ${_contract.tenantName.isNotEmpty ? _contract.tenantName : "........................................"}');
    buffer.writeln('بطاقة شخصية رقم: ${_contract.tenantIdCard.isNotEmpty ? _contract.tenantIdCard : "...................."}');
    buffer.writeln('');
    buffer.writeln('العين المؤجرة:');
    buffer.writeln('عقار كائن في محافظة ${widget.property.city} - مديرية ${widget.property.district} - ${widget.property.addressDetails ?? ""}');
    buffer.writeln('المواصفات: ${widget.property.title}');
    buffer.writeln('');
    buffer.writeln('بنود وشروط الاتفاق:');
    buffer.writeln('1. مدة العقد: ${_contract.durationText} تبدأ من تاريخ ${_contract.startDate} وحتى ${_contract.endDate}، ${_contract.isRenewableOnlyByOwner ? "غير قابلة للتجديد إلا برغبة وموافقة خطية من الطرف الأول." : "تجدد تلقائياً ما لم يخطر أحد الطرفين الآخر قبل شهر."}');
    buffer.writeln('2. الإيجار المتفق عليه: مبلغ وقدره ${Formatters.formatCurrency(_contract.amount, _contract.currency)} يدفع ${_contract.paymentFrequency}.');
    if (_contract.securityDeposit > 0) {
      buffer.writeln('3. مبلغ الضمان / التأمين: ${Formatters.formatCurrency(_contract.securityDeposit, _contract.currency)} يسلم للمؤجر ويُعاد للمستأجر عند انتهاء العقد وتسليم العين بحالتها الأولى.');
    }
    buffer.writeln('4. فواتير الخدمات: ${_contract.utilitiesPayableBy}.');
    buffer.writeln('5. الصيانة والاستخدام: ${_contract.maintenanceLiability}.');
    if (_contract.forbidSubleasing) {
      buffer.writeln('6. منع التأجير من الباطن: هذا العقد شخصي للمستأجر ولا يحق له التنازل أو التقبيل أو التأجير من الباطن كلياً أو جزئياً.');
    }
    buffer.writeln('7. التخلف عن السداد: ${_contract.latePaymentPolicy}.');
    
    if (_contract.customClauses.isNotEmpty) {
      buffer.writeln('8. شروط خاصة إضافية من المؤجر:');
      for (int i = 0; i < _contract.customClauses.length; i++) {
        buffer.writeln('   - ${_contract.customClauses[i]}');
      }
    }

    buffer.writeln('');
    buffer.writeln('توقيع الطرف الأول (المؤجر): .....................');
    buffer.writeln('توقيع الطرف الثاني (المستأجر): .....................');
    buffer.writeln('الشاهد الأول: .....................    الشاهد الثاني: .....................');
    return buffer.toString();
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _generatePlainText()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم نسخ نص العقد الكامل إلى الحافظة بنجاح، يمكنك لصقه وطباعته في أي برنامج',
          style: GoogleFonts.cairo(),
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
    final pdf = pw.Document();
    final fontData = await rootBundle.load('assets/fonts/Cairo.ttf');
    final fontCairo = pw.Font.ttf(fontData);
    final fontCairoBold = fontCairo;

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(28),
        theme: pw.ThemeData.withFont(
          base: fontCairo,
          bold: fontCairoBold,
        ),
        build: (pw.Context ctx) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
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
                    'بسم الله الرحمن الرحيم',
                    style: pw.TextStyle(font: fontCairoBold, fontSize: 13),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    'الجمهورية اليمنية',
                    style: pw.TextStyle(font: fontCairoBold, fontSize: 12),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    _contract.title.isNotEmpty ? _contract.title : 'عقد إيجار شرعي وقانوني',
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
                              'الطرف الأول (المؤجر/المالك): ${_contract.ownerName.isNotEmpty ? _contract.ownerName : widget.property.owner?.fullName ?? "المالك"}',
                              style: pw.TextStyle(font: fontCairoBold, fontSize: 9.5),
                            ),
                            pw.Text(
                              'هوية رقم: ${_contract.ownerIdCard.isNotEmpty ? _contract.ownerIdCard : "...................."}',
                              style: pw.TextStyle(font: fontCairo, fontSize: 9),
                            ),
                            pw.Text(
                              'هاتف: ${_contract.ownerPhone.isNotEmpty ? _contract.ownerPhone : widget.property.contactPhone}',
                              style: pw.TextStyle(font: fontCairo, fontSize: 9),
                            ),
                            pw.Text(
                              'العنوان: ${_contract.ownerAddress}',
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
                              'الطرف الثاني (المستأجر): ${_contract.tenantName.isNotEmpty ? _contract.tenantName : "...................................."}',
                              style: pw.TextStyle(font: fontCairoBold, fontSize: 9.5),
                            ),
                            pw.Text(
                              'بطاقة شخصية رقم: ${_contract.tenantIdCard.isNotEmpty ? _contract.tenantIdCard : "...................."}',
                              style: pw.TextStyle(font: fontCairo, fontSize: 9),
                            ),
                            pw.Text(
                              'هاتف المستأجر: ${_contract.tenantPhone.isNotEmpty ? _contract.tenantPhone : "...................."}',
                              style: pw.TextStyle(font: fontCairo, fontSize: 9),
                            ),
                            pw.Text(
                              'محل الإقامة: ${_contract.tenantAddress.isNotEmpty ? _contract.tenantAddress : "...................."}',
                              style: pw.TextStyle(font: fontCairo, fontSize: 9),
                            ),
                            pw.Text(
                              'تاريخ البدء: ${_contract.startDate}',
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
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey200,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                      'العين المؤجرة: عقار كائن في محافظة ${widget.property.city} - مديرية ${widget.property.district} - ${widget.property.addressDetails ?? ""} (${widget.property.title})',
                      style: pw.TextStyle(font: fontCairoBold, fontSize: 9),
                    ),
                  ),
                  pw.SizedBox(height: 8),

                  // Clauses Title
                  pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(
                      'بنود وشروط الاتفاق والتراضي:',
                      style: pw.TextStyle(font: fontCairoBold, fontSize: 10),
                    ),
                  ),
                  pw.SizedBox(height: 5),

                  _buildPdfClause(
                    1,
                    'مدة العقد: ${_contract.durationText} تبدأ من تاريخ ${_contract.startDate} وحتى ${_contract.endDate}، ${_contract.isRenewableOnlyByOwner ? "غير قابلة للتجديد إلا برغبة وموافقة خطية من الطرف الأول." : "تجدد بالتراضي بين الطرفين."}',
                    fontCairo,
                    fontCairoBold,
                  ),
                  _buildPdfClause(
                    2,
                    'الإيجار الشهري المتفق عليه: مبلغ وقدره ${Formatters.formatCurrency(_contract.amount, _contract.currency)} يدفع ${_contract.paymentFrequency} مقدماً وبسندات رسمية، وفي حال التأخر أسبوعين يعتبر العقد لاغياً.',
                    fontCairo,
                    fontCairoBold,
                  ),
                  _buildPdfClause(
                    3,
                    'هذا العقد شخصي بين الطرفين أعلاه وتم بقناعتهم ورضاهم جميعاً ولا يخضع لأي نظم تضر بمصلحة المؤجر.',
                    fontCairo,
                    fontCairoBold,
                  ),
                  _buildPdfClause(
                    4,
                    'أقر المستأجر بأنه قد استلم العين المؤجرة في حالة سليمة وتعهد بالمحافظة عليها من الداخل والخارج، ويتحمل مسؤولية أي تلف أو خلل يحصل في العين المؤجرة.',
                    fontCairo,
                    fontCairoBold,
                  ),
                  _buildPdfClause(
                    5,
                    'العقد شخصي للمستأجر والمدون اسمه أعلاه ولا يجوز التنازل عنه للغير من الباطن أو الظاهر ولا يحق له التقبيل مطلقاً.',
                    fontCairo,
                    fontCairoBold,
                  ),
                  _buildPdfClause(
                    6,
                    'إن المؤجر غير مسؤول عن أي ضرر أو أخطار قد تقع في الأرواح أو الأصول لأي سبب كان مثل الحرائق أو الأمطار والسيول أو السرقات.',
                    fontCairo,
                    fontCairoBold,
                  ),

                  if (_contract.securityDeposit > 0)
                    _buildPdfClause(
                      7,
                      'الضمان والتأمين: دفع مبلغ ${Formatters.formatCurrency(_contract.securityDeposit, _contract.currency)} كوديعة تأمين تسترد عند تسليم العين بحالتها الأصلية.',
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
                            'توقيع المؤجر (الطرف الأول)',
                            style: pw.TextStyle(font: fontCairoBold, fontSize: 9),
                          ),
                          pw.SizedBox(height: 20),
                          pw.Text('................................', style: pw.TextStyle(font: fontCairo, fontSize: 9)),
                        ],
                      ),
                      pw.Column(
                        children: [
                          pw.Text(
                            'توقيع المستأجر (الطرف الثاني)',
                            style: pw.TextStyle(font: fontCairoBold, fontSize: 9),
                          ),
                          pw.SizedBox(height: 20),
                          pw.Text('................................', style: pw.TextStyle(font: fontCairo, fontSize: 9)),
                        ],
                      ),
                      pw.Column(
                        children: [
                          pw.Text(
                            'الشاهد الأول / الثاني',
                            style: pw.TextStyle(font: fontCairoBold, fontSize: 9),
                          ),
                          pw.SizedBox(height: 20),
                          pw.Text('................................', style: pw.TextStyle(font: fontCairo, fontSize: 9)),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.Divider(thickness: 0.5, color: PdfColors.grey400),
                  pw.Text(
                    '${AppConstants.copyrightNoticeAr} — بوابة اليمن العقارية',
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
          'عقد_ايجار_${cleanCity}_${DateTime.now().millisecondsSinceEpoch}.pdf';
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
                  'تم حفظ العقد PDF',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Text(
              'تم حفظ ملف العقد الرسمي بصيغة PDF بنجاح في جهازك:\n\n📂 المسار:\n${file.path}\n\nيمكنك الآن إرساله عبر واتساب أو طباعته أو فتحه عبر مدير الملفات (التنزيلات).',
              style: GoogleFonts.cairo(height: 1.5, fontSize: 13),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _copyToClipboard();
                },
                child: const Text('نسخ نص العقد'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('حسناً'),
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
              'حدث خطأ أثناء حفظ ملف PDF: $e',
              style: GoogleFonts.cairo(),
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: Text(
          'معاينة وتشكيل العقد',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'تعديل وتشكيل البنود',
            icon: const Icon(Icons.tune),
            onPressed: _openContractEditor,
          ),
          IconButton(
            tooltip: 'حفظ العقد PDF',
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _saveAsPdf,
          ),
          IconButton(
            tooltip: 'نسخ نص العقد',
            icon: const Icon(Icons.copy),
            onPressed: _copyToClipboard,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
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
                    'تعديل البنود',
                    style: GoogleFonts.cairo(
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
                    backgroundColor: const Color(0xFFB91C1C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.picture_as_pdf, size: 18),
                  label: Text(
                    'حفظ العقد PDF',
                    style: GoogleFonts.cairo(
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
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.print, size: 18),
                  label: Text(
                    'طباعة',
                    style: GoogleFonts.cairo(
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
              color: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFD1D5DB)),
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
                            'بسم الله الرحمن الرحيم',
                            style: GoogleFonts.amiri(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'الجمهورية اليمنية',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
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
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: Colors.black26, thickness: 1),
                    const SizedBox(height: 14),

                    // Date & Contract ID
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'تاريخ التحرير: ${_contract.startDate.isNotEmpty ? _contract.startDate : DateTime.now().toString().split(" ").first}',
                          style: GoogleFonts.cairo(fontSize: 12, color: Colors.black87),
                        ),
                        Text(
                          'رقم العقد: ${_contract.id}',
                          style: GoogleFonts.outfit(fontSize: 12, color: Colors.black54),
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
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.edit_note, color: AppColors.primary, size: 28),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'تعبئة وكتابة بيانات العقد مباشرة',
                                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryDark),
                                ),
                                Text(
                                  'اضغط هنا أو على أي خانة لكتابة اسم المستأجر والمؤجر وأرقام الهويات ومبالغ وشروط العقد لتظهر مطبوعة في الـ PDF دون فراغات',
                                  style: GoogleFonts.cairo(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            onPressed: _openContractEditor,
                            icon: const Icon(Icons.edit, size: 15),
                            label: Text('تعبئة الخانات', style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),

                    // Parties Information Table
                    _buildSectionTitle('أولاً: أطراف العقد'),
                    const SizedBox(height: 8),
                    _buildPartyBox(
                      title: 'الطرف الأول (المؤجر / المالك):',
                      name: _contract.ownerName.isNotEmpty ? _contract.ownerName : (widget.property.owner?.fullName ?? 'المالك'),
                      phone: _contract.ownerPhone.isNotEmpty ? _contract.ownerPhone : widget.property.contactPhone,
                      idCard: _contract.ownerIdCard.isNotEmpty ? _contract.ownerIdCard : '................................',
                      address: _contract.ownerAddress,
                      onEdit: _openContractEditor,
                    ),
                    const SizedBox(height: 10),
                    _buildPartyBox(
                      title: 'الطرف الثاني (المستأجر):',
                      name: _contract.tenantName.isNotEmpty ? _contract.tenantName : '................................................',
                      phone: _contract.tenantPhone.isNotEmpty ? _contract.tenantPhone : '................................',
                      idCard: _contract.tenantIdCard.isNotEmpty ? _contract.tenantIdCard : '................................',
                      address: _contract.tenantAddress.isNotEmpty ? _contract.tenantAddress : '................................',
                      onEdit: _openContractEditor,
                    ),
                    const SizedBox(height: 20),

                    // Property Specs
                    _buildSectionTitle('ثانياً: بيانات العين المؤجرة وموقعها'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Text(
                        'عقار كائن في محافظة ${widget.property.city} - مديرية ${widget.property.district} - ${widget.property.addressDetails ?? ""}.\nالمواصفات: ${widget.property.title} بمساحة تقريبية ${widget.property.areaSqm} م².',
                        style: GoogleFonts.cairo(fontSize: 13, height: 1.6),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Contract Clauses
                    _buildSectionTitle('ثالثاً: بنود وشروط الاتفاق الشرعية والقانونية'),
                    const SizedBox(height: 10),

                    _buildClauseItem(
                      number: '1',
                      title: 'مدة العقد وتاريخ السريان:',
                      body: 'مدة العقد (${_contract.durationText}) تبدأ من تاريخ ${_contract.startDate} وتنتهي في تاريخ ${_contract.endDate}، ${_contract.isRenewableOnlyByOwner ? "وهي غير قابلة للتجديد إلا برغبة وموافقة خطية صريحة من الطرف الأول." : "قابلة للتجديد برضا الطرفين."}',
                    ),

                    _buildClauseItem(
                      number: '2',
                      title: 'القيمة الإيجارية وطريقة السداد:',
                      body: 'اتفق الطرفان على قيمة إيجارية شهرية قدرها (${Formatters.formatCurrency(_contract.amount, _contract.currency)}) تدفع (${_contract.paymentFrequency}) وبسندات قبض موقعة.',
                    ),

                    if (_contract.securityDeposit > 0)
                      _buildClauseItem(
                        number: '3',
                        title: 'مبلغ الضمان والتأمين:',
                        body: 'يدفع الطرف الثاني مبلغ تأمين وضمان قدره (${Formatters.formatCurrency(_contract.securityDeposit, _contract.currency)}) يبقى لدى الطرف الأول كوديعة ضمان لصيانة ونظافة العين وتسديد الفواتير، ويُرد للمستأجر عند الإخلاء بحالة سليمة.',
                      ),

                    _buildClauseItem(
                      number: '4',
                      title: 'فواتير الخدمات والاستهلاك:',
                      body: 'يتحمل ${_contract.utilitiesPayableBy} كافة فواتير الكهرباء والمياه وخدمات النظافة والاتصالات المترتبة على العين المؤجرة طوال فترة الإيجار.',
                    ),

                    _buildClauseItem(
                      number: '5',
                      title: 'المحافظة على العين والصيانة:',
                      body: '${_contract.maintenanceLiability}. ولا يحق للمستأجر إحداث أي فتحات أو تغييرات في المبنى إلا بإذن كتابي مسبق.',
                    ),

                    if (_contract.forbidSubleasing)
                      _buildClauseItem(
                        number: '6',
                        title: 'منع التأجير من الباطن أو التقبيل:',
                        body: 'هذا العقد شخصي للمستأجر فقط، ولا يجوز له التنازل عنه للغير كلياً أو جزئياً من الباطن أو التقبيل نهائياً.',
                      ),

                    _buildClauseItem(
                      number: '7',
                      title: 'فسخ العقد وإخلاء العين:',
                      body: '${_contract.latePaymentPolicy}.',
                    ),

                    if (_contract.customClauses.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'شروط إضافية خاصة بالمؤجر:',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ..._contract.customClauses.map((clause) => Padding(
                            padding: const EdgeInsets.only(bottom: 6, right: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                                Expanded(
                                  child: Text(
                                    clause,
                                    style: GoogleFonts.cairo(fontSize: 12.5, height: 1.5),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],

                    const SizedBox(height: 30),

                    // Signatures Section
                    _buildSectionTitle('رابعاً: الإقرار والتوقيعات'),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSignatureBox('توقيع المؤجر (الطرف الأول)'),
                        _buildSignatureBox('توقيع المستأجر (الطرف الثاني)'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSignatureBox('الشاهد الأول'),
                        _buildSignatureBox('الشاهد الثاني'),
                      ],
                    ),

                    const SizedBox(height: 30),
                    const Divider(color: Colors.black26),
                    Center(
                      child: Text(
                        'وثيقة رسمية صادرة عبر بوابة اليمن العقارية — هيبه سوفت (Hiba Soft) © 2026',
                        style: GoogleFonts.cairo(
                          fontSize: 10,
                          color: Colors.black45,
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
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
        border: const Border(right: BorderSide(color: AppColors.primary, width: 4)),
      ),
      child: Text(
        title,
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: AppColors.primaryDark,
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
          color: isFilled ? const Color(0xFFF9FCF9) : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isFilled ? AppColors.primary.withOpacity(0.4) : const Color(0xFFE5E7EB),
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
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_note, size: 16, color: AppColors.primary),
                  label: Text('كتابة / تعديل', style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(child: Text('الاسم: $name', style: GoogleFonts.cairo(fontSize: 12, fontWeight: isFilled ? FontWeight.bold : FontWeight.normal))),
                Expanded(child: Text('هاتف: $phone', style: GoogleFonts.cairo(fontSize: 12))),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(child: Text('الهوية / البطاقة: $idCard', style: GoogleFonts.cairo(fontSize: 12))),
                Expanded(child: Text('العنوان: $address', style: GoogleFonts.cairo(fontSize: 12))),
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
            margin: const EdgeInsets.only(top: 2, left: 8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.cairo(color: Colors.black87, fontSize: 13, height: 1.6),
                children: [
                  TextSpan(
                    text: '$title ',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
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
          border: Border.all(color: Colors.black26, style: BorderStyle.solid),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(role, style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold)),
            const Text('التوقيع / البصمة: ...................', style: TextStyle(fontSize: 10, color: Colors.black45)),
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

class _ContractEditorSheetState extends State<_ContractEditorSheet> with SingleTickerProviderStateMixin {
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
    _ownerIdCardController = TextEditingController(text: widget.contract.ownerIdCard);
    _ownerAddressController = TextEditingController(text: widget.contract.ownerAddress);

    _tenantNameController = TextEditingController(text: widget.contract.tenantName);
    _tenantPhoneController = TextEditingController(text: widget.contract.tenantPhone);
    _tenantIdCardController = TextEditingController(text: widget.contract.tenantIdCard);
    _tenantAddressController = TextEditingController(text: widget.contract.tenantAddress);

    _titleController = TextEditingController(text: widget.contract.title);
    _amountController = TextEditingController(text: widget.contract.amount.toStringAsFixed(0));
    _depositController = TextEditingController(text: widget.contract.securityDeposit.toStringAsFixed(0));
    _durationController = TextEditingController(text: widget.contract.durationText);
    _startDateController = TextEditingController(text: widget.contract.startDate);
    _endDateController = TextEditingController(text: widget.contract.endDate);
    _utilitiesController = TextEditingController(text: widget.contract.utilitiesPayableBy);
    _maintenanceController = TextEditingController(text: widget.contract.maintenanceLiability);
    _latePolicyController = TextEditingController(text: widget.contract.latePaymentPolicy);
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
      securityDeposit: double.tryParse(_depositController.text) ?? widget.contract.securityDeposit,
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
    final availableHeight = media.size.height - media.viewPadding.top - keyboardHeight - 16;
    final targetHeight = availableHeight.clamp(320.0, media.size.height * 0.90);

    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Container(
        height: targetHeight,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.edit_document, color: AppColors.primary, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'تعبئة وتعديل بيانات العقد',
                      style: GoogleFonts.cairo(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
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
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12),
              tabs: const [
                Tab(icon: Icon(Icons.people_outline, size: 18), text: 'المستأجر والمؤجر'),
                Tab(icon: Icon(Icons.gavel_outlined, size: 18), text: 'الشروط والماليات'),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Parties Information
                  ListView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
                    padding: const EdgeInsets.only(bottom: 16),
                    children: [
                      // الطرف الثاني: المستأجر
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person, color: AppColors.primary, size: 20),
                                const SizedBox(width: 6),
                                Text(
                                  'الطرف الثاني (المستأجر) - تعبئة الفراغات',
                                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryDark),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _buildField('اسم المستأجر الكامل *', _tenantNameController, hint: 'مثال: محمد عبدالله الأهدل'),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(child: _buildField('رقم البطاقة الشخصية / الهوية *', _tenantIdCardController, hint: 'مثال: 01010023456')),
                                const SizedBox(width: 10),
                                Expanded(child: _buildField('رقم الهاتف للتواصل *', _tenantPhoneController, hint: '770000000')),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _buildField('العنوان ومحل الإقامة الحالي', _tenantAddressController, hint: 'مثال: صنعاء - الأصبحي'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // الطرف الأول: المؤجر / المالك
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.real_estate_agent, color: AppColors.accentDark, size: 20),
                                const SizedBox(width: 6),
                                Text(
                                  'الطرف الأول (المؤجر / المالك)',
                                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.accentDark),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _buildField('اسم المؤجر / المالك *', _ownerNameController, hint: 'اسم المالك الرباعي'),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(child: _buildField('رقم البطاقة الشخصية للمؤجر', _ownerIdCardController, hint: 'رقم الهوية')),
                                const SizedBox(width: 10),
                                Expanded(child: _buildField('هاتف المؤجر *', _ownerPhoneController, hint: 'هاتف التواصل')),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _buildField('عنوان المؤجر المعتمد', _ownerAddressController, hint: 'مثال: صنعاء - حدة'),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Tab 2: Financials & Clauses
                  ListView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
                    padding: const EdgeInsets.only(bottom: 16),
                    children: [
                      _buildField('عنوان العقد الرسمي', _titleController),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildField('مبلغ الإيجار (${widget.contract.currency})', _amountController, isNumber: true)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildField('مبلغ الضمان والتأمين', _depositController, isNumber: true)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildField('مدة العقد', _durationController, hint: 'سنة كاملة')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildField('تاريخ البدء', _startDateController, hint: '2026/10/17')),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildField('تاريخ الانتهاء', _endDateController, hint: '2027/10/17'),
                      const SizedBox(height: 16),

                      // Switches
                      SwitchListTile(
                        title: Text('غير قابل للتجديد إلا برغبة وموافقة المالك', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text('حماية لحق المؤجر في تقرير التجديد من عدمه', style: GoogleFonts.cairo(fontSize: 11)),
                        value: _isRenewableOnlyByOwner,
                        onChanged: (val) => setState(() => _isRenewableOnlyByOwner = val),
                        activeColor: AppColors.primary,
                      ),
                      SwitchListTile(
                        title: Text('منع التأجير من الباطن أو التقبيل نهائياً', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text('يمنع المستأجر من تسليم العين لشخص آخر دون موافقة المالك الخطية', style: GoogleFonts.cairo(fontSize: 11)),
                        value: _forbidSubleasing,
                        onChanged: (val) => setState(() => _forbidSubleasing = val),
                        activeColor: AppColors.primary,
                      ),
                      const SizedBox(height: 12),

                      _buildField('مسؤولية فواتير الخدمات (كهرباء، ماء)', _utilitiesController),
                      const SizedBox(height: 12),
                      _buildField('شروط الصيانة وتسليم العين', _maintenanceController),
                      const SizedBox(height: 12),
                      _buildField('شرط التأخير عن السداد والفسخ', _latePolicyController),
                      const SizedBox(height: 16),

                      // Custom Clauses
                      Text(
                        'شروط خاصة إضافية من المالك:',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      ..._customClauses.asMap().entries.map((entry) => Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(child: Text(entry.value, style: GoogleFonts.cairo(fontSize: 12))),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                  onPressed: () => setState(() => _customClauses.removeAt(entry.key)),
                                ),
                              ],
                            ),
                          )),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _newClauseController,
                              scrollPadding: const EdgeInsets.only(bottom: 90),
                              decoration: InputDecoration(
                                hintText: 'اكتب شرطاً مخصصاً (مثال: عدم التدخين بالداخل)...',
                                hintStyle: GoogleFonts.cairo(fontSize: 12),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: _addCustomClause,
                            child: const Text('إضافة'),
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
                          border: Border.all(color: AppColors.accent.withAlpha(80)),
                        ),
                        child: SwitchListTile(
                          title: Text(
                            'حفظ هذا العقد كنموذج افتراضي لعقاراتي القادمة',
                            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryDark),
                          ),
                          subtitle: Text(
                            'عند تفعيل هذا الخيار، سيتم تطبيق هذه الشروط تلقائياً عند إضافة أي عرض جديد',
                            style: GoogleFonts.cairo(fontSize: 11),
                          ),
                          value: _saveAsDefault,
                          onChanged: (val) => setState(() => _saveAsDefault = val),
                          activeColor: AppColors.accent,
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
                      'حفظ وتطبيق التعديلات',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _save,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text('إلغاء', style: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {bool isNumber = false, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          scrollPadding: const EdgeInsets.only(bottom: 90),
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: GoogleFonts.cairo(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.cairo(fontSize: 11, color: Colors.grey.shade400),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}
