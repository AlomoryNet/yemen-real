import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/l10n/context_l10n.dart';
import '../../../../core/theme/app_colors.dart';

/// A bounded list for the admin tables.
///
/// Admin data sources can contain hundreds of rows (the demo catalog alone has
/// 440 properties). Building all of them at once makes the dashboard sluggish
/// and buries the other sections. This widget shows [pageSize] rows initially
/// and reveals more on demand, while callers keep access to the full list for
/// CSV/PDF export.
class AdminPagedList<T> extends StatefulWidget {
  const AdminPagedList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.separatorBuilder,
    this.pageSize = 12,
  });

  /// Full, unfiltered data source (only a prefix is built at any time).
  final List<T> items;

  /// Builds one row. [index] is the index within [items].
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// Optional separator between rows. Defaults to a hairline divider.
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  /// Number of rows revealed per "Load more" tap.
  final int pageSize;

  @override
  State<AdminPagedList<T>> createState() => _AdminPagedListState<T>();
}

class _AdminPagedListState<T> extends State<AdminPagedList<T>> {
  late int _visibleCount = widget.pageSize;

  @override
  void didUpdateWidget(covariant AdminPagedList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.items, widget.items)) {
      // Keep the reader's place when a refresh swaps in a new list instance.
      _visibleCount = math.min(_visibleCount, widget.items.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleCount = math.min(_visibleCount, widget.items.length);
    final hasMore = visibleCount < widget.items.length;

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            itemCount: visibleCount,
            separatorBuilder:
                widget.separatorBuilder ?? (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) =>
                widget.itemBuilder(context, widget.items[index], index),
          ),
        ),
        if (hasMore)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: OutlinedButton.icon(
              onPressed: () => setState(() {
                _visibleCount = math.min(
                  _visibleCount + widget.pageSize,
                  widget.items.length,
                );
              }),
              icon: const Icon(Icons.expand_more_rounded, size: 18),
              label: Text(context.l10n.map_load_more),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryInk,
                side: BorderSide(color: AppColors.divider),
              ),
            ),
          ),
      ],
    );
  }
}
