import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kaamsathi/l10n/app_localizations.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_spacing.dart';
import '../data/workers_mock_data.dart';
import '../domain/worker_models.dart';

class WorkerEditScreen extends StatefulWidget {
  const WorkerEditScreen({
    super.key,
    required this.orgId,
    required this.workerId,
  });

  final String orgId;
  final String workerId;

  static const String name = RouteNames.workerEdit;

  @override
  State<WorkerEditScreen> createState() => _WorkerEditScreenState();
}

class _WorkerEditScreenState extends State<WorkerEditScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _skills;
  late final TextEditingController _notes;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final WorkerDetail? d = WorkersMockData.detailById(widget.workerId);
    _name = TextEditingController(text: d?.displayName ?? '');
    _skills = TextEditingController(text: d?.skillsSummary ?? '');
    _notes = TextEditingController(text: d?.notes ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _skills.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.workersSnackbarSaved)),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final WorkerDetail? d = WorkersMockData.detailById(widget.workerId);

    if (d == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.pgWorkerEdit)),
        body: Center(child: Text(l10n.workersNotFoundTitle)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pgWorkerEdit)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: <Widget>[
            Text(
              d.displayName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              d.phoneE164,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.xl),
            TextFormField(
              controller: _name,
              decoration: InputDecoration(
                labelText: l10n.authFullNameHint,
                prefixIcon: const Icon(Icons.person_outline_rounded),
              ),
              validator: (String? v) =>
                  (v ?? '').trim().length >= 2 ? null : l10n.authErrorNameShort,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _skills,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: l10n.workersSkillsSection,
                prefixIcon: const Icon(Icons.construction_rounded),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _notes,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: l10n.workersNotesSection,
                prefixIcon: const Icon(Icons.notes_rounded),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: _saving ? null : () => _save(l10n),
              child: _saving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.workersSaveChanges),
            ),
          ],
        ),
      ),
    );
  }
}
