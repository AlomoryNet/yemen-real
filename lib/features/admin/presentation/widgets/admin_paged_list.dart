import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/l10n/context_l10n.dart';
import '../../../../core/theme/app_colors.dart';

/// A bounded list for the admin tables.
///
/// With only [items] and [itemBuilder], this reveals a prefix of a full list
/// (the legacy behavior). When [onLoadMore] is supplied, the list renders only
/// the rows that were actually fetched and asks the caller for the next page.
/// CSV/PDF exports always use separate full-list providers.
class AdminPagedList<T> extends StatefulWidget {
  const AdminPagedList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.separatorBuilder,
    this.pageSize = 12,
    this.hasMore,
    this.isLoadingMore = false,
    this.onLoadMore,
  });

  /// Loaded rows. With external paging this is already a bounded page.
  final List<T> items;

  /// Builds one row. [index] is the index within [items].
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// Optional separator between rows. Defaults to a hairline divider.
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  /// Number of rows revealed per tap when using the legacy prefix mode.
  final int pageSize;

  /// Whether the caller has another page to fetch. Ignored in prefix mode.
  final bool? hasMore;

  /// Shows a spinner in the button while an external page request is running.
  final bool isLoadingMore;

  /// When provided, the button fetches more rows instead of revealing a prefix.
  final Future<void> Function()? onLoadMore;

  @override
  State<AdminPagedList<T>> createState() => _AdminPagedListState<T>();
}

class _AdminPagedListState<T> extends State<AdminPagedList<T>> {
  late int _visibleCount = widget.pageSize;

  bool get _usesExternalPaging => widget.onLoadMore != null;

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
    final external = _usesExternalPaging;
    final visibleCount = external
        ? widget.items.length
        : math.min(_visibleCount, widget.items.length);
    final hasMore = external
        ? (widget.hasMore ?? true)
        : visibleCount < widget.items.length;
    final loading = external && widget.isLoadingMore;

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
              onPressed: loading
                  ? null
                  : () {
                      if (external) {
                        widget.onLoadMore!();
                      } else {
                        setState(() {
                          _visibleCount = math.min(
                            _visibleCount + widget.pageSize,
                            widget.items.length,
                          );
                        });
                      }
                    },
              icon: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.expand_more_rounded, size: 18),
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
