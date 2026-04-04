/// Product scope for KaamSathi (who the app serves).
///
/// **Personas (long-term)** — design and copy should stay aware of all three:
///
/// 1. **Contractee** — Party who *provides* work/contracts to a contractor (client /
///    project owner). Often *outside* the contractor’s org in real life. The API does not
///    yet model this as its own membership role; future work may add contractee portals,
///    org types, or separate products.
///
/// 2. **Organization owner (contractor / builder)** — Runs their organization: roster,
///    sites, engagements, payroll, reports. Aligns with Rails membership **`manager`**.
///    **Current build focus:** ship this experience first ([organizationOwnerExperienceFirst]).
///
/// 3. **Worker** — Works *for* the contractor (wages, attendance, assignments). Aligns
///    with Rails **`worker`**. **Next phase:** worker-first home and flows; [AuthRedirect]
///    already hides manager-only routes from workers.
abstract final class ProductScope {
  /// When `true`, product copy and defaults assume **organization owner** (`manager`)
  /// workflows. Set to `false` when prioritizing **worker** UX app-wide.
  static const bool organizationOwnerExperienceFirst = true;
}
