import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:kaamsathi/l10n/app_localizations.dart';

import '../../../core/router/app_paths.dart';
import '../../../core/router/route_names.dart';
import '../../../core/session/app_membership_role.dart';
import '../../../core/session/auth_session_notifier.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../features/auth/data/auth_api.dart';
import '../../../shared/contacts/pick_contact_phone.dart';
import '../../../shared/widgets/widgets.dart';
import '../data/project_site_repository.dart';
import '../data/project_sites_api.dart';
import '../domain/project_site_models.dart';

class ProjectSitesListScreen extends ConsumerStatefulWidget {
  const ProjectSitesListScreen({super.key, required this.orgId});

  final String orgId;

  static const String name = RouteNames.sitesList;

  @override
  ConsumerState<ProjectSitesListScreen> createState() =>
      _ProjectSitesListScreenState();
}

class _ProjectSitesListScreenState extends ConsumerState<ProjectSitesListScreen> {
  final TextEditingController _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isManager =
        ref.watch(authSessionProvider).role == AppMembershipRole.manager;
    final AsyncValue<List<ProjectSite>> asyncSites =
        ref.watch(projectSitesProvider(widget.orgId));

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(projectSitesProvider(widget.orgId).future),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: <Widget>[
            SliverAppBar.large(
              title: Text(l10n.pgSitesList),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverToBoxAdapter(
                child: TextField(
                  controller: _query,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: l10n.sitesSearchHint,
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _query.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _query.clear();
                              setState(() {});
                            },
                          ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
            ...asyncSites.when(
              data: (List<ProjectSite> sites) => <Widget>[
                _sitesSliver(
                  sites: sites,
                  scheme: scheme,
                  textTheme: textTheme,
                  isManager: isManager,
                  l10n: l10n,
                ),
              ],
              loading: () => <Widget>[
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
              error: (Object error, StackTrace _) => <Widget>[
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(l10n.sitesLoadError),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            error.toString(),
                            textAlign: TextAlign.center,
                            style: textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          FilledButton(
                            onPressed: () => ref.invalidate(
                              projectSitesProvider(widget.orgId),
                            ),
                            child: Text(l10n.retry),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
          ],
        ),
      ),
      floatingActionButton: isManager
          ? FloatingActionButton.extended(
              onPressed: () => context.push(AppPaths.orgSiteNew(widget.orgId)),
              icon: const Icon(Icons.add_location_alt_rounded),
              label: Text(l10n.sitesAddSite),
            )
          : null,
    );
  }

  Widget _sitesSliver({
    required List<ProjectSite> sites,
    required ColorScheme scheme,
    required TextTheme textTheme,
    required bool isManager,
    required AppLocalizations l10n,
  }) {
    final List<ProjectSite> filtered = sites.where((ProjectSite s) {
      final String q = _query.text.trim().toLowerCase();
      if (q.isEmpty) {
        return true;
      }
      if (s.name.toLowerCase().contains(q)) {
        return true;
      }
      if (s.addressLine.toLowerCase().contains(q)) {
        return true;
      }
      final String? c = s.contractee?.displayName.toLowerCase();
      if (c != null && c.contains(q)) {
        return true;
      }
      final String? em = s.contractee?.email?.toLowerCase();
      return em != null && em.contains(q);
    }).toList();

    if (filtered.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: KaamEmptyState(
          title: l10n.sitesEmptyTitle,
          message: l10n.sitesEmptyBody,
          icon: Icons.location_on_outlined,
          actionLabel: isManager ? l10n.sitesAddSite : null,
          onAction: isManager
              ? () => context.push(AppPaths.orgSiteNew(widget.orgId))
              : null,
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final ProjectSite site = filtered[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Material(
                color: scheme.surfaceContainerLow,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: scheme.outlineVariant.withValues(alpha: 0.35),
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => context.push(
                    AppPaths.orgSiteDetail(widget.orgId, site.id),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _NetworkAvatar(
                          imageUrl: site.contractee?.avatarUrl,
                          label: site.contractee?.displayName.isNotEmpty == true
                              ? site.contractee!.displayName
                              : site.name,
                          size: 56,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                site.name,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.1,
                                ),
                              ),
                              if (site.contractee != null) ...<Widget>[
                                const SizedBox(height: 8),
                                if (site.contractee!.displayName.isNotEmpty)
                                  Text(
                                    site.contractee!.displayName,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.bodyMedium?.copyWith(
                                      height: 1.25,
                                    ),
                                  ),
                                if (site.contractee!.email != null &&
                                    site.contractee!.email!.trim().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      site.contractee!.email!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                              ],
                              if (site.addressLine.isNotEmpty) ...<Widget>[
                                const SizedBox(height: 6),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Icon(
                                      Icons.place_outlined,
                                      size: 16,
                                      color: scheme.outline,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        site.addressLine,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: textTheme.bodySmall?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                          height: 1.25,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: scheme.outline,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
          childCount: filtered.length,
        ),
      ),
    );
  }
}

String _initialsFromLabel(String raw) {
  final String t = raw.trim();
  if (t.isEmpty || t == '—') {
    return '?';
  }
  final List<String> parts =
      t.split(RegExp(r'\s+')).where((String s) => s.isNotEmpty).toList();
  if (parts.length >= 2) {
    String one(String s) {
      final Iterator<int> it = s.runes.iterator;
      return it.moveNext() ? String.fromCharCode(it.current) : '';
    }

    return '${one(parts[0])}${one(parts[1])}'.toUpperCase();
  }
  final Iterator<int> it = t.runes.iterator;
  if (!it.moveNext()) {
    return '?';
  }
  return String.fromCharCode(it.current).toUpperCase();
}

/// Circle avatar from contractee [imageUrl] or initials from [label].
class _NetworkAvatar extends StatelessWidget {
  const _NetworkAvatar({
    required this.imageUrl,
    required this.label,
    this.size = 56,
  });

  final String? imageUrl;
  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final double d = size;
    final Widget fallback = Container(
      width: d,
      height: d,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Text(
        _initialsFromLabel(label),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
    final String? u = imageUrl?.trim();
    if (u == null || u.isEmpty) {
      return fallback;
    }
    return ClipOval(
      child: SizedBox(
        width: d,
        height: d,
        child: Image.network(
          u,
          fit: BoxFit.cover,
          errorBuilder:
              (BuildContext context, Object error, StackTrace? stackTrace) =>
                  fallback,
          loadingBuilder: (
            BuildContext context,
            Widget child,
            ImageChunkEvent? loadingProgress,
          ) {
            if (loadingProgress == null) {
              return child;
            }
            return Container(
              width: d,
              height: d,
              color: scheme.surfaceContainerHighest,
              alignment: Alignment.center,
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SiteHeroThumb extends StatelessWidget {
  const _SiteHeroThumb({required this.site});

  final ProjectSite site;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    const double s = 88;
    final String? u = site.firstImageUrl;
    if (u != null && u.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: s,
          height: s,
          child: Image.network(
            u,
            fit: BoxFit.cover,
            errorBuilder:
                (BuildContext context, Object error, StackTrace? stackTrace) =>
                    _placeholder(
              scheme,
              s,
            ),
          ),
        ),
      );
    }
    return _placeholder(scheme, s);
  }

  Widget _placeholder(ColorScheme scheme, double s) {
    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: scheme.tertiaryContainer,
      ),
      child: Icon(
        Icons.apartment_rounded,
        size: 40,
        color: scheme.onTertiaryContainer,
      ),
    );
  }
}

class _StaffingStat extends StatelessWidget {
  const _StaffingStat({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: <Widget>[
          Icon(icon, size: 22, color: scheme.primary),
          const SizedBox(height: 6),
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 3,
            style: textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class ProjectSiteNewScreen extends ConsumerStatefulWidget {
  const ProjectSiteNewScreen({super.key, required this.orgId});

  final String orgId;

  static const String name = RouteNames.siteNew;

  @override
  ConsumerState<ProjectSiteNewScreen> createState() =>
      _ProjectSiteNewScreenState();
}

class _ProjectSiteNewScreenState extends ConsumerState<ProjectSiteNewScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _firstController = TextEditingController();
  final _middleController = TextEditingController();
  final _lastController = TextEditingController();

  bool _forSelf = true;
  bool _submitting = false;
  PhoneNumber? _contracteePhone;
  Uint8List? _contracteeAvatarBytes;
  int _phoneFieldKey = 0;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _firstController.dispose();
    _middleController.dispose();
    _lastController.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.orgCreateNameValidation)),
      );
      return;
    }
    if (!_forSelf) {
      final String email = _emailController.text.trim();
      if (email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.sitesContracteeEmailRequired)),
        );
        return;
      }
    }

    Map<String, dynamic>? contractee;
    if (!_forSelf) {
      String? phoneE164;
      if (_contracteePhone != null) {
        try {
          phoneE164 = AuthApi.phoneNumberToE164(_contracteePhone!);
        } on AuthApiException {
          phoneE164 = null;
        }
      }
      contractee = <String, dynamic>{
        'email': _emailController.text.trim(),
        if (phoneE164 != null && phoneE164.isNotEmpty)
          'phone_e164': phoneE164,
        if (_firstController.text.trim().isNotEmpty)
          'first_name': _firstController.text.trim(),
        if (_middleController.text.trim().isNotEmpty)
          'middle_name': _middleController.text.trim(),
        if (_lastController.text.trim().isNotEmpty)
          'last_name': _lastController.text.trim(),
      };
    }

    setState(() => _submitting = true);
    try {
      await ref.read(projectSiteRepositoryProvider).createSite(
            orgId: widget.orgId,
            name: name,
            forSelf: _forSelf,
            contractee: contractee,
            addressString: _addressController.text.trim().isEmpty
                ? null
                : _addressController.text.trim(),
            contracteeAvatarBytes:
                (!_forSelf && _contracteeAvatarBytes != null)
                    ? _contracteeAvatarBytes
                    : null,
          );
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.sitesCreatedSnackbar)),
      );
      ref.invalidate(projectSitesProvider(widget.orgId));
      context.pop();
    } on ProjectSitesApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
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

  Future<void> _pickContracteePhone(BuildContext context) async {
    final String iso = _phoneCountryIso(context);
    final ContactContracteePick? picked =
        await pickContactPhoneNumber(context, defaultCountryIso: iso);
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      _contracteePhone = picked.phone;
      _phoneController.text = picked.phone.number;
      _phoneFieldKey++;
      final String? em = picked.email;
      if (em != null && em.isNotEmpty) {
        _emailController.text = em;
      }
      _contracteeAvatarBytes = picked.avatarBytes;
      _firstController.text = picked.firstName ?? '';
      _middleController.text = picked.middleName ?? '';
      _lastController.text = picked.lastName ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.pgSiteNew)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.sitesNameLabel,
                hintText: l10n.orgCreateNameLabel,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: l10n.sitesAddressLabel,
                hintText: l10n.sitesAddressHint,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.sitesContracteeMyself),
              subtitle: Text(l10n.sitesContracteeHelp),
              value: _forSelf,
              onChanged: _submitting
                  ? null
                  : (bool v) {
                      setState(() {
                        _forSelf = v;
                        if (v) {
                          _contracteePhone = null;
                          _contracteeAvatarBytes = null;
                          _phoneController.clear();
                          _emailController.clear();
                          _firstController.clear();
                          _middleController.clear();
                          _lastController.clear();
                          _phoneFieldKey++;
                        }
                      });
                    },
            ),
            if (!_forSelf) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: l10n.sitesContracteeEmail,
                ),
              ),
              if (_contracteeAvatarBytes != null) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundImage:
                        MemoryImage(_contracteeAvatarBytes!),
                  ),
                  title: Text(l10n.sitesContracteePhotoPreview),
                  trailing: IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    tooltip: MaterialLocalizations.of(context)
                        .deleteButtonTooltip,
                    onPressed: _submitting
                        ? null
                        : () => setState(() => _contracteeAvatarBytes = null),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: KeyedSubtree(
                      key: ValueKey<int>(_phoneFieldKey),
                      child: KaamPhoneField(
                        controller: _phoneController,
                        initialCountryCode: _contracteePhone?.countryISOCode ??
                            _phoneCountryIso(context),
                        onPhoneUpdate: (PhoneNumber phone) =>
                            setState(() => _contracteePhone = phone),
                        decoration: InputDecoration(
                          labelText: l10n.authPhoneHint,
                          hintText: l10n.sitesContracteePhoneHint,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Tooltip(
                    message: l10n.sitesPickFromContacts,
                    child: IconButton(
                      icon: const Icon(Icons.contacts_rounded),
                      onPressed:
                          _submitting ? null : () => _pickContracteePhone(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _firstController,
                decoration: InputDecoration(
                  labelText: l10n.sitesContracteeFirstName,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _middleController,
                decoration: InputDecoration(
                  labelText: l10n.sitesContracteeMiddleName,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _lastController,
                decoration: InputDecoration(
                  labelText: l10n.sitesContracteeLastName,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: _submitting ? null : () => _submit(context),
              child: _submitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.sitesCreateCta),
            ),
          ],
        ),
      ),
    );
  }
}

class ProjectSiteDetailScreen extends ConsumerWidget {
  const ProjectSiteDetailScreen({
    super.key,
    required this.orgId,
    required this.siteId,
  });

  final String orgId;
  final String siteId;

  static const String name = RouteNames.siteDetail;

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(l10n.sitesDeleteConfirmTitle),
        content: Text(l10n.sitesDeleteConfirmBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.onError,
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: Text(l10n.sitesDeleteAction),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) {
      return;
    }
    try {
      await ref.read(projectSiteRepositoryProvider).deleteSite(orgId, siteId);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.sitesDeletedSnackbar)),
      );
      ref.invalidate(projectSitesProvider(orgId));
      context.pop();
    } on ProjectSitesApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AsyncValue<ProjectSite?> asyncSite =
        ref.watch(projectSiteProvider((orgId: orgId, siteId: siteId)));
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isManager =
        ref.watch(authSessionProvider).role == AppMembershipRole.manager;
    final DateFormat updatedFmt = DateFormat.yMMMd();

    return Scaffold(
      body: asyncSite.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, StackTrace _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: KaamErrorBanner(
              message: e.toString(),
              onRetry: () => ref.invalidate(
                projectSiteProvider((orgId: orgId, siteId: siteId)),
              ),
              retryLabel: l10n.retry,
            ),
          ),
        ),
        data: (ProjectSite? site) {
          if (site == null) {
            return KaamEmptyState(
              title: l10n.sitesNotFoundTitle,
              message: l10n.sitesNotFoundBody,
              icon: Icons.error_outline_rounded,
              actionLabel: l10n.sitesBackToList,
              onAction: () => context.pop(),
            );
          }

          return CustomScrollView(
            slivers: <Widget>[
              SliverAppBar.large(
                title: Text(site.name),
                actions: <Widget>[
                  if (isManager) ...<Widget>[
                    IconButton(
                      icon: const Icon(Icons.edit_rounded),
                      onPressed: () =>
                          context.push(AppPaths.orgSiteEdit(orgId, siteId)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded),
                      onPressed: () => _confirmDelete(context, ref, l10n),
                    ),
                  ],
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.xl,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(<Widget>[
                    Card(
                      elevation: 0,
                      color: scheme.surfaceContainerLow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color:
                              scheme.outlineVariant.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _SiteHeroThumb(site: site),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    l10n.sitesNameLabel.toUpperCase(),
                                    style: textTheme.labelMedium?.copyWith(
                                      color: scheme.primary,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    site.name,
                                    style: textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      height: 1.15,
                                    ),
                                  ),
                                  if (site.addressLine.isNotEmpty) ...<Widget>[
                                    const SizedBox(height: AppSpacing.sm),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Icon(
                                          Icons.place_outlined,
                                          size: 18,
                                          color: scheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            site.addressLine,
                                            style: textTheme.bodyMedium
                                                ?.copyWith(height: 1.35),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: AppSpacing.sm),
                                  Wrap(
                                    spacing: AppSpacing.md,
                                    runSpacing: 4,
                                    children: <Widget>[
                                      if (site.createdAt != null)
                                        Text(
                                          '${l10n.sitesCreatedAt}: ${updatedFmt.format(site.createdAt!.toLocal())}',
                                          style: textTheme.bodySmall?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                          ),
                                        ),
                                      if (site.updatedAt != null)
                                        Text(
                                          '${l10n.sitesUpdatedAt}: ${updatedFmt.format(site.updatedAt!.toLocal())}',
                                          style: textTheme.bodySmall?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (site.contractee != null) ...<Widget>[
                      const SizedBox(height: AppSpacing.md),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color:
                                scheme.outlineVariant.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              _NetworkAvatar(
                                imageUrl: site.contractee!.avatarUrl,
                                label: site.contractee!.displayName.isNotEmpty
                                    ? site.contractee!.displayName
                                    : (site.contractee!.email ?? site.name),
                                size: 72,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      l10n.sitesContracteeSection,
                                      style: textTheme.labelLarge?.copyWith(
                                        color: scheme.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      site.contractee!.displayName.isNotEmpty
                                          ? site.contractee!.displayName
                                          : '—',
                                      style:
                                          textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    if (site.contractee!.email != null &&
                                        site.contractee!.email!
                                            .trim()
                                            .isNotEmpty) ...<Widget>[
                                      const SizedBox(height: 10),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Icon(
                                            Icons.email_outlined,
                                            size: 18,
                                            color: scheme.onSurfaceVariant,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: SelectableText(
                                              site.contractee!.email!,
                                              style: textTheme.bodyMedium
                                                  ?.copyWith(
                                                color:
                                                    scheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (site.images.isNotEmpty) ...<Widget>[
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        l10n.sitesSitePhotos,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SizedBox(
                        height: 112,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: site.images.length,
                          separatorBuilder:
                              (BuildContext context, int index) =>
                              const SizedBox(width: AppSpacing.sm),
                          itemBuilder: (BuildContext context, int i) {
                            final ProjectSiteImage img = site.images[i];
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                width: 112,
                                height: 112,
                                child: Image.network(
                                  img.url,
                                  fit: BoxFit.cover,
                                  errorBuilder: (BuildContext context,
                                          Object error,
                                          StackTrace? stackTrace) =>
                                      ColoredBox(
                                    color: scheme.surfaceContainerHighest,
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      color: scheme.outline,
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    if (site.staffingSummary != null) ...<Widget>[
                      const SizedBox(height: AppSpacing.lg),
                      Card(
                        elevation: 0,
                        color: scheme.surfaceContainerLow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color:
                                scheme.outlineVariant.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                l10n.sitesStaffingSection,
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: _StaffingStat(
                                      value: site.staffingSummary!
                                          .workersScheduledToday
                                          .toString(),
                                      label: l10n.sitesWorkersScheduledToday,
                                      icon: Icons.groups_outlined,
                                    ),
                                  ),
                                  Expanded(
                                    child: _StaffingStat(
                                      value: site.staffingSummary!
                                          .assignmentsToday
                                          .toString(),
                                      label: l10n.sitesAssignmentsToday,
                                      icon: Icons.assignment_turned_in_outlined,
                                    ),
                                  ),
                                  Expanded(
                                    child: _StaffingStat(
                                      value: site.staffingSummary!
                                          .defaultHomeWorkersCount
                                          .toString(),
                                      label: l10n.sitesDefaultHomeWorkers,
                                      icon: Icons.home_work_outlined,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ProjectSiteEditScreen extends ConsumerStatefulWidget {
  const ProjectSiteEditScreen({
    super.key,
    required this.orgId,
    required this.siteId,
  });

  final String orgId;
  final String siteId;

  static const String name = RouteNames.siteEdit;

  @override
  ConsumerState<ProjectSiteEditScreen> createState() =>
      _ProjectSiteEditScreenState();
}

class _ProjectSiteEditScreenState extends ConsumerState<ProjectSiteEditScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  bool _hydrated = false;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _save(BuildContext context, ProjectSite site) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.orgCreateNameValidation)),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref.read(projectSiteRepositoryProvider).updateSite(
            orgId: widget.orgId,
            site: site,
            name: name,
            addressString: _addressController.text.trim(),
          );
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.sitesUpdatedSnackbar)),
      );
      ref.invalidate(
        projectSiteProvider((orgId: widget.orgId, siteId: widget.siteId)),
      );
      ref.invalidate(projectSitesProvider(widget.orgId));
      context.pop();
    } on ProjectSitesApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AsyncValue<ProjectSite?> asyncSite = ref.watch(
      projectSiteProvider((orgId: widget.orgId, siteId: widget.siteId)),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pgSiteEdit)),
      body: asyncSite.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, StackTrace _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: KaamErrorBanner(
              message: e.toString(),
              onRetry: () => ref.invalidate(
                projectSiteProvider(
                  (orgId: widget.orgId, siteId: widget.siteId),
                ),
              ),
              retryLabel: l10n.retry,
            ),
          ),
        ),
        data: (ProjectSite? site) {
          if (site == null) {
            return Center(child: Text(l10n.sitesNotFoundTitle));
          }
          if (!_hydrated) {
            _nameController.text = site.name;
            _addressController.text = site.addressLine;
            _hydrated = true;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.sitesNameLabel,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _addressController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: l10n.sitesAddressLabel,
                    hintText: l10n.sitesAddressHint,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                FilledButton(
                  onPressed: _submitting ? null : () => _save(context, site),
                  child: _submitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.sitesSaveChanges),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
