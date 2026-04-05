import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaamsathi/l10n/app_localizations.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/widgets.dart';
import '../data/workers_api.dart';
import '../data/workers_repository.dart';
import '../domain/worker_models.dart';
import '../../engagements/data/engagements_repository.dart';

class WorkerEditScreen extends ConsumerStatefulWidget {
  const WorkerEditScreen({
    super.key,
    required this.orgId,
    required this.workerId,
  });

  final String orgId;
  final String workerId;

  static const String name = RouteNames.workerEdit;

  @override
  ConsumerState<WorkerEditScreen> createState() => _WorkerEditScreenState();
}

class _WorkerEditScreenState extends ConsumerState<WorkerEditScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _displayName;
  late final TextEditingController _skills;
  late final TextEditingController _experience;
  late final TextEditingController _bankName;
  late final TextEditingController _bankNumber;
  late final TextEditingController _bankIfsc;
  bool _saving = false;
  bool _fieldsApplied = false;

  @override
  void didUpdateWidget(covariant WorkerEditScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.workerId != widget.workerId) {
      _fieldsApplied = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _displayName = TextEditingController();
    _skills = TextEditingController();
    _experience = TextEditingController();
    _bankName = TextEditingController();
    _bankNumber = TextEditingController();
    _bankIfsc = TextEditingController();
  }

  @override
  void dispose() {
    _displayName.dispose();
    _skills.dispose();
    _experience.dispose();
    _bankName.dispose();
    _bankNumber.dispose();
    _bankIfsc.dispose();
    super.dispose();
  }

  void _applyWorkerFields(Worker w) {
    if (_fieldsApplied) {
      return;
    }
    _fieldsApplied = true;
    _displayName.text = w.displayName;
    _skills.text = w.skills ?? '';
    _experience.text = w.experience ?? '';
    _bankName.text = w.bankAccountName ?? '';
    _bankNumber.text = w.bankAccountNumber ?? '';
    _bankIfsc.text = w.bankIfsc ?? '';
  }

  Future<void> _save() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(workersRepositoryProvider).updateWorker(
            widget.orgId,
            widget.workerId,
            worker: <String, dynamic>{
              'display_name': _displayName.text.trim(),
              'skills': _skills.text.trim().isEmpty ? '' : _skills.text.trim(),
              'experience': _experience.text.trim().isEmpty
                  ? ''
                  : _experience.text.trim(),
              'bank_account_name': _bankName.text.trim().isEmpty
                  ? ''
                  : _bankName.text.trim(),
              'bank_account_number': _bankNumber.text.trim().isEmpty
                  ? ''
                  : _bankNumber.text.trim(),
              'bank_ifsc':
                  _bankIfsc.text.trim().isEmpty ? '' : _bankIfsc.text.trim(),
            },
          );
      if (!mounted) {
        return;
      }
      ref.invalidate(workerDetailProvider((
        orgId: widget.orgId,
        workerId: widget.workerId,
      )));
      ref.invalidate(workersListProvider(widget.orgId));
      ref.invalidate(engagementsListProvider(widget.orgId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.workersSnackbarSaved)),
      );
      context.pop();
    } on WorkersApiException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final AsyncValue<Worker> async = ref.watch(
      workerDetailProvider((orgId: widget.orgId, workerId: widget.workerId)),
    );

    return async.when(
      loading: () => Scaffold(
        key: ValueKey<String>('worker-edit-${widget.workerId}'),
        appBar: AppBar(title: Text(l10n.pgWorkerEdit)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (Object e, StackTrace _) => Scaffold(
        key: ValueKey<String>('worker-edit-${widget.workerId}'),
        appBar: AppBar(title: Text(l10n.pgWorkerEdit)),
        body: KaamErrorBanner(
          message: e.toString(),
          onRetry: () => ref.invalidate(
            workerDetailProvider((
              orgId: widget.orgId,
              workerId: widget.workerId,
            )),
          ),
          retryLabel: l10n.retry,
        ),
      ),
      data: (Worker w) {
        _applyWorkerFields(w);
        return Scaffold(
          key: ValueKey<String>('worker-edit-${widget.workerId}'),
          appBar: AppBar(title: Text(l10n.pgWorkerEdit)),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: <Widget>[
                if (w.user?.email != null)
                  Text(
                    w.user!.email!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _displayName,
                  decoration: InputDecoration(
                    labelText: l10n.workersDisplayNameLabel,
                    prefixIcon: const Icon(Icons.badge_outlined),
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
                  controller: _experience,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: l10n.workersExperienceLabel,
                    prefixIcon: const Icon(Icons.work_history_outlined),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _bankName,
                  decoration: InputDecoration(
                    labelText: l10n.workersBankAccount,
                    prefixIcon: const Icon(Icons.account_balance_rounded),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _bankNumber,
                  decoration: const InputDecoration(
                    labelText: 'Account number',
                    prefixIcon: Icon(Icons.numbers_rounded),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _bankIfsc,
                  decoration: const InputDecoration(
                    labelText: 'IFSC',
                    prefixIcon: Icon(Icons.tag_rounded),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                FilledButton(
                  onPressed: _saving ? null : _save,
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
      },
    );
  }
}
