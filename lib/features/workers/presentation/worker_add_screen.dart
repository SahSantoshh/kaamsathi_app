import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:kaamsathi/l10n/app_localizations.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../features/auth/data/auth_api.dart';
import '../../../shared/widgets/kaam_phone_field.dart';
import '../data/workers_mock_data.dart';
import '../domain/worker_models.dart';
import 'worker_ui_helpers.dart';

class WorkerAddScreen extends StatefulWidget {
  const WorkerAddScreen({super.key, required this.orgId});

  final String orgId;

  static const String name = RouteNames.workerAdd;

  @override
  State<WorkerAddScreen> createState() => _WorkerAddScreenState();
}

class _WorkerAddScreenState extends State<WorkerAddScreen> {
  final TextEditingController _phone = TextEditingController();
  PhoneNumber? _phoneNumber;
  bool _searching = false;
  WorkerDetail? _match;

  @override
  void initState() {
    super.initState();
    _phone.addListener(() => setState(() {}));
  }

  Future<void> _search(AppLocalizations l10n) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _searching = true;
      _match = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) {
      return;
    }
    final String e164 = AuthApi.phoneNumberToE164(_phoneNumber!);
    setState(() {
      _searching = false;
      _match = WorkersMockData.searchByPhone(e164);
    });
  }

  void _confirmAdd(AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.workersSnackbarAdded)),
    );
    context.pop();
  }

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pgWorkerAdd)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: <Widget>[
          Text(
            l10n.workersSearchByPhoneTitle,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.workersSearchByPhoneSubtitle,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          KaamPhoneField(
            controller: _phone,
            onPhoneUpdate: (PhoneNumber phone) =>
                setState(() => _phoneNumber = phone),
            decoration: InputDecoration(
              labelText: l10n.authPhoneHint,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: _searching ||
                    _phone.text.replaceAll(RegExp(r'\D'), '').length < 8
                ? null
                : () => _search(l10n),
            child: _searching
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(Icons.search_rounded, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Text(l10n.workersSearchButton),
                    ],
                  ),
          ),
          if (_match != null) ...<Widget>[
            const SizedBox(height: AppSpacing.xl),
            Text(
              l10n.workersSearchMatchTitle,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.workersSearchMatchSubtitle,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Material(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 28,
                      backgroundColor:
                          scheme.primaryContainer.withValues(alpha: 0.9),
                      child: Text(
                        workerInitials(_match!.displayName),
                        style: textTheme.titleMedium?.copyWith(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            _match!.displayName,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _match!.phoneE164,
                            style: textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 6),
                          workerStatusChip(context, _match!.statusLabel),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: () => _confirmAdd(l10n),
              child: Text(l10n.workersAddToOrganization),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          Text(
            l10n.workersDemoBadge,
            style: textTheme.labelSmall?.copyWith(color: scheme.outline),
          ),
        ],
      ),
    );
  }
}
