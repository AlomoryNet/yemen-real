import 'package:flutter/material.dart';
import 'empty_state_view.dart';
import 'loading_view.dart';

/// Loads a deferred route library once, then builds the screen.
///
/// On Flutter web this keeps admin/map code out of the initial bundle. On
/// native platforms `loadLibrary()` completes immediately, so behaviour is
/// unchanged apart from a single loading frame.
class DeferredScreen extends StatefulWidget {
  const DeferredScreen({
    super.key,
    required this.load,
    required this.builder,
    required this.loadingText,
    required this.errorText,
    required this.retryText,
  });

  final Future<void> Function() load;
  final Widget Function() builder;
  final String loadingText;
  final String errorText;
  final String retryText;

  @override
  State<DeferredScreen> createState() => _DeferredScreenState();
}

class _DeferredScreenState extends State<DeferredScreen> {
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = widget.load();
  }

  void _retry() {
    setState(() {
      _loadFuture = widget.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(body: LoadingView(message: widget.loadingText));
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: EmptyStateView(
              icon: Icons.error_outline,
              title: widget.errorText,
              actionText: widget.retryText,
              onAction: _retry,
            ),
          );
        }
        return widget.builder();
      },
    );
  }
}
