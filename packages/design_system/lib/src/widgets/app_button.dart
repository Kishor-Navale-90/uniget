import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, destructive }

/// Every "Approve", "Transfer", "Check In" action across the app uses
/// this instead of raw ElevatedButton/OutlinedButton calls, so button
/// styling is a one-place change, not a 100-screen find-and-replace.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : Text(label);

    return switch (variant) {
      AppButtonVariant.primary => ElevatedButton(onPressed: isLoading ? null : onPressed, child: child),
      AppButtonVariant.secondary => OutlinedButton(onPressed: isLoading ? null : onPressed, child: child),
      AppButtonVariant.destructive => ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
          onPressed: isLoading ? null : onPressed,
          child: child,
        ),
    };
  }
}
