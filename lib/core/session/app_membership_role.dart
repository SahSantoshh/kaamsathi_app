/// Membership role from the API (`GET /me` → `memberships[].role`).
///
/// Product mapping (see `ProductScope` in `lib/core/product/product_scope.dart`):
/// - [manager] — **Organization owner / contractor**: roster, payroll, manager routes.
/// - [worker] — **Field worker**: assignments, attendance, pay views (deepening later).
///
/// **Contractee** (client who awards contracts to the contractor) is not a value here yet.
/// Extend when the API models it.
enum AppMembershipRole {
  worker,
  manager,
}
