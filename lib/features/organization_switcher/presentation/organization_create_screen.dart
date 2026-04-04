import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaamsathi/l10n/app_localizations.dart';

import '../../../core/router/app_paths.dart';
import '../../../core/router/route_names.dart';
import '../../../core/session/app_membership_role.dart';
import '../../../core/session/auth_session_notifier.dart';
import '../../../core/theme/app_spacing.dart';
import '../../organization/data/organizations_api.dart';
import '../../organization/data/organizations_api_provider.dart';
import '../data/select_org_data_provider.dart';

class OrganizationCreateScreen extends ConsumerStatefulWidget {
  const OrganizationCreateScreen({super.key});

  static const String name = RouteNames.organizationCreate;

  @override
  ConsumerState<OrganizationCreateScreen> createState() =>
      _OrganizationCreateScreenState();
}

class _OrganizationCreateScreenState
    extends ConsumerState<OrganizationCreateScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _address = TextEditingController();
  String? _organizationType;
  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _submit(AppLocalizations l10n) async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _submitting = true);
    try {
      final OrganizationsApi api = ref.read(organizationsApiProvider);
      final OrganizationEntity created = await api.createOrganization(
        name: _name.text.trim(),
        organizationType: _organizationType,
        addressString: _address.text.trim().isEmpty
            ? null
            : _address.text.trim(),
      );
      if (!mounted) {
        return;
      }
      ref
          .read(authSessionProvider.notifier)
          .selectOrganization(created.id, role: AppMembershipRole.manager);
      await ref
          .read(authSessionProvider.notifier)
          .setDefaultOrganization(created.id);
      ref.invalidate(selectOrgDataProvider);
      ref.invalidate(defaultOrganizationIdProvider);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.orgCreateSuccessSnackbar)));
      context.go(AppPaths.home);
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
        ).showSnackBar(SnackBar(content: Text(l10n.orgCreateErrorGeneric)));
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
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pgOrganizationCreate), centerTitle: true),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: <Widget>[
            Text(
              l10n.pgOrganizationCreate,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.selectOrgSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: l10n.orgCreateNameLabel,
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
            DropdownButtonFormField<String?>(
              initialValue: _organizationType,
              decoration: InputDecoration(
                labelText: l10n.orgCreateTypeLabel,
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
              onChanged: _submitting
                  ? null
                  : (String? v) => setState(() => _organizationType = v),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _address,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.orgCreateAddressLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: _submitting ? null : () => _submit(l10n),
              child: _submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.orgCreateSubmit),
            ),
          ],
        ),
      ),
    );
  }
}
