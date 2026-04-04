import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import 'kaam_error_banner.dart';

/// Loading / error / data pattern for lists and detail screens (doc §12).
class KaamAsyncBody<T> extends StatelessWidget {
  const KaamAsyncBody({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.data,
    required this.dataBuilder,
    this.onRetry,
    this.retryLabel,
    this.padding = const EdgeInsets.all(AppSpacing.md),
  });

  final bool isLoading;
  final String? errorMessage;
  final T? data;
  final Widget Function(BuildContext context, T data) dataBuilder;
  final VoidCallback? onRetry;
  final String? retryLabel;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final String? err = errorMessage;
    if (err != null && err.isNotEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: padding,
          child: KaamErrorBanner(
            message: err,
            onRetry: onRetry,
            retryLabel: retryLabel,
          ),
        ),
      );
    }
    final T? value = data;
    if (value != null) {
      return Padding(padding: padding, child: dataBuilder(context, value));
    }
    return SizedBox.expand(
      child: Padding(
        padding: padding,
        child: Center(
          child: Text(
            'No data',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
