# feature_gate_pass

Structured identically to `feature_asset_management` — see that
package's README for the full layer-by-layer pattern (domain/data/
presentation, offline-first repository, SyncHandler registration).

Covers concept doc §5.2: request creation, single/multi-level approval
routing, QR gate verification, returnable/overdue tracking, vehicle &
driver capture, time-bound validity, OTP/digital-signature approval,
and emergency override with escalation logging.

## Scaffolded so far

* `domain/entities/gate_pass.dart`, `gate_pass_status.dart`
* `domain/repositories/gate_pass_repository.dart`
* `domain/usecases/create_gate_pass_request.dart`,
  `verify_gate_pass_at_gate.dart`
* `presentation/bloc/gate_pass_list/` (stub)
* `presentation/pages/gate_pass_list_page.dart` (stub)

## Not yet implemented (follow the asset_management reference to add)

* `data/local/` Drift table + database for offline-first gate pass caching
* `data/datasources/`, `data/repositories/gate_pass_repository_impl.dart`
* The `SyncHandler` registration for queued approvals/verifications
* Multi-level approval routing logic, vehicle/driver capture fields,
  returnable-item overdue detection
