import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kaamsathi/l10n/app_localizations.dart';

import '../../../core/router/app_paths.dart';
import '../../../core/router/route_names.dart';
import '../../../core/session/app_membership_role.dart';
import '../../../core/session/auth_session_notifier.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/widgets.dart';
import '../../organization_switcher/data/select_org_data_provider.dart';
import '../data/organization_detail_provider.dart';
import '../data/organizations_api.dart';
import '../data/organizations_api_provider.dart';

class OrgProfileScreen extends ConsumerWidget {
  const OrgProfileScreen({super.key, required this.orgId});

  final String orgId;

  static const String name = RouteNames.orgProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AppMembershipRole role = ref.watch(authSessionProvider).role;
    final bool canEdit = role == AppMembershipRole.manager;
    final AsyncValue<OrganizationEntity> asyncOrg = ref.watch(
      organizationDetailProvider(orgId),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pgOrgProfile), centerTitle: true),
      body: asyncOrg.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object _, StackTrace stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(l10n.orgProfileLoadError, textAlign: TextAlign.center),
          ),
        ),
        data: (OrganizationEntity o) =>
            _OrgProfileLoaded(orgId: orgId, initial: o, canEdit: canEdit),
      ),
    );
  }
}

String _formatAddress(OrganizationEntity o) {
  if (o.addressSingleLine != null && o.addressSingleLine!.trim().isNotEmpty) {
    return o.addressSingleLine!.trim();
  }
  return <String?>[
    o.addressLine1,
    o.city,
    o.region,
    o.postalCode,
    o.countryCode,
  ].whereType<String>().where((String x) => x.trim().isNotEmpty).join(', ');
}

class _OrgProfileLoaded extends ConsumerStatefulWidget {
  const _OrgProfileLoaded({
    required this.orgId,
    required this.initial,
    required this.canEdit,
  });

  final String orgId;
  final OrganizationEntity initial;
  final bool canEdit;

  @override
  ConsumerState<_OrgProfileLoaded> createState() => _OrgProfileLoadedState();
}

class _OrgProfileLoadedState extends ConsumerState<_OrgProfileLoaded> {
  static const List<String> _standardFrequencies = <String>[
    'monthly',
    'weekly',
    'biweekly',
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _name;
  late TextEditingController _address;
  late TextEditingController _anchorDay;
  String? _organizationType;
  late String _payFrequency;
  bool _editing = false;
  bool _saving = false;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    final OrganizationEntity o = widget.initial;
    _name = TextEditingController(text: o.name);
    _address = TextEditingController(text: _formatAddress(o));
    _anchorDay = TextEditingController(text: '${o.payScheduleAnchorDay()}');
    _organizationType = o.organizationType;
    _payFrequency = o.payScheduleFrequencyLabel();
  }

  @override
  void didUpdateWidget(_OrgProfileLoaded oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_editing) {
      final OrganizationEntity a = oldWidget.initial;
      final OrganizationEntity b = widget.initial;
      if (a.name != b.name ||
          _formatAddress(a) != _formatAddress(b) ||
          a.organizationType != b.organizationType ||
          a.payScheduleFrequencyLabel() != b.payScheduleFrequencyLabel() ||
          a.payScheduleAnchorDay() != b.payScheduleAnchorDay()) {
        _syncFromEntity(b);
      }
    }
  }

  void _syncFromEntity(OrganizationEntity o) {
    _name.text = o.name;
    _address.text = _formatAddress(o);
    _organizationType = o.organizationType;
    _payFrequency = o.payScheduleFrequencyLabel();
    _anchorDay.text = '${o.payScheduleAnchorDay()}';
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _anchorDay.dispose();
    super.dispose();
  }

  String _frequencyTitle(String v, AppLocalizations l10n) {
    switch (v) {
      case 'monthly':
        return l10n.orgPayFrequencyMonthly;
      case 'weekly':
        return l10n.orgPayFrequencyWeekly;
      case 'biweekly':
        return l10n.orgPayFrequencyBiweekly;
      default:
        return l10n.orgPayFrequencyCustom(v);
    }
  }

  List<DropdownMenuItem<String>> _payFrequencyItems(AppLocalizations l10n) {
    final List<String> values = <String>[];
    if (!_standardFrequencies.contains(_payFrequency)) {
      values.add(_payFrequency);
    }
    values.addAll(_standardFrequencies);
    return values
        .map(
          (String v) => DropdownMenuItem<String>(
            value: v,
            child: Text(_frequencyTitle(v, l10n)),
          ),
        )
        .toList();
  }

  Map<String, dynamic> _payScheduleForSave(OrganizationEntity o) {
    final Map<String, dynamic> merged = Map<String, dynamic>.from(
      o.payScheduleMap,
    );
    merged['frequency'] = _payFrequency;
    final int? parsed = int.tryParse(_anchorDay.text.trim());
    int day = parsed ?? OrganizationPayScheduleDefaults.v1AnchorDay;
    if (day < 1) {
      day = 1;
    }
    if (day > 31) {
      day = 31;
    }
    merged['anchor_day'] = day;
    return merged;
  }

  String? _validateAnchor(String? v, AppLocalizations l10n) {
    final int? n = int.tryParse((v ?? '').trim());
    if (n == null || n < 1 || n > 31) {
      return l10n.orgPayScheduleAnchorDayError;
    }
    return null;
  }

  Future<void> _save(AppLocalizations l10n) async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _saving = true);
    try {
      final OrganizationsApi api = ref.read(organizationsApiProvider);
      await api.updateOrganization(
        id: widget.orgId,
        name: _name.text.trim(),
        addressString: _address.text.trim().isEmpty ? '' : _address.text.trim(),
        patchOrganizationType: true,
        organizationType: _organizationType,
        paySchedule: _payScheduleForSave(widget.initial),
      );
      ref.invalidate(organizationDetailProvider(widget.orgId));
      if (mounted) {
        setState(() => _editing = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.orgProfileSavedSnackbar)));
      }
    } on OrganizationsApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.orgProfileLoadError)));
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _confirmDelete(AppLocalizations l10n) async {
    final bool ok = await showDestructiveConfirmDialog(
      context,
      title: l10n.orgDeleteConfirmTitle,
      message: l10n.orgDeleteConfirmMessage,
      cancelLabel: MaterialLocalizations.of(context).cancelButtonLabel,
      confirmLabel: l10n.orgDeleteConfirmCta,
    );
    if (!ok || !mounted) {
      return;
    }
    setState(() => _deleting = true);
    try {
      final OrganizationsApi api = ref.read(organizationsApiProvider);
      await api.deleteOrganization(widget.orgId);
      await ref
          .read(authSessionProvider.notifier)
          .onOrganizationDeleted(widget.orgId);
      ref.invalidate(selectOrgDataProvider);
      ref.invalidate(defaultOrganizationIdProvider);
      ref.invalidate(organizationDetailProvider(widget.orgId));
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.orgDeletedSnackbar)));
        context.go(AppPaths.selectOrganization);
      }
    } on OrganizationsApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.orgDeleteError)));
      }
    } finally {
      if (mounted) {
        setState(() => _deleting = false);
      }
    }
  }

  Widget _metaCard(BuildContext context, OrganizationEntity o) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final DateTime? created = o.createdAt;
    final String createdLabel = created != null
        ? DateFormat.yMMMd().format(created.toLocal())
        : l10n.orgMetaUnknown;

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.orgVerificationStatus,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text(
              (o.verificationStatus?.trim().isNotEmpty ?? false)
                  ? o.verificationStatus!.trim()
                  : l10n.orgMetaUnknown,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.orgCreatedAt,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text(createdLabel, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }

  Widget _payScheduleSection(
    BuildContext context,
    OrganizationEntity o,
    AppLocalizations l10n,
  ) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.orgPayScheduleSection,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.orgPayScheduleHelper,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (!_editing || !widget.canEdit) ...<Widget>[
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.orgPayScheduleFrequency),
                subtitle: Text(
                  _frequencyTitle(o.payScheduleFrequencyLabel(), l10n),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.orgPayScheduleAnchorDay),
                subtitle: Text('${o.payScheduleAnchorDay()}'),
              ),
            ] else ...<Widget>[
              DropdownButtonFormField<String>(
                key: ValueKey<String>('pay_freq_$_payFrequency'),
                initialValue: _payFrequency,
                decoration: InputDecoration(
                  labelText: l10n.orgPayScheduleFrequency,
                  border: const OutlineInputBorder(),
                ),
                items: _payFrequencyItems(l10n),
                onChanged: _saving || _deleting
                    ? null
                    : (String? v) {
                        if (v != null) {
                          setState(() => _payFrequency = v);
                        }
                      },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _anchorDay,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.orgPayScheduleAnchorDay,
                  border: const OutlineInputBorder(),
                ),
                validator: (String? v) => _validateAnchor(v, l10n),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final OrganizationEntity o = widget.initial;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                l10n.dashboardCurrentOrgLabel,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            if (widget.canEdit)
              TextButton.icon(
                onPressed: _saving || _deleting
                    ? null
                    : () {
                        setState(() {
                          _editing = !_editing;
                          if (!_editing) {
                            _syncFromEntity(o);
                          }
                        });
                      },
                icon: Icon(_editing ? Icons.close : Icons.edit_outlined),
                label: Text(
                  _editing
                      ? MaterialLocalizations.of(context).cancelButtonLabel
                      : l10n.orgProfileEdit,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (!widget.canEdit)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Text(
              l10n.orgProfileReadOnly,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        _metaCard(context, o),
        const SizedBox(height: AppSpacing.md),
        _payScheduleSection(context, o, l10n),
        const SizedBox(height: AppSpacing.lg),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                l10n.pgOrgProfile,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _name,
                readOnly: !widget.canEdit || !_editing,
                decoration: InputDecoration(
                  labelText: l10n.orgFieldName,
                  border: const OutlineInputBorder(),
                ),
                validator: (String? v) {
                  if (v == null || v.trim().isEmpty) {
                    return l10n.orgCreateNameValidation;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              if (widget.canEdit && _editing)
                DropdownButtonFormField<String?>(
                  initialValue: _organizationType,
                  decoration: InputDecoration(
                    labelText: l10n.orgFieldType,
                    border: const OutlineInputBorder(),
                  ),
                  items: <DropdownMenuItem<String?>>[
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(l10n.orgCreateTypeNone),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'contractor',
                      child: Text(l10n.orgCreateTypeContractor),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'company',
                      child: Text(l10n.orgCreateTypeCompany),
                    ),
                  ],
                  onChanged: _saving || _deleting
                      ? null
                      : (String? v) => setState(() => _organizationType = v),
                )
              else if (o.organizationType != null &&
                  o.organizationType!.isNotEmpty) ...<Widget>[
                Text(
                  l10n.orgFieldType,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  o.organizationType!,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _address,
                readOnly: !widget.canEdit || !_editing,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.orgFieldAddress,
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              if (widget.canEdit && _editing) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: (_saving || _deleting) ? null : () => _save(l10n),
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.orgProfileSave),
                ),
              ],
            ],
          ),
        ),
        if (widget.canEdit) ...<Widget>[
          const SizedBox(height: AppSpacing.xl),
          Text(
            l10n.orgDelete,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: scheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: _saving || _deleting ? null : () => _confirmDelete(l10n),
            icon: _deleting
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: scheme.error,
                    ),
                  )
                : Icon(Icons.delete_outline_rounded, color: scheme.error),
            label: Text(l10n.orgDelete),
            style: OutlinedButton.styleFrom(
              foregroundColor: scheme.error,
              side: BorderSide(color: scheme.error.withValues(alpha: 0.6)),
            ),
          ),
        ],
      ],
    );
  }
}
