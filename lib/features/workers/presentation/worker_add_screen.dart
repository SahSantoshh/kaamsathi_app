import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:kaamsathi/l10n/app_localizations.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../features/auth/data/auth_api.dart';
import '../../../features/project_sites/data/project_site_repository.dart';
import '../../../features/project_sites/domain/project_site_models.dart';
import '../../../shared/contacts/pick_contact_phone.dart';
import '../../../shared/widgets/kaam_phone_field.dart';
import '../data/workers_api.dart';
import '../data/workers_repository.dart';
import '../domain/worker_models.dart';
import '../../engagements/data/engagements_repository.dart';
import 'worker_ui_helpers.dart';

class WorkerAddScreen extends ConsumerStatefulWidget {
  const WorkerAddScreen({
    super.key,
    required this.orgId,
    this.projectSiteId,
  });

  final String orgId;
  final String? projectSiteId;

  static const String name = RouteNames.workerAdd;

  @override
  ConsumerState<WorkerAddScreen> createState() => _WorkerAddScreenState();
}

class _WorkerAddScreenState extends ConsumerState<WorkerAddScreen> {
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _displayName = TextEditingController();
  PhoneNumber? _phoneNumber;
  int _phoneFieldKey = 0;
  String? _homeSiteId;
  bool _searching = false;
  bool _linking = false;
  bool _creating = false;
  WorkerSearchOutcome? _outcome;
  WorkerSearchMatch? _selectedMatch;

  String? _resolvedProjectSiteId() {
    final String? fromRoute = widget.projectSiteId;
    if (fromRoute != null && fromRoute.isNotEmpty) {
      return fromRoute;
    }
    return _homeSiteId;
  }

  Map<String, dynamic>? _engagementDefaults() {
    final String? siteId = _resolvedProjectSiteId();
    if (siteId == null || siteId.isEmpty) {
      return null;
    }
    return <String, dynamic>{
      'default_project_site_id': siteId,
    };
  }

  bool _hasSearchablePhone() {
    final PhoneNumber? p = _phoneNumber;
    if (p == null) {
      return false;
    }
    return p.number.replaceAll(RegExp(r'\D'), '').length >= 8;
  }

  String? _phoneE164OrNull() {
    if (!_hasSearchablePhone()) {
      return null;
    }
    try {
      return AuthApi.phoneNumberToE164(_phoneNumber!);
    } on AuthApiException {
      return null;
    }
  }

  bool _canRunSearch() {
    final String email = _email.text.trim();
    return _phoneE164OrNull() != null || email.isNotEmpty;
  }

  WorkerSearchMatch? _effectiveMatchFor(WorkerSearchOutcome o) {
    if (o.matches.length == 1) {
      return o.matches.first;
    }
    if (o.matches.length > 1) {
      return _selectedMatch;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    void clearOutcome() {
      setState(() {
        _outcome = null;
        _selectedMatch = null;
      });
    }

    _phone.addListener(clearOutcome);
    _email.addListener(clearOutcome);
  }

  Future<void> _search() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _searching = true;
      _outcome = null;
      _selectedMatch = null;
    });
    final String? phoneE164 = _phoneE164OrNull();
    final String email = _email.text.trim();
    if ((phoneE164 == null || phoneE164.isEmpty) && email.isEmpty) {
      setState(() => _searching = false);
      return;
    }
    try {
      final WorkerSearchOutcome outcome =
          await ref.read(workersRepositoryProvider).searchWorker(
                widget.orgId,
                phoneE164: phoneE164,
                email: email.isEmpty ? null : email,
              );
      if (!mounted) {
        return;
      }
      setState(() {
        _searching = false;
        _outcome = outcome;
        _selectedMatch =
            outcome.matches.length == 1 ? outcome.matches.first : null;
      });
    } on WorkersApiException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _searching = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  Future<void> _linkExisting(Worker w) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    setState(() => _linking = true);
    try {
      await ref.read(workersRepositoryProvider).linkWorker(
            widget.orgId,
            w.id,
            engagement: _engagementDefaults(),
          );
      if (!mounted) {
        return;
      }
      ref.invalidate(workersListProvider(widget.orgId));
      ref.invalidate(engagementsListProvider(widget.orgId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.workersLinkedSnackbar)),
      );
      context.pop();
    } on WorkersApiException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _linking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  Future<void> _createWorker() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String name = _displayName.text.trim();
    if (name.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authErrorNameShort)),
      );
      return;
    }
    final WorkerSearchOutcome? searched = _outcome;
    final WorkerSearchMatch? em =
        searched == null ? null : _effectiveMatchFor(searched);
    final bool warmUserWithoutWorker = em != null &&
        em.userId.isNotEmpty &&
        em.worker == null;

    final Map<String, dynamic> workerPayload;
    if (warmUserWithoutWorker) {
      workerPayload = <String, dynamic>{
        'display_name': name,
        'user_id': em.userId,
      };
    } else {
      final String? phoneE164 = _phoneE164OrNull();
      final String email = _email.text.trim();
      final Map<String, dynamic> userMap = <String, dynamic>{};
      if (phoneE164 != null && phoneE164.isNotEmpty) {
        userMap['phone_e164'] = phoneE164;
      }
      if (email.isNotEmpty) {
        userMap['email'] = email;
      }
      if (userMap.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.workersSearchNeedContact)),
        );
        return;
      }
      workerPayload = <String, dynamic>{
        'display_name': name,
        'user': userMap,
      };
    }

    setState(() => _creating = true);
    try {
      await ref.read(workersRepositoryProvider).createWorker(
            widget.orgId,
            worker: workerPayload,
            engagement: _engagementDefaults(),
          );
      if (!mounted) {
        return;
      }
      ref.invalidate(workersListProvider(widget.orgId));
      ref.invalidate(engagementsListProvider(widget.orgId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.workersLinkedSnackbar)),
      );
      context.pop();
    } on WorkersApiException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _creating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  String _phoneCountryIso(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final String? cc = locale.countryCode;
    if (cc != null && cc.length == 2) {
      return cc;
    }
    return 'NP';
  }

  String _displayNameFromContactPick(ContactContracteePick picked) {
    final List<String> parts = <String>[
      if (picked.firstName != null &&
          picked.firstName!.trim().isNotEmpty)
        picked.firstName!.trim(),
      if (picked.middleName != null &&
          picked.middleName!.trim().isNotEmpty)
        picked.middleName!.trim(),
      if (picked.lastName != null && picked.lastName!.trim().isNotEmpty)
        picked.lastName!.trim(),
    ];
    return parts.join(' ');
  }

  Future<void> _pickFromContacts(BuildContext context) async {
    final String iso = _phoneCountryIso(context);
    final ContactContracteePick? picked =
        await pickContactPhoneNumber(context, defaultCountryIso: iso);
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      _phoneNumber = picked.phone;
      _phone.text = picked.phone.number;
      _phoneFieldKey++;
      final String? em = picked.email;
      if (em != null && em.isNotEmpty) {
        _email.text = em;
      }
      final String contactName = _displayNameFromContactPick(picked);
      if (contactName.isNotEmpty) {
        _displayName.text = contactName;
      }
      _outcome = null;
      _selectedMatch = null;
    });
  }

  @override
  void dispose() {
    _phone.dispose();
    _email.dispose();
    _displayName.dispose();
    super.dispose();
  }

  Widget _siteContextBanner(
    AppLocalizations l10n,
    ColorScheme scheme,
    TextTheme textTheme,
  ) {
    final AsyncValue<ProjectSite?> async = ref.watch(
      projectSiteProvider((
        orgId: widget.orgId,
        siteId: widget.projectSiteId!,
      )),
    );
    return async.when(
      data: (ProjectSite? s) {
        if (s == null) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Material(
            color: scheme.secondaryContainer.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.apartment_rounded,
                    color: scheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      l10n.workersAddFromSiteBanner(s.name),
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.md),
        child: LinearProgressIndicator(minHeight: 3),
      ),
      error: (Object error, StackTrace stackTrace) =>
          const SizedBox.shrink(),
    );
  }

  String _matchPrimaryLabel(WorkerSearchMatch m) {
    final String? t = m.worker?.title;
    if (t != null && t.isNotEmpty) {
      return t;
    }
    final String? e = m.email;
    if (e != null && e.isNotEmpty) {
      return e;
    }
    return m.userId;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final WorkerSearchOutcome? outcome = _outcome;
    final List<WorkerSearchMatch> matches = outcome?.matches ?? const <WorkerSearchMatch>[];
    final WorkerSearchMatch? effective =
        outcome == null ? null : _effectiveMatchFor(outcome);
    final Worker? match = effective?.worker;
    final bool showPickList = matches.length > 1;
    final bool showLink = effective != null && effective.worker != null;
    final bool showColdCreate = outcome != null && matches.isEmpty;
    final bool showWarmCreate = effective != null &&
        effective.worker == null &&
        (!showPickList || _selectedMatch != null);
    final bool createBlock = showColdCreate || showWarmCreate;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pgWorkerAdd)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: <Widget>[
          if (widget.projectSiteId != null)
            _siteContextBanner(l10n, scheme, textTheme),
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
          if (widget.projectSiteId == null)
            ref.watch(projectSitesProvider(widget.orgId)).when(
                  loading: () => const Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.md),
                    child: LinearProgressIndicator(minHeight: 3),
                  ),
                  error: (Object error, StackTrace stackTrace) =>
                      const SizedBox.shrink(),
                  data: (List<ProjectSite> sites) {
                    if (sites.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: l10n.workersHomeSiteHint,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            value: _homeSiteId,
                            isExpanded: true,
                            isDense: true,
                            items: <DropdownMenuItem<String?>>[
                              DropdownMenuItem<String?>(
                                value: null,
                                child: Text(l10n.workersHomeSiteNone),
                              ),
                              ...sites.map(
                                (ProjectSite s) => DropdownMenuItem<String?>(
                                  value: s.id,
                                  child: Text(s.name),
                                ),
                              ),
                            ],
                            onChanged: (String? v) =>
                                setState(() => _homeSiteId = v),
                          ),
                        ),
                      ),
                    );
                  },
                ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: KeyedSubtree(
                  key: ValueKey<int>(_phoneFieldKey),
                  child: KaamPhoneField(
                    controller: _phone,
                    initialCountryCode: _phoneNumber?.countryISOCode ??
                        _phoneCountryIso(context),
                    onPhoneUpdate: (PhoneNumber phone) =>
                        setState(() => _phoneNumber = phone),
                    decoration: InputDecoration(
                      labelText: l10n.authPhoneHint,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Tooltip(
                message: l10n.workersPickFromContacts,
                child: IconButton(
                  icon: const Icon(Icons.contacts_rounded),
                  onPressed:
                      _searching ? null : () => _pickFromContacts(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: l10n.workersSearchEmailLabel,
              prefixIcon: const Icon(Icons.alternate_email_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: _searching || !_canRunSearch() ? null : _search,
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
          if (showPickList) ...<Widget>[
            const SizedBox(height: AppSpacing.xl),
            Text(
              l10n.workersSearchPickMatchTitle,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.workersSearchPickMatchSubtitle,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ...matches.map(
              (WorkerSearchMatch m) => ListTile(
                selected: _selectedMatch?.userId == m.userId,
                selectedTileColor:
                    scheme.primaryContainer.withValues(alpha: 0.35),
                leading: Icon(
                  m.worker != null
                      ? Icons.person_rounded
                      : Icons.person_outline_rounded,
                  color: scheme.primary,
                ),
                title: Text(_matchPrimaryLabel(m)),
                subtitle: Text(
                  m.worker != null
                      ? l10n.workersSearchMatchHasWorker
                      : l10n.workersSearchMatchNeedsProfile,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                onTap: () => setState(() => _selectedMatch = m),
              ),
            ),
          ],
          if (showLink && match != null) ...<Widget>[
            const SizedBox(height: AppSpacing.xl),
            Text(
              l10n.engagementSectionTitle,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Material(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: <Widget>[
                    workerListAvatar(context, match, radius: 28),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            match.title,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (match.user?.email != null)
                            Text(
                              match.user!.email!,
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: _linking ? null : () => _linkExisting(match),
              child: _linking
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.workersLinkToOrganization),
            ),
          ],
          if (createBlock) ...<Widget>[
            const SizedBox(height: AppSpacing.xl),
            Text(
              showColdCreate
                  ? l10n.workersSearchOnboardNew
                  : l10n.workersSearchUserNoWorker,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _displayName,
              decoration: InputDecoration(
                labelText: l10n.workersDisplayNameLabel,
                prefixIcon: const Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: _creating ? null : _createWorker,
              child: _creating
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.workersCreateWorkerCta),
            ),
          ],
        ],
      ),
    );
  }
}
