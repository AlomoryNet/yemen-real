import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yemen_real_estate_portal/core/theme/app_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/admin_provider.dart';
import '../../../providers/property_provider.dart';
import '../../../providers/rental_request_provider.dart';

/// Builds and saves the comprehensive PDF report for the active admin tab.
class AdminPdfService {
  static Future<void> exportCurrentSection(
    BuildContext context,
    WidgetRef ref, {
    required int sectionIndex,
  }) async {
    final l10n = context.l10n;
    // Snapshot direction before any async work so PDF rows and headers follow
    // the active locale instead of always rendering as Arabic/RTL.
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final pdfDirection = isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr;
    final cellAlignment = isRtl
        ? pw.Alignment.centerRight
        : pw.Alignment.centerLeft;
    final int currentTab = sectionIndex;
    final List<String> sectionTitles = [
      l10n.admin_tab_properties,
      l10n.admin_tab_requests,
      l10n.admin_tab_commissions,
      l10n.admin_tab_reports,
      l10n.admin_section_users,
    ];

    final sectionTitle = sectionTitles[currentTab];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${l10n.admin_pdf_preparing} $sectionTitle...',
          style: AppFonts.cairo(),
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      final fontData = await rootBundle.load('assets/fonts/Cairo.ttf');
      final fontCairo = pw.Font.ttf(fontData);
      final fontCairoBold = pw.Font.ttf(fontData);
      if (!context.mounted) return;

      final now = DateTime.now();
      final arabicDays = [
        l10n.admin_day_monday,
        l10n.admin_day_tuesday,
        l10n.admin_day_wednesday,
        l10n.admin_day_thursday,
        l10n.admin_day_friday,
        l10n.admin_day_saturday,
        l10n.admin_day_sunday,
      ];
      final arabicMonths = [
        l10n.admin_month_january,
        l10n.admin_month_february,
        l10n.admin_month_march,
        l10n.admin_month_april,
        l10n.admin_month_may,
        l10n.admin_month_june,
        l10n.admin_month_july,
        l10n.admin_month_august,
        l10n.admin_month_september,
        l10n.admin_month_october,
        l10n.admin_month_november,
        l10n.admin_month_december,
      ];

      final dayName = arabicDays[now.weekday - 1];
      final dayNum = now.day;
      final monthName = arabicMonths[now.month - 1];
      final yearNum = now.year;
      final int rawHour = now.hour;
      final int hour12 = rawHour > 12
          ? rawHour - 12
          : (rawHour == 0 ? 12 : rawHour);
      final period = rawHour >= 12 ? l10n.admin_pm : l10n.admin_am;
      final minute = now.minute.toString().padLeft(2, '0');
      final timeFormatted = '$hour12:$minute $period ${l10n.admin_sanaa_time}';

      final pdf = pw.Document();

      // Prepare table data based on current active tab
      List<String> tableHeaders = [];
      List<List<String>> tableData = [];

      switch (currentTab) {
        case 0: // Properties
          final props = ref.read(searchPropertiesProvider).asData?.value ?? [];
          tableHeaders = [
            l10n.admin_col_property_id,
            l10n.admin_col_address,
            l10n.admin_col_deal,
            l10n.admin_col_city,
            l10n.admin_col_price,
            l10n.admin_status_label,
          ];
          tableData = props
              .map(
                (p) => [
                  p.id,
                  p.title,
                  AppConstants.getDealTypeNameAr(p.dealType),
                  p.city,
                  Formatters.formatCurrency(p.price, p.currency),
                  AppConstants.getPropertyStatusNameAr(p.status),
                ],
              )
              .toList();
          break;

        case 1: // Rental Requests
          final reqs = await ref.read(allRentalRequestsProvider.future);
          tableHeaders = [
            l10n.admin_col_request_id,
            l10n.admin_property_label,
            l10n.admin_col_tenant,
            l10n.admin_col_phone,
            l10n.admin_col_start_date,
            l10n.admin_status_label,
          ];
          tableData = reqs
              .map(
                (r) => [
                  r.requestNumber,
                  r.propertyTitle ?? r.propertyId,
                  r.fullName,
                  r.phone,
                  r.requestedStartDate?.toIso8601String().split('T').first ??
                      '-',
                  AppConstants.getRentalRequestStatusNameAr(r.status),
                ],
              )
              .toList();
          break;

        case 2: // Commissions
          final comms = await ref.read(adminCommissionsProvider.future);
          tableHeaders = [
            l10n.admin_col_id,
            l10n.admin_property_label,
            l10n.admin_liable_party,
            l10n.admin_col_amount,
            l10n.admin_currency,
            l10n.admin_col_settlement_status,
          ];
          tableData = comms
              .map(
                (c) => [
                  c.id,
                  c.propertyTitle ?? c.propertyId,
                  AppConstants.getLiablePartyNameAr(c.liableParty),
                  Formatters.formatCurrency(c.totalAmount, c.currency),
                  c.currency,
                  AppConstants.getCommissionStatusNameAr(c.settlementStatus),
                ],
              )
              .toList();
          break;

        case 3: // Reports
          final reps = await ref.read(adminReportsProvider.future);
          tableHeaders = [
            l10n.admin_col_id,
            l10n.admin_col_property_id,
            l10n.admin_col_report_reason,
            l10n.admin_status_label,
            l10n.admin_col_report_date,
          ];
          tableData = reps
              .map(
                (rp) => [
                  rp.id,
                  rp.propertyId,
                  rp.reason,
                  rp.status == 'pending'
                      ? l10n.admin_status_under_review
                      : l10n.admin_status_resolved,
                  rp.createdAt.toIso8601String().split('T').first,
                ],
              )
              .toList();
          break;

        case 4: // Users
        default:
          final users = await ref.read(allUsersProvider.future);
          tableHeaders = [
            l10n.admin_col_number,
            l10n.admin_col_username,
            l10n.admin_col_account_email,
            l10n.admin_col_encryption_status,
            l10n.admin_created_at,
          ];
          tableData = users.asMap().entries.map((entry) {
            final u = entry.value;
            final account =
                u.email ??
                (u.phone != null && u.phone!.isNotEmpty ? u.phone! : u.id);
            return [
              '${entry.key + 1}',
              u.fullName,
              account,
              l10n.admin_encrypted_protected_pdf,
              u.createdAt.toString().split(' ').first,
            ];
          }).toList();
          break;
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          textDirection: pdfDirection,
          margin: const pw.EdgeInsets.all(24),
          build: (pw.Context ctx) {
            return [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      l10n.admin_pdf_bismillah,
                      style: pw.TextStyle(font: fontCairoBold, fontSize: 11),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      l10n.admin_pdf_republic,
                      style: pw.TextStyle(
                        font: fontCairoBold,
                        fontSize: 13,
                        color: PdfColors.green900,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      l10n.admin_pdf_report_header,
                      style: pw.TextStyle(font: fontCairoBold, fontSize: 11),
                    ),
                    pw.Divider(thickness: 0.5, color: PdfColors.grey400),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          '${l10n.admin_pdf_section}: $sectionTitle',
                          style: pw.TextStyle(
                            font: fontCairoBold,
                            fontSize: 10,
                            color: PdfColors.green800,
                          ),
                        ),
                        pw.Text(
                          l10n.admin_pdf_issuer,
                          style: pw.TextStyle(font: fontCairo, fontSize: 9.5),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    // تفاصيل الوقت واليوم والشهر والسنة
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey200,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            '${l10n.admin_pdf_day_label}: $dayName',
                            style: pw.TextStyle(
                              font: fontCairoBold,
                              fontSize: 8.5,
                            ),
                          ),
                          pw.Text(
                            '${l10n.admin_pdf_date_label}: $dayNum',
                            style: pw.TextStyle(
                              font: fontCairoBold,
                              fontSize: 8.5,
                            ),
                          ),
                          pw.Text(
                            '${l10n.admin_pdf_month_label}: $monthName (${now.month})',
                            style: pw.TextStyle(
                              font: fontCairoBold,
                              fontSize: 8.5,
                            ),
                          ),
                          pw.Text(
                            '${l10n.admin_pdf_year_label}: $yearNum ${l10n.admin_pdf_year_suffix}',
                            style: pw.TextStyle(
                              font: fontCairoBold,
                              fontSize: 8.5,
                            ),
                          ),
                          pw.Text(
                            '${l10n.admin_pdf_time_label}: $timeFormatted',
                            style: pw.TextStyle(
                              font: fontCairoBold,
                              fontSize: 8.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),

              // KPI Summary
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    '${l10n.admin_pdf_total_items}: ${tableData.length}',
                    style: pw.TextStyle(font: fontCairoBold, fontSize: 10),
                  ),
                  pw.Text(
                    l10n.admin_pdf_data_status,
                    style: pw.TextStyle(
                      font: fontCairo,
                      fontSize: 9,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),

              // Detailed Table
              pw.Table.fromTextArray(
                headers: tableHeaders,
                data: tableData.isEmpty
                    ? [
                        List.generate(
                          tableHeaders.length,
                          (_) => l10n.admin_pdf_no_data,
                        ),
                      ]
                    : tableData,
                headerStyle: pw.TextStyle(
                  font: fontCairoBold,
                  fontSize: 8.5,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.green800,
                ),
                cellStyle: pw.TextStyle(font: fontCairo, fontSize: 7.5),
                cellAlignment: cellAlignment,
                cellPadding: const pw.EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 4,
                ),
              ),

              pw.SizedBox(height: 20),

              // Footer
              pw.Divider(thickness: 0.5, color: PdfColors.grey400),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    l10n.admin_pdf_copyright,
                    style: pw.TextStyle(
                      font: fontCairo,
                      fontSize: 7.5,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.Text(
                    l10n.admin_pdf_doc_footer,
                    style: pw.TextStyle(
                      font: fontCairo,
                      fontSize: 7.5,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            ];
          },
        ),
      );

      final pdfBytes = await pdf.save();

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

      final filename =
          '${l10n.admin_report_filename_prefix}${sectionTitle.replaceAll(" ", "_")}_${now.year}_${now.month}_${now.day}_${now.hour}${now.minute}.pdf';
      final file = File('${dir!.path}/$filename');
      await file.writeAsBytes(pdfBytes);

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (dialogCtx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.picture_as_pdf,
                  color: AppColors.primaryInk,
                  size: 26,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.admin_pdf_export_success,
                    style: AppFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.admin_pdf_saved_prefix}$sectionTitle${l10n.admin_pdf_saved_suffix}',
                  style: AppFonts.cairo(fontSize: 13),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.admin_pdf_file_name,
                        style: AppFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        filename,
                        style: AppFonts.cairo(
                          fontSize: 11,
                          color: AppColors.primaryInk,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.admin_pdf_save_path,
                        style: AppFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      SelectableText(
                        file.path,
                        style: const TextStyle(
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton.icon(
                icon: const Icon(Icons.copy, size: 16),
                label: Text(l10n.admin_copy_path, style: AppFonts.cairo()),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: file.path));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.admin_path_copied,
                        style: AppFonts.cairo(),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: Text(
                  l10n.admin_ok,
                  style: AppFonts.cairo(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${l10n.admin_export_failed}: $e',
              style: AppFonts.cairo(),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
