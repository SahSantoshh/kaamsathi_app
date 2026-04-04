import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:kaamsathi/l10n/app_localizations.dart';

import '../../../core/phone/e164_lookup.dart';
import '../../../core/router/app_paths.dart';
import '../../../core/router/route_names.dart';
import '../../../features/auth/data/auth_api_provider.dart';
import '../../../core/session/auth_session_notifier.dart';
import '../../../core/session/auth_state.dart';
import '../../../core/theme/app_spacing.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const String name = RouteNames.profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    final AuthState session = ref.watch(authSessionProvider);
    final Map<String, dynamic>? me = session.meProfile;
    final List<Map<String, dynamic>> memberships =
        List<Map<String, dynamic>>.from(session.memberships);
    final String? selectedOrgId = session.selectedOrganizationId;

    final List<Map<String, dynamic>> phones = _phoneEntries(me?['user_phone_numbers']);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pgProfile),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        children: <Widget>[
          if (me == null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Text(
                l10n.profileMeDataHint,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ),
          if (me != null) ...<Widget>[
            _ProfileHeaderCard(
              me: me,
              theme: theme,
              scheme: scheme,
            ),
            const SizedBox(height: AppSpacing.lg),
            _SectionTitle(label: l10n.profileSectionAccount, theme: theme),
            const SizedBox(height: AppSpacing.sm),
            _AccountDetailsCard(
              me: me,
              l10n: l10n,
              scheme: scheme,
              theme: theme,
            ),
            const SizedBox(height: AppSpacing.lg),
            _SectionTitle(label: l10n.pgProfilePhones, theme: theme),
            const SizedBox(height: AppSpacing.sm),
            _PhonesCard(
              phones: phones,
              l10n: l10n,
              scheme: scheme,
              theme: theme,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.settings_phone_outlined),
              title: Text(l10n.profileOpenPhoneSettings),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppPaths.profilePhones),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          _SectionTitle(label: l10n.profileSectionOrganizations, theme: theme),
          const SizedBox(height: AppSpacing.sm),
          if (memberships.isEmpty)
            Text(
              l10n.profileNoMembershipsDetail,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.45,
              ),
            )
          else
            ...memberships.map(
              (Map<String, dynamic> m) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _MembershipCard(
                  membership: m,
                  l10n: l10n,
                  theme: theme,
                  scheme: scheme,
                  isCurrentWorkspace: _orgId(m) == selectedOrgId,
                  onOpenOrg: () {
                    final String? id = _orgId(m);
                    if (id != null && context.mounted) {
                      context.push(AppPaths.orgProfile(id));
                    }
                  },
                ),
              ),
            ),
          if (session.isAuthenticated) ...<Widget>[
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: scheme.error,
                  side: BorderSide(
                    color: scheme.error.withValues(alpha: 0.55),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.md,
                    horizontal: AppSpacing.lg,
                  ),
                ),
                onPressed: () async {
                  final String? t = session.accessToken;
                  if (t != null && t.isNotEmpty) {
                    await ref.read(authApiProvider).logout(t);
                  }
                  await ref.read(authSessionProvider.notifier).signOut();
                  if (context.mounted) {
                    context.go(AppPaths.login);
                  }
                },
                icon: const Icon(Icons.logout_rounded),
                label: Text(l10n.sessionSignOut),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

List<Map<String, dynamic>> _phoneEntries(Object? raw) {
  if (raw is! List<dynamic>) {
    return <Map<String, dynamic>>[];
  }
  final List<Map<String, dynamic>> out = <Map<String, dynamic>>[];
  for (final Object? item in raw) {
    if (item is Map<String, dynamic>) {
      out.add(Map<String, dynamic>.from(item));
    } else if (item is Map) {
      out.add(
        Map<String, dynamic>.from(
          item.map((Object? k, Object? v) => MapEntry(k.toString(), v)),
        ),
      );
    }
  }
  return out;
}

String? _orgId(Map<String, dynamic> membership) {
  final Object? org = membership['organization'];
  if (org is Map<String, dynamic>) {
    return org['id'] as String?;
  }
  if (org is Map) {
    return org['id'] as String?;
  }
  return null;
}

Map<String, dynamic>? _orgMap(Map<String, dynamic> membership) {
  final Object? org = membership['organization'];
  if (org is Map<String, dynamic>) {
    return Map<String, dynamic>.from(org);
  }
  if (org is Map) {
    return Map<String, dynamic>.from(
      org.map((Object? k, Object? v) => MapEntry(k.toString(), v)),
    );
  }
  return null;
}

String? _nonEmptyField(Map<String, dynamic> me, String key) {
  final Object? raw = me[key];
  if (raw == null) {
    return null;
  }
  final String s = raw.toString().trim();
  return s.isEmpty ? null : s;
}

String? _legalNameLine(Map<String, dynamic> me) {
  final String? fn = _nonEmptyField(me, 'first_name');
  final String? mn = _nonEmptyField(me, 'middle_name');
  final String? ln = _nonEmptyField(me, 'last_name');
  final List<String> parts = <String>[
    ?fn,
    ?mn,
    ?ln,
  ];
  if (parts.isEmpty) {
    return null;
  }
  return parts.join(' ');
}

String _displayName(Map<String, dynamic> me) {
  final String? full = me['full_name'] as String?;
  if (full != null && full.trim().isNotEmpty) {
    return full.trim();
  }
  final String? legal = _legalNameLine(me);
  if (legal != null) {
    return legal;
  }
  final String? email = me['email'] as String?;
  if (email != null && email.trim().isNotEmpty) {
    return email.trim();
  }
  return '';
}

String _initialsForProfile(Map<String, dynamic> me) {
  final String name = _displayName(me);
  if (name.isNotEmpty) {
    final List<String> parts =
        name.split(RegExp(r'\s+')).where((String s) => s.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    if (parts.isNotEmpty) {
      final String p = parts.first;
      if (p.length >= 2) {
        return p.substring(0, 2).toUpperCase();
      }
      return p[0].toUpperCase();
    }
  }
  final String? email = me['email'] as String?;
  final String e = (email ?? '').trim();
  if (e.length >= 2) {
    return e.substring(0, 2).toUpperCase();
  }
  return '?';
}

String? _formatIso(BuildContext context, String? raw) {
  if (raw == null || raw.isEmpty) {
    return null;
  }
  final DateTime? parsed = DateTime.tryParse(raw);
  if (parsed == null) {
    return raw;
  }
  final String localeName = Localizations.localeOf(context).toString();
  return DateFormat.yMMMd(localeName).add_jm().format(parsed.toLocal());
}

String? _userAddressLine(dynamic address) {
  if (address == null) {
    return null;
  }
  if (address is String) {
    final String t = address.trim();
    return t.isEmpty ? null : t;
  }
  if (address is Map) {
    final Map<String, dynamic> m = Map<String, dynamic>.from(
      address.map((Object? k, Object? v) => MapEntry(k.toString(), v)),
    );
    final List<String?> candidates = <String?>[
      m['line1'] as String?,
      m['line_1'] as String?,
      m['street'] as String?,
      m['city'] as String?,
      m['region'] as String?,
      m['state'] as String?,
      m['postal_code'] as String?,
      m['country'] as String?,
      m['country_code'] as String?,
    ];
    final List<String> parts = candidates
        .whereType<String>()
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return null;
    }
    return parts.join(', ');
  }
  return null;
}

String _payFrequencyLabel(AppLocalizations l10n, String? raw) {
  switch ((raw ?? '').toLowerCase()) {
    case 'monthly':
      return l10n.orgPayFrequencyMonthly;
    case 'weekly':
      return l10n.orgPayFrequencyWeekly;
    case 'biweekly':
      return l10n.orgPayFrequencyBiweekly;
    default:
      return l10n.orgPayFrequencyCustom(raw ?? l10n.orgMetaUnknown);
  }
}

String _titleCaseRole(String? raw) {
  if (raw == null || raw.isEmpty) {
    return '—';
  }
  final String s = raw.toLowerCase();
  return s.length == 1 ? s.toUpperCase() : '${s[0].toUpperCase()}${s.substring(1)}';
}

String _orgTypeDisplay(AppLocalizations l10n, String? raw) {
  switch ((raw ?? '').toLowerCase()) {
    case 'contractor':
      return l10n.orgCreateTypeContractor;
    case 'company':
      return l10n.orgCreateTypeCompany;
    case 'none':
      return l10n.orgCreateTypeNone;
    default:
      return _titleCaseRole(raw);
  }
}

(Color bg, Color fg) _verificationColors(ColorScheme scheme, String? raw) {
  switch ((raw ?? '').toLowerCase()) {
    case 'verified':
      return (scheme.primaryContainer, scheme.onPrimaryContainer);
    case 'pending':
      return (scheme.tertiaryContainer, scheme.onTertiaryContainer);
    case 'rejected':
    case 'failed':
      return (scheme.errorContainer, scheme.onErrorContainer);
    default:
      return (
        scheme.surfaceContainerHighest,
        scheme.onSurfaceVariant,
      );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label, required this.theme});

  final String label;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({
    required this.me,
    required this.theme,
    required this.scheme,
  });

  final Map<String, dynamic> me;
  final ThemeData theme;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final String title = _displayName(me);
    final String? email = me['email'] as String?;
    final String initials = _initialsForProfile(me);

    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 36,
              backgroundColor: scheme.primaryContainer,
              foregroundColor: scheme.onPrimaryContainer,
              child: Text(
                initials,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (title.isNotEmpty)
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (email != null && email.trim().isNotEmpty) ...<Widget>[
                    if (title.isNotEmpty) const SizedBox(height: 4),
                    Text(
                      email.trim(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountDetailsCard extends StatelessWidget {
  const _AccountDetailsCard({
    required this.me,
    required this.l10n,
    required this.scheme,
    required this.theme,
  });

  final Map<String, dynamic> me;
  final AppLocalizations l10n;
  final ColorScheme scheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final String? id = me['id'] as String?;
    final String? created = _formatIso(context, me['created_at'] as String?);
    final String? address = _userAddressLine(me['address']);
    final String? fullName = _nonEmptyField(me, 'full_name');
    final String? firstName = _nonEmptyField(me, 'first_name');
    final String? middleName = _nonEmptyField(me, 'middle_name');
    final String? lastName = _nonEmptyField(me, 'last_name');

    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Column(
          children: <Widget>[
            if (fullName != null)
              _MetaRow(
                label: l10n.profileFieldFullName,
                value: fullName,
                theme: theme,
                scheme: scheme,
              ),
            if (firstName != null)
              _MetaRow(
                label: l10n.profileFieldFirstName,
                value: firstName,
                theme: theme,
                scheme: scheme,
              ),
            if (middleName != null)
              _MetaRow(
                label: l10n.profileFieldMiddleName,
                value: middleName,
                theme: theme,
                scheme: scheme,
              ),
            if (lastName != null)
              _MetaRow(
                label: l10n.profileFieldLastName,
                value: lastName,
                theme: theme,
                scheme: scheme,
              ),
            if (id != null && id.isNotEmpty)
              _MetaRow(
                label: l10n.profileFieldUserId,
                value: id,
                monospace: true,
                theme: theme,
                scheme: scheme,
              ),
            if (created != null)
              _MetaRow(
                label: l10n.profileFieldMemberSince,
                value: created,
                theme: theme,
                scheme: scheme,
              ),
            if (address != null)
              _MetaRow(
                label: l10n.orgFieldAddress,
                value: address,
                theme: theme,
                scheme: scheme,
              ),
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.label,
    required this.value,
    required this.theme,
    required this.scheme,
    this.monospace = false,
  });

  final String label;
  final String value;
  final ThemeData theme;
  final ColorScheme scheme;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 128,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: monospace ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhonesCard extends StatelessWidget {
  const _PhonesCard({
    required this.phones,
    required this.l10n,
    required this.scheme,
    required this.theme,
  });

  final List<Map<String, dynamic>> phones;
  final AppLocalizations l10n;
  final ColorScheme scheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    if (phones.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Text(
          l10n.profileNoPhonesDetail,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
      );
    }

    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: phones.map((Map<String, dynamic> p) {
          final String? e164 = p['phone_e164'] as String?;
          final bool primary = p['primary'] == true;
          final String? verifiedRaw = p['verified_at'] as String?;
          final Country? country = lookupCountryForE164(e164);
          final String? verified = _formatIso(context, verifiedRaw);

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 44,
                  child: Center(
                    child: Text(
                      country?.flag ?? '📞',
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SelectableText(
                        e164 ?? '—',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: <Widget>[
                          if (primary)
                            Chip(
                              visualDensity: VisualDensity.compact,
                              label: Text(l10n.profilePhonePrimary),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              labelStyle: theme.textTheme.labelSmall,
                            ),
                          if (verified != null)
                            Text(
                              l10n.profilePhoneVerifiedOn(verified),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.primary,
                              ),
                            )
                          else
                            Text(
                              l10n.profilePhoneNotVerified,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.outline,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MembershipCard extends StatelessWidget {
  const _MembershipCard({
    required this.membership,
    required this.l10n,
    required this.theme,
    required this.scheme,
    required this.isCurrentWorkspace,
    required this.onOpenOrg,
  });

  final Map<String, dynamic> membership;
  final AppLocalizations l10n;
  final ThemeData theme;
  final ColorScheme scheme;
  final bool isCurrentWorkspace;
  final VoidCallback onOpenOrg;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? org = _orgMap(membership);
    final String name =
        org != null ? (org['name'] as String? ?? l10n.orgMetaUnknown) : '—';
    final String? orgType = org?['organization_type'] as String?;
    final String? verification =
        org?['verification_status'] as String?;
    final String? roleRaw = membership['role'] as String?;
    final String? memberSince =
        _formatIso(context, membership['created_at'] as String?);
    final String? orgCreated =
        _formatIso(context, org?['created_at'] as String?);

    Map<String, dynamic>? pay;
    final Object? payRaw = org?['pay_schedule'];
    if (payRaw is Map<String, dynamic>) {
      pay = payRaw;
    } else if (payRaw is Map) {
      pay = Map<String, dynamic>.from(
        payRaw.map((Object? k, Object? v) => MapEntry(k.toString(), v)),
      );
    }
    final String? freqRaw = pay?['frequency'] as String?;
    final int? anchorDay = pay?['anchor_day'] is int
        ? pay!['anchor_day'] as int
        : int.tryParse('${pay?['anchor_day']}');
    final String? payLine = freqRaw != null && anchorDay != null
        ? l10n.dashboardPayScheduleLine(
              _payFrequencyLabel(l10n, freqRaw),
              anchorDay,
            )
        : null;

    final String? orgAddress = org != null
        ? _userAddressLine(org['address'])
        : null;

    final (Color verifyBg, Color verifyFg) =
        _verificationColors(scheme, verification);

    final String orgInitial = () {
      final String t = name.trim();
      if (t.isEmpty) {
        return '?';
      }
      return String.fromCharCode(t.runes.first).toUpperCase();
    }();

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: scheme.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpenOrg,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CircleAvatar(
                    radius: 26,
                    backgroundColor:
                        scheme.primaryContainer.withValues(alpha: 0.88),
                    foregroundColor: scheme.onPrimaryContainer,
                    child: Text(
                      orgInitial,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                        if (isCurrentWorkspace) ...<Widget>[
                          const SizedBox(height: 6),
                          Chip(
                            avatar: Icon(
                              Icons.work_outline_rounded,
                              size: 16,
                              color: scheme.primary,
                            ),
                            visualDensity: VisualDensity.compact,
                            label: Text(l10n.profileCurrentWorkspaceBadge),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            labelStyle: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: scheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: <Widget>[
                  Chip(
                    avatar: Icon(
                      Icons.badge_outlined,
                      size: 18,
                      color: scheme.secondary,
                    ),
                    label: Text(_titleCaseRole(roleRaw)),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    labelStyle: theme.textTheme.labelMedium,
                    side: BorderSide(color: scheme.outlineVariant),
                    backgroundColor:
                        scheme.surfaceContainerHighest.withValues(alpha: 0.45),
                  ),
                  if (orgType != null && orgType.isNotEmpty)
                    Chip(
                      avatar: Icon(
                        Icons.apartment_rounded,
                        size: 18,
                        color: scheme.primary,
                      ),
                      label: Text(_orgTypeDisplay(l10n, orgType)),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      labelStyle: theme.textTheme.labelMedium,
                      side: BorderSide(color: scheme.outlineVariant),
                      backgroundColor:
                          scheme.surfaceContainerHighest.withValues(alpha: 0.35),
                    ),
                  if (verification != null && verification.isNotEmpty)
                    Chip(
                      label: Text(_titleCaseRole(verification)),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      labelStyle: theme.textTheme.labelMedium?.copyWith(
                        color: verifyFg,
                        fontWeight: FontWeight.w600,
                      ),
                      backgroundColor: verifyBg,
                    ),
                ],
              ),
              if (payLine != null) ...<Widget>[
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color:
                        scheme.surfaceContainerHighest.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                        Icons.calendar_month_outlined,
                        size: 22,
                        color: scheme.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              l10n.orgPayScheduleSection,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              payLine,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (memberSince != null || orgCreated != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (memberSince != null)
                        Expanded(
                          child: _MembershipMiniBlock(
                            icon: Icons.person_add_alt_rounded,
                            label: l10n.profileFieldMembershipSince,
                            value: memberSince,
                            scheme: scheme,
                            theme: theme,
                          ),
                        ),
                      if (memberSince != null && orgCreated != null)
                        const SizedBox(width: AppSpacing.sm),
                      if (orgCreated != null)
                        Expanded(
                          child: _MembershipMiniBlock(
                            icon: Icons.event_rounded,
                            label: l10n.orgCreatedAt,
                            value: orgCreated,
                            scheme: scheme,
                            theme: theme,
                          ),
                        ),
                    ],
                  ),
                ),
              if (orgAddress != null) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      Icons.place_outlined,
                      size: 20,
                      color: scheme.outline,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        orgAddress,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Text(
                  l10n.dashboardViewOrgProfile,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MembershipMiniBlock extends StatelessWidget {
  const _MembershipMiniBlock({
    required this.icon,
    required this.label,
    required this.value,
    required this.scheme,
    required this.theme,
  });

  final IconData icon;
  final String label;
  final String value;
  final ColorScheme scheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 18, color: scheme.primary),
          const SizedBox(height: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(height: 1.35),
          ),
        ],
      ),
    );
  }
}
